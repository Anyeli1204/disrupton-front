class MuralQuestion {
  final String id;
  final String question;
  final String? description;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> tags;
  final int commentCount;
  final int likeCount;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  MuralQuestion({
    required this.id,
    required this.question,
    this.description,
    this.category = 'general',
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.tags = const [],
    this.commentCount = 0,
    this.likeCount = 0,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory MuralQuestion.fromJson(Map<String, dynamic> json) {
    return MuralQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'general',
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'].toString())
          : DateTime.now(),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'].toString())
          : DateTime.now().add(const Duration(days: 7)),
      isActive: json['isActive'] ?? true,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : [],
      commentCount: json['commentCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'description': description,
      'category': category,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'tags': tags,
      'commentCount': commentCount,
      'likeCount': likeCount,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  MuralQuestion copyWith({
    String? id,
    String? question,
    String? description,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List<String>? tags,
    int? commentCount,
    int? likeCount,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return MuralQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      description: description ?? this.description,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Métodos de utilidad
  bool get isCurrent => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  Duration get remainingTime => endDate.difference(DateTime.now());
  String get formattedRemainingTime {
    final remaining = remainingTime;
    if (remaining.isNegative) return 'Expirada';
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    if (days > 0) return '$days días, $hours horas';
    return '$hours horas';
  }
}

