// Admin Dashboard Models
class DashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int totalContent;
  final int pendingApprovals;
  final int totalInteractions;
  final int arSessions;
  final double averageSessionTime;
  final int totalDownloads;

  const DashboardStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalContent,
    required this.pendingApprovals,
    required this.totalInteractions,
    required this.arSessions,
    required this.averageSessionTime,
    required this.totalDownloads,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalContent: json['totalContent'] ?? 0,
      pendingApprovals: json['pendingApprovals'] ?? 0,
      totalInteractions: json['totalInteractions'] ?? 0,
      arSessions: json['arSessions'] ?? 0,
      averageSessionTime: (json['averageSessionTime'] ?? 0.0).toDouble(),
      totalDownloads: json['totalDownloads'] ?? 0,
    );
  }
}

class ChartData {
  final String label;
  final double value;
  final DateTime date;

  const ChartData({
    required this.label,
    required this.value,
    required this.date,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0.0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Moderator Models
class ModerationRequest {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String title;
  final String description;
  final String modelUrl;
  final List<String> imageUrls;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewerNotes;

  const ModerationRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.title,
    required this.description,
    required this.modelUrl,
    required this.imageUrls,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewerNotes,
  });

  factory ModerationRequest.fromJson(Map<String, dynamic> json) {
    return ModerationRequest(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      modelUrl: json['modelUrl'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      status: json['status'] ?? 'pending',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      reviewerNotes: json['reviewerNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'title': title,
      'description': description,
      'modelUrl': modelUrl,
      'imageUrls': imageUrls,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewerNotes': reviewerNotes,
    };
  }
}

// Guide Models
class GuidePromotion {
  final String id;
  final String guideId;
  final String title;
  final String description;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final String location;
  final int duration; // in hours
  final int maxParticipants;
  final List<String> highlights;
  final String contactInfo;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GuidePromotion({
    required this.id,
    required this.guideId,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrls,
    required this.location,
    required this.duration,
    required this.maxParticipants,
    required this.highlights,
    required this.contactInfo,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory GuidePromotion.fromJson(Map<String, dynamic> json) {
    return GuidePromotion(
      id: json['id'] ?? '',
      guideId: json['guideId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'PEN',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      location: json['location'] ?? '',
      duration: json['duration'] ?? 1,
      maxParticipants: json['maxParticipants'] ?? 10,
      highlights: List<String>.from(json['highlights'] ?? []),
      contactInfo: json['contactInfo'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guideId': guideId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrls': imageUrls,
      'location': location,
      'duration': duration,
      'maxParticipants': maxParticipants,
      'highlights': highlights,
      'contactInfo': contactInfo,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// Artisan Models
class ArtisanProduct {
  final String id;
  final String artisanId;
  final String name;
  final String description;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final String category;
  final List<String> materials;
  final Map<String, String>
      dimensions; // e.g., {"length": "20cm", "width": "15cm"}
  final int stockQuantity;
  final String origin; // Region/location of origin
  final bool isHandmade;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ArtisanProduct({
    required this.id,
    required this.artisanId,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrls,
    required this.category,
    required this.materials,
    required this.dimensions,
    required this.stockQuantity,
    required this.origin,
    required this.isHandmade,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory ArtisanProduct.fromJson(Map<String, dynamic> json) {
    return ArtisanProduct(
      id: json['id'] ?? '',
      artisanId: json['artisanId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'PEN',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      category: json['category'] ?? '',
      materials: List<String>.from(json['materials'] ?? []),
      dimensions: Map<String, String>.from(json['dimensions'] ?? {}),
      stockQuantity: json['stockQuantity'] ?? 0,
      origin: json['origin'] ?? '',
      isHandmade: json['isHandmade'] ?? true,
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  ArtisanProduct copyWith({
    String? id,
    String? artisanId,
    String? name,
    String? description,
    double? price,
    String? currency,
    List<String>? imageUrls,
    String? category,
    List<String>? materials,
    Map<String, String>? dimensions,
    int? stockQuantity,
    String? origin,
    bool? isHandmade,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ArtisanProduct(
      id: id ?? this.id,
      artisanId: artisanId ?? this.artisanId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      materials: materials ?? this.materials,
      dimensions: dimensions ?? this.dimensions,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      origin: origin ?? this.origin,
      isHandmade: isHandmade ?? this.isHandmade,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artisanId': artisanId,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrls': imageUrls,
      'category': category,
      'materials': materials,
      'dimensions': dimensions,
      'stockQuantity': stockQuantity,
      'origin': origin,
      'isHandmade': isHandmade,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
