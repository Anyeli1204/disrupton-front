import 'package:flutter/foundation.dart';
import '../models/pieza.dart';
import '../services/pieza_service.dart';
import '../utils/model_loader.dart';

class ARProvider with ChangeNotifier {
  List<Pieza> _piezas = [];
  Pieza? _piezaSeleccionada;
  bool _isLoading = false;
  String? _error;
  bool _arSessionActive = false;
  bool _modelLoaded = false;

  // Getters
  List<Pieza> get piezas => _piezas;
  Pieza? get piezaSeleccionada => _piezaSeleccionada;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get arSessionActive => _arSessionActive;
  bool get modelLoaded => _modelLoaded;

  // Cargar todas las piezas
  Future<void> cargarPiezas() async {
    _setLoading(true);
    try {
      _piezas = await PiezaService.obtenerPiezas();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Seleccionar pieza para AR
  Future<void> seleccionarPieza(Pieza pieza) async {
    _piezaSeleccionada = pieza;
    _modelLoaded = false;
    notifyListeners();

    // Pre-cargar el modelo 3D
    if (pieza.urlModelo3D.isNotEmpty) {
      await _precargarModelo(pieza);
    }
  }

  // Pre-cargar modelo 3D
  Future<void> _precargarModelo(Pieza pieza) async {
    try {
      final modelPath = await ModelLoader.cargarModeloDesdeUrl(
        pieza.urlModelo3D,
        pieza.id,
      );
      
      if (modelPath != null) {
        _modelLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error cargando modelo: $e';
      notifyListeners();
    }
  }

  // Iniciar sesión AR
  void iniciarSesionAR() {
    _arSessionActive = true;
    notifyListeners();
  }

  // Finalizar sesión AR
  void finalizarSesionAR() {
    _arSessionActive = false;
    _modelLoaded = false;
    notifyListeners();
  }

  // Buscar piezas
  Future<void> buscarPiezas(String query) async {
    _setLoading(true);
    try {
      _piezas = await PiezaService.buscarPiezas(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Filtrar por categoría
  Future<void> filtrarPorCategoria(String categoria) async {
    _setLoading(true);
    try {
      _piezas = await PiezaService.obtenerPiezasPorCategoria(categoria);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Filtrar por ubicación
  Future<void> filtrarPorUbicacion(String ubicacion) async {
    _setLoading(true);
    try {
      _piezas = await PiezaService.obtenerPiezasPorUbicacion(ubicacion);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Limpiar caché de modelos
  Future<void> limpiarCache() async {
    try {
      await ModelLoader.limpiarCache();
      _modelLoaded = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error limpiando caché: $e';
      notifyListeners();
    }
  }

  // Verificar disponibilidad del modelo
  Future<bool> verificarModeloDisponible(String url) async {
    return await PiezaService.verificarModeloDisponible(url);
  }

  // Obtener metadatos del modelo
  Future<Map<String, dynamic>> obtenerMetadatosModelo(String url) async {
    return await PiezaService.obtenerMetadatosModelo(url);
  }

  // Resetear estado
  void resetear() {
    _piezaSeleccionada = null;
    _modelLoaded = false;
    _arSessionActive = false;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
