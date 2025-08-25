import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cultural_object_service.dart'; // Import the CulturalObjectService
import '../widgets/product_list_tile.dart'; // Import the ProductListTile

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({Key? key}) : super(key: key);

  @override
  _ProductsListScreenState createState() => _ProductsListScreenState();
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
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    setState(() {
      _isLoading = false;
      // TODO: Replace with actual fetched products
      // _products = fetchedProducts;
    });    _products = fetchedProducts;  } catch (e) {    // Handle error (e.g., show a snackbar)
      print('Error fetching products: $e');
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
        title: const Text('Products'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
 return ProductListTile(product: product);
              },
            ),
    );
  }
}