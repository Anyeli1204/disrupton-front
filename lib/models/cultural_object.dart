import 'package:cloud_firestore/cloud_firestore.dart';

class CulturalObject {
  final String objectId;
  final String name;
  final String description;
  final String? culturalType;
  final String? theme;
  final String? culture;
  final String? period;
  final String? region;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String? model3dUrl;
  final String? audioUrl;
  final String? videoUrl;
  final String? additionalInfo;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CulturalObject({
    required this.objectId,
    required this.name,
    required this.description,
    this.culturalType,
    this.theme,
    this.culture,
    this.period,
    this.region,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.model3dUrl,
    this.audioUrl,
    this.videoUrl,
    this.additionalInfo,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CulturalObject.fromJson(Map<String, dynamic> json) {
    return CulturalObject(
      objectId: json['objectId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      culturalType: json['culturalType'],
      theme: json['theme'],
      culture: json['culture'],
      period: json['period'],
      region: json['region'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrl: json['imageUrl'],
      model3dUrl: json['model3dUrl'],
      audioUrl: json['audioUrl'],
      videoUrl: json['videoUrl'],
      additionalInfo: json['additionalInfo'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? _parseTimestamp(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? _parseTimestamp(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'name': name,
      'description': description,
      'culturalType': culturalType,
      'theme': theme,
      'culture': culture,
      'period': period,
      'region': region,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'model3dUrl': model3dUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'additionalInfo': additionalInfo,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    
    // Si es un Timestamp de Firestore
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    
    // Si es un Map con _seconds y _nanoseconds (formato del backend)
    if (timestamp is Map) {
      final seconds = timestamp['_seconds'] ?? timestamp['seconds'];
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }
    
    // Si es un String ISO8601
    if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }
    
    return null;
  }

  CulturalObject copyWith({
    String? objectId,
    String? name,
    String? description,
    String? culturalType,
    String? theme,
    String? culture,
    String? period,
    String? region,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? model3dUrl,
    String? audioUrl,
    String? videoUrl,
    String? additionalInfo,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CulturalObject(
      objectId: objectId ?? this.objectId,
      name: name ?? this.name,
      description: description ?? this.description,
      culturalType: culturalType ?? this.culturalType,
      theme: theme ?? this.theme,
      culture: culture ?? this.culture,
      period: period ?? this.period,
      region: region ?? this.region,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      model3dUrl: model3dUrl ?? this.model3dUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CulturalObjectRequest {
  final String name;
  final String description;
  final String? culturalType;
  final String? theme;
  final String? culture;
  final String? period;
  final String? region;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String? model3dUrl;
  final String? audioUrl;
  final String? videoUrl;
  final String? additionalInfo;

  CulturalObjectRequest({
    required this.name,
    required this.description,
    this.culturalType,
    this.theme,
    this.culture,
    this.period,
    this.region,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.model3dUrl,
    this.audioUrl,
    this.videoUrl,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'culturalType': culturalType,
      'theme': theme,
      'culture': culture,
      'period': period,
      'region': region,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'model3dUrl': model3dUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'additionalInfo': additionalInfo,
    };
  }
}
