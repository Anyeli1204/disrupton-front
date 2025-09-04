class StoreProduct {
  final String id;
  final String title;
  final String description;
  final String category;
  final String categoryDisplayName;
  final String type;
  final String typeDisplayName;
  final double price;
  final String formattedPrice;
  final String currency;
  final String location;
  final String department;
  final int stock;
  final List<String> images;
  final String artisanId;
  final String artisanName;
  final String artisanEmail;
  final String artisanPhone;
  final double rating;
  final String formattedRating;
  final int reviewCount;
  final int viewCount;
  final bool isActive;
  final String availabilityStatus;
  final String createdAt;
  final String updatedAt;

  StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryDisplayName,
    required this.type,
    required this.typeDisplayName,
    required this.price,
    required this.formattedPrice,
    required this.currency,
    required this.location,
    required this.department,
    required this.stock,
    required this.images,
    required this.artisanId,
    required this.artisanName,
    required this.artisanEmail,
    required this.artisanPhone,
    required this.rating,
    required this.formattedRating,
    required this.reviewCount,
    required this.viewCount,
    required this.isActive,
    required this.availabilityStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      categoryDisplayName: json['categoryDisplayName'] ?? '',
      type: json['type'] ?? '',
      typeDisplayName: json['typeDisplayName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      formattedPrice: json['formattedPrice'] ?? '',
      currency: json['currency'] ?? 'PEN',
      location: json['location'] ?? '',
      department: json['department'] ?? '',
      stock: json['stock'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      artisanId: json['artisanId'] ?? '',
      artisanName: json['artisanName'] ?? '',
      artisanEmail: json['artisanEmail'] ?? '',
      artisanPhone: json['artisanPhone'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      formattedRating: json['formattedRating'] ?? '',
      reviewCount: json['reviewCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      availabilityStatus: json['availabilityStatus'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'categoryDisplayName': categoryDisplayName,
      'type': type,
      'typeDisplayName': typeDisplayName,
      'price': price,
      'formattedPrice': formattedPrice,
      'currency': currency,
      'location': location,
      'department': department,
      'stock': stock,
      'images': images,
      'artisanId': artisanId,
      'artisanName': artisanName,
      'artisanEmail': artisanEmail,
      'artisanPhone': artisanPhone,
      'rating': rating,
      'formattedRating': formattedRating,
      'reviewCount': reviewCount,
      'viewCount': viewCount,
      'isActive': isActive,
      'availabilityStatus': availabilityStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Getters para iconos según categoría
  String get categoryIcon {
    switch (category.toUpperCase()) {
      case 'TEXTILES':
        return '🧵';
      case 'CERAMICA':
        return '🏺';
      case 'ORFEBRERIA':
        return '💍';
      case 'MADERA':
        return '🪵';
      case 'CUERO':
        return '👜';
      case 'PIEDRA':
        return '🗿';
      default:
        return '🎨';
    }
  }

  String get typeIcon {
    switch (type.toUpperCase()) {
      case 'TEJIDO':
        return '🧶';
      case 'DECORATIVO':
        return '🏠';
      case 'FUNCIONAL':
        return '🍶';
      case 'JOYERIA':
        return '💎';
      case 'ACCESORIO':
        return '👒';
      case 'CEREMONIAL':
        return '🎭';
      default:
        return '✨';
    }
  }

  bool get isAvailable => availabilityStatus == 'Disponible' && stock > 0;

  String get mainImage => images.isNotEmpty ? images.first : '';
}
