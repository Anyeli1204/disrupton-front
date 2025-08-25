import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/permission_models.dart' as pm;

class PermissionService {
  static const String _permissionStateKey = 'permission_states';
  static const String _tutorialCompletedKey = 'tutorial_completed';
  static const String _firstLoginKey = 'first_login_completed';

  // Get saved permission states
  static Future<Map<pm.PermissionType, pm.PermissionState>>
      getSavedPermissionStates() async {
    final prefs = await SharedPreferences.getInstance();
    final statesJson = prefs.getString(_permissionStateKey);

    if (statesJson == null) {
      return _getDefaultPermissionStates();
    }

    try {
      final statesMap = jsonDecode(statesJson) as Map<String, dynamic>;
      final result = <pm.PermissionType, pm.PermissionState>{};

      for (final entry in statesMap.entries) {
        final type = pm.PermissionType.values[int.parse(entry.key)];
        final state = pm.PermissionState.fromJson(entry.value);
        result[type] = state;
      }

      return result;
    } catch (e) {
      debugPrint('Error loading permission states: $e');
      return _getDefaultPermissionStates();
    }
  }

  // Save permission states
  static Future<void> savePermissionStates(
      Map<pm.PermissionType, pm.PermissionState> states) async {
    final prefs = await SharedPreferences.getInstance();
    final statesMap = <String, dynamic>{};

    for (final entry in states.entries) {
      statesMap[entry.key.index.toString()] = entry.value.toJson();
    }

    await prefs.setString(_permissionStateKey, jsonEncode(statesMap));
  }

  // Check if any permissions need popup
  static Future<List<pm.PermissionType>> getPermissionsNeedingPopup() async {
    final states = await getSavedPermissionStates();
    final needingPopup = <pm.PermissionType>[];

    for (final entry in states.entries) {
      if (entry.value.shouldShowPopup) {
        needingPopup.add(entry.key);
      }
    }

    return needingPopup;
  }

  // Request specific permission
  static Future<pm.PermissionState> requestPermission(
      pm.PermissionType type) async {
    ph.Permission permission;

    switch (type) {
      case pm.PermissionType.camera:
        permission = ph.Permission.camera;
        break;
      case pm.PermissionType.photos:
        permission = ph.Permission.photos;
        break;
      case pm.PermissionType.storage:
        permission = ph.Permission.storage;
        break;
      case pm.PermissionType.location:
        permission = ph.Permission.location;
        break;
      case pm.PermissionType.microphone:
        permission = ph.Permission.microphone;
        break;
    }

    final status = await permission.request();
    return _mapPermissionStatus(type, status);
  }

  // Update permission state after user selection
  static Future<void> updatePermissionChoice(
    pm.PermissionType type,
    bool allowWhileUsingApp,
    bool onlyThisTime,
  ) async {
    final states = await getSavedPermissionStates();
    final currentState = states[type] ?? _getDefaultPermissionState(type);

    pm.PermissionStatus finalStatus = pm.PermissionStatus.denied;

    if (allowWhileUsingApp || onlyThisTime) {
      // First check current system permission status
      final currentSystemStatus = await _checkSystemPermissionStatus(type);

      if (currentSystemStatus == pm.PermissionStatus.granted) {
        // System permission already granted
        finalStatus = pm.PermissionStatus.granted;
      } else {
        // Request the actual system permission only if not already granted
        final systemState = await requestPermission(type);
        finalStatus = systemState.status;
      }
    }

    final updatedState = currentState.copyWith(
      hasAskedBefore: true,
      lastAskedDate: DateTime.now(),
      allowWhileUsingApp: allowWhileUsingApp,
      onlyThisTime: onlyThisTime,
      status: finalStatus,
    );

    states[type] = updatedState;
    await savePermissionStates(states);
  }

  // Check system permission status without requesting
  static Future<pm.PermissionStatus> _checkSystemPermissionStatus(
      pm.PermissionType type) async {
    ph.Permission permission;

    switch (type) {
      case pm.PermissionType.camera:
        permission = ph.Permission.camera;
        break;
      case pm.PermissionType.photos:
        permission = ph.Permission.photos;
        break;
      case pm.PermissionType.storage:
        permission = ph.Permission.storage;
        break;
      case pm.PermissionType.location:
        permission = ph.Permission.location;
        break;
      case pm.PermissionType.microphone:
        permission = ph.Permission.microphone;
        break;
    }

    final status = await permission.status;
    return _mapPermissionStatusOnly(status);
  }

