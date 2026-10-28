import 'package:flutter_test/flutter_test.dart';
import 'package:find_my_volt/models/models.dart';
import 'package:find_my_volt/services/api_service.dart';
import 'package:find_my_volt/data/repositories/app_repository.dart';
import 'package:find_my_volt/state/app_state.dart';

void main() {
  setUpAll(() {
    AppState.enableRealtimeTimer = false;
    AppState().stopSimulation();
  });

  tearDownAll(() {
    AppState().stopSimulation();
  });

  group('Model Serialization & Deserialization Tests', () {
    test('ChargerStation fromJson and toJson roundtrip', () {
      final jsonMap = {
        'id': 'test_station',
        'name': 'Test Station',
        'hostName': 'Test Host',
        'hostAvatar': 'https://example.com/avatar.png',
        'hostRating': 4.9,
        'hostReviews': 25,
        'isVerified': true,
        'isSuperhost': true,
        'address': 'MG Road, Bangalore',
        'landmark': 'Near Metro',
        'distanceKm': 2.5,
        'driveTimeMinutes': 10,
        'powerKw': 22.0,
        'connectorType': 'Type-2 Gun',
        'tariffPerHour': 150,
        'parkingFee': 20,
        'bayType': 'Covered Bay',
        'isCovered': true,
        'hasCctv': true,
        'hasWifi': true,
        'isSolar': true,
        'isOpen': true,
        'openUntil': '11:00 PM',
        'isOnline': true,
        'compatibleVehicles': ['Tata Nexon EV', 'MG ZS EV'],
        'images': ['https://example.com/img1.png'],
        'mapX': 0.45,
        'mapY': 120.0,
      };

      final station = ChargerStation.fromJson(jsonMap);
      expect(station.id, 'test_station');
      expect(station.name, 'Test Station');
      expect(station.tariffPerHour, 150);
      expect(station.compatibleVehicles.length, 2);

      final outJson = station.toJson();
      expect(outJson['id'], 'test_station');
      expect(outJson['tariffPerHour'], 150);
      expect(outJson['powerKw'], 22.0);
    });

    test('ChargingBooking fromJson and toJson roundtrip', () {
      final now = DateTime.now();
      final jsonMap = {
        'id': 'BK-TEST',
        'stationId': 'st_1',
        'stationName': 'Station 1',
        'hostName': 'Host 1',
        'vehicleName': 'Tata Nexon EV',
        'vehicleReg': 'KA 03 NA 1111',
        'startTime': now.toIso8601String(),
        'endTime': now.add(const Duration(hours: 2)).toIso8601String(),
        'durationHours': 2,
        'powerKw': 7.4,
        'targetSoc': 80.0,
        'currentSoc': 65.0,
        'currentDeliveredKwh': 5.2,
        'currentCost': 140.0,
        'status': 'active',
        'passCode': '#1234',
        'transactionId': 'TXN123456',
      };

      final booking = ChargingBooking.fromJson(jsonMap);
      expect(booking.id, 'BK-TEST');
      expect(booking.durationHours, 2);
      expect(booking.currentSoc, 65.0);

      final outJson = booking.toJson();
      expect(outJson['id'], 'BK-TEST');
      expect(outJson['status'], 'active');
    });

    test('Vehicle fromJson and toJson roundtrip', () {
      final jsonMap = {
        'id': 'v_test',
        'make': 'Tata',
        'model': 'Curvv EV',
        'regNumber': 'KA 04 MM 5566',
        'batteryCapacityKwh': 55.0,
        'currentSoc': 75.0,
        'maxAcSpeedKw': 7.4,
        'maxDcSpeedKw': 70.0,
        'isDefault': true,
      };

      final vehicle = Vehicle.fromJson(jsonMap);
      expect(vehicle.id, 'v_test');
      expect(vehicle.model, 'Curvv EV');
      expect(vehicle.isDefault, isTrue);

      final outJson = vehicle.toJson();
      expect(outJson['id'], 'v_test');
      expect(outJson['isDefault'], isTrue);
    });

    test('HostRequest fromJson and toJson roundtrip', () {
      final jsonMap = {
        'id': 'REQ-TEST',
        'driverName': 'Vikram R',
        'driverAvatar': '',
        'vehicleModel': 'Nexon EV',
        'slotTime': '3:00 PM - 5:00 PM',
        'durationHours': 2,
        'amount': 280,
        'status': 'pending',
      };

      final req = HostRequest.fromJson(jsonMap);
      expect(req.id, 'REQ-TEST');
      expect(req.amount, 280);

      final outJson = req.toJson();
      expect(outJson['amount'], 280);
      expect(outJson['status'], 'pending');
    });
  });

  group('Backend API & Repository Integration Tests', () {
    final api = ApiService();
    final repo = AppRepository();

    test('API Health Check succeeds against running backend', () async {
      final isHealthy = await api.checkHealth();
      expect(isHealthy, isTrue);
    });

    test('Fetch stations from Repository returns populated list', () async {
      final stations = await repo.getStations();
      expect(stations, isNotNull);
      expect(stations!.isNotEmpty, isTrue);
      expect(stations.any((s) => s.id == 'sharma_villa'), isTrue);
    });

    test('Fetch vehicles from Repository returns user garage', () async {
      final vehicles = await repo.getVehicles();
      expect(vehicles, isNotNull);
      expect(vehicles!.isNotEmpty, isTrue);
    });

    test('Fetch wallet balance from Repository returns valid double', () async {
      final balance = await repo.getWalletBalance();
      expect(balance, isNotNull);
      expect(balance! >= 0, isTrue);
    });

    test('Fetch active booking from Repository', () async {
      var booking = await repo.getActiveBooking();
      if (booking == null) {
        booking = await repo.createBooking({
          'id': 'BK-TEST-ACTIVE',
          'stationId': 'sharma_villa',
          'stationName': 'Sharma Villa P2P Charger',
          'hostName': 'Rajesh Sharma',
          'vehicleName': 'Tata Nexon EV Max',
          'vehicleReg': 'KA 03 NA 4120',
          'startTime': DateTime.now().toIso8601String(),
          'endTime': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
          'durationHours': 2,
          'powerKw': 7.4,
          'targetSoc': 80.0,
          'currentSoc': 65.0,
          'currentDeliveredKwh': 5.2,
          'totalAmount': 180.0,
          'passCode': '#8492',
          'transactionId': 'TXN123456',
        });
      }
      expect(booking, isNotNull);
      expect(booking!.status, 'active');
    });

    test('Fetch host requests from Repository', () async {
      final reqs = await repo.getHostRequests();
      expect(reqs, isNotNull);
    });

    test('Fetch chat messages from Repository', () async {
      final messages = await repo.getChatMessages();
      expect(messages, isNotNull);
      expect(messages!.isNotEmpty, isTrue);
    });
  });

  group('AppState Backend Synchronization Tests', () {
    test('syncFromBackend loads remote data and preserves reactive state', () async {
      final state = AppState();
      await state.syncFromBackend();

      expect(state.stations.isNotEmpty, isTrue);
      expect(state.vehicles.isNotEmpty, isTrue);
      expect(state.walletBalance >= 0, isTrue);
      expect(state.chatMessages.isNotEmpty, isTrue);
    });
  });
}
