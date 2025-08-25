enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  provisional,
  limited,
  unknown,
}

enum PermissionType {
  camera,
  photos,
  storage,
  location,
  microphone,
}

class PermissionState {
  final PermissionType type;
  final PermissionStatus status;
  final bool hasAskedBefore;
  final DateTime? lastAskedDate;
  final bool allowWhileUsingApp;
  final bool onlyThisTime;

  const PermissionState({
    required this.type,
    required this.status,
    this.hasAskedBefore = false,
    this.lastAskedDate,
    this.allowWhileUsingApp = false,
    this.onlyThisTime = false,
  });

  factory PermissionState.fromJson(Map<String, dynamic> json) {
    return PermissionState(
      type: PermissionType.values[json['type'] ?? 0],
      status: PermissionStatus.values[json['status'] ?? 0],
      hasAskedBefore: json['hasAskedBefore'] ?? false,
      lastAskedDate: json['lastAskedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastAskedDate'])
          : null,
      allowWhileUsingApp: json['allowWhileUsingApp'] ?? false,
      onlyThisTime: json['onlyThisTime'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'status': status.index,
      'hasAskedBefore': hasAskedBefore,
      'lastAskedDate': lastAskedDate?.millisecondsSinceEpoch,
      'allowWhileUsingApp': allowWhileUsingApp,
      'onlyThisTime': onlyThisTime,
    };
  }

  PermissionState copyWith({
    PermissionType? type,
    PermissionStatus? status,
    bool? hasAskedBefore,
    DateTime? lastAskedDate,
    bool? allowWhileUsingApp,
    bool? onlyThisTime,
  }) {
    return PermissionState(
      type: type ?? this.type,
      status: status ?? this.status,
      hasAskedBefore: hasAskedBefore ?? this.hasAskedBefore,
      lastAskedDate: lastAskedDate ?? this.lastAskedDate,
      allowWhileUsingApp: allowWhileUsingApp ?? this.allowWhileUsingApp,
      onlyThisTime: onlyThisTime ?? this.onlyThisTime,
    );
  }

  bool get shouldShowPopup {
    // Don't show if already granted and user chose "allow while using app"
    if (status == PermissionStatus.granted && allowWhileUsingApp) {
      return false;
    }

    // Don't show if permanently denied or restricted
    if (status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.restricted) {
      return false;
    }

    // Show popup if user only chose "this time only" in last session and permission is not granted
    if (onlyThisTime && status != PermissionStatus.granted) {
      return true;
    }

    // Show popup for new users who haven't been asked before
    if (!hasAskedBefore) {
      return true;
    }

    // For any other case, don't show popup to avoid spam
    return false;
  }
}
