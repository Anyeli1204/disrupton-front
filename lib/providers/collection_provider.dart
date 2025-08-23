import 'package:flutter/material.dart';
import '../models/collection_models.dart';
import '../services/collection_service.dart';

enum CollectionState {
  initial,
  loading,
  loaded,
  error,
}

class CollectionProvider extends ChangeNotifier {
  final CollectionService _collectionService = CollectionService();

  CollectionState _state = CollectionState.initial;
  List<Department> _departments = [];
  Map<String, List<CulturalObject>> _departmentObjects = {};
  CulturalObject? _selectedObject;
  String? _errorMessage;

  // Getters
  CollectionState get state => _state;
  List<Department> get departments => _departments;
  Map<String, List<CulturalObject>> get departmentObjects => _departmentObjects;
  CulturalObject? get selectedObject => _selectedObject;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CollectionState.loading;

  /// Inicializa la carga de departamentos
  Future<void> initialize() async {
    if (_departments.isNotEmpty) return; // Ya inicializado

    await loadDepartments();
  }

  /// Carga todos los departamentos
  Future<void> loadDepartments() async {
    _setState(CollectionState.loading);

    try {
      _departments = await _collectionService.getDepartments();
      _setState(CollectionState.loaded);
    } catch (e) {
      _setError('Error al cargar departamentos: ${e.toString()}');
    }
  }

  /// Carga objetos culturales de un departamento específico
  Future<List<CulturalObject>> loadCulturalObjects(String departmentId) async {
    try {
      // Si ya están cargados, devolverlos desde el caché
      if (_departmentObjects.containsKey(departmentId)) {
        return _departmentObjects[departmentId]!;
      }

      // Cargar desde el servicio
      final objects =
          await _collectionService.getCulturalObjectsByDepartment(departmentId);
      _departmentObjects[departmentId] = objects;
      notifyListeners();

      return objects;
    } catch (e) {
      _setError('Error al cargar objetos culturales: ${e.toString()}');
      return [];
    }
  }

  /// Selecciona un objeto cultural específico
  Future<void> selectCulturalObject(String objectId) async {
    try {
      _selectedObject =
          await _collectionService.getCulturalObjectById(objectId);
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar objeto cultural: ${e.toString()}');
    }
  }

  /// Obtiene un departamento por ID
  Department? getDepartmentById(String departmentId) {
    try {
      return _departments.firstWhere((dept) => dept.id == departmentId);
    } catch (e) {
      return null;
    }
  }

  /// Busca objetos culturales por texto
  List<CulturalObject> searchCulturalObjects(String query) {
    if (query.isEmpty) return [];

    final allObjects = <CulturalObject>[];
    for (final objects in _departmentObjects.values) {
      allObjects.addAll(objects);
    }

    return allObjects.where((object) {
      return object.name.toLowerCase().contains(query.toLowerCase()) ||
          object.description.toLowerCase().contains(query.toLowerCase()) ||
          object.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Filtra objetos por categoría
  List<CulturalObject> getObjectsByCategory(String category) {
    final allObjects = <CulturalObject>[];
    for (final objects in _departmentObjects.values) {
      allObjects.addAll(objects);
    }

    return allObjects
        .where(
            (object) => object.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Obtiene objetos recientes (últimos 30 días)
  List<CulturalObject> getRecentObjects() {
    final allObjects = <CulturalObject>[];
    for (final objects in _departmentObjects.values) {
      allObjects.addAll(objects);
    }

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return allObjects
        .where((object) => object.createdAt.isAfter(thirtyDaysAgo))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Limpia el error actual
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpia el objeto seleccionado
  void clearSelectedObject() {
    _selectedObject = null;
    notifyListeners();
  }

  /// Refresca los datos
  Future<void> refresh() async {
    _departments = [];
    _departmentObjects.clear();
    _selectedObject = null;
    await loadDepartments();
  }

  /// Actualiza el estado y notifica a los listeners
  void _setState(CollectionState newState) {
    _state = newState;
    if (newState != CollectionState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// Establece un error y actualiza el estado
  void _setError(String error) {
    _errorMessage = error;
    _state = CollectionState.error;
    notifyListeners();
  }
}
