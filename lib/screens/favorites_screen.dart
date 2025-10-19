import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/firebase_auth_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/service_card.dart';
import '../models/store_product.dart';
import '../models/tourism_service.dart';
import '../services/store_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeFavorites() async {
    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      // Use a default user ID for now - this should be replaced with actual user data
      favoritesProvider.setUserId('current_user_id');
    }
  }

  Future<void> _refreshFavorites() async {
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: false);
    await favoritesProvider.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE91E63).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: Consumer<FavoritesProvider>(
                  builder: (context, favoritesProvider, child) {
                    if (favoritesProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE91E63),
                        ),
                      );
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProductFavorites(favoritesProvider),
                        _buildServiceFavorites(favoritesProvider),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis Favoritos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
                Consumer<FavoritesProvider>(
                  builder: (context, favoritesProvider, child) {
                    final stats = favoritesProvider.stats;
                    return Text(
                      '${stats['total']} elementos guardados',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _refreshFavorites,
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFFE91E63),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFFE91E63),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        tabs: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              final count = favoritesProvider.productFavorites.length;
              return Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Productos ($count)'),
                  ],
                ),
              );
            },
          ),
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              final count = favoritesProvider.serviceFavorites.length;
              return Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tour_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Servicios ($count)'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductFavorites(FavoritesProvider favoritesProvider) {
    final productFavorites = favoritesProvider.productFavorites;

    if (productFavorites.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'No tienes productos favoritos',
        subtitle: 'Explora la tienda y guarda tus productos preferidos',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFavorites,
      child: FutureBuilder<List<StoreProduct>>(
        future: _getProductsFromFavorites(productFavorites),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E63)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState();
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceFavorites(FavoritesProvider favoritesProvider) {
    final serviceFavorites = favoritesProvider.serviceFavorites;

    if (serviceFavorites.isEmpty) {
      return _buildEmptyState(
        icon: Icons.tour_outlined,
        title: 'No tienes servicios favoritos',
        subtitle: 'Explora los tours y guarda tus experiencias preferidas',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFavorites,
      child: FutureBuilder<List<TourismService>>(
        future: _getServicesFromFavorites(serviceFavorites),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E63)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState();
          }

          final services = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return ServiceCard(service: services[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.explore, color: Colors.white),
            label: const Text('Explorar Tienda'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar favoritos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta nuevamente más tarde',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshFavorites,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<StoreProduct>> _getProductsFromFavorites(favorites) async {
    final products = <StoreProduct>[];
    for (final favorite in favorites) {
      try {
        final product = await StoreService.getProductById(favorite.itemId);
        if (product != null) {
          products.add(product);
        }
      } catch (e) {
        print('Error cargando producto ${favorite.itemId}: $e');
      }
    }
    return products;
  }

  Future<List<TourismService>> _getServicesFromFavorites(favorites) async {
    final services = <TourismService>[];
    for (final favorite in favorites) {
      try {
        final service = await StoreService.getServiceById(favorite.itemId);
        if (service != null) {
          services.add(service);
        }
      } catch (e) {
        print('Error cargando servicio ${favorite.itemId}: $e');
      }
    }
    return services;
  }
}
