class CulturalObject {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final String origin;
  final String cultureType;
  final String history;
  final double latitude;
  final double longitude;

  CulturalObject({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.origin,
    required this.cultureType,
    required this.history,
    required this.latitude,
    required this.longitude,
  });

  factory CulturalObject.fromJson(Map<String, dynamic> json) {
    return CulturalObject(
      id: json['id'] as String? ?? '', // Provide default empty string if null
      name: json['name'] as String? ?? 'Unnamed Object',
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? 'No description available.',
      origin: json['origin'] as String? ?? 'Unknown origin',
      cultureType: json['cultureType'] as String? ?? 'Unknown culture type',
      history: json['history'] as String? ?? 'No history available.',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0, // Handle num and provide default 0.0
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0, // Handle num and provide default 0.0
    );
  }
}