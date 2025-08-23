class Department {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final List<String> culturalObjectIds;

  Department({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.culturalObjectIds,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      culturalObjectIds: List<String>.from(json['culturalObjectIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'culturalObjectIds': culturalObjectIds,
    };
  }
}

class CulturalObject {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final String departmentId;
  final String category;
  final DateTime createdAt;
  final Map<String, dynamic>? additionalInfo;

  CulturalObject({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.departmentId,
    required this.category,
    required this.createdAt,
    this.additionalInfo,
  });

  factory CulturalObject.fromJson(Map<String, dynamic> json) {
    return CulturalObject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      departmentId: json['departmentId'] ?? '',
      category: json['category'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'departmentId': departmentId,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'additionalInfo': additionalInfo,
    };
  }
}
