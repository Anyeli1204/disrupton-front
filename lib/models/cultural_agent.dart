// Modelo de Agente Cultural (de Yeimi)
class CulturalAgent {
  final String id;
  final String name;
  final String imageUrl;
  final String region;
  final String? description;
  final String? expertise;
  final List<String>? specialties;

  CulturalAgent({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.region,
    this.description,
    this.expertise,
    this.specialties,
  });

  factory CulturalAgent.fromJson(Map<String, dynamic> json) {
    return CulturalAgent(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      region: json['region'] ?? 'Unknown',
      description: json['description'],
      expertise: json['expertise'],
      specialties: json['specialties'] != null
          ? List<String>.from(json['specialties'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'region': region,
      'description': description,
      'expertise': expertise,
      'specialties': specialties,
    };
  }
}
