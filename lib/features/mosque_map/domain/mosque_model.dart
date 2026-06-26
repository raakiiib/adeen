class MosqueModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final bool hasWomenSection;
  final bool hasParking;
  final bool hasJummahShifts;
  final Map<String, String> iqamahTimes;
  final int fetchedAt; // Milliseconds timestamp of when this data was fetched

  MosqueModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.hasWomenSection,
    required this.hasParking,
    required this.hasJummahShifts,
    required this.iqamahTimes,
    required this.fetchedAt,
  });

  factory MosqueModel.fromJson(Map<dynamic, dynamic> json) {
    final String id = (json['id'] ?? '').toString();
    final String name = json['name'] as String? ?? 'Mosque';
    
    double lat = 0.0;
    double lng = 0.0;
    if (json.containsKey('lat') && json.containsKey('lon')) {
      lat = (json['lat'] as num).toDouble();
      lng = (json['lon'] as num).toDouble();
    } else if (json.containsKey('center')) {
      final center = json['center'] as Map;
      lat = (center['lat'] as num).toDouble();
      lng = (center['lon'] as num).toDouble();
    } else {
      lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    final times = <String, String>{};
    if (json['iqamahTimes'] != null) {
      (json['iqamahTimes'] as Map).forEach((k, v) {
        times[k.toString()] = v.toString();
      });
    }

    return MosqueModel(
      id: id,
      name: name,
      latitude: lat,
      longitude: lng,
      hasWomenSection: json['hasWomenSection'] as bool? ?? false,
      hasParking: json['hasParking'] as bool? ?? false,
      hasJummahShifts: json['hasJummahShifts'] as bool? ?? false,
      iqamahTimes: times,
      fetchedAt: json['fetchedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'hasWomenSection': hasWomenSection,
      'hasParking': hasParking,
      'hasJummahShifts': hasJummahShifts,
      'iqamahTimes': iqamahTimes,
      'fetchedAt': fetchedAt,
    };
  }

  MosqueModel copyWith({
    String? name,
    bool? hasWomenSection,
    bool? hasParking,
    bool? hasJummahShifts,
    Map<String, String>? iqamahTimes,
    int? fetchedAt,
  }) {
    return MosqueModel(
      id: id,
      name: name ?? this.name,
      latitude: latitude,
      longitude: longitude,
      hasWomenSection: hasWomenSection ?? this.hasWomenSection,
      hasParking: hasParking ?? this.hasParking,
      hasJummahShifts: hasJummahShifts ?? this.hasJummahShifts,
      iqamahTimes: iqamahTimes ?? Map.from(this.iqamahTimes),
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
