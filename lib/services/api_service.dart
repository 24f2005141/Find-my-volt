import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Base URL for the Find My Volt REST API
  /// Defaults to live AWS Free Tier instance in ap-south-2.
  /// Can be overridden at runtime or configured via --dart-define=API_BASE_URL=...
  String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://16.113.152.82/api',
  );

  void setBaseUrl(String url) {
    baseUrl = url.replaceAll(RegExp(r'/+$'), '');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // -------------------------------------------------------------
  // Health
  // -------------------------------------------------------------
  Future<bool> checkHealth() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------
  // Wallet
  // -------------------------------------------------------------
  Future<double?> fetchWalletBalance() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/wallet')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return (data['walletBalance'] as num?)?.toDouble();
      }
    } catch (e) {
      // Graceful offline fallback
    }
    return null;
  }

  Future<double?> topupWallet(double amount) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/wallet/topup'),
            headers: _headers,
            body: json.encode({'amount': amount}),
          )
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return (data['walletBalance'] as num?)?.toDouble();
      }
    } catch (e) {
      // Graceful offline fallback
    }
    return null;
  }

  Future<bool> deductWallet(double amount) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/wallet/deduct'),
            headers: _headers,
            body: json.encode({'amount': amount}),
          )
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // -------------------------------------------------------------
  // Stations
  // -------------------------------------------------------------
  Future<List<ChargerStation>?> fetchStations() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/stations')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => ChargerStation.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Graceful offline fallback
    }
    return null;
  }

  Future<ChargerStation?> createStation(ChargerStation station) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/stations'),
            headers: _headers,
            body: json.encode(station.toJson()),
          )
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return ChargerStation.fromJson(json.decode(res.body));
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateStationOnline(String stationId, bool isOnline) async {
    try {
      final res = await http
          .patch(
            Uri.parse('$baseUrl/stations/$stationId/online'),
            headers: _headers,
            body: json.encode({'isOnline': isOnline}),
          )
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------
  // Vehicles
  // -------------------------------------------------------------
  Future<List<Vehicle>?> fetchVehicles() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/vehicles')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => Vehicle.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<List<Vehicle>?> createVehicle(Vehicle vehicle) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/vehicles'),
            headers: _headers,
            body: json.encode(vehicle.toJson()),
          )
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => Vehicle.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<List<Vehicle>?> setDefaultVehicle(String vehicleId) async {
    try {
      final res = await http
          .patch(
            Uri.parse('$baseUrl/vehicles/$vehicleId/default'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => Vehicle.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return null;
  }

  // -------------------------------------------------------------
  // Bookings
  // -------------------------------------------------------------
  Future<ChargingBooking?> fetchActiveBooking() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/bookings/active')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['booking'] != null) {
          return ChargingBooking.fromJson(data['booking']);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<List<ChargingBooking>?> fetchCompletedBookings() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/bookings/history')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => ChargingBooking.fromJson(item)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<ChargingBooking?> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/bookings'),
            headers: _headers,
            body: json.encode(bookingData),
          )
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return ChargingBooking.fromJson(json.decode(res.body));
      }
    } catch (_) {}
    return null;
  }

  Future<bool> stopActiveBooking(String bookingId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/bookings/stop'),
            headers: _headers,
            body: json.encode({'id': bookingId}),
          )
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateBookingTelemetry(String bookingId, double soc, double kwh, double cost) async {
    try {
      await http
          .patch(
            Uri.parse('$baseUrl/bookings/$bookingId/telemetry'),
            headers: _headers,
            body: json.encode({
              'currentSoc': soc,
              'currentDeliveredKwh': kwh,
              'currentCost': cost,
            }),
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {}
  }

  // -------------------------------------------------------------
  // Host
  // -------------------------------------------------------------
  Future<List<HostRequest>?> fetchHostRequests() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/host/requests')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => HostRequest.fromJson(item)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<List<HostRequest>?> acceptHostRequest(String requestId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/host/requests/$requestId/accept'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => HostRequest.fromJson(item)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<List<HostRequest>?> declineHostRequest(String requestId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/host/requests/$requestId/decline'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => HostRequest.fromJson(item)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> fetchHostEarnings() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/host/earnings')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<List<Map<String, String>>?> fetchTransactions() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/host/transactions')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) {
          return {
            'driver': (item['driver'] ?? '') as String,
            'meta': (item['meta'] ?? '') as String,
            'amount': (item['amount'] ?? '') as String,
          };
        }).toList();
      }
    } catch (_) {}
    return null;
  }

  // -------------------------------------------------------------
  // Chat
  // -------------------------------------------------------------
  Future<List<Map<String, dynamic>>?> fetchChatMessages() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/chat/messages')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<List<Map<String, dynamic>>?> sendChatMessage(String sender, String text, String time) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/chat/messages'),
            headers: _headers,
            body: json.encode({
              'sender': sender,
              'text': text,
              'time': time,
            }),
          )
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (_) {}
    return null;
  }
}
