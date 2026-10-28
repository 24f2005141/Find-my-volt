import '../../models/models.dart';
import '../../services/api_service.dart';

class AppRepository {
  final ApiService _api = ApiService();

  // --- Initial Data Sync ---
  Future<List<ChargerStation>?> getStations() async {
    return await _api.fetchStations();
  }

  Future<ChargerStation?> addStation(ChargerStation station) async {
    return await _api.createStation(station);
  }

  Future<bool> setStationOnline(String stationId, bool isOnline) async {
    return await _api.updateStationOnline(stationId, isOnline);
  }

  // --- Vehicles ---
  Future<List<Vehicle>?> getVehicles() async {
    return await _api.fetchVehicles();
  }

  Future<List<Vehicle>?> addVehicle(Vehicle vehicle) async {
    return await _api.createVehicle(vehicle);
  }

  Future<List<Vehicle>?> setDefaultVehicle(String vehicleId) async {
    return await _api.setDefaultVehicle(vehicleId);
  }

  // --- Wallet ---
  Future<double?> getWalletBalance() async {
    return await _api.fetchWalletBalance();
  }

  Future<double?> topupWallet(double amount) async {
    return await _api.topupWallet(amount);
  }

  Future<bool> deductWallet(double amount) async {
    return await _api.deductWallet(amount);
  }

  // --- Bookings ---
  Future<ChargingBooking?> getActiveBooking() async {
    return await _api.fetchActiveBooking();
  }

  Future<List<ChargingBooking>?> getCompletedBookings() async {
    return await _api.fetchCompletedBookings();
  }

  Future<ChargingBooking?> createBooking(Map<String, dynamic> bookingData) async {
    return await _api.createBooking(bookingData);
  }

  Future<bool> stopActiveBooking(String bookingId) async {
    return await _api.stopActiveBooking(bookingId);
  }

  Future<void> updateTelemetry(String bookingId, double soc, double kwh, double cost) async {
    await _api.updateBookingTelemetry(bookingId, soc, kwh, cost);
  }

  // --- Host ---
  Future<List<HostRequest>?> getHostRequests() async {
    return await _api.fetchHostRequests();
  }

  Future<List<HostRequest>?> acceptHostRequest(String requestId) async {
    return await _api.acceptHostRequest(requestId);
  }

  Future<List<HostRequest>?> declineHostRequest(String requestId) async {
    return await _api.declineHostRequest(requestId);
  }

  Future<Map<String, dynamic>?> getHostEarnings() async {
    return await _api.fetchHostEarnings();
  }

  Future<List<Map<String, String>>?> getTransactions() async {
    return await _api.fetchTransactions();
  }

  // --- Chat ---
  Future<List<Map<String, dynamic>>?> getChatMessages() async {
    return await _api.fetchChatMessages();
  }

  Future<List<Map<String, dynamic>>?> sendChatMessage(String sender, String text, String time) async {
    return await _api.sendChatMessage(sender, text, time);
  }
}
