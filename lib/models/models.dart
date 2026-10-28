class ChargerStation {
  final String id;
  final String name;
  final String hostName;
  final String hostAvatar;
  final double hostRating;
  final int hostReviews;
  final bool isVerified;
  final bool isSuperhost;
  final String address;
  final String landmark;
  final double distanceKm;
  final int driveTimeMinutes;
  final double powerKw;
  final String connectorType;
  final int tariffPerHour;
  final int parkingFee;
  final String bayType;
  final bool isCovered;
  final bool hasCctv;
  final bool hasWifi;
  final bool isSolar;
  final bool isOpen;
  final String openUntil;
  bool isOnline;
  final List<String> compatibleVehicles;
  final List<String> images;
  final double mapX;
  final double mapY;

  ChargerStation({
    required this.id,
    required this.name,
    required this.hostName,
    required this.hostAvatar,
    required this.hostRating,
    required this.hostReviews,
    this.isVerified = true,
    this.isSuperhost = true,
    required this.address,
    required this.landmark,
    required this.distanceKm,
    required this.driveTimeMinutes,
    required this.powerKw,
    required this.connectorType,
    required this.tariffPerHour,
    this.parkingFee = 0,
    required this.bayType,
    this.isCovered = true,
    this.hasCctv = true,
    this.hasWifi = true,
    this.isSolar = true,
    this.isOpen = true,
    required this.openUntil,
    this.isOnline = true,
    required this.compatibleVehicles,
    required this.images,
    required this.mapX,
    required this.mapY,
  });

  factory ChargerStation.fromJson(Map<String, dynamic> json) {
    return ChargerStation(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      hostName: (json['hostName'] ?? json['host_name']) as String? ?? 'Host',
      hostAvatar: (json['hostAvatar'] ?? json['host_avatar']) as String? ?? '',
      hostRating: ((json['hostRating'] ?? json['host_rating']) as num?)?.toDouble() ?? 4.9,
      hostReviews: ((json['hostReviews'] ?? json['host_reviews']) as num?)?.toInt() ?? 0,
      isVerified: (json['isVerified'] ?? json['is_verified']) == 1 || (json['isVerified'] ?? json['is_verified']) == true,
      isSuperhost: (json['isSuperhost'] ?? json['is_superhost']) == 1 || (json['isSuperhost'] ?? json['is_superhost']) == true,
      address: json['address'] as String? ?? '',
      landmark: json['landmark'] as String? ?? '',
      distanceKm: ((json['distanceKm'] ?? json['distance_km']) as num?)?.toDouble() ?? 1.0,
      driveTimeMinutes: ((json['driveTimeMinutes'] ?? json['drive_time_minutes']) as num?)?.toInt() ?? 5,
      powerKw: ((json['powerKw'] ?? json['power_kw']) as num?)?.toDouble() ?? 7.4,
      connectorType: (json['connectorType'] ?? json['connector_type']) as String? ?? 'Type-2 Gun',
      tariffPerHour: ((json['tariffPerHour'] ?? json['tariff_per_hour']) as num?)?.toInt() ?? 140,
      parkingFee: ((json['parkingFee'] ?? json['parking_fee']) as num?)?.toInt() ?? 0,
      bayType: (json['bayType'] ?? json['bay_type']) as String? ?? 'Stilt Bay',
      isCovered: (json['isCovered'] ?? json['is_covered']) == 1 || (json['isCovered'] ?? json['is_covered']) == true,
      hasCctv: (json['hasCctv'] ?? json['has_cctv']) == 1 || (json['hasCctv'] ?? json['has_cctv']) == true,
      hasWifi: (json['hasWifi'] ?? json['has_wifi']) == 1 || (json['hasWifi'] ?? json['has_wifi']) == true,
      isSolar: (json['isSolar'] ?? json['is_solar']) == 1 || (json['isSolar'] ?? json['is_solar']) == true,
      isOpen: (json['isOpen'] ?? json['is_open']) == 1 || (json['isOpen'] ?? json['is_open']) == true,
      openUntil: (json['openUntil'] ?? json['open_until']) as String? ?? '10:00 PM',
      isOnline: (json['isOnline'] ?? json['is_online']) == 1 || (json['isOnline'] ?? json['is_online']) == true,
      compatibleVehicles: (json['compatibleVehicles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['compatible_vehicles'] is List ? (json['compatible_vehicles'] as List).map((e) => e.toString()).toList() : []),
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      mapX: ((json['mapX'] ?? json['map_x']) as num?)?.toDouble() ?? 0.5,
      mapY: ((json['mapY'] ?? json['map_y']) as num?)?.toDouble() ?? 150.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostName': hostName,
      'hostAvatar': hostAvatar,
      'hostRating': hostRating,
      'hostReviews': hostReviews,
      'isVerified': isVerified,
      'isSuperhost': isSuperhost,
      'address': address,
      'landmark': landmark,
      'distanceKm': distanceKm,
      'driveTimeMinutes': driveTimeMinutes,
      'powerKw': powerKw,
      'connectorType': connectorType,
      'tariffPerHour': tariffPerHour,
      'parkingFee': parkingFee,
      'bayType': bayType,
      'isCovered': isCovered,
      'hasCctv': hasCctv,
      'hasWifi': hasWifi,
      'isSolar': isSolar,
      'isOpen': isOpen,
      'openUntil': openUntil,
      'isOnline': isOnline,
      'compatibleVehicles': compatibleVehicles,
      'images': images,
      'mapX': mapX,
      'mapY': mapY,
    };
  }

  ChargerStation copyWith({
    bool? isOnline,
    int? tariffPerHour,
  }) {
    return ChargerStation(
      id: id,
      name: name,
      hostName: hostName,
      hostAvatar: hostAvatar,
      hostRating: hostRating,
      hostReviews: hostReviews,
      isVerified: isVerified,
      isSuperhost: isSuperhost,
      address: address,
      landmark: landmark,
      distanceKm: distanceKm,
      driveTimeMinutes: driveTimeMinutes,
      powerKw: powerKw,
      connectorType: connectorType,
      tariffPerHour: tariffPerHour ?? this.tariffPerHour,
      parkingFee: parkingFee,
      bayType: bayType,
      isCovered: isCovered,
      hasCctv: hasCctv,
      hasWifi: hasWifi,
      isSolar: isSolar,
      isOpen: isOpen,
      openUntil: openUntil,
      isOnline: isOnline ?? this.isOnline,
      compatibleVehicles: compatibleVehicles,
      images: images,
      mapX: mapX,
      mapY: mapY,
    );
  }
}

class ChargingBooking {
  final String id;
  final String stationId;
  final String stationName;
  final String hostName;
  final String vehicleName;
  final String vehicleReg;
  final DateTime startTime;
  final DateTime endTime;
  final int durationHours;
  final double powerKw;
  final double targetSoc;
  double currentSoc;
  double currentDeliveredKwh;
  double currentCost;
  String status; // 'active', 'completed', 'cancelled'
  final String passCode;
  final String transactionId;

  ChargingBooking({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.hostName,
    required this.vehicleName,
    required this.vehicleReg,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.powerKw,
    required this.targetSoc,
    required this.currentSoc,
    required this.currentDeliveredKwh,
    required this.currentCost,
    this.status = 'active',
    required this.passCode,
    required this.transactionId,
  });

  factory ChargingBooking.fromJson(Map<String, dynamic> json) {
    return ChargingBooking(
      id: json['id'] as String? ?? '',
      stationId: (json['stationId'] ?? json['station_id']) as String? ?? '',
      stationName: (json['stationName'] ?? json['station_name']) as String? ?? 'Charging Station',
      hostName: (json['hostName'] ?? json['host_name']) as String? ?? 'Host',
      vehicleName: (json['vehicleName'] ?? json['vehicle_name']) as String? ?? 'EV',
      vehicleReg: (json['vehicleReg'] ?? json['vehicle_reg']) as String? ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? json['start_time'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? json['end_time'] ?? '') ?? DateTime.now().add(const Duration(hours: 2)),
      durationHours: ((json['durationHours'] ?? json['duration_hours']) as num?)?.toInt() ?? 2,
      powerKw: ((json['powerKw'] ?? json['power_kw']) as num?)?.toDouble() ?? 7.4,
      targetSoc: ((json['targetSoc'] ?? json['target_soc']) as num?)?.toDouble() ?? 80.0,
      currentSoc: ((json['currentSoc'] ?? json['current_soc']) as num?)?.toDouble() ?? 60.0,
      currentDeliveredKwh: ((json['currentDeliveredKwh'] ?? json['current_delivered_kwh']) as num?)?.toDouble() ?? 0.0,
      currentCost: ((json['currentCost'] ?? json['current_cost']) as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'active',
      passCode: (json['passCode'] ?? json['pass_code']) as String? ?? '#0000',
      transactionId: (json['transactionId'] ?? json['transaction_id']) as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stationId': stationId,
      'stationName': stationName,
      'hostName': hostName,
      'vehicleName': vehicleName,
      'vehicleReg': vehicleReg,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationHours': durationHours,
      'powerKw': powerKw,
      'targetSoc': targetSoc,
      'currentSoc': currentSoc,
      'currentDeliveredKwh': currentDeliveredKwh,
      'currentCost': currentCost,
      'status': status,
      'passCode': passCode,
      'transactionId': transactionId,
    };
  }

  ChargingBooking copyWith({
    double? currentSoc,
    double? currentDeliveredKwh,
    double? currentCost,
    String? status,
  }) {
    return ChargingBooking(
      id: id,
      stationId: stationId,
      stationName: stationName,
      hostName: hostName,
      vehicleName: vehicleName,
      vehicleReg: vehicleReg,
      startTime: startTime,
      endTime: endTime,
      durationHours: durationHours,
      powerKw: powerKw,
      targetSoc: targetSoc,
      currentSoc: currentSoc ?? this.currentSoc,
      currentDeliveredKwh: currentDeliveredKwh ?? this.currentDeliveredKwh,
      currentCost: currentCost ?? this.currentCost,
      status: status ?? this.status,
      passCode: passCode,
      transactionId: transactionId,
    );
  }
}

class Vehicle {
  final String id;
  final String make;
  final String model;
  final String regNumber;
  final double batteryCapacityKwh;
  double currentSoc;
  final double maxAcSpeedKw;
  final double maxDcSpeedKw;
  bool isDefault;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.regNumber,
    required this.batteryCapacityKwh,
    required this.currentSoc,
    required this.maxAcSpeedKw,
    required this.maxDcSpeedKw,
    this.isDefault = false,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      regNumber: (json['regNumber'] ?? json['reg_number']) as String? ?? '',
      batteryCapacityKwh: ((json['batteryCapacityKwh'] ?? json['battery_capacity_kwh']) as num?)?.toDouble() ?? 50.0,
      currentSoc: ((json['currentSoc'] ?? json['current_soc']) as num?)?.toDouble() ?? 70.0,
      maxAcSpeedKw: ((json['maxAcSpeedKw'] ?? json['max_ac_speed_kw']) as num?)?.toDouble() ?? 7.4,
      maxDcSpeedKw: ((json['maxDcSpeedKw'] ?? json['max_dc_speed_kw']) as num?)?.toDouble() ?? 50.0,
      isDefault: (json['isDefault'] ?? json['is_default']) == 1 || (json['isDefault'] ?? json['is_default']) == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'regNumber': regNumber,
      'batteryCapacityKwh': batteryCapacityKwh,
      'currentSoc': currentSoc,
      'maxAcSpeedKw': maxAcSpeedKw,
      'maxDcSpeedKw': maxDcSpeedKw,
      'isDefault': isDefault,
    };
  }
}

class HostRequest {
  final String id;
  final String driverName;
  final String driverAvatar;
  final String vehicleModel;
  final String slotTime;
  final int durationHours;
  final int amount;
  String status; // 'pending', 'accepted', 'declined'

  HostRequest({
    required this.id,
    required this.driverName,
    required this.driverAvatar,
    required this.vehicleModel,
    required this.slotTime,
    required this.durationHours,
    required this.amount,
    this.status = 'pending',
  });

  factory HostRequest.fromJson(Map<String, dynamic> json) {
    return HostRequest(
      id: json['id'] as String? ?? '',
      driverName: (json['driverName'] ?? json['driver_name']) as String? ?? 'Driver',
      driverAvatar: (json['driverAvatar'] ?? json['driver_avatar']) as String? ?? '',
      vehicleModel: (json['vehicleModel'] ?? json['vehicle_model']) as String? ?? 'EV Model',
      slotTime: (json['slotTime'] ?? json['slot_time']) as String? ?? '',
      durationHours: ((json['durationHours'] ?? json['duration_hours']) as num?)?.toInt() ?? 2,
      amount: ((json['amount']) as num?)?.toInt() ?? 280,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverName': driverName,
      'driverAvatar': driverAvatar,
      'vehicleModel': vehicleModel,
      'slotTime': slotTime,
      'durationHours': durationHours,
      'amount': amount,
      'status': status,
    };
  }
}
