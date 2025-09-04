import 'package:flutter/material.dart';
import '../models/favorite.dart';
import '../models/store_product.dart';
import '../models/tourism_service.dart';
import '../services/favorites_service.dart';

class FavoritesProvider with ChangeNotifier {
  List<Favorite> _favorites = [];
  bool _isLoading = false;
  String? _currentUserId;

  List<Favorite> get favorites => _favorites;
  bool get isLoading => _isLoading;

  List<Favorite> get productFavorites =>
      _favorites.where((f) => f.isProduct).toList();

  List<Favorite> get serviceFavorites =>
      _favorites.where((f) => f.isService).toList();

  /// Inicializar con usuario
  void setUserId(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _favorites.clear();
      loadFavorites();
    }
  }

  /// Cargar favoritos del usuario
  Future<void> loadFavorites() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final favorites =
          await FavoritesService.getUserFavorites(_currentUserId!);
      _favorites = favorites;
    } catch (e) {
      print('Error cargando favoritos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verificar si un item está en favoritos
  bool isFavorite(String itemId) {
    return _favorites.any((f) => f.itemId == itemId);
  }

  /// Agregar producto a favoritos
  Future<bool> addProductToFavorites(StoreProduct product) async {
    if (_currentUserId == null) return false;

    final success = await FavoritesService.addToFavorites(
      userId: _currentUserId!,
      itemId: product.id,
      itemType: 'product',
      title: product.title,
      imageUrl: product.mainImage,
      price: product.price,
      location: product.location,
    );

    if (success) {
      final favorite = Favorite(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUserId!,
        itemId: product.id,
        itemType: 'product',
        title: product.title,
        imageUrl: product.mainImage,
        price: product.price,
        location: product.location,
        createdAt: DateTime.now(),
      );

      _favorites.add(favorite);
      notifyListeners();
    }

    return success;
  }

  /// Agregar servicio a favoritos
  Future<bool> addServiceToFavorites(TourismService service) async {
    if (_currentUserId == null) return false;

    final success = await FavoritesService.addToFavorites(
      userId: _currentUserId!,
      itemId: service.id,
      itemType: 'service',
      title: service.title,
      imageUrl: service.mainImage,
      price: service.price,
      location: service.location,
    );

    if (success) {
      final favorite = Favorite(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUserId!,
        itemId: service.id,
        itemType: 'service',
        title: service.title,
        imageUrl: service.mainImage,
        price: service.price,
        location: service.location,
        createdAt: DateTime.now(),
      );

      _favorites.add(favorite);
      notifyListeners();
    }

    return success;
  }

  /// Remover de favoritos
  Future<bool> removeFromFavorites(String itemId) async {
    if (_currentUserId == null) return false;

    final success =
        await FavoritesService.removeFromFavorites(_currentUserId!, itemId);

    if (success) {
      _favorites.removeWhere((f) => f.itemId == itemId);
      notifyListeners();
    }

    return success;
  }

  /// Toggle favorito
  Future<bool> toggleFavorite(dynamic item) async {
    if (item is StoreProduct) {
      if (isFavorite(item.id)) {
        return await removeFromFavorites(item.id);
      } else {
        return await addProductToFavorites(item);
      }
    } else if (item is TourismService) {
      if (isFavorite(item.id)) {
        return await removeFromFavorites(item.id);
      } else {
        return await addServiceToFavorites(item);
      }
    }
    return false;
  }

  /// Limpiar favoritos (para logout)
  void clearFavorites() {
    _favorites.clear();
    _currentUserId = null;
    notifyListeners();
  }

  /// Obtener estadísticas
  Map<String, int> get stats {
    return {
      'total': _favorites.length,
      'products': productFavorites.length,
      'services': serviceFavorites.length,
    };
  }
}
