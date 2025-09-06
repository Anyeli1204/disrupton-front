import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/store_product.dart';
import '../widgets/proxy_image.dart';
import '../widgets/product_detail_modal.dart';
import '../providers/favorites_provider.dart';

class ProductCard extends StatelessWidget {
  final StoreProduct product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(product.id);

        return Card(
          elevation: 6, // Reducido de 8 a 6
          margin: const EdgeInsets.all(6), // Reducido de 8 a 6
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14), // Reducido de 16 a 14
          ),
          child: InkWell(
            onTap: () => _showProductDetail(context),
            borderRadius: BorderRadius.circular(14), // Reducido de 16 a 14
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14), // Reducido de 16 a 14
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getCategoryColor(product.category).withOpacity(0.1),
                    _getCategoryColor(product.category).withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header con categoría y favorito
                  Container(
                    padding: const EdgeInsets.all(8), // Reducido de 12 a 8
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Categoría
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(product.category),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  product.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _getCategoryColor(product.category),
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botón favorito
                        IconButton(
                          onPressed: () =>
                              _toggleFavorite(context, favoritesProvider),
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Imagen principal
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      child: ClipRoundedRectangle(
                        borderRadius: 12,
                        child: product.mainImage.isNotEmpty
                            ? ProxyImage(
                                imageUrl: product.mainImage,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sin imagen',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Información del producto
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(8), // Reducido de 12 a 8
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 13, // Reducido de 14
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3), // Reducido de 4

                          // Artesano
                          if (product.artisanName.isNotEmpty)
                            Text(
                              'Por ${product.artisanName}',
                              style: TextStyle(
                                fontSize: 10, // Reducido de 11
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                          const Spacer(),

                          // Precio y ubicación
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Precio
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(product.category)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getCategoryColor(product.category)
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'S/ ${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getCategoryColor(product.category),
                                  ),
                                ),
                              ),

                              // Ubicación
                              if (product.location.isNotEmpty)
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 2),
                                      Flexible(
                                        child: Text(
                                          product.location,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Disponibilidad
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: product.isActive
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.isActive ? 'DISPONIBLE' : 'AGOTADO',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: product.isActive
                                    ? const Color(0xFF4CAF50)
                                    : Colors.red,
                                letterSpacing: 0.5,
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
          ),
        );
      },
    );
  }

  void _showProductDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProductDetailModal(product: product),
    );
  }

  Future<void> _toggleFavorite(
      BuildContext context, FavoritesProvider favoritesProvider) async {
    final success = await favoritesProvider.toggleFavorite(product);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar favoritos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'TEXTILES':
        return const Color(0xFF9C27B0); // Purple
      case 'CERAMICA':
        return const Color(0xFF795548); // Brown
      case 'ORFEBRERIA':
        return const Color(0xFFFFD700); // Gold
      case 'MADERA':
        return const Color(0xFF8D6E63); // Wood brown
      case 'CUERO':
        return const Color(0xFF6D4C41); // Leather brown
      case 'PIEDRA':
        return const Color(0xFF607D8B); // Blue grey
      default:
        return const Color(0xFF2196F3); // Default blue
    }
  }
}

class ClipRoundedRectangle extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const ClipRoundedRectangle({
    Key? key,
    required this.child,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: child,
    );
  }
}
