import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/repositories/app_repository.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;

  final AppRepository _repository = AppRepository();

  AppState._internal() {
    _initDefaultData();
    _startRealtimeChargingSimulation();
    syncFromBackend();
  }

  // --- Real-time Stations State ---
  late List<ChargerStation> _stations;
  List<ChargerStation> get stations => _stations;

  String _selectedStationId = 'sharma_villa';
  String get selectedStationId => _selectedStationId;

  ChargerStation get selectedStation {
    return _stations.firstWhere(
      (s) => s.id == _selectedStationId,
      orElse: () => _stations.first,
    );
  }

  void selectStation(String id) {
    if (_stations.any((s) => s.id == id)) {
      _selectedStationId = id;
      notifyListeners();
    }
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedFilter = 'All (24)';
  String get selectedFilter => _selectedFilter;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<ChargerStation> get filteredStations {
    return _stations.where((station) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = station.name.toLowerCase().contains(q);
        final matchesAddress = station.address.toLowerCase().contains(q);
        final matchesConnector = station.connectorType.toLowerCase().contains(q);
        if (!matchesName && !matchesAddress && !matchesConnector) return false;
      }

      if (_selectedFilter == 'Home P2P' && !station.name.contains('P2P') && !station.name.contains('Resident')) {
        return false;
      }
      if (_selectedFilter == 'CCS2 60kW+' && station.powerKw < 60) {
        return false;
      }
      if (_selectedFilter == 'Type 2 AC' && !station.connectorType.contains('Type-2') && !station.connectorType.contains('Type 2')) {
        return false;
      }
      if (_selectedFilter == '< ₹160/hr' && station.tariffPerHour >= 160) {
        return false;
      }

      return true;
    }).toList();
  }

  // --- Real-time Vehicles & Garage State ---
  late List<Vehicle> _vehicles;
  List<Vehicle> get vehicles => _vehicles;

  Vehicle get defaultVehicle => _vehicles.firstWhere((v) => v.isDefault, orElse: () => _vehicles.first);

  void setDefaultVehicle(String id) {
    for (var v in _vehicles) {
      v.isDefault = (v.id == id);
    }
    notifyListeners();
    _repository.setDefaultVehicle(id);
  }

  void addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
    notifyListeners();
    _repository.addVehicle(vehicle);
  }

  // --- Real-time Wallet State ---
  double _walletBalance = 1450.0;
  double get walletBalance => _walletBalance;

  void topUpWallet(double amount) {
    _walletBalance += amount;
    notifyListeners();
    _repository.topupWallet(amount);
  }

  bool deductWallet(double amount) {
    if (_walletBalance >= amount) {
      _walletBalance -= amount;
      notifyListeners();
      _repository.deductWallet(amount);
      return true;
    }
    return false;
  }

  // --- Real-time Bookings & Active Session ---
  ChargingBooking? _activeBooking;
  ChargingBooking? get activeBooking => _activeBooking;

  final List<ChargingBooking> _completedBookings = [];
  List<ChargingBooking> get completedBookings => List.unmodifiable(_completedBookings);

  final List<ChargingBooking> _cancelledBookings = [];
  List<ChargingBooking> get cancelledBookings => List.unmodifiable(_cancelledBookings);

  static bool enableRealtimeTimer = true;
  Timer? _chargingTimer;
  int _telemetryTickCount = 0;

  void startSimulation() {
    _startRealtimeChargingSimulation();
  }

  void stopSimulation() {
    _chargingTimer?.cancel();
    _chargingTimer = null;
  }

  void simulateTick() {
    if (_activeBooking != null && _activeBooking!.status == 'active') {
      if (_activeBooking!.currentSoc < _activeBooking!.targetSoc) {
        _activeBooking!.currentSoc += 0.25;
        _activeBooking!.currentDeliveredKwh += 0.04;
        _activeBooking!.currentCost += 0.78;
        notifyListeners();

        _telemetryTickCount++;
        if (_telemetryTickCount % 5 == 0) {
          _repository.updateTelemetry(
            _activeBooking!.id,
            _activeBooking!.currentSoc,
            _activeBooking!.currentDeliveredKwh,
            _activeBooking!.currentCost,
          );
        }
      }
    }
  }

  void _startRealtimeChargingSimulation() {
    _chargingTimer?.cancel();
    if (!enableRealtimeTimer) return;
    _chargingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      simulateTick();
    });
  }

  void createBooking({
    required String stationId,
    required String stationName,
    required String hostName,
    required String vehicleName,
    required String vehicleReg,
    required int durationHours,
    required double powerKw,
    required double totalAmount,
  }) {
    deductWallet(totalAmount);

    final newBooking = ChargingBooking(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch % 10000}',
      stationId: stationId,
      stationName: stationName,
      hostName: hostName,
      vehicleName: vehicleName,
      vehicleReg: vehicleReg,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: durationHours)),
      durationHours: durationHours,
      powerKw: powerKw,
      targetSoc: 85.0,
      currentSoc: 68.0,
      currentDeliveredKwh: 0.1,
      currentCost: totalAmount,
      status: 'active',
      passCode: '#${1000 + (DateTime.now().millisecond % 9000)}',
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
    );

    _activeBooking = newBooking;
    notifyListeners();

    _repository.createBooking({
      ...newBooking.toJson(),
      'totalAmount': totalAmount,
    });
  }

  void stopActiveChargingSession() {
    if (_activeBooking != null) {
      final stoppingId = _activeBooking!.id;
      _activeBooking!.status = 'completed';
      _completedBookings.insert(0, _activeBooking!);

      // Also credit host revenue
      _hostMonthlyEarnings += _activeBooking!.currentCost;
      _hostTotalSessions += 1;
      _hostRecentTransactions.insert(0, {
        'driver': 'Vikram R. • ${_activeBooking!.vehicleName}',
        'meta': 'Today • ${_activeBooking!.durationHours} hrs • ${_activeBooking!.currentDeliveredKwh.toStringAsFixed(1)} kWh',
        'amount': '₹${_activeBooking!.currentCost.toStringAsFixed(0)}.00',
      });

      _activeBooking = null;
      notifyListeners();

      _repository.stopActiveBooking(stoppingId);
    }
  }

  // --- Real-time Host Mode State ---
  bool _hostModeActive = true;
  bool get hostModeActive => _hostModeActive;

  void toggleHostMode(bool active) {
    _hostModeActive = active;
    notifyListeners();
  }

  double _hostMonthlyEarnings = 18420.0;
  double get hostMonthlyEarnings => _hostMonthlyEarnings;

  int _hostTotalSessions = 142;
  int get hostTotalSessions => _hostTotalSessions;

  final double _hostRating = 4.94;
  double get hostRating => _hostRating;

  late List<HostRequest> _hostRequests;
  List<HostRequest> get hostRequests => _hostRequests;

  void acceptHostRequest(String id) {
    final req = _hostRequests.firstWhere((r) => r.id == id);
    req.status = 'accepted';
    _hostTotalSessions += 1;
    _hostMonthlyEarnings += req.amount;
    notifyListeners();
    _repository.acceptHostRequest(id);
  }

  void declineHostRequest(String id) {
    final req = _hostRequests.firstWhere((r) => r.id == id);
    req.status = 'declined';
    _hostRequests.remove(req);
    notifyListeners();
    _repository.declineHostRequest(id);
  }

  void toggleStationOnline(String stationId, bool online) {
    final index = _stations.indexWhere((s) => s.id == stationId);
    if (index != -1) {
      _stations[index] = _stations[index].copyWith(isOnline: online);
      notifyListeners();
      _repository.setStationOnline(stationId, online);
    }
  }

  void addHostStation(ChargerStation station) {
    _stations.insert(0, station);
    _selectedStationId = station.id;
    notifyListeners();
    _repository.addStation(station);
  }

  final List<Map<String, String>> _hostRecentTransactions = [
    {
      'driver': 'Vikram R. • Tata Nexon EV Max',
      'meta': 'Today, 28 Oct • 12:00 - 02:00 PM',
      'amount': '₹280.00',
    },
    {
      'driver': 'Priya S. • MG ZS EV',
      'meta': 'Yesterday, 27 Oct • 2h 15m',
      'amount': '₹310.00',
    },
    {
      'driver': 'Anand K. • Mahindra XUV400',
      'meta': '26 Oct 2026 • 1h 45m',
      'amount': '₹260.00',
    },
    {
      'driver': 'Ramesh N. • Tata Punch EV',
      'meta': '25 Oct 2026 • 1h 00m',
      'amount': '₹140.00',
    },
  ];
  List<Map<String, String>> get hostRecentTransactions => _hostRecentTransactions;

  // --- Real-time Chat with Host ---
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'sender': 'host',
      'text': 'Hello Vikram! Welcome to Sharma Villa. The stilt bay gate opens automatically with your pass code.',
      'time': '11:45 AM',
    },
  ];
  List<Map<String, dynamic>> get chatMessages => _chatMessages;

  void sendChatMessage(String text) {
    _chatMessages.add({
      'sender': 'user',
      'text': text,
      'time': 'Just now',
    });
    notifyListeners();
    _repository.sendChatMessage('user', text, 'Just now');

    // Simulated real-time Host Response after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      final hostReply = 'Got it! I am home right now. Feel free to plug in and let me know if you need any assistance with the cable.';
      _chatMessages.add({
        'sender': 'host',
        'text': hostReply,
        'time': 'Just now',
      });
      notifyListeners();
      _repository.sendChatMessage('host', hostReply, 'Just now');
    });
  }

  // --- Synchronization with Backend SQLite REST API ---
  Future<void> syncFromBackend() async {
    try {
      // 1. Sync wallet
      final remoteWallet = await _repository.getWalletBalance();
      if (remoteWallet != null) {
        _walletBalance = remoteWallet;
      }

      // 2. Sync stations
      final remoteStations = await _repository.getStations();
      if (remoteStations != null && remoteStations.isNotEmpty) {
        _stations = remoteStations;
      }

      // 3. Sync vehicles
      final remoteVehicles = await _repository.getVehicles();
      if (remoteVehicles != null && remoteVehicles.isNotEmpty) {
        _vehicles = remoteVehicles;
      }

      // 4. Sync active booking
      final remoteActive = await _repository.getActiveBooking();
      if (remoteActive != null) {
        _activeBooking = remoteActive;
      }

      // 5. Sync completed bookings
      final remoteCompleted = await _repository.getCompletedBookings();
      if (remoteCompleted != null && remoteCompleted.isNotEmpty) {
        _completedBookings.clear();
        _completedBookings.addAll(remoteCompleted);
      }

      // 6. Sync host requests
      final remoteReqs = await _repository.getHostRequests();
      if (remoteReqs != null && remoteReqs.isNotEmpty) {
        _hostRequests = remoteReqs;
      }

      // 7. Sync host earnings
      final remoteEarnings = await _repository.getHostEarnings();
      if (remoteEarnings != null) {
        _hostMonthlyEarnings = (remoteEarnings['monthlyEarnings'] as num?)?.toDouble() ?? _hostMonthlyEarnings;
        _hostTotalSessions = (remoteEarnings['totalSessions'] as num?)?.toInt() ?? _hostTotalSessions;
      }

      // 8. Sync transactions
      final remoteTx = await _repository.getTransactions();
      if (remoteTx != null && remoteTx.isNotEmpty) {
        _hostRecentTransactions.clear();
        _hostRecentTransactions.addAll(remoteTx);
      }

      // 9. Sync chat
      final remoteChat = await _repository.getChatMessages();
      if (remoteChat != null && remoteChat.isNotEmpty) {
        _chatMessages.clear();
        _chatMessages.addAll(remoteChat);
      }

      notifyListeners();
    } catch (_) {
      // Graceful offline fallback maintains in-memory seed dataset
    }
  }

  void _initDefaultData() {
    _stations = [
      ChargerStation(
        id: 'sharma_villa',
        name: 'Sharma Villa P2P Charger',
        hostName: 'Rajesh Sharma',
        hostAvatar:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuA9GvFZmwZhc4TjcwSkuatG7pJPgjmrce8IAYN4d2LeLpWFIBnfZa06KGvCT5oczJi4hEX_PIh4L6BtRoUCTTYl-7YLnDrvhHUCCoZpI1wzOwq0CdiR5zOj2rQRw48VrKPslnZzw4Y1EVC8oOryhtD5AtcNN-VHVcyZiTB-A2zaCPbJ79pRyaWoRfGwMMpU0HwHqMy-oG9ElcvGNvT9QDmqa8tUjt8QKqiFI-zOWQ8',
        hostRating: 4.9,
        hostReviews: 42,
        address: '12th Main Road, HAL 2nd Stage, Indiranagar',
        landmark: 'Near Toit Brewpub & 100ft Rd Metro',
        distanceKm: 1.2,
        driveTimeMinutes: 6,
        powerKw: 7.4,
        connectorType: 'Type-2 Gun',
        tariffPerHour: 140,
        parkingFee: 0,
        bayType: 'Stilt Bay',
        isCovered: true,
        hasCctv: true,
        hasWifi: true,
        isSolar: true,
        isOpen: true,
        openUntil: '4:30 PM',
        isOnline: true,
        compatibleVehicles: ['Tata Nexon EV', 'Punch EV', 'MG ZS EV', 'Mahindra XUV400', 'Hyundai Ioniq 5'],
        images: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCCa9t426l29JFAyMQC0VWVGrqh1R0lL08jZdECr_PtpPJHprWlqI5eNGxZMW9mjx-WKOuIp1Ya4YF_puGs13LHGps9KGaCGJHLHz6sTnx2eLwspJkZMHiYuP5BDO-dkOEUgcgKlFQlGp_OQy3IQfAGza_nSPums4XJer0jVAfaZ24NUHh_di6sYCqTUkdmzcnzF2nZfh5_3ofRfYdJv6o-ssjniseDRps_bRPn23c',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAI0WXa5DWs_h4SwSSBmwj6ZCJLHyqW1oNYcq3_FpQ7sAa2aV-h63ypIVnO1vNhlwmdiz4rDbENXMaI47oHkpqSfc3uyj0EK4k2aTFtDqpqJ8XtgpDw-1X_9cpGMS1I-J44RkncCpeNJi-EUylp77sKwp0CggKbAzP2AsvHDInslfRYWk3vml9MGE1lXLVIYQIQHkiMQQvWzoTaBm-_j8QwUpO7Uz8mqH580pQIWjM',
        ],
        mapX: 0.52,
        mapY: 180,
      ),
      ChargerStation(
        id: 'nexus',
        name: 'Nexus Mall DC Fast Hub',
        hostName: 'Nexus Retail Network',
        hostAvatar: '',
        hostRating: 4.8,
        hostReviews: 128,
        address: 'Koramangala 1st Block, 80ft Road',
        landmark: 'Opposite Forum Plaza',
        distanceKm: 2.4,
        driveTimeMinutes: 11,
        powerKw: 60.0,
        connectorType: 'CCS2 Dual Gun',
        tariffPerHour: 220,
        parkingFee: 30,
        bayType: 'Basement Fast Bay',
        isCovered: true,
        hasCctv: true,
        hasWifi: true,
        isSolar: false,
        isOpen: true,
        openUntil: '11:00 PM',
        isOnline: true,
        compatibleVehicles: ['All CCS2 EVs', 'Tata', 'MG', 'Hyundai', 'BYD', 'Kia'],
        images: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCCa9t426l29JFAyMQC0VWVGrqh1R0lL08jZdECr_PtpPJHprWlqI5eNGxZMW9mjx-WKOuIp1Ya4YF_puGs13LHGps9KGaCGJHLHz6sTnx2eLwspJkZMHiYuP5BDO-dkOEUgcgKlFQlGp_OQy3IQfAGza_nSPums4XJer0jVAfaZ24NUHh_di6sYCqTUkdmzcnzF2nZfh5_3ofRfYdJv6o-ssjniseDRps_bRPn23c',
        ],
        mapX: 0.22,
        mapY: 130,
      ),
      ChargerStation(
        id: 'koramangala',
        name: 'Koramangala Community Charger',
        hostName: 'Suresh Patel',
        hostAvatar: '',
        hostRating: 4.7,
        hostReviews: 29,
        address: '4th Block, 14th Main, Koramangala',
        landmark: 'Near Wipro Park',
        distanceKm: 3.1,
        driveTimeMinutes: 14,
        powerKw: 11.0,
        connectorType: 'Type-2 Gun',
        tariffPerHour: 150,
        parkingFee: 0,
        bayType: 'Driveway Bay',
        isCovered: true,
        hasCctv: true,
        hasWifi: true,
        isSolar: true,
        isOpen: true,
        openUntil: '9:00 PM',
        isOnline: true,
        compatibleVehicles: ['Tata Nexon EV', 'MG ZS EV', 'Mahindra XUV400'],
        images: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAI0WXa5DWs_h4SwSSBmwj6ZCJLHyqW1oNYcq3_FpQ7sAa2aV-h63ypIVnO1vNhlwmdiz4rDbENXMaI47oHkpqSfc3uyj0EK4k2aTFtDqpqJ8XtgpDw-1X_9cpGMS1I-J44RkncCpeNJi-EUylp77sKwp0CggKbAzP2AsvHDInslfRYWk3vml9MGE1lXLVIYQIQHkiMQQvWzoTaBm-_j8QwUpO7Uz8mqH580pQIWjM',
        ],
        mapX: 0.78,
        mapY: 100,
      ),
      ChargerStation(
        id: 'prestige_ozone',
        name: 'Prestige Ozone Resident P2P',
        hostName: 'Anita Krishnan',
        hostAvatar: '',
        hostRating: 4.9,
        hostReviews: 18,
        address: 'Whitefield Main Road, Palm Meadows',
        landmark: 'Near Forum Shantiniketan',
        distanceKm: 4.1,
        driveTimeMinutes: 18,
        powerKw: 11.0,
        connectorType: 'Type-2 Gun',
        tariffPerHour: 120,
        parkingFee: 0,
        bayType: 'Villa Carport',
        isCovered: true,
        hasCctv: true,
        hasWifi: true,
        isSolar: true,
        isOpen: true,
        openUntil: '8:00 PM',
        isOnline: true,
        compatibleVehicles: ['Tata Nexon EV', 'Punch EV', 'MG ZS EV', 'Kia EV6'],
        images: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCCa9t426l29JFAyMQC0VWVGrqh1R0lL08jZdECr_PtpPJHprWlqI5eNGxZMW9mjx-WKOuIp1Ya4YF_puGs13LHGps9KGaCGJHLHz6sTnx2eLwspJkZMHiYuP5BDO-dkOEUgcgKlFQlGp_OQy3IQfAGza_nSPums4XJer0jVAfaZ24NUHh_di6sYCqTUkdmzcnzF2nZfh5_3ofRfYdJv6o-ssjniseDRps_bRPn23c',
        ],
        mapX: 0.85,
        mapY: 280,
      ),
    ];

    _vehicles = [
      Vehicle(
        id: 'nexon_ev',
        make: 'Tata',
        model: 'Nexon EV Max',
        regNumber: 'KA 03 NA 4120',
        batteryCapacityKwh: 40.5,
        currentSoc: 68.0,
        maxAcSpeedKw: 7.2,
        maxDcSpeedKw: 50.0,
        isDefault: true,
      ),
      Vehicle(
        id: 'mg_zs_ev',
        make: 'MG',
        model: 'ZS EV Excite',
        regNumber: 'KA 01 MJ 8892',
        batteryCapacityKwh: 50.3,
        currentSoc: 82.0,
        maxAcSpeedKw: 7.4,
        maxDcSpeedKw: 50.0,
        isDefault: false,
      ),
    ];

    _activeBooking = ChargingBooking(
      id: 'BK-8492',
      stationId: 'sharma_villa',
      stationName: 'Sharma Villa P2P Charger',
      hostName: 'Rajesh Sharma',
      vehicleName: 'Tata Nexon EV Max',
      vehicleReg: 'KA 03 NA 4120',
      startTime: DateTime.now().subtract(const Duration(minutes: 36)),
      endTime: DateTime.now().add(const Duration(minutes: 84)),
      durationHours: 2,
      powerKw: 7.2,
      targetSoc: 80.0,
      currentSoc: 62.0,
      currentDeliveredKwh: 9.6,
      currentCost: 182.0,
      status: 'active',
      passCode: '#8492',
      transactionId: 'TXN891240',
    );

    _completedBookings.addAll([
      ChargingBooking(
        id: 'BK-7120',
        stationId: 'koramangala',
        stationName: 'Koramangala 4th Block P2P',
        hostName: 'Suresh Patel',
        vehicleName: 'Tata Nexon EV Max',
        vehicleReg: 'KA 03 NA 4120',
        startTime: DateTime.now().subtract(const Duration(days: 10)),
        endTime: DateTime.now().subtract(const Duration(days: 10, hours: -2)),
        durationHours: 2,
        powerKw: 7.4,
        targetSoc: 100.0,
        currentSoc: 100.0,
        currentDeliveredKwh: 18.2,
        currentCost: 245.0,
        status: 'completed',
        passCode: '#7120',
        transactionId: 'TXN771029',
      ),
      ChargingBooking(
        id: 'BK-6510',
        stationId: 'nexus',
        stationName: 'Indiranagar Metro Hub (Fast DC)',
        hostName: 'Metro EV Network',
        vehicleName: 'Tata Nexon EV Max',
        vehicleReg: 'KA 03 NA 4120',
        startTime: DateTime.now().subtract(const Duration(days: 16)),
        endTime: DateTime.now().subtract(const Duration(days: 16, minutes: -35)),
        durationHours: 1,
        powerKw: 50.0,
        targetSoc: 80.0,
        currentSoc: 80.0,
        currentDeliveredKwh: 24.5,
        currentCost: 412.0,
        status: 'completed',
        passCode: '#6510',
        transactionId: 'TXN660142',
      ),
    ]);

    _hostRequests = [
      HostRequest(
        id: 'REQ-1',
        driverName: 'Rahul Verma',
        driverAvatar: '',
        vehicleModel: 'Tata Nexon EV',
        slotTime: 'Today, 4:00 PM - 6:00 PM',
        durationHours: 2,
        amount: 280,
      ),
      HostRequest(
        id: 'REQ-2',
        driverName: 'Sneha Rao',
        driverAvatar: '',
        vehicleModel: 'MG ZS EV',
        slotTime: 'Tomorrow, 11:00 AM - 1:00 PM',
        durationHours: 2,
        amount: 280,
      ),
    ];
  }

  @override
  void dispose() {
    _chargingTimer?.cancel();
    super.dispose();
  }
}
