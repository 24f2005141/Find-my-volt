-- ====================================================================
-- Find My Volt - Relational Database Schema (SQLite)
-- Version: 1.0.0
-- ====================================================================

PRAGMA foreign_keys = ON;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT NOT NULL,
    avatar_url TEXT,
    wallet_balance REAL NOT NULL DEFAULT 1450.00,
    is_host INTEGER NOT NULL DEFAULT 1,
    role TEXT NOT NULL DEFAULT 'Pioneer Host',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Vehicles Table (EV Garage)
CREATE TABLE IF NOT EXISTS vehicles (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    reg_number TEXT NOT NULL UNIQUE,
    battery_capacity_kwh REAL NOT NULL,
    current_soc REAL NOT NULL DEFAULT 68.0,
    max_ac_speed_kw REAL NOT NULL DEFAULT 7.4,
    max_dc_speed_kw REAL NOT NULL DEFAULT 50.0,
    is_default INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Charger Stations Table (P2P Host & Network Bays)
CREATE TABLE IF NOT EXISTS stations (
    id TEXT PRIMARY KEY,
    host_id TEXT NOT NULL,
    name TEXT NOT NULL,
    host_name TEXT NOT NULL,
    host_avatar TEXT,
    host_rating REAL NOT NULL DEFAULT 4.9,
    host_reviews INTEGER NOT NULL DEFAULT 0,
    is_verified INTEGER NOT NULL DEFAULT 1,
    is_superhost INTEGER NOT NULL DEFAULT 1,
    address TEXT NOT NULL,
    landmark TEXT NOT NULL,
    distance_km REAL NOT NULL,
    drive_time_minutes INTEGER NOT NULL,
    power_kw REAL NOT NULL,
    connector_type TEXT NOT NULL,
    tariff_per_hour INTEGER NOT NULL,
    parking_fee INTEGER NOT NULL DEFAULT 0,
    bay_type TEXT NOT NULL,
    is_covered INTEGER NOT NULL DEFAULT 1,
    has_cctv INTEGER NOT NULL DEFAULT 1,
    has_wifi INTEGER NOT NULL DEFAULT 1,
    is_solar INTEGER NOT NULL DEFAULT 1,
    is_open INTEGER NOT NULL DEFAULT 1,
    open_until TEXT NOT NULL,
    is_online INTEGER NOT NULL DEFAULT 1,
    compatible_vehicles TEXT NOT NULL, -- JSON array string
    images TEXT NOT NULL,             -- JSON array string
    map_x REAL NOT NULL DEFAULT 0.5,
    map_y REAL NOT NULL DEFAULT 150.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (host_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. Bookings & Charging Sessions Table
CREATE TABLE IF NOT EXISTS bookings (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    station_id TEXT NOT NULL,
    station_name TEXT NOT NULL,
    host_name TEXT NOT NULL,
    vehicle_name TEXT NOT NULL,
    vehicle_reg TEXT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    duration_hours INTEGER NOT NULL,
    power_kw REAL NOT NULL,
    target_soc REAL NOT NULL DEFAULT 80.0,
    current_soc REAL NOT NULL,
    current_delivered_kwh REAL NOT NULL,
    current_cost REAL NOT NULL,
    status TEXT NOT NULL CHECK(status IN ('active', 'completed', 'cancelled')),
    pass_code TEXT NOT NULL,
    transaction_id TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (station_id) REFERENCES stations(id) ON DELETE CASCADE
);

-- 5. Host Driver Booking Requests Table
CREATE TABLE IF NOT EXISTS host_requests (
    id TEXT PRIMARY KEY,
    station_id TEXT NOT NULL,
    host_id TEXT NOT NULL,
    driver_name TEXT NOT NULL,
    driver_avatar TEXT,
    vehicle_model TEXT NOT NULL,
    slot_time TEXT NOT NULL,
    duration_hours INTEGER NOT NULL,
    amount REAL NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'accepted', 'declined')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES stations(id) ON DELETE CASCADE,
    FOREIGN KEY (host_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 6. Host Earnings & Analytics Summary Table
CREATE TABLE IF NOT EXISTS host_earnings (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    monthly_earnings REAL NOT NULL DEFAULT 18420.00,
    total_sessions INTEGER NOT NULL DEFAULT 142,
    host_rating REAL NOT NULL DEFAULT 4.94,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 7. Payout Transactions Ledger Table
CREATE TABLE IF NOT EXISTS transactions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    driver TEXT NOT NULL,
    meta TEXT NOT NULL,
    amount TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 8. Real-time Host-Driver Chat Table
CREATE TABLE IF NOT EXISTS chat_messages (
    id TEXT PRIMARY KEY,
    sender TEXT NOT NULL CHECK(sender IN ('host', 'user')),
    text TEXT NOT NULL,
    time_label TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indices for Fast Querying
CREATE INDEX IF NOT EXISTS idx_stations_online ON stations(is_online);
CREATE INDEX IF NOT EXISTS idx_bookings_user ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_vehicles_user ON vehicles(user_id);
CREATE INDEX IF NOT EXISTS idx_host_requests_status ON host_requests(status);
