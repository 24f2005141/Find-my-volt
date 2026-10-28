"""
AWS Lambda Serverless Handler for Find My Volt Backend.
Operates within the AWS Lambda 100% Free Forever Tier (1,000,000 requests/month).
Interacts directly with SQLite database persistent store /tmp/find_my_volt.db.
"""

import sys
import os
import json
from urllib.parse import parse_qs

# Point SQLite database path to AWS Lambda writable storage /tmp
os.environ["SQLITE_DB_PATH"] = "/tmp/find_my_volt.db"

# Add backend directory to sys.path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.join(BASE_DIR, "..", "..", "backend")
sys.path.insert(0, BACKEND_DIR)

from database.db import (
    init_db,
    get_user_profile,
    get_wallet,
    topup_wallet,
    deduct_wallet,
    get_all_stations,
    get_station_by_id,
    create_station,
    update_station_online,
    get_all_vehicles,
    create_vehicle,
    set_default_vehicle,
    get_active_booking,
    get_completed_bookings,
    create_booking,
    stop_active_booking,
    update_booking_telemetry,
    get_all_host_requests,
    accept_host_request,
    decline_host_request,
    get_host_earnings_data,
    get_all_transactions,
    get_all_chat_messages,
    add_chat_message
)

# Ensure database tables exist on cold start
try:
    init_db()
except Exception as e:
    print(f"Database init warning: {e}")

def _response(status, data):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PATCH, PUT, DELETE, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, Authorization"
        },
        "body": json.dumps(data)
    }

def handler(event, context):
    """Main entrypoint for AWS Lambda triggered by API Gateway HTTP API."""
    
    # Extract HTTP method and path
    http_ctx = event.get("requestContext", {}).get("http", {})
    method = http_ctx.get("method", event.get("httpMethod", "GET")).upper()
    raw_path = event.get("rawPath", event.get("path", "/api/health")).rstrip("/")

    # Handle CORS preflight
    if method == "OPTIONS":
        return _response(200, {"status": "ok"})

    # Parse body if present
    body = {}
    if event.get("body"):
        try:
            body_str = event["body"]
            if event.get("isBase64Encoded", False):
                import base64
                body_str = base64.b64decode(body_str).decode("utf-8")
            body = json.loads(body_str)
        except Exception:
            body = {}

    try:
        # -------------------------------------------------------------
        # GET Endpoints
        # -------------------------------------------------------------
        if method == "GET":
            if raw_path in ["", "/api", "/api/health"]:
                return _response(200, {"status": "ok", "service": "Find My Volt AWS Lambda API", "version": "1.0.0"})
            elif raw_path == "/api/user":
                return _response(200, get_user_profile())
            elif raw_path == "/api/wallet":
                return _response(200, get_wallet())
            elif raw_path == "/api/stations":
                return _response(200, get_all_stations())
            elif raw_path.startswith("/api/stations/"):
                st_id = raw_path.split("/api/stations/")[1]
                station = get_station_by_id(st_id)
                return _response(200, station) if station else _response(404, {"error": "Station not found"})
            elif raw_path == "/api/vehicles":
                return _response(200, get_all_vehicles())
            elif raw_path == "/api/bookings/active":
                return _response(200, {"booking": get_active_booking()})
            elif raw_path == "/api/bookings/history":
                return _response(200, get_completed_bookings())
            elif raw_path == "/api/host/requests":
                return _response(200, get_all_host_requests())
            elif raw_path == "/api/host/earnings":
                return _response(200, get_host_earnings_data())
            elif raw_path == "/api/host/transactions":
                return _response(200, get_all_transactions())
            elif raw_path == "/api/chat/messages":
                return _response(200, get_all_chat_messages())

        # -------------------------------------------------------------
        # POST Endpoints
        # -------------------------------------------------------------
        elif method == "POST":
            if raw_path == "/api/wallet/topup":
                res = topup_wallet(float(body.get("amount", 0.0)))
                return _response(200, res)
            elif raw_path == "/api/wallet/deduct":
                res = deduct_wallet(float(body.get("amount", 0.0)))
                return _response(200, res)
            elif raw_path == "/api/stations":
                res = create_station(body)
                return _response(201, res)
            elif raw_path == "/api/vehicles":
                res = create_vehicle(body)
                return _response(201, res)
            elif raw_path == "/api/bookings":
                res = create_booking(body)
                return _response(201, res)
            elif raw_path == "/api/bookings/stop":
                res = stop_active_booking(body.get("id"))
                return _response(200, res)
            elif raw_path.startswith("/api/host/requests/") and raw_path.endswith("/accept"):
                req_id = raw_path.split("/api/host/requests/")[1].replace("/accept", "")
                return _response(200, accept_host_request(req_id))
            elif raw_path.startswith("/api/host/requests/") and raw_path.endswith("/decline"):
                req_id = raw_path.split("/api/host/requests/")[1].replace("/decline", "")
                return _response(200, decline_host_request(req_id))
            elif raw_path == "/api/chat/messages":
                sender = body.get("sender", "user")
                text = body.get("text", "")
                time_label = body.get("time", "Now")
                return _response(201, add_chat_message(sender, text, time_label))

        # -------------------------------------------------------------
        # PATCH Endpoints
        # -------------------------------------------------------------
        elif method == "PATCH":
            if raw_path.startswith("/api/stations/") and raw_path.endswith("/online"):
                st_id = raw_path.split("/api/stations/")[1].replace("/online", "")
                return _response(200, update_station_online(st_id, bool(body.get("isOnline", True))))
            elif raw_path.startswith("/api/vehicles/") and raw_path.endswith("/default"):
                v_id = raw_path.split("/api/vehicles/")[1].replace("/default", "")
                return _response(200, set_default_vehicle(v_id))
            elif raw_path.startswith("/api/bookings/") and raw_path.endswith("/telemetry"):
                b_id = raw_path.split("/api/bookings/")[1].replace("/telemetry", "")
                return _response(200, update_booking_telemetry(
                    b_id,
                    float(body.get("currentSoc", 0.0)),
                    float(body.get("currentDeliveredKwh", 0.0)),
                    float(body.get("currentCost", 0.0))
                ))

        return _response(404, {"error": f"Path not found: {method} {raw_path}"})

    except Exception as e:
        return _response(500, {"error": str(e), "success": False})
