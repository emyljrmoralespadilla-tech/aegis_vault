class Safehouse {
  final String codename;
  final String sector;
  final double latitude;
  final double longitude;
  final int capacity;
  final bool isCompromised;
  final bool isSelected;


  Safehouse({
    required this.codename,
    required this.sector,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.isCompromised,
    this.isSelected = false,
  });

  Safehouse copyWith({
    String? codename,
    String? sector,
    double? latitude,
    double? longitude,
    int? capacity,
    bool? isCompromised,
    bool? isSelected,
  }) {
    return Safehouse(
      codename: codename ?? this.codename,
      sector: sector ?? this.sector,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capacity: capacity ?? this.capacity,
      isCompromised: isCompromised ?? this.isCompromised,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory Safehouse.fromJson(Map<String, dynamic> json) {
    return Safehouse(
      codename: json['codename'],
      sector: json['sector'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      capacity: json['capacity'],
      isCompromised: json['is_compromised'],
    );
  }
}