  // Helper to map status without creating full PermissionState
  static pm.PermissionStatus _mapPermissionStatusOnly(
      ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return pm.PermissionStatus.granted;
      case ph.PermissionStatus.denied:
        return pm.PermissionStatus.denied;
      case ph.PermissionStatus.permanentlyDenied:
        return pm.PermissionStatus.permanentlyDenied;
      case ph.PermissionStatus.restricted:
        return pm.PermissionStatus.restricted;
      case ph.PermissionStatus.provisional:
        return pm.PermissionStatus.provisional;
      case ph.PermissionStatus.limited:
        return pm.PermissionStatus.limited;
    }
  }

  // Check current permission status
  static Future<pm.PermissionState> checkPermissionStatus(
      pm.PermissionType type) async {
    ph.Permission permission;

    switch (type) {
      case pm.PermissionType.camera:
        permission = ph.Permission.camera;
        break;
      case pm.PermissionType.photos:
        permission = ph.Permission.photos;
        break;
      case pm.PermissionType.storage:
        permission = ph.Permission.storage;
        break;
      case pm.PermissionType.location:
        permission = ph.Permission.location;
        break;
      case pm.PermissionType.microphone:
        permission = ph.Permission.microphone;
        break;
    }

    final status = await permission.status;
    return _mapPermissionStatus(type, status);
  }

  // Tutorial completion
  static Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  static Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, false);
  }

  // First login management
  static Future<bool> isFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_firstLoginKey) ?? false);
  }

  static Future<void> markFirstLoginCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLoginKey, true);
  }

  static Future<void> resetFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLoginKey, false);
  }

  // Reset all user preferences (for testing)
  static Future<void> resetAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_permissionStateKey);
    await prefs.remove(_tutorialCompletedKey);
    await prefs.remove(_firstLoginKey);
  }

  // Private helper methods
  static Map<pm.PermissionType, pm.PermissionState>
      _getDefaultPermissionStates() {
    return {
      pm.PermissionType.camera:
          _getDefaultPermissionState(pm.PermissionType.camera),
      pm.PermissionType.photos:
          _getDefaultPermissionState(pm.PermissionType.photos),
    };
  }

  static pm.PermissionState _getDefaultPermissionState(pm.PermissionType type) {
    return pm.PermissionState(
      type: type,
      status: pm.PermissionStatus.unknown,
      hasAskedBefore: false,
    );
  }

  static pm.PermissionState _mapPermissionStatus(
      pm.PermissionType type, ph.PermissionStatus status) {
    pm.PermissionStatus mappedStatus;
    switch (status) {
      case ph.PermissionStatus.granted:
        mappedStatus = pm.PermissionStatus.granted;
        break;
      case ph.PermissionStatus.denied:
        mappedStatus = pm.PermissionStatus.denied;
        break;
      case ph.PermissionStatus.permanentlyDenied:
        mappedStatus = pm.PermissionStatus.permanentlyDenied;
        break;
      case ph.PermissionStatus.restricted:
        mappedStatus = pm.PermissionStatus.restricted;
        break;
      case ph.PermissionStatus.provisional:
        mappedStatus = pm.PermissionStatus.provisional;
        break;
      case ph.PermissionStatus.limited:
        mappedStatus = pm.PermissionStatus.limited;
        break;
    }

    return pm.PermissionState(
      type: type,
      status: mappedStatus,
      hasAskedBefore: true,
      lastAskedDate: DateTime.now(),
    );
  }

  // Get user-friendly permission names
  static String getPermissionName(pm.PermissionType type) {
    switch (type) {
      case pm.PermissionType.camera:
        return 'Cámara';
      case pm.PermissionType.photos:
        return 'Galería de fotos';
      case pm.PermissionType.storage:
        return 'Almacenamiento';
      case pm.PermissionType.location:
        return 'Ubicación';
      case pm.PermissionType.microphone:
        return 'Micrófono';
    }
  }

  static String getPermissionDescription(pm.PermissionType type) {
    switch (type) {
      case pm.PermissionType.camera:
        return 'Para tomar fotos de las piezas culturales y usar la realidad aumentada';
      case pm.PermissionType.photos:
        return 'Para acceder a tus fotos y permitirte cargar imágenes';
      case pm.PermissionType.storage:
        return 'Para guardar y acceder a archivos necesarios para la aplicación';
      case pm.PermissionType.location:
        return 'Para mostrarte contenido cultural cercano a tu ubicación';
      case pm.PermissionType.microphone:
        return 'Para grabaciones de audio en tours guiados';
    }
  }

  static IconData getPermissionIcon(pm.PermissionType type) {
    switch (type) {
      case pm.PermissionType.camera:
        return Icons.camera_alt;
      case pm.PermissionType.photos:
        return Icons.photo_library;
      case pm.PermissionType.storage:
        return Icons.storage;
      case pm.PermissionType.location:
        return Icons.location_on;
      case pm.PermissionType.microphone:
        return Icons.mic;
    }
  }
}
