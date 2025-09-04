class TourismService {
  final String id;
  final String title;
  final String description;
  final String category;
  final String categoryDisplayName;
  final double price;
  final String formattedPrice;
  final String currency;
  final String location;
  final String department;
  final int durationHours;
  final String formattedDuration;
  final int maxGroupSize;
  final String difficulty;
  final String difficultyDisplayName;
  final List<String> languages;
  final List<String> included;
  final List<String> notIncluded;
  final List<String> requirements;
  final int advanceBookingDays;
  final List<String> images;
  final String guideId;
  final String guideName;
  final String guideContact;
  final double rating;
  final String formattedRating;
  final int reviewCount;
  final int viewCount;
  final bool isActive;
  final String availabilityStatus;
  final String createdAt;
  final String updatedAt;

  TourismService({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryDisplayName,
    required this.price,
    required this.formattedPrice,
    required this.currency,
    required this.location,
    required this.department,
    required this.durationHours,
    required this.formattedDuration,
    required this.maxGroupSize,
    required this.difficulty,
    required this.difficultyDisplayName,
    required this.languages,
    required this.included,
    required this.notIncluded,
    required this.requirements,
    required this.advanceBookingDays,
    required this.images,
    required this.guideId,
    required this.guideName,
    required this.guideContact,
    required this.rating,
    required this.formattedRating,
    required this.reviewCount,
    required this.viewCount,
    required this.isActive,
    required this.availabilityStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TourismService.fromJson(Map<String, dynamic> json) {
    return TourismService(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      categoryDisplayName: json['categoryDisplayName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      formattedPrice: json['formattedPrice'] ?? '',
      currency: json['currency'] ?? 'PEN',
      location: json['location'] ?? '',
      department: json['department'] ?? '',
      durationHours: json['durationHours'] ?? 0,
      formattedDuration: json['formattedDuration'] ?? '',
      maxGroupSize: json['maxGroupSize'] ?? 0,
      difficulty: json['difficulty'] ?? '',
      difficultyDisplayName: json['difficultyDisplayName'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      included: List<String>.from(json['included'] ?? []),
      notIncluded: List<String>.from(json['notIncluded'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      advanceBookingDays: json['advanceBookingDays'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      guideId: json['guideId'] ?? '',
      guideName: json['guideName'] ?? '',
      guideContact: json['guideContact'] ?? '',
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
      'price': price,
      'formattedPrice': formattedPrice,
      'currency': currency,
      'location': location,
      'department': department,
      'durationHours': durationHours,
      'formattedDuration': formattedDuration,
      'maxGroupSize': maxGroupSize,
      'difficulty': difficulty,
      'difficultyDisplayName': difficultyDisplayName,
      'languages': languages,
      'included': included,
      'notIncluded': notIncluded,
      'requirements': requirements,
      'advanceBookingDays': advanceBookingDays,
      'images': images,
      'guideId': guideId,
      'guideName': guideName,
      'guideContact': guideContact,
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
      case 'CULTURAL':
        return '🏛️';
      case 'NATURALEZA':
        return '🌿';
      case 'GASTRONOMICO':
        return '🍽️';
      case 'AVENTURA':
        return '⛰️';
      case 'MISTICO':
        return '🧘';
      case 'ARQUEOLOGICO':
        return '🗿';
      default:
        return '🗺️';
    }
  }

  String get difficultyIcon {
    switch (difficulty.toUpperCase()) {
      case 'FACIL':
        return '🟢';
      case 'MODERADO':
        return '🟡';
      case 'DIFICIL':
        return '🔴';
      case 'EXTREMO':
        return '⚫';
      default:
        return '⚪';
    }
  }

  bool get isAvailable => availabilityStatus == 'Disponible';

  String get mainImage => images.isNotEmpty ? images.first : '';

  String get durationText {
    if (durationHours < 24) {
      return '${durationHours}h';
    } else {
      final days = (durationHours / 24).round();
      return '${days}d';
    }
  }

  String get groupSizeText => '${maxGroupSize} personas máx.';

  String get languagesText => languages.join(', ');
}
