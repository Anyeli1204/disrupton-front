// Modelo de Agente Cultural - Versión Expandida
class CulturalAgent {
  final String id;
  final String name;
  final String imageUrl;
  final String region;
  final String? description;
  final String? expertise;
  final List<String>? specialties;
  final AgentType type;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final double? rating;
  final int? totalRatings;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<String>? workPhotos;
  final bool isActive;
  final String? department;
  final String? province;
  final String? district;

  CulturalAgent({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.region,
    required this.type,
    this.description,
    this.expertise,
    this.specialties,
    this.phone,
    this.whatsapp,
    this.email,
    this.rating,
    this.totalRatings,
    this.location,
    this.latitude,
    this.longitude,
    this.workPhotos,
    this.isActive = true,
    this.department,
    this.province,
    this.district,
  });

  // Getters de conveniencia
  String get primaryContact => whatsapp ?? phone ?? '';
  String get typeIcon => type == AgentType.artisan ? '🎨' : '🗺️';
  String get typeLabel =>
      type == AgentType.artisan ? 'Artesano' : 'Guía Turístico';
  String get formattedRating =>
      rating != null ? '⭐ ${rating!.toStringAsFixed(1)}' : '';
  String get fullLocation => location ?? '$district, $province';

  factory CulturalAgent.fromJson(Map<String, dynamic> json) {
    return CulturalAgent(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      region: json['region'] ?? 'Unknown',
      type: _parseAgentType(json['type']),
      description: json['description'],
      expertise: json['expertise'],
      specialties: _parseStringList(json['specialties']),
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      email: json['email'],
      rating: json['rating']?.toDouble(),
      totalRatings: json['totalRatings'],
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      workPhotos: _parseStringList(json['workPhotos']),
      isActive: json['isActive'] ?? true,
      department: json['department'],
      province: json['province'],
      district: json['district'],
    );
  }

  static AgentType _parseAgentType(dynamic typeValue) {
    if (typeValue == null) return AgentType.artisan;

    String typeStr = typeValue.toString().toUpperCase();

    switch (typeStr) {
      case 'ARTISAN':
        return AgentType.artisan;
      case 'TOURIST_GUIDE':
      case 'GUIDE':
        return AgentType.guide;
      default:
        return AgentType.artisan;
    }
  }

  static List<String>? _parseStringList(dynamic listValue) {
    if (listValue == null) return null;
    if (listValue is List) {
      return listValue
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'region': region,
      'type': type.toString().split('.').last,
      'description': description,
      'expertise': expertise,
      'specialties': specialties,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'rating': rating,
      'totalRatings': totalRatings,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'workPhotos': workPhotos,
      'isActive': isActive,
      'department': department,
      'province': province,
      'district': district,
    };
  }
}

enum AgentType {
  artisan,
  guide,
}
