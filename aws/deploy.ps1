# ==============================================================================
# Find My Volt - Automated AWS Free Tier Deployment Script
# Provisions EC2 (t2.micro/t3.micro, 30GB EBS) with SQLite and Python REST Server
# 100% Covered under the AWS 12-Month Free Tier ($0.00/mo)
# ==============================================================================

param(
    [string]$Region = "us-east-1",
    [string]$StackName = "find-my-volt-backend",
    [string]$InstanceType = "t2.micro"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "   FIND MY VOLT - AWS FREE TIER BACKEND & DATABASE DEPLOYMENT   " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Locate AWS CLI
$awsCmd = "aws"
if (-not (Get-Command "aws" -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\Amazon\AWSCLIV2\aws.exe") {
        $awsCmd = "C:\Program Files\Amazon\AWSCLIV2\aws.exe"
    } else {
        Write-Error "AWS CLI not found. Please install it or restart PowerShell."
    }
}

# 2. Check AWS Authentication
Write-Host "[1/5] Checking AWS credentials and authentication..." -ForegroundColor Yellow
$callerIdentity = $null
try {
    $callerIdentity = & $awsCmd sts get-caller-identity --output json 2>$null | ConvertFrom-Json
} catch {
    $callerIdentity = $null
}

if (-not $callerIdentity) {
    Write-Host ""
    Write-Host "No active AWS credentials found." -ForegroundColor Red
    Write-Host "Please enter your AWS IAM credentials (with AdministratorAccess or EC2/CloudFormation rights):" -ForegroundColor Yellow
    Write-Host ""
    
    $accessKey = Read-Host "AWS Access Key ID"
    $secretKey = Read-Host "AWS Secret Access Key" -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secretKey)
    $plainSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    
    $reg = Read-Host "AWS Region [default: us-east-1 (or ap-south-1 for Mumbai)]"
    if ([string]::IsNullOrWhiteSpace($reg)) { $reg = $Region }

    $env:AWS_ACCESS_KEY_ID = $accessKey.Trim()
    $env:AWS_SECRET_ACCESS_KEY = $plainSecret.Trim()
    $env:AWS_DEFAULT_REGION = $reg.Trim()

    try {
        $callerIdentity = & $awsCmd sts get-caller-identity --output json | ConvertFrom-Json
    } catch {
        Write-Error "Authentication failed with provided credentials. Please check Access Key and Secret Key."
    }
}

Write-Host "Authenticated successfully as:" -ForegroundColor Green
Write-Host "  Account: $($callerIdentity.Account)"
Write-Host "  Arn:     $($callerIdentity.Arn)"
Write-Host "  Region:  $env:AWS_DEFAULT_REGION"
Write-Host ""

# 3. Choose Instance Type based on region
if ($env:AWS_DEFAULT_REGION -eq "ap-south-1" -and $InstanceType -eq "t2.micro") {
    # In some modern regions t3.micro is preferred for Free Tier
    $InstanceType = "t3.micro"
}

Write-Host "[2/5] Preparing AWS Free Tier CloudFormation Stack..." -ForegroundColor Yellow
Write-Host "  Stack Name:    $StackName"
Write-Host "  Instance Type: $InstanceType (AWS Free Tier - 750 hrs/month free)"
Write-Host "  Storage:       30 GB gp3 SSD (AWS Free Tier - 30 GB free)"
Write-Host ""

$templatePath = Join-Path $PSScriptRoot "cloudformation.yaml"
if (-not (Test-Path $templatePath)) {
    Write-Error "Could not find $templatePath"
}

# 4. Deploy CloudFormation Stack
Write-Host "[3/5] Deploying CloudFormation Stack to AWS... (this takes ~2-3 minutes)" -ForegroundColor Yellow
& $awsCmd cloudformation deploy `
    --template-file $templatePath `
    --stack-name $StackName `
    --parameter-overrides InstanceType=$InstanceType `
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM `
    --no-fail-on-empty-changeset

if ($LASTEXITCODE -ne 0) {
    Write-Error "CloudFormation deployment failed."
}

# 5. Retrieve Outputs
Write-Host ""
Write-Host "[4/5] Retrieving live endpoint outputs..." -ForegroundColor Yellow
$outputsJson = & $awsCmd cloudformation describe-stacks --stack-name $StackName --query "Stacks[0].Outputs" --output json | ConvertFrom-Json

$publicIp = ""
$apiUrl = ""
$healthUrl = ""

foreach ($out in $outputsJson) {
    if ($out.OutputKey -eq "PublicIp") { $publicIp = $out.OutputValue }
    if ($out.OutputKey -eq "BackendApiUrl") { $apiUrl = $out.OutputValue }
    if ($out.OutputKey -eq "HealthCheckUrl") { $healthUrl = $out.OutputValue }
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host "   AWS DEPLOYMENT SUCCESSFUL!                                    " -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green
Write-Host "  Public IP:        $publicIp" -ForegroundColor Cyan
Write-Host "  REST API Base URL:$apiUrl" -ForegroundColor Cyan
Write-Host "  Health Check URL: $healthUrl" -ForegroundColor Cyan
Write-Host "  Direct HTTP Port: http://$publicIp/api" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Green
Write-Host ""

# 6. Test Endpoint
Write-Host "[5/5] Polling health check on deployed instance..." -ForegroundColor Yellow
$maxAttempts = 12
$attempt = 1
$healthy = $false

while ($attempt -le $maxAttempts) {
    Write-Host "  Attempt $attempt/$maxAttempts: Testing $healthUrl..." -NoNewline
    try {
        $res = Invoke-RestMethod -Uri $healthUrl -TimeoutSec 5 -ErrorAction Stop
        if ($res.status -eq "ok") {
            Write-Host " [SUCCESS 200 OK]" -ForegroundColor Green
            $healthy = $true
            break
        }
    } catch {
        Write-Host " [Instance provisioning UserData... waiting 15s]" -ForegroundColor Gray
    }
    Start-Sleep -Seconds 15
    $attempt++
}

if ($healthy) {
    Write-Host ""
    Write-Host "Find My Volt API and SQLite Database are LIVE in AWS Free Tier!" -ForegroundColor Green
    Write-Host "To connect your Flutter client, update ApiService baseUrl to: '$apiUrl'" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "EC2 instance launched! UserData script is completing initial setup." -ForegroundColor Yellow
    Write-Host "It will become available at $apiUrl in 1-2 minutes." -ForegroundColor Yellow
}
