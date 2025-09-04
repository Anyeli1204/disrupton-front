import 'package:flutter/material.dart';
import '../models/cultural_agent.dart';
import '../services/agente_cultural_service.dart';

class AgentesCulturalesProvider with ChangeNotifier {
  List<CulturalAgent> _artesanos = [];
  List<CulturalAgent> _guias = [];
  List<CulturalAgent> _filteredAgents = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  // Getters
  List<CulturalAgent> get artesanos => _artesanos;
  List<CulturalAgent> get guias => _guias;
  List<CulturalAgent> get filteredAgents => _filteredAgents;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;

  /// Carga los artesanos
  Future<void> cargarArtesanos() async {
    _setLoading(true);
    try {
      _artesanos = await AgenteCulturalService.obtenerArtesanos();
      _error = '';
      debugPrint('✅ Cargados ${_artesanos.length} artesanos');
    } catch (e) {
      _error = 'Error al cargar artesanos: $e';
      debugPrint('❌ Error cargando artesanos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carga los guías turísticos
  Future<void> cargarGuias() async {
    _setLoading(true);
    try {
      _guias = await AgenteCulturalService.obtenerGuias();
      _error = '';
      debugPrint('✅ Cargados ${_guias.length} guías turísticos');
    } catch (e) {
      _error = 'Error al cargar guías: $e';
      debugPrint('❌ Error cargando guías: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Busca agentes por texto
  Future<void> buscarAgentes(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _filteredAgents = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      _filteredAgents = await AgenteCulturalService.buscarAgentes(query);
      _error = '';
      debugPrint(
          '🔍 Encontrados ${_filteredAgents.length} agentes para "$query"');
    } catch (e) {
      _error = 'Error en la búsqueda: $e';
      debugPrint('❌ Error buscando: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Limpia la búsqueda
  void limpiarBusqueda() {
    _searchQuery = '';
    _filteredAgents = [];
    notifyListeners();
  }

  /// Inicializa los datos
  Future<void> inicializar() async {
    await Future.wait([
      cargarArtesanos(),
      cargarGuias(),
    ]);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Limpia todos los datos
  void limpiar() {
    _artesanos = [];
    _guias = [];
    _filteredAgents = [];
    _searchQuery = '';
    _error = '';
    _isLoading = false;
    notifyListeners();
  }
}
