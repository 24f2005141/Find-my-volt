import 'package:flutter_test/flutter_test.dart';
import 'package:find_my_volt/state/app_state.dart';
import 'package:find_my_volt/models/models.dart';

void main() {
  setUp(() {
    AppState.enableRealtimeTimer = false;
    AppState().stopSimulation();
  });

  tearDown(() {
    AppState().stopSimulation();
  });

  group('Real-Time AppState & Interactive Functionalities', () {
    test('Station Search & Filter Logic works in real-time', () {
      final state = AppState();

      // Default station count
      expect(state.stations.length, greaterThanOrEqualTo(4));

      // Test Search query filter
      state.setSearchQuery('Nexus');
      expect(state.filteredStations.length, 1);
      expect(state.filteredStations.first.name, contains('Nexus'));

      state.setSearchQuery('');
      expect(state.filteredStations.length, state.stations.length);

      // Test Category Filter
      state.setSelectedFilter('CCS2 60kW+');
      expect(state.filteredStations.every((s) => s.powerKw >= 60), isTrue);

      state.setSelectedFilter('All (24)');
      expect(state.filteredStations.length, state.stations.length);
    });

    test('Wallet Top Up and Debit operate in real-time', () {
      final state = AppState();
      final initialBalance = state.walletBalance;

      // Top up ₹500
      state.topUpWallet(500.0);
      expect(state.walletBalance, initialBalance + 500.0);

      // Deduct ₹250
      final success = state.deductWallet(250.0);
      expect(success, isTrue);
      expect(state.walletBalance, initialBalance + 250.0);

      // Overdraw attempt fails
      final overdraw = state.deductWallet(999999.0);
      expect(overdraw, isFalse);
    });

    test('Live Charging Simulation increments battery and telemetry', () {
      final state = AppState();
      final active = state.activeBooking;
      expect(active, isNotNull);

      final initialSoc = active!.currentSoc;
      final initialKwh = active.currentDeliveredKwh;
      final initialCost = active.currentCost;

      // Simulate a real-time tick
      state.simulateTick();

      expect(active.currentSoc, greaterThan(initialSoc));
      expect(active.currentDeliveredKwh, greaterThan(initialKwh));
      expect(active.currentCost, greaterThan(initialCost));
    });

    test('Stopping Active Charging Session credits host and moves to completed', () {
      final state = AppState();
      expect(state.activeBooking, isNotNull);

      final initialCompletedCount = state.completedBookings.length;
      final initialEarnings = state.hostMonthlyEarnings;

      state.stopActiveChargingSession();

      expect(state.activeBooking, isNull);
      expect(state.completedBookings.length, initialCompletedCount + 1);
      expect(state.hostMonthlyEarnings, greaterThan(initialEarnings));
      expect(state.hostRecentTransactions.first['driver'], contains('Vikram'));
    });

    test('Host Mode and Bay Online/Offline toggling', () {
      final state = AppState();

      // Toggle host mode
      final initialHostMode = state.hostModeActive;
      state.toggleHostMode(!initialHostMode);
      expect(state.hostModeActive, !initialHostMode);

      // Toggle station online
      state.toggleStationOnline('sharma_villa', false);
      expect(state.selectedStation.isOnline, isFalse);

      state.toggleStationOnline('sharma_villa', true);
      expect(state.selectedStation.isOnline, isTrue);
    });

    test('Host Request Acceptance credits earnings and updates request list', () {
      final state = AppState();
      expect(state.hostRequests.isNotEmpty, isTrue);

      final initialEarnings = state.hostMonthlyEarnings;
      final reqToAccept = state.hostRequests.first;

      state.acceptHostRequest(reqToAccept.id);

      expect(reqToAccept.status, 'accepted');
      expect(state.hostMonthlyEarnings, initialEarnings + reqToAccept.amount);
    });

    test('Host Request Decline removes request from queue', () {
      final state = AppState();
      final initialCount = state.hostRequests.length;
      final reqToDecline = state.hostRequests.first;

      state.declineHostRequest(reqToDecline.id);

      expect(state.hostRequests.length, initialCount - 1);
      expect(state.hostRequests.any((r) => r.id == reqToDecline.id), isFalse);
    });

    test('Vehicle garage management allows switching default and adding cars', () {
      final state = AppState();
      final initialCount = state.vehicles.length;

      // Add car
      final newVehicle = Vehicle(
        id: 'hyundai_ioniq5',
        make: 'Hyundai',
        model: 'Ioniq 5',
        regNumber: 'KA 04 MM 5566',
        batteryCapacityKwh: 72.6,
        currentSoc: 85.0,
        maxAcSpeedKw: 11.0,
        maxDcSpeedKw: 350.0,
      );
      state.addVehicle(newVehicle);
      expect(state.vehicles.length, initialCount + 1);

      // Set default
      state.setDefaultVehicle(newVehicle.id);
      expect(state.defaultVehicle.id, newVehicle.id);
      expect(state.defaultVehicle.make, 'Hyundai');
    });

    test('Host-Driver Chat Messaging dispatches user messages', () {
      final state = AppState();
      final initialMsgCount = state.chatMessages.length;

      state.sendChatMessage('Is your bay available right now?');

      expect(state.chatMessages.length, initialMsgCount + 1);
      expect(state.chatMessages.last['sender'], 'user');
      expect(state.chatMessages.last['text'], 'Is your bay available right now?');
    });
  });
}
