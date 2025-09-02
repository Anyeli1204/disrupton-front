// Pantalla de Lista de Productos (de Yeimi)
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cultural_object_service.dart';
import '../widgets/product_list_tile.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  final CulturalObjectService _culturalObjectService = CulturalObjectService();

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedProducts = await _culturalObjectService.fetchProducts();
      setState(() {
        _products = fetchedProducts;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos Culturales'),
        backgroundColor: Colors.deepPurple.shade600,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(
                  child: Text(
                    'No hay productos disponibles',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      return ProductListTile(product: _products[index]);
                    },
                  ),
                ),
    );
  }
}
