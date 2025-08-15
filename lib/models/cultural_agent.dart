class CulturalAgent {
  final String id;
  final String name;
  final String description;
  final String category; // ARTISAN, GUIDE, CULTURAL_EXPERT
  final String? imageUrl;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? region;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String> specialties;
  final List<String> languages;
  final double? rating;
  final int reviewCount;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final String? userId;
  final Map<String, dynamic>? additionalInfo;

  CulturalAgent({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl,
    this.phoneNumber,
    this.email,
    this.website,
    this.region,
    this.address,
    this.latitude,
    this.longitude,
    this.specialties = const [],
    this.languages = const [],
    this.rating,
    this.reviewCount = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.lastUpdated,
    this.userId,
    this.additionalInfo,
  });

  factory CulturalAgent.fromJson(Map<String, dynamic> json) {
    return CulturalAgent(
      id: json['id'] ?? json['collaboratorId'] ?? '',
      name: json['name'] ?? json['fullName'] ?? '',
      description: json['description'] ?? json['bio'] ?? '',
      category: json['category'] ?? json['type'] ?? 'CULTURAL_EXPERT',
      imageUrl: json['imageUrl'] ?? json['profileImageUrl'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      website: json['website'],
      region: json['region'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      specialties: json['specialties'] != null 
          ? List<String>.from(json['specialties'])
          : [],
      languages: json['languages'] != null 
          ? List<String>.from(json['languages'])
          : [],
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'].toString())
          : null,
      userId: json['userId'] ?? json['createdBy'],
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'region': region,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'specialties': specialties,
      'languages': languages,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'userId': userId,
      'additionalInfo': additionalInfo,
    };
  }

  CulturalAgent copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    String? phoneNumber,
    String? email,
    String? website,
    String? region,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? specialties,
    List<String>? languages,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? userId,
    Map<String, dynamic>? additionalInfo,
  }) {
    return CulturalAgent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      region: region ?? this.region,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      specialties: specialties ?? this.specialties,
      languages: languages ?? this.languages,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userId: userId ?? this.userId,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}

