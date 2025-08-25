class CulturalAgent {
  final String id;
  final String name;
  final String imageUrl;
  final String region;

  CulturalAgent({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.region,
  });

  factory CulturalAgent.fromJson(Map<String, dynamic> json) {
    return CulturalAgent(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      region: json['region'] ?? 'Unknown',
    );
  }
}