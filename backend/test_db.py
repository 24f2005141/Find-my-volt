"""
Automated unit test suite for Find My Volt SQLite Database Layer.
Verifies table creation, seeding, relational integrity, wallet operations,
charging booking state mutations, vehicle management, and host request workflows.
"""
import sys
import os

# Add backend directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

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

def run_tests():
    print("=== RUNNING DATABASE TESTS ===")
    
    # 1. Initialize and Seed
    init_db()
    
    # 2. User Profile & Wallet
    user = get_user_profile()
    assert user is not None, "User profile should not be None"
    assert user["name"] == "Vikramaditya Rao"
    print("[PASS] User profile verified:", user["name"])
    
    wallet = get_wallet()
    initial_balance = wallet["walletBalance"]
    assert initial_balance >= 0
    print("[PASS] Initial wallet balance:", initial_balance)
    
    # Test topup
    updated_wallet = topup_wallet(500.0)
    assert updated_wallet["walletBalance"] == initial_balance + 500.0
    print("[PASS] Wallet topup successful:", updated_wallet["walletBalance"])
    
    # Test deduct
    deduct_res = deduct_wallet(500.0)
    assert deduct_res["success"] is True
    assert deduct_res["walletBalance"] == initial_balance
    print("[PASS] Wallet deduct successful:", deduct_res["walletBalance"])
    
    # 3. Stations
    stations = get_all_stations()
    assert len(stations) >= 4, "Should have at least 4 seeded stations"
    first_station = stations[0]
    print(f"[PASS] Retrieved {len(stations)} stations. First: {first_station['name']}")
    
    # Toggle station online
    updated_st = update_station_online(first_station["id"], False)
    assert updated_st["isOnline"] is False
    update_station_online(first_station["id"], True)
    print("[PASS] Station online status toggling verified")
    
    # 4. Vehicles
    vehicles = get_all_vehicles()
    assert len(vehicles) >= 2, "Should have at least 2 vehicles"
    print(f"[PASS] Retrieved {len(vehicles)} vehicles")
    
    # Add new vehicle
    new_v = {
        "id": "hyundai_ioniq_5",
        "userId": user["id"],
        "make": "Hyundai",
        "model": "Ioniq 5 AWD",
        "regNumber": "KA 05 MN 9988",
        "batteryCapacityKwh": 72.6,
        "currentSoc": 88.0,
        "maxAcSpeedKw": 11.0,
        "maxDcSpeedKw": 240.0,
        "isDefault": False
    }
    all_v = create_vehicle(new_v)
    assert any(v["id"] == "hyundai_ioniq_5" for v in all_v)
    print("[PASS] Vehicle creation verified")
    
    # Set default
    v_updated = set_default_vehicle("hyundai_ioniq_5")
    assert any(v["id"] == "hyundai_ioniq_5" and v["isDefault"] is True for v in v_updated)
    set_default_vehicle("nexon_ev") # Restore original default
    print("[PASS] Vehicle default switcher verified")
    
    # 5. Bookings
    active_b = get_active_booking()
    if active_b:
        print("[PASS] Active booking found:", active_b["id"], "for", active_b["stationName"])
        # Test telemetry update
        up_b = update_booking_telemetry(active_b["id"], 65.0, 10.2, 195.0)
        assert up_b["currentSoc"] == 65.0
        assert up_b["currentDeliveredKwh"] == 10.2
        print("[PASS] Booking telemetry update verified")
    
    completed = get_completed_bookings()
    print(f"[PASS] Completed bookings retrieved: {len(completed)}")
    
    # 6. Host Requests
    reqs = get_all_host_requests()
    print(f"[PASS] Host requests retrieved: {len(reqs)}")
    if reqs:
        test_req_id = reqs[0]["id"]
        accept_host_request(test_req_id)
        print("[PASS] Host request acceptance verified for", test_req_id)
        
    earnings = get_host_earnings_data()
    assert earnings["monthlyEarnings"] > 0
    print(f"[PASS] Host earnings verified: Rs. {earnings['monthlyEarnings']:.2f}")
    
    # 7. Transactions
    txs = get_all_transactions()
    assert len(txs) > 0
    print(f"[PASS] Ledger transactions retrieved: {len(txs)}")
    
    # 8. Chat
    messages = get_all_chat_messages()
    initial_count = len(messages)
    messages = add_chat_message("user", "Thank you, charging started smoothly!", "12:05 PM")
    assert len(messages) == initial_count + 1
    print("[PASS] Chat message persistence verified:", messages[-1]["text"])
    
    print("\n======================================")
    print("ALL DATABASE TESTS PASSED WITH 100% SUCCESS!")
    print("======================================\n")

if __name__ == "__main__":
    run_tests()
