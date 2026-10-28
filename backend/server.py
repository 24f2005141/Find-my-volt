"""
Find My Volt - Clean Modular REST API Server
Built with Python standard library (http.server + sqlite3 + json).
Zero external heavy dependencies, full cross-platform compatibility, and production-grade CORS support.
"""

import sys
import os
import json
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

# Add backend directory to sys.path
BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
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

PORT = int(os.environ.get("PORT", 5000))

class RequestHandler(BaseHTTPRequestHandler):
    """Handles all REST API endpoints for the Find My Volt client application."""

    def _set_headers(self, status=200, content_type="application/json"):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PATCH, PUT, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With")
        self.end_headers()

    def do_OPTIONS(self):
        """Respond to CORS preflight requests."""
        self._set_headers(200)

    def _read_json(self):
        """Reads and parses JSON body from request."""
        try:
            content_length = int(self.headers.get("Content-Length", 0))
            if content_length > 0:
                raw_data = self.rfile.read(content_length).decode("utf-8")
                return json.loads(raw_data)
        except Exception as e:
            print(f"[ERROR] Failed to read JSON payload: {e}")
        return {}

    def _send_json(self, data, status=200):
        self._set_headers(status, "application/json")
        self.wfile.write(json.dumps(data, indent=2).encode("utf-8"))

    def _send_error(self, message, status=400):
        self._set_headers(status, "application/json")
        self.wfile.write(json.dumps({"error": message, "success": False}).encode("utf-8"))

    # -------------------------------------------------------------
    # GET Handlers
    # -------------------------------------------------------------
    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path.rstrip("/")
        query = parse_qs(parsed.query)

        try:
            # Health check
            if path == "" or path == "/api" or path == "/api/health":
                return self._send_json({"status": "ok", "service": "Find My Volt API", "version": "1.0.0"})

            # User Profile
            elif path == "/api/user":
                user = get_user_profile()
                return self._send_json(user)

            # Wallet
            elif path == "/api/wallet":
                wallet = get_wallet()
                return self._send_json(wallet)

            # Stations
            elif path == "/api/stations":
                stations = get_all_stations()
                return self._send_json(stations)

            elif path.startswith("/api/stations/"):
                station_id = path.split("/api/stations/")[1]
                station = get_station_by_id(station_id)
                if station:
                    return self._send_json(station)
                return self._send_error("Station not found", 404)

            # Vehicles
            elif path == "/api/vehicles":
                vehicles = get_all_vehicles()
                return self._send_json(vehicles)

            # Bookings
            elif path == "/api/bookings/active":
                booking = get_active_booking()
                return self._send_json({"booking": booking})

            elif path == "/api/bookings/history":
                history = get_completed_bookings()
                return self._send_json(history)

            # Host
            elif path == "/api/host/requests":
                requests = get_all_host_requests()
                return self._send_json(requests)

            elif path == "/api/host/earnings":
                earnings = get_host_earnings_data()
                return self._send_json(earnings)

            elif path == "/api/host/transactions":
                transactions = get_all_transactions()
                return self._send_json(transactions)

            # Chat
            elif path == "/api/chat/messages":
                messages = get_all_chat_messages()
                return self._send_json(messages)

            else:
                return self._send_error(f"Route not found: {path}", 404)

        except Exception as e:
            print(f"[ERROR] Exception during GET {path}: {e}")
            return self._send_error(str(e), 500)

    # -------------------------------------------------------------
    # POST Handlers
    # -------------------------------------------------------------
    def do_POST(self):
        parsed = urlparse(self.path)
        path = parsed.path.rstrip("/")
        body = self._read_json()

        try:
            # Wallet Topup
            if path == "/api/wallet/topup":
                amount = float(body.get("amount", 0.0))
                if amount <= 0:
                    return self._send_error("Invalid topup amount", 400)
                res = topup_wallet(amount)
                return self._send_json(res)

            # Wallet Deduct
            elif path == "/api/wallet/deduct":
                amount = float(body.get("amount", 0.0))
                res = deduct_wallet(amount)
                if not res.get("success", False):
                    return self._send_error(res.get("message", "Deduct failed"), 400)
                return self._send_json(res)

            # Stations Creation
            elif path == "/api/stations":
                if not body.get("name") or not body.get("id"):
                    return self._send_error("Missing required station parameters", 400)
                new_st = create_station(body)
                return self._send_json(new_st, 201)

            # Vehicles Creation
            elif path == "/api/vehicles":
                if not body.get("model") or not body.get("id"):
                    return self._send_error("Missing required vehicle parameters", 400)
                all_v = create_vehicle(body)
                return self._send_json(all_v, 201)

            # Create Booking (Slot reservation / charging start)
            elif path == "/api/bookings":
                if not body.get("stationId") or not body.get("id"):
                    return self._send_error("Missing booking parameters", 400)
                booking = create_booking(body)
                return self._send_json(booking, 201)

            # Stop Active Booking (Session completed)
            elif path == "/api/bookings/stop":
                booking_id = body.get("id")
                res = stop_active_booking(booking_id)
                return self._send_json(res)

            # Host Request Accept
            elif path.startswith("/api/host/requests/") and path.endswith("/accept"):
                req_id = path.split("/api/host/requests/")[1].replace("/accept", "")
                requests = accept_host_request(req_id)
                return self._send_json(requests)

            # Host Request Decline
            elif path.startswith("/api/host/requests/") and path.endswith("/decline"):
                req_id = path.split("/api/host/requests/")[1].replace("/decline", "")
                requests = decline_host_request(req_id)
                return self._send_json(requests)

            # Chat Send
            elif path == "/api/chat/messages":
                sender = body.get("sender", "user")
                text = body.get("text", "")
                time_label = body.get("time", "Now")
                if not text.strip():
                    return self._send_error("Message text cannot be empty", 400)
                messages = add_chat_message(sender, text, time_label)
                return self._send_json(messages, 201)

            else:
                return self._send_error(f"Endpoint not found: {path}", 404)

        except Exception as e:
            print(f"[ERROR] Exception during POST {path}: {e}")
            return self._send_error(str(e), 500)

    # -------------------------------------------------------------
    # PATCH Handlers
    # -------------------------------------------------------------
    def do_PATCH(self):
        parsed = urlparse(self.path)
        path = parsed.path.rstrip("/")
        body = self._read_json()

        try:
            # Toggle Station Online / Offline
            if path.startswith("/api/stations/") and path.endswith("/online"):
                station_id = path.split("/api/stations/")[1].replace("/online", "")
                is_online = bool(body.get("isOnline", True))
                updated = update_station_online(station_id, is_online)
                return self._send_json(updated)

            # Set Default Vehicle
            elif path.startswith("/api/vehicles/") and path.endswith("/default"):
                vehicle_id = path.split("/api/vehicles/")[1].replace("/default", "")
                all_v = set_default_vehicle(vehicle_id)
                return self._send_json(all_v)

            # Telemetry Update for Active Booking
            elif path.startswith("/api/bookings/") and path.endswith("/telemetry"):
                booking_id = path.split("/api/bookings/")[1].replace("/telemetry", "")
                soc = float(body.get("currentSoc", 0.0))
                kwh = float(body.get("currentDeliveredKwh", 0.0))
                cost = float(body.get("currentCost", 0.0))
                updated = update_booking_telemetry(booking_id, soc, kwh, cost)
                return self._send_json(updated)

            else:
                return self._send_error(f"Endpoint not found: {path}", 404)

        except Exception as e:
            print(f"[ERROR] Exception during PATCH {path}: {e}")
            return self._send_error(str(e), 500)

    def log_message(self, format, *args):
        """Custom formatted log for cleaner server logs."""
        print(f"[API Server] {self.command} {self.path} -> {args[1] if len(args) > 1 else ''}")

def run_server(port=PORT):
    init_db()
    server_address = ("", port)
    httpd = HTTPServer(server_address, RequestHandler)
    print(f"=====================================================")
    print(f" Find My Volt REST API Server running on port {port}")
    print(f" Base URL: http://localhost:{port}/api")
    print(f" Health check: http://localhost:{port}/api/health")
    print(f"=====================================================")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server gracefully...")
        httpd.server_close()

if __name__ == "__main__":
    run_server()
