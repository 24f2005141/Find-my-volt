import os
import sqlite3
import json
from datetime import datetime

DB_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(DB_DIR, "find_my_volt.db")
SCHEMA_PATH = os.path.join(DB_DIR, "schema.sql")

def get_connection():
    """Returns a new SQLite connection with foreign keys enabled and row_factory as Row."""
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON;")
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    """Initializes tables using schema.sql and seeds initial data if database is empty."""
    os.makedirs(DB_DIR, exist_ok=True)
    with get_connection() as conn:
        with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
            conn.executescript(f.read())
        conn.commit()
    seed_if_empty()

def seed_if_empty():
    """Seeds rich initial dataset if users table is empty."""
    with get_connection() as conn:
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) as count FROM users;")
        row = cur.fetchone()
        if row and row["count"] > 0:
            return

        print("Seeding initial Find My Volt database records...")

        # 1. User
        user_id = "user_vikram_01"
        conn.execute("""
            INSERT INTO users (id, name, email, phone, avatar_url, wallet_balance, is_host, role)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """, (
            user_id,
            "Vikramaditya Rao",
            "vikram@evpioneer.in",
            "+91 98450 12345",
            "https://lh3.googleusercontent.com/aida-public/AB6AXuCO5ZiPaX53wSN6udXYa7Wl7PDaKJKd83ZvIKL75YYh1nPubpsTqdkNMUGMOcyrRLEkvU9gkZksTPEnoRYRBB1AIPn7Bz6IcsbtmdF6mcvJb9VoaW-vcMuDO1cGeLi8xH2aC6BoVZIglp3SqggfoLRPcTsbmjfIFEezuEHGYPZ5TNCKOJ5Y363OP3TKMNZkOTBFbr8pCG2KlB-mKZ1FB7P0aR8qNXJtd4I3i4zIFOI",
            1450.00,
            1,
            "PIONEER"
        ))

        # 2. Vehicles
        vehicles = [
            ("nexon_ev", user_id, "Tata", "Nexon EV Max", "KA 03 NA 4120", 40.5, 68.0, 7.2, 50.0, 1),
            ("mg_zs_ev", user_id, "MG", "ZS EV Excite", "KA 01 MJ 8892", 50.3, 82.0, 7.4, 50.0, 0),
        ]
        conn.executemany("""
            INSERT INTO vehicles (id, user_id, make, model, reg_number, battery_capacity_kwh, current_soc, max_ac_speed_kw, max_dc_speed_kw, is_default)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, vehicles)

        # 3. Stations
        stations = [
            (
                "sharma_villa",
                user_id,
                "Sharma Villa P2P Charger",
                "Rajesh Sharma",
                "https://lh3.googleusercontent.com/aida-public/AB6AXuA9GvFZmwZhc4TjcwSkuatG7pJPgjmrce8IAYN4d2LeLpWFIBnfZa06KGvCT5oczJi4hEX_PIh4L6BtRoUCTTYl-7YLnDrvhHUCCoZpI1wzOwq0CdiR5zOj2rQRw48VrKPslnZzw4Y1EVC8oOryhtD5AtcNN-VHVcyZiTB-A2zaCPbJ79pRyaWoRfGwMMpU0HwHqMy-oG9ElcvGNvT9QDmqa8tUjt8QKqiFI-zOWQ8",
                4.9,
                42,
                1,
                1,
                "12th Main Road, HAL 2nd Stage, Indiranagar",
                "Near Toit Brewpub & 100ft Rd Metro",
                1.2,
                6,
                7.4,
                "Type-2 Gun",
                140,
                0,
                "Stilt Bay",
                1, 1, 1, 1, 1,
                "4:30 PM",
                1,
                json.dumps(["Tata Nexon EV", "Punch EV", "MG ZS EV", "Mahindra XUV400", "Hyundai Ioniq 5"]),
                json.dumps([
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuCCa9t426l29JFAyMQC0VWVGrqh1R0lL08jZdECr_PtpPJHprWlqI5eNGxZMW9mjx-WKOuIp1Ya4YF_puGs13LHGps9KGaCGJHLHz6sTnx2eLwspJkZMHiYuP5BDO-dkOEUgcgKlFQlGp_OQy3IQfAGza_nSPums4XJer0jVAfaZ24NUHh_di6sYCqTUkdmzcnzF2nZfh5_3ofRfYdJv6o-ssjniseDRps_bRPn23c",
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuAI0WXa5DWs_h4SwSSBmwj6ZCJLHyqW1oNYcq3_FpQ7sAa2aV-h63ypIVnO1vNhlwmdiz4rDbENXMaI47oHkpqSfc3uyj0EK4k2aTFtDqpqJ8XtgpDw-1X_9cpGMS1I-J44RkncCpeNJi-EUylp77sKwp0CggKbAzP2AsvHDInslfRYWk3vml9MGE1lXLVIYQIQHkiMQQvWzoTaBm-_j8QwUpO7Uz8mqH580pQIWjM"
                ]),
                0.52,
                180.0
            ),
            (
                "nexus",
                user_id,
                "Nexus Mall DC Fast Hub",
                "Nexus Retail Network",
                "",
                4.8,
                128,
                1,
                0,
                "Koramangala 1st Block, 80ft Road",
                "Opposite Forum Plaza",
                2.4,
                11,
                60.0,
                "CCS2 Dual Gun",
                220,
                30,
                "Basement Fast Bay",
                1, 1, 1, 0, 1,
                "11:00 PM",
                1,
                json.dumps(["All CCS2 EVs", "Tata", "MG", "Hyundai", "BYD", "Kia"]),
                json.dumps([
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuCCa9t426l29JFAyMQC0VWVGrqh1R0lL08jZdECr_PtpPJHprWlqI5eNGxZMW9mjx-WKOuIp1Ya4YF_puGs13LHGps9KGaCGJHLHz6sTnx2eLwspJkZMHiYuP5BDO-dkOEUgcgKlFQlGp_OQy3IQfAGza_nSPums4XJer0jVAfaZ24NUHh_di6sYCqTUkdmzcnzF2nZfh5_3ofRfYdJv6o-ssjniseDRps_bRPn23c"
                ]),
                0.22,
                130.0
            ),
            (
                "koramangala",
                user_id,
                "Koramangala Community Charger",
                "Suresh Patel",
                "",
                4.7,
                29,
                1,
                1,
                "4th Block, 14th Main, Koramangala",
                "Near Wipro Park",
                3.1,
                14,
                11.0,
                "Type-2 Gun",
                150,
                0,
                "Driveway Bay",
                1, 1, 1, 1, 1,
                "9:00 PM",
                1,
                json.dumps(["Tata Nexon EV", "MG ZS EV", "Mahindra XUV400"]),
                json.dumps([
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuAI0WXa5DWs_h4SwSSBmwj6ZCJLHyqW1oNYcq3_FpQ7sAa2aV-h63ypIVnO1vNhlwmdiz4rDbENXMaI47oHkpqSfc3uyj0EK4k2aTFtDqpqJ8XtgpDw-1X_9cpGMS1I-J44RkncCpeNJi-EUylp77sKwp0CggKbAzP2AsvHDInslfRYWk3vml9MGE1lXLVIYQIQHkiMQQvWzoTaBm-_j8QwUpO7Uz8mqH580pQIWjM"
                ]),
                0.78,
                100.0
            ),
            (
                "prestige_ozone",
                user_id,
                "Prestige Ozone Resident P2P",
                "Anita Krishnan",
                "",
                4.9,
                18,
                1,
                1,
                "Whitefield Main Road, Palm Meadows",
                "Near Forum Shantiniketan",
                4.1,
                18,
                11.0,
                "Type-2 Gun",
                120,
                0,
                "Villa Carport",
                1, 1, 1, 1, 1,
                "8:00 PM",
                1,
                json.dumps(["Tata Nexon EV", "Punch EV", "MG ZS EV", "Kia EV6"]),
                json.dumps([
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuCCa9t426l29JFAyMQC0VWVGrqh1R0lL08jZdECr_PtpPJHprWlqI5eNGxZMW9mjx-WKOuIp1Ya4YF_puGs13LHGps9KGaCGJHLHz6sTnx2eLwspJkZMHiYuP5BDO-dkOEUgcgKlFQlGp_OQy3IQfAGza_nSPums4XJer0jVAfaZ24NUHh_di6sYCqTUkdmzcnzF2nZfh5_3ofRfYdJv6o-ssjniseDRps_bRPn23c"
                ]),
                0.85,
                280.0
            )
        ]
        conn.executemany("""
            INSERT INTO stations (
                id, host_id, name, host_name, host_avatar, host_rating, host_reviews,
                is_verified, is_superhost, address, landmark, distance_km, drive_time_minutes,
                power_kw, connector_type, tariff_per_hour, parking_fee, bay_type,
                is_covered, has_cctv, has_wifi, is_solar, is_open, open_until, is_online,
                compatible_vehicles, images, map_x, map_y
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, stations)

        # 4. Bookings
        now = datetime.now()
        bookings = [
            (
                "BK-8492",
                user_id,
                "sharma_villa",
                "Sharma Villa P2P Charger",
                "Rajesh Sharma",
                "Tata Nexon EV Max",
                "KA 03 NA 4120",
                now.isoformat(),
                now.isoformat(),
                2,
                7.2,
                80.0,
                62.0,
                9.6,
                182.0,
                "active",
                "#8492",
                "TXN891240"
            ),
            (
                "BK-7120",
                user_id,
                "koramangala",
                "Koramangala 4th Block P2P",
                "Suresh Patel",
                "Tata Nexon EV Max",
                "KA 03 NA 4120",
                "2026-10-18T10:00:00",
                "2026-10-18T12:00:00",
                2,
                7.4,
                100.0,
                100.0,
                18.2,
                245.0,
                "completed",
                "#7120",
                "TXN771029"
            ),
            (
                "BK-6510",
                user_id,
                "nexus",
                "Indiranagar Metro Hub (Fast DC)",
                "Metro EV Network",
                "Tata Nexon EV Max",
                "KA 03 NA 4120",
                "2026-10-12T14:00:00",
                "2026-10-12T14:45:00",
                1,
                50.0,
                80.0,
                80.0,
                24.5,
                412.0,
                "completed",
                "#6510",
                "TXN660142"
            )
        ]
        conn.executemany("""
            INSERT INTO bookings (
                id, user_id, station_id, station_name, host_name, vehicle_name, vehicle_reg,
                start_time, end_time, duration_hours, power_kw, target_soc, current_soc,
                current_delivered_kwh, current_cost, status, pass_code, transaction_id
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, bookings)

        # 5. Host Requests
        requests = [
            ("REQ-1", "sharma_villa", user_id, "Rahul Verma", "", "Tata Nexon EV", "Today, 4:00 PM - 6:00 PM", 2, 280.0, "pending"),
            ("REQ-2", "sharma_villa", user_id, "Sneha Rao", "", "MG ZS EV", "Tomorrow, 11:00 AM - 1:00 PM", 2, 280.0, "pending"),
        ]
        conn.executemany("""
            INSERT INTO host_requests (id, station_id, host_id, driver_name, driver_avatar, vehicle_model, slot_time, duration_hours, amount, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, requests)

        # 6. Host Earnings Summary
        conn.execute("""
            INSERT INTO host_earnings (id, user_id, monthly_earnings, total_sessions, host_rating)
            VALUES (?, ?, ?, ?, ?);
        """, ("HE-01", user_id, 18420.00, 142, 4.94))

        # 7. Transactions
        txs = [
            ("TX-1", user_id, "Vikram R. • Tata Nexon EV Max", "Today, 28 Oct • 12:00 - 02:00 PM", "₹280.00"),
            ("TX-2", user_id, "Priya S. • MG ZS EV", "Yesterday, 27 Oct • 2h 15m", "₹310.00"),
            ("TX-3", user_id, "Anand K. • Mahindra XUV400", "26 Oct 2026 • 1h 45m", "₹260.00"),
            ("TX-4", user_id, "Ramesh N. • Tata Punch EV", "25 Oct 2026 • 1h 00m", "₹140.00"),
        ]
        conn.executemany("""
            INSERT INTO transactions (id, user_id, driver, meta, amount)
            VALUES (?, ?, ?, ?, ?);
        """, txs)

        # 8. Chat Messages
        chat = [
            ("MSG-1", "host", "Hello Vikram! Welcome to Sharma Villa. The stilt bay gate opens automatically with your pass code.", "11:45 AM")
        ]
        conn.executemany("""
            INSERT INTO chat_messages (id, sender, text, time_label)
            VALUES (?, ?, ?, ?);
        """, chat)

        conn.commit()
        print("Database seeded successfully with production data!")

# Data Access Object Helper Functions

def get_user_profile():
    with get_connection() as conn:
        row = conn.execute("SELECT * FROM users LIMIT 1;").fetchone()
        return dict(row) if row else None

def get_wallet():
    with get_connection() as conn:
        row = conn.execute("SELECT wallet_balance FROM users LIMIT 1;").fetchone()
        return {"walletBalance": row["wallet_balance"]} if row else {"walletBalance": 0.0}

def topup_wallet(amount):
    with get_connection() as conn:
        conn.execute("UPDATE users SET wallet_balance = wallet_balance + ?;", (amount,))
        conn.commit()
        return get_wallet()

def deduct_wallet(amount):
    with get_connection() as conn:
        cur = conn.cursor()
        cur.execute("SELECT wallet_balance FROM users LIMIT 1;")
        row = cur.fetchone()
        if not row or row["wallet_balance"] < amount:
            return {"success": False, "message": "Insufficient wallet funds"}
        conn.execute("UPDATE users SET wallet_balance = wallet_balance - ?;", (amount,))
        conn.commit()
        return {"success": True, "walletBalance": row["wallet_balance"] - amount}

def get_all_stations():
    with get_connection() as conn:
        rows = conn.execute("SELECT * FROM stations ORDER BY created_at DESC;").fetchall()
        result = []
        for r in rows:
            d = dict(r)
            d["compatibleVehicles"] = json.loads(d["compatible_vehicles"])
            d["images"] = json.loads(d["images"])
            d["isVerified"] = bool(d["is_verified"])
            d["isSuperhost"] = bool(d["is_superhost"])
            d["isCovered"] = bool(d["is_covered"])
            d["hasCctv"] = bool(d["has_cctv"])
            d["hasWifi"] = bool(d["has_wifi"])
            d["isSolar"] = bool(d["is_solar"])
            d["isOpen"] = bool(d["is_open"])
            d["isOnline"] = bool(d["is_online"])
            d["powerKw"] = d["power_kw"]
            d["tariffPerHour"] = d["tariff_per_hour"]
            d["parkingFee"] = d["parking_fee"]
            d["hostName"] = d["host_name"]
            d["hostAvatar"] = d["host_avatar"]
            d["hostRating"] = d["host_rating"]
            d["hostReviews"] = d["host_reviews"]
            d["driveTimeMinutes"] = d["drive_time_minutes"]
            d["distanceKm"] = d["distance_km"]
            d["bayType"] = d["bay_type"]
            d["connectorType"] = d["connector_type"]
            d["openUntil"] = d["open_until"]
            d["mapX"] = d["map_x"]
            d["mapY"] = d["map_y"]
            result.append(d)
        return result

def get_station_by_id(station_id):
    stations = get_all_stations()
    for s in stations:
        if s["id"] == station_id:
            return s
    return None

def create_station(station_dict):
    with get_connection() as conn:
        conn.execute("""
            INSERT INTO stations (
                id, host_id, name, host_name, host_avatar, host_rating, host_reviews,
                is_verified, is_superhost, address, landmark, distance_km, drive_time_minutes,
                power_kw, connector_type, tariff_per_hour, parking_fee, bay_type,
                is_covered, has_cctv, has_wifi, is_solar, is_open, open_until, is_online,
                compatible_vehicles, images, map_x, map_y
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, (
            station_dict["id"],
            station_dict.get("host_id", "user_vikram_01"),
            station_dict["name"],
            station_dict["hostName"],
            station_dict.get("hostAvatar", ""),
            station_dict.get("hostRating", 5.0),
            station_dict.get("hostReviews", 0),
            1 if station_dict.get("isVerified", True) else 0,
            1 if station_dict.get("isSuperhost", True) else 0,
            station_dict["address"],
            station_dict["landmark"],
            station_dict["distanceKm"],
            station_dict["driveTimeMinutes"],
            station_dict["powerKw"],
            station_dict["connectorType"],
            int(station_dict["tariffPerHour"]),
            int(station_dict.get("parkingFee", 0)),
            station_dict["bayType"],
            1 if station_dict.get("isCovered", True) else 0,
            1 if station_dict.get("hasCctv", True) else 0,
            1 if station_dict.get("hasWifi", True) else 0,
            1 if station_dict.get("isSolar", True) else 0,
            1 if station_dict.get("isOpen", True) else 0,
            station_dict.get("openUntil", "10:00 PM"),
            1 if station_dict.get("isOnline", True) else 0,
            json.dumps(station_dict.get("compatibleVehicles", [])),
            json.dumps(station_dict.get("images", [])),
            station_dict.get("mapX", 0.5),
            station_dict.get("mapY", 150.0)
        ))
        conn.commit()
    return get_station_by_id(station_dict["id"])

def update_station_online(station_id, online):
    with get_connection() as conn:
        conn.execute("UPDATE stations SET is_online = ? WHERE id = ?;", (1 if online else 0, station_id))
        conn.commit()
    return get_station_by_id(station_id)

def get_all_vehicles():
    with get_connection() as conn:
        rows = conn.execute("SELECT * FROM vehicles ORDER BY is_default DESC;").fetchall()
        result = []
        for r in rows:
            d = dict(r)
            d["isDefault"] = bool(d["is_default"])
            d["batteryCapacityKwh"] = d["battery_capacity_kwh"]
            d["currentSoc"] = d["current_soc"]
            d["maxAcSpeedKw"] = d["max_ac_speed_kw"]
            d["maxDcSpeedKw"] = d["max_dc_speed_kw"]
            d["regNumber"] = d["reg_number"]
            result.append(d)
        return result

def create_vehicle(v_dict):
    with get_connection() as conn:
        conn.execute("""
            INSERT INTO vehicles (id, user_id, make, model, reg_number, battery_capacity_kwh, current_soc, max_ac_speed_kw, max_dc_speed_kw, is_default)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, (
            v_dict["id"],
            v_dict.get("userId", "user_vikram_01"),
            v_dict["make"],
            v_dict["model"],
            v_dict["regNumber"],
            float(v_dict["batteryCapacityKwh"]),
            float(v_dict.get("currentSoc", 70.0)),
            float(v_dict.get("maxAcSpeedKw", 7.4)),
            float(v_dict.get("maxDcSpeedKw", 50.0)),
            1 if v_dict.get("isDefault", False) else 0
        ))
        conn.commit()
    return get_all_vehicles()

def set_default_vehicle(vehicle_id):
    with get_connection() as conn:
        conn.execute("UPDATE vehicles SET is_default = 0;")
        conn.execute("UPDATE vehicles SET is_default = 1 WHERE id = ?;", (vehicle_id,))
        conn.commit()
    return get_all_vehicles()

def get_active_booking():
    with get_connection() as conn:
        row = conn.execute("SELECT * FROM bookings WHERE status = 'active' LIMIT 1;").fetchone()
        if not row:
            return None
        d = dict(row)
        d["startTime"] = d["start_time"]
        d["endTime"] = d["end_time"]
        d["durationHours"] = d["duration_hours"]
        d["powerKw"] = d["power_kw"]
        d["targetSoc"] = d["target_soc"]
        d["currentSoc"] = d["current_soc"]
        d["currentDeliveredKwh"] = d["current_delivered_kwh"]
        d["currentCost"] = d["current_cost"]
        d["passCode"] = d["pass_code"]
        d["transactionId"] = d["transaction_id"]
        d["stationName"] = d["station_name"]
        d["hostName"] = d["host_name"]
        d["vehicleName"] = d["vehicle_name"]
        d["vehicleReg"] = d["vehicle_reg"]
        return d

def get_completed_bookings():
    with get_connection() as conn:
        rows = conn.execute("SELECT * FROM bookings WHERE status = 'completed' ORDER BY created_at DESC;").fetchall()
        result = []
        for r in rows:
            d = dict(r)
            d["startTime"] = d["start_time"]
            d["endTime"] = d["end_time"]
            d["durationHours"] = d["duration_hours"]
            d["powerKw"] = d["power_kw"]
            d["targetSoc"] = d["target_soc"]
            d["currentSoc"] = d["current_soc"]
            d["currentDeliveredKwh"] = d["current_delivered_kwh"]
            d["currentCost"] = d["current_cost"]
            d["passCode"] = d["pass_code"]
            d["transactionId"] = d["transaction_id"]
            d["stationName"] = d["station_name"]
            d["hostName"] = d["host_name"]
            d["vehicleName"] = d["vehicle_name"]
            d["vehicleReg"] = d["vehicle_reg"]
            result.append(d)
        return result

def create_booking(b_dict):
    with get_connection() as conn:
        conn.execute("""
            INSERT INTO bookings (
                id, user_id, station_id, station_name, host_name, vehicle_name, vehicle_reg,
                start_time, end_time, duration_hours, power_kw, target_soc, current_soc,
                current_delivered_kwh, current_cost, status, pass_code, transaction_id
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, (
            b_dict["id"],
            b_dict.get("userId", "user_vikram_01"),
            b_dict["stationId"],
            b_dict["stationName"],
            b_dict["hostName"],
            b_dict["vehicleName"],
            b_dict["vehicleReg"],
            b_dict["startTime"],
            b_dict["endTime"],
            b_dict["durationHours"],
            b_dict["powerKw"],
            b_dict.get("targetSoc", 80.0),
            b_dict.get("currentSoc", 68.0),
            b_dict.get("currentDeliveredKwh", 0.1),
            b_dict["totalAmount"],
            "active",
            b_dict.get("passCode", "#8492"),
            b_dict.get("transactionId", f"TXN{int(datetime.now().timestamp())}")
        ))
        # Deduct wallet
        conn.execute("UPDATE users SET wallet_balance = wallet_balance - ?;", (b_dict["totalAmount"],))
        conn.commit()
    return get_active_booking()

def stop_active_booking(booking_id=None):
    with get_connection() as conn:
        active = get_active_booking()
        if not active:
            return None
        b_id = booking_id or active["id"]
        conn.execute("UPDATE bookings SET status = 'completed' WHERE id = ?;", (b_id,))
        # Credit host
        cost = active["currentCost"]
        conn.execute("UPDATE host_earnings SET monthly_earnings = monthly_earnings + ?, total_sessions = total_sessions + 1;", (cost,))
        # Add transaction
        conn.execute("""
            INSERT INTO transactions (id, user_id, driver, meta, amount)
            VALUES (?, ?, ?, ?, ?);
        """, (
            f"TX-{int(datetime.now().timestamp())}",
            "user_vikram_01",
            f"Vikram R. • {active['vehicleName']}",
            f"Today • {active['durationHours']} hrs • {active['currentDeliveredKwh']:.1f} kWh",
            f"₹{cost:.2f}"
        ))
        conn.commit()
    return {"message": "Session stopped and archived to history"}

def update_booking_telemetry(booking_id, current_soc, current_kwh, current_cost):
    with get_connection() as conn:
        conn.execute("""
            UPDATE bookings
            SET current_soc = ?, current_delivered_kwh = ?, current_cost = ?
            WHERE id = ? AND status = 'active';
        """, (current_soc, current_kwh, current_cost, booking_id))
        conn.commit()
    return get_active_booking()

def get_all_host_requests():
    with get_connection() as conn:
        rows = conn.execute("SELECT * FROM host_requests WHERE status != 'declined' ORDER BY created_at DESC;").fetchall()
        result = []
        for r in rows:
            d = dict(r)
            d["driverName"] = d["driver_name"]
            d["driverAvatar"] = d["driver_avatar"]
            d["vehicleModel"] = d["vehicle_model"]
            d["slotTime"] = d["slot_time"]
            d["durationHours"] = d["duration_hours"]
            result.append(d)
        return result

def accept_host_request(request_id):
    with get_connection() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM host_requests WHERE id = ?;", (request_id,))
        req = cur.fetchone()
        if req:
            conn.execute("UPDATE host_requests SET status = 'accepted' WHERE id = ?;", (request_id,))
            conn.execute("UPDATE host_earnings SET monthly_earnings = monthly_earnings + ?, total_sessions = total_sessions + 1;", (req["amount"],))
            conn.commit()
    return get_all_host_requests()

def decline_host_request(request_id):
    with get_connection() as conn:
        conn.execute("UPDATE host_requests SET status = 'declined' WHERE id = ?;", (request_id,))
        conn.commit()
    return get_all_host_requests()

def get_host_earnings_data():
    with get_connection() as conn:
        row = conn.execute("SELECT * FROM host_earnings LIMIT 1;").fetchone()
        if not row:
            return {"monthlyEarnings": 18420.0, "totalSessions": 142, "hostRating": 4.94}
        d = dict(row)
        return {
            "monthlyEarnings": d["monthly_earnings"],
            "totalSessions": d["total_sessions"],
            "hostRating": d["host_rating"]
        }

def get_all_transactions():
    with get_connection() as conn:
        rows = conn.execute("SELECT * FROM transactions ORDER BY created_at DESC;").fetchall()
        return [dict(r) for r in rows]

def get_all_chat_messages():
    with get_connection() as conn:
        rows = conn.execute("SELECT * FROM chat_messages ORDER BY created_at ASC;").fetchall()
        return [{"sender": r["sender"], "text": r["text"], "time": r["time_label"]} for r in rows]

def add_chat_message(sender, text, time_label):
    with get_connection() as conn:
        msg_id = f"MSG-{int(datetime.now().timestamp() * 1000)}"
        conn.execute("""
            INSERT INTO chat_messages (id, sender, text, time_label)
            VALUES (?, ?, ?, ?);
        """, (msg_id, sender, text, time_label))
        conn.commit()
    return get_all_chat_messages()
