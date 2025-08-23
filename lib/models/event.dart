class Event {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime dateTime;
  final String location;
  final double? latitude;
  final double? longitude;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<String> tags;
  final int attendeesCount;
  final bool isPastEvent;
  final String timeUntilEvent;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.dateTime,
    required this.location,
    this.latitude,
    this.longitude,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.tags,
    required this.attendeesCount,
    required this.isPastEvent,
    required this.timeUntilEvent,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      dateTime: _parseDateTime(json['dateTime']),
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
      attendeesCount: json['attendeesCount'] ?? 0,
      isPastEvent: json['isPastEvent'] ?? false,
      timeUntilEvent: json['timeUntilEvent'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'tags': tags,
      'attendeesCount': attendeesCount,
      'isPastEvent': isPastEvent,
      'timeUntilEvent': timeUntilEvent,
    };
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();

    if (dateTime is String) {
      // Intenta parsear como ISO 8601 primero
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        // Si falla, intenta con formato DD/MM/YYYY HH:mm
        try {
          final parts = dateTime.split(' ');
          final dateParts = parts[0].split('/');
          final timeParts =
              parts.length > 1 ? parts[1].split(':') : ['00', '00'];

          return DateTime(
            int.parse(dateParts[2]), // año
            int.parse(dateParts[1]), // mes
            int.parse(dateParts[0]), // día
            int.parse(timeParts[0]), // hora
            int.parse(timeParts[1]), // minuto
          );
        } catch (e) {
          return DateTime.now();
        }
      }
    }

    return DateTime.now();
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? dateTime,
    String? location,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? tags,
    int? attendeesCount,
    bool? isPastEvent,
    String? timeUntilEvent,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      isPastEvent: isPastEvent ?? this.isPastEvent,
      timeUntilEvent: timeUntilEvent ?? this.timeUntilEvent,
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, title: $title, dateTime: $dateTime, location: $location, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class EventCreateRequest {
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime dateTime;
  final String location;
  final double? latitude;
  final double? longitude;
  final List<String> tags;

  EventCreateRequest({
    required this.title,
    required this.description,
    this.imageUrl,
    required this.dateTime,
    required this.location,
    this.latitude,
    this.longitude,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags,
    };
  }
}

class EventUpdateRequest {
  final String? title;
  final String? description;
  final String? imageUrl;
  final DateTime? dateTime;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<String>? tags;
  final bool? isActive;

  EventUpdateRequest({
    this.title,
    this.description,
    this.imageUrl,
    this.dateTime,
    this.location,
    this.latitude,
    this.longitude,
    this.tags,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (imageUrl != null) json['imageUrl'] = imageUrl;
    if (dateTime != null) json['dateTime'] = dateTime!.toIso8601String();
    if (location != null) json['location'] = location;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (tags != null) json['tags'] = tags;
    if (isActive != null) json['isActive'] = isActive;

    return json;
  }
}

class EventStats {
  final int totalEvents;
  final int activeEvents;
  final int inactiveEvents;
  final int upcomingEvents;
  final int pastEvents;

  EventStats({
    required this.totalEvents,
    required this.activeEvents,
    required this.inactiveEvents,
    required this.upcomingEvents,
    required this.pastEvents,
  });

  factory EventStats.fromJson(Map<String, dynamic> json) {
    return EventStats(
      totalEvents: json['totalEvents'] ?? 0,
      activeEvents: json['activeEvents'] ?? 0,
      inactiveEvents: json['inactiveEvents'] ?? 0,
      upcomingEvents: json['upcomingEvents'] ?? 0,
      pastEvents: json['pastEvents'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEvents': totalEvents,
      'activeEvents': activeEvents,
      'inactiveEvents': inactiveEvents,
      'upcomingEvents': upcomingEvents,
      'pastEvents': pastEvents,
    };
  }
}
