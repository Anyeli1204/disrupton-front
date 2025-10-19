import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/store_product.dart';
import '../models/tourism_service.dart';
import '../services/store_service.dart';
import '../widgets/product_detail_modal.dart';
import '../widgets/service_detail_modal.dart';
import '../core/theme/app_colors.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers para búsqueda
  final TextEditingController _searchController = TextEditingController();

  // Estados de carga
  bool _isLoadingProducts = true;
  bool _isLoadingServices = true;

  // Datos
  List<StoreProduct> _allProducts = [];
  List<StoreProduct> _filteredProducts = [];
  List<TourismService> _allServices = [];
  List<TourismService> _filteredServices = [];

  // Favoritos y carrito
  Set<String> _favoriteProducts = {};
  Set<String> _favoriteServices = {};
  Map<String, int> _cartItems = {};

  // Filtros
  String _selectedProductCategory = '';
  String _selectedServiceCategory = '';
  String _selectedDifficulty = '';
  double _minPrice = 0;
  double _maxPrice = 2000;
  bool _showFilters = false;

  // Categorías disponibles
  Map<String, String> _productCategories = {};
  Map<String, String> _serviceCategories = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Cargar datos iniciales
  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadProducts(),
      _loadServices(),
      _loadCategories(),
    ]);
  }

  /// Cargar productos
  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() => _isLoadingProducts = true);

    try {
      final products = await StoreService.getAllProducts();
      if (mounted) {
        setState(() {
          _allProducts = products;
          _filteredProducts = products;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      print('Error cargando productos: $e');
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  /// Cargar servicios
  Future<void> _loadServices() async {
    if (!mounted) return;
    setState(() => _isLoadingServices = true);

    try {
      final services = await StoreService.getAllServices();
      if (mounted) {
        setState(() {
          _allServices = services;
          _filteredServices = services;
          _isLoadingServices = false;
        });
      }
    } catch (e) {
      print('Error cargando servicios: $e');
      if (mounted) {
        setState(() => _isLoadingServices = false);
      }
    }
  }

  /// Cargar categorías
  Future<void> _loadCategories() async {
    try {
      final productCats = await StoreService.getProductCategories();
      final serviceCats = await StoreService.getServiceCategories();

      if (mounted) {
        setState(() {
          _productCategories = productCats;
          _serviceCategories = serviceCats;
        });
      }
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }

  /// Aplicar filtros de productos
  void _filterProducts() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        // Filtro por texto
        final searchTerm = _searchController.text.toLowerCase();
        if (searchTerm.isNotEmpty) {
          if (!product.title.toLowerCase().contains(searchTerm) &&
              !product.description.toLowerCase().contains(searchTerm) &&
              !product.location.toLowerCase().contains(searchTerm)) {
            return false;
          }
        }

        // Filtro por categoría
        if (_selectedProductCategory.isNotEmpty &&
            product.category != _selectedProductCategory) {
          return false;
        }

        // Filtro por precio
        if (product.price < _minPrice || product.price > _maxPrice) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  /// Aplicar filtros de servicios
  void _filterServices() {
    setState(() {
      _filteredServices = _allServices.where((service) {
        // Filtro por texto
        final searchTerm = _searchController.text.toLowerCase();
        if (searchTerm.isNotEmpty) {
          if (!service.title.toLowerCase().contains(searchTerm) &&
              !service.description.toLowerCase().contains(searchTerm) &&
              !service.location.toLowerCase().contains(searchTerm)) {
            return false;
          }
        }

        // Filtro por categoría
        if (_selectedServiceCategory.isNotEmpty &&
            service.category != _selectedServiceCategory) {
          return false;
        }

        // Filtro por dificultad
        if (_selectedDifficulty.isNotEmpty &&
            service.difficulty != _selectedDifficulty) {
          return false;
        }

        // Filtro por precio
        if (service.price < _minPrice || service.price > _maxPrice) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  /// Limpiar filtros
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedProductCategory = '';
      _selectedServiceCategory = '';
      _selectedDifficulty = '';
      _minPrice = 0;
      _maxPrice = 2000;
      _filteredProducts = _allProducts;
      _filteredServices = _allServices;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItemCount =
        _cartItems.values.fold<int>(0, (sum, count) => sum + count);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header mejorado con carrito
            _buildModernHeader(cartItemCount),

            // Barra de búsqueda mejorada
            _buildModernSearchBar(),

            // Filtros (si están visibles)
            if (_showFilters) _buildModernFilters(),

            // Tabs mejorados
            Expanded(
              child: Column(
                children: [
                  _buildModernTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildModernProductsGrid(),
                        _buildModernServicesGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(int cartItemCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Logo/Icono
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              // Título y subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Artesanía y experiencias peruanas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Botones de acción
              Row(
                children: [
                  // Botón filtros
                  _buildHeaderIconButton(
                    icon: _showFilters
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined,
                    color: _showFilters
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    onTap: () {
                      setState(() => _showFilters = !_showFilters);
                    },
                  ),

                  const SizedBox(width: 8),

                  // Botón carrito con badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildHeaderIconButton(
                        icon: Icons.shopping_cart_outlined,
                        color: AppColors.textSecondary,
                        onTap: () {
                          _showCartBottomSheet();
                        },
                      ),
                      if (cartItemCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              cartItemCount > 99 ? '99+' : '$cartItemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: AppColors.textDisabled.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textDisabled.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _filterProducts();
          _filterServices();
        },
        style: TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '¿Qué estás buscando?',
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterProducts();
                    _filterServices();
                  },
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildModernFilters() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textDisabled.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: Icon(Icons.clear_all, size: 18, color: AppColors.primary),
                label: Text(
                  'Limpiar',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filtros según tab activo
          if (_tabController.index == 0) ...[
            _buildModernDropdown(
              'Categoría',
              _selectedProductCategory,
              _productCategories,
              (value) {
                setState(() => _selectedProductCategory = value ?? '');
                _filterProducts();
              },
            ),
          ] else ...[
            _buildModernDropdown(
              'Categoría',
              _selectedServiceCategory,
              _serviceCategories,
              (value) {
                setState(() => _selectedServiceCategory = value ?? '');
                _filterServices();
              },
            ),
            const SizedBox(height: 16),
            _buildModernDropdown(
              'Dificultad',
              _selectedDifficulty,
              {
                'FACIL': 'Fácil',
                'MODERADO': 'Moderado',
                'DIFICIL': 'Difícil',
                'EXTREMO': 'Extremo',
              },
              (value) {
                setState(() => _selectedDifficulty = value ?? '');
                _filterServices();
              },
            ),
          ],

          const SizedBox(height: 20),

          // Rango de precios
          Text(
            'Rango de precio',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'S/ ${_minPrice.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'S/ ${_maxPrice.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primaryBackground,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0,
              max: 2000,
              divisions: 40,
              onChanged: (values) {
                setState(() {
                  _minPrice = values.start;
                  _maxPrice = values.end;
                });
              },
              onChangeEnd: (values) {
                _filterProducts();
                _filterServices();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown(
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(
              color: AppColors.textDisabled.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.isEmpty ? null : value,
              hint: Text(
                'Seleccionar $label',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary),
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text(
                    'Todos',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...options.entries.map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.textDisabled.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            height: 44,
            child: Text('Productos'),
          ),
          Tab(
            height: 44,
            child: Text('Servicios'),
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            _filterProducts();
          } else {
            _filterServices();
          }
        },
      ),
    );
  }

  Widget _buildModernProductsGrid() {
    if (_isLoadingProducts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando productos...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No hay productos',
        subtitle: 'Intenta ajustar los filtros de búsqueda',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildModernServicesGrid() {
    if (_isLoadingServices) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando servicios...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredServices.isEmpty) {
      return _buildEmptyState(
        icon: Icons.explore_outlined,
        title: 'No hay servicios',
        subtitle: 'Intenta ajustar los filtros de búsqueda',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return _buildServiceCard(service);
      },
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 50,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(StoreProduct product) {
    final isFavorite = _favoriteProducts.contains(product.id);
    final imageUrl = product.images.isNotEmpty ? product.images[0] : '';

    return GestureDetector(
      onTap: () {
        showProductDetail(context, product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textDisabled.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: imageUrl.isNotEmpty
                        ? Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage('🎨');
                            },
                          )
                        : _buildPlaceholderImage('🎨'),
                  ),
                ),

                // Botones de acción en la imagen
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      _buildIconActionButton(
                        icon:
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.error : Colors.white,
                        backgroundColor: isFavorite
                            ? Colors.white
                            : Colors.black.withOpacity(0.3),
                        onTap: () {
                          setState(() {
                            if (isFavorite) {
                              _favoriteProducts.remove(product.id);
                            } else {
                              _favoriteProducts.add(product.id);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 6),
                      _buildIconActionButton(
                        icon: Icons.share_outlined,
                        color: Colors.white,
                        backgroundColor: Colors.black.withOpacity(0.3),
                        onTap: () {
                          final shareText =
                              '¡Mira este producto! ${product.title}\n'
                              '${product.description}\n'
                              'Precio: ${product.formattedPrice}\n'
                              'Artesano: ${product.artisanName}';
                          Clipboard.setData(ClipboardData(text: shareText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Información copiada al portapapeles'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Badge de categoría
                if (product.categoryDisplayName.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.categoryDisplayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Información del producto
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nombre del producto
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Rating y precio en una sola línea
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        if (product.rating > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 9,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.formattedRating,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),

                        // Precio
                        Text(
                          product.formattedPrice,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Botón agregar al carrito
                    SizedBox(
                      width: double.infinity,
                      height: 22,
                      child: ElevatedButton(
                        onPressed: () {
                          _addToCart(product.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_shopping_cart, size: 11),
                            const SizedBox(width: 3),
                            Text(
                              'Agregar',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(TourismService service) {
    final isFavorite = _favoriteServices.contains(service.id);
    final imageUrl = service.images.isNotEmpty ? service.images[0] : '';

    return GestureDetector(
      onTap: () {
        showServiceDetail(context, service);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textDisabled.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del servicio
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: imageUrl.isNotEmpty
                        ? Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage('🗺️');
                            },
                          )
                        : _buildPlaceholderImage('🗺️'),
                  ),
                ),

                // Botones de acción
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      _buildIconActionButton(
                        icon:
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.error : Colors.white,
                        backgroundColor: isFavorite
                            ? Colors.white
                            : Colors.black.withOpacity(0.3),
                        onTap: () {
                          setState(() {
                            if (isFavorite) {
                              _favoriteServices.remove(service.id);
                            } else {
                              _favoriteServices.add(service.id);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 6),
                      _buildIconActionButton(
                        icon: Icons.share_outlined,
                        color: Colors.white,
                        backgroundColor: Colors.black.withOpacity(0.3),
                        onTap: () {
                          final shareText =
                              '¡Mira este servicio! ${service.title}\n'
                              '${service.description}\n'
                              'Precio: ${service.formattedPrice}\n'
                              'Duración: ${service.formattedDuration}';
                          Clipboard.setData(ClipboardData(text: shareText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Información copiada al portapapeles'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Badge de dificultad
                if (service.difficulty.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(service.difficulty),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getDifficultyLabel(service.difficulty),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Información del servicio
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nombre del servicio
                    Text(
                      service.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Rating y precio en una sola línea
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        if (service.rating > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 9,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                service.formattedRating,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),

                        // Precio
                        Text(
                          service.formattedPrice,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Botón reservar
                    SizedBox(
                      width: double.infinity,
                      height: 22,
                      child: ElevatedButton(
                        onPressed: () {
                          showServiceDetail(context, service);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_available, size: 11),
                            const SizedBox(width: 3),
                            Text(
                              'Ver detalles',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(String emoji) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }

  Widget _buildIconActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'FACIL':
        return AppColors.success;
      case 'MODERADO':
        return AppColors.warning;
      case 'DIFICIL':
        return Colors.orange[700]!;
      case 'EXTREMO':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'FACIL':
        return 'Fácil';
      case 'MODERADO':
        return 'Moderado';
      case 'DIFICIL':
        return 'Difícil';
      case 'EXTREMO':
        return 'Extremo';
      default:
        return difficulty;
    }
  }

  void _addToCart(String productId) {
    setState(() {
      _cartItems[productId] = (_cartItems[productId] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Producto agregado al carrito',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCartBottomSheet() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.shopping_cart_outlined, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Tu carrito está vacío',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mi Carrito',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Contenido
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Tienes ${_cartItems.length} producto(s) en tu carrito',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Aquí irían los items del carrito
                  Center(
                    child: Text(
                      'Funcionalidad completa próximamente',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer con total y botón
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'S/ 0.00',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // Acción de checkout
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Proceder al pago',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
