import 'package:flutter/material.dart';
import '../models/store_product.dart';
import '../models/tourism_service.dart';
import '../services/store_service.dart';
import '../widgets/product_card.dart';
import '../widgets/service_card.dart';

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

  // Filtros
  String _selectedProductCategory = '';
  String _selectedServiceCategory = '';
  String _selectedDifficulty = '';
  double _minPrice = 0;
  double _maxPrice = 1000;
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
    setState(() => _isLoadingProducts = true);

    try {
      final products = await StoreService.getAllProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      print('Error cargando productos: $e');
      setState(() => _isLoadingProducts = false);
    }
  }

  /// Cargar servicios
  Future<void> _loadServices() async {
    setState(() => _isLoadingServices = true);

    try {
      final services = await StoreService.getAllServices();
      setState(() {
        _allServices = services;
        _filteredServices = services;
        _isLoadingServices = false;
      });
    } catch (e) {
      print('Error cargando servicios: $e');
      setState(() => _isLoadingServices = false);
    }
  }

  /// Cargar categorías
  Future<void> _loadCategories() async {
    try {
      final productCats = await StoreService.getProductCategories();
      final serviceCats = await StoreService.getServiceCategories();

      setState(() {
        _productCategories = productCats;
        _serviceCategories = serviceCats;
      });
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
      _maxPrice = 1000;
      _filteredProducts = _allProducts;
      _filteredServices = _allServices;
    });
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
              const Color(0xFF1A237E).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header personalizado
              _buildHeader(),

              // Barra de búsqueda
              _buildSearchBar(),

              // Filtros (si están visibles)
              if (_showFilters) _buildFilters(),

              // Tabs y contenido
              Expanded(
                child: Column(
                  children: [
                    // Tab bar personalizado
                    _buildTabBar(),

                    // Contenido de tabs
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildProductsTab(),
                          _buildServicesTab(),
                        ],
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Botón back
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🛍️ Tienda Cultural',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                Text(
                  'Productos artesanales y turismo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Botones de acción
          Row(
            children: [
              // Botón favoritos
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/favorites');
                },
                icon: const Icon(
                  Icons.favorite_border,
                  color: Color(0xFFE91E63),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Botón filtros
              IconButton(
                onPressed: () {
                  setState(() => _showFilters = !_showFilters);
                },
                icon: Icon(
                  _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                  color: _showFilters ? const Color(0xFF1A237E) : Colors.grey,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _filterProducts();
          _filterServices();
        },
        decoration: InputDecoration(
          hintText: 'Buscar productos o servicios...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterProducts();
                    _filterServices();
                  },
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Limpiar'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filtros según tab activo
          if (_tabController.index == 0) ...[
            // Filtros de productos
            _buildDropdown(
              'Categoría',
              _selectedProductCategory,
              _productCategories,
              (value) {
                setState(() => _selectedProductCategory = value ?? '');
                _filterProducts();
              },
            ),
          ] else ...[
            // Filtros de servicios
            _buildDropdown(
              'Categoría',
              _selectedServiceCategory,
              _serviceCategories,
              (value) {
                setState(() => _selectedServiceCategory = value ?? '');
                _filterServices();
              },
            ),
            const SizedBox(height: 12),
            _buildDropdown(
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

          const SizedBox(height: 16),

          // Rango de precios
          Text(
            'Precio: S/ ${_minPrice.toInt()} - S/ ${_maxPrice.toInt()}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              'S/ ${_minPrice.toInt()}',
              'S/ ${_maxPrice.toInt()}',
            ),
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
        ],
      ),
    );
  }

  Widget _buildDropdown(
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
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.isEmpty ? null : value,
              hint: Text('Seleccionar $label'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('Todos'),
                ),
                ...options.entries.map((entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    )),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF1A237E),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎨'),
                const SizedBox(width: 8),
                Text('Productos (${_filteredProducts.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🗺️'),
                const SizedBox(width: 8),
                Text('Servicios (${_filteredServices.length})'),
              ],
            ),
          ),
        ],
        onTap: (index) {
          // Recargar filtros cuando cambie de tab
          if (index == 0) {
            _filterProducts();
          } else {
            _filterServices();
          }
        },
      ),
    );
  }

  Widget _buildProductsTab() {
    if (_isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1A237E),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron productos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta ajustar los filtros de búsqueda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
          product: product,
        );
      },
    );
  }

  Widget _buildServicesTab() {
    if (_isLoadingServices) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1A237E),
        ),
      );
    }

    if (_filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron servicios',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta ajustar los filtros de búsqueda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return ServiceCard(
          service: service,
        );
      },
    );
  }
}
