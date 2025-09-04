import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/store_product.dart';
import '../widgets/proxy_image.dart';

class ProductDetailModal extends StatefulWidget {
  final StoreProduct product;

  const ProductDetailModal({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal>
    with SingleTickerProviderStateMixin {
  late PageController _imageController;
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con imagen y close button
            _buildHeader(),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductInfo(),
                    const SizedBox(height: 20),
                    _buildSpecs(),
                    const SizedBox(height: 20),
                    _buildArtisanInfo(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor().withOpacity(0.2),
            _getCategoryColor().withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Galería de imágenes
          if (widget.product.images.isNotEmpty) ...[
            PageView.builder(
              controller: _imageController,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemCount: widget.product.images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: ProxyImage(
                    imageUrl: widget.product.images[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),

            // Indicadores de página
            if (widget.product.images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.product.images.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == entry.key
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ] else ...[
            // Placeholder sin imagen
            Container(
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sin imágenes disponibles',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Botones superiores
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Categoría badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.product.categoryIcon,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.product.categoryDisplayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botones de acción
                Row(
                  children: [
                    // Favorito
                    _buildActionButton(
                      icon:
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                      onPressed: () {
                        setState(() => _isFavorite = !_isFavorite);
                      },
                    ),
                    const SizedBox(width: 8),

                    // Cerrar
                    _buildActionButton(
                      icon: Icons.close,
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        iconSize: 20,
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y precio
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        widget.product.typeIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.product.typeDisplayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.product.formattedPrice,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.product.isAvailable
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.product.isAvailable ? 'Disponible' : 'Agotado',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Rating y reviews
        Row(
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < widget.product.rating.floor()
                      ? Icons.star
                      : (index < widget.product.rating
                          ? Icons.star_half
                          : Icons.star_border),
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              widget.product.formattedRating,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${widget.product.reviewCount} reviews)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            Text(
              '${widget.product.viewCount} vistas',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Descripción
        Text(
          'Descripción',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Especificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSpecRow('📍 Ubicación', widget.product.location),
          _buildSpecRow('🏛️ Departamento', widget.product.department),
          _buildSpecRow(
              '📦 Stock disponible', '${widget.product.stock} unidades'),
          _buildSpecRow('💰 Moneda', widget.product.currency),
          _buildSpecRow('📅 Creado', _formatDate(widget.product.createdAt)),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getCategoryColor().withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👨‍🎨 Artesano',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor(),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.product.artisanName.isNotEmpty
                        ? widget.product.artisanName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.artisanName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Especialista en ${widget.product.categoryDisplayName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón principal de contacto
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _contactArtisan(),
            icon: const Icon(Icons.message, color: Colors.white),
            label: const Text(
              'Contactar Artesano',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getCategoryColor(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botones secundarios
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _callArtisan(),
                icon: Icon(Icons.phone, color: _getCategoryColor()),
                label: Text(
                  'Llamar',
                  style: TextStyle(color: _getCategoryColor()),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _getCategoryColor()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _emailArtisan(),
                icon: Icon(Icons.email, color: _getCategoryColor()),
                label: Text(
                  'Email',
                  style: TextStyle(color: _getCategoryColor()),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _getCategoryColor()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (widget.product.category.toUpperCase()) {
      case 'TEXTILES':
        return const Color(0xFF9C27B0);
      case 'CERAMICA':
        return const Color(0xFF795548);
      case 'ORFEBRERIA':
        return const Color(0xFFFFD700);
      case 'MADERA':
        return const Color(0xFF8D6E63);
      case 'CUERO':
        return const Color(0xFF6D4C41);
      case 'PIEDRA':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF2196F3);
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _contactArtisan() async {
    final message = '''
¡Hola ${widget.product.artisanName}!

Me interesa tu producto "${widget.product.title}" que vi en la Tienda Cultural de Disrupton.

Precio: ${widget.product.formattedPrice}
Ubicación: ${widget.product.location}

¿Podrías darme más información sobre disponibilidad y formas de pago?

¡Gracias!
    ''';

    final whatsappUrl =
        'https://wa.me/51${widget.product.artisanPhone.replaceAll(RegExp(r'[^0-9]'), '')}?text=${Uri.encodeComponent(message)}';

    try {
      await launchUrl(Uri.parse(whatsappUrl));
    } catch (e) {
      print('Error abriendo WhatsApp: $e');
      _showErrorSnackBar('No se pudo abrir WhatsApp');
    }
  }

  Future<void> _callArtisan() async {
    final phoneUrl = 'tel:${widget.product.artisanPhone}';

    try {
      await launchUrl(Uri.parse(phoneUrl));
    } catch (e) {
      print('Error iniciando llamada: $e');
      _showErrorSnackBar('No se pudo iniciar la llamada');
    }
  }

  Future<void> _emailArtisan() async {
    final subject = 'Consulta sobre ${widget.product.title}';
    final body = '''
Hola ${widget.product.artisanName},

Me interesa tu producto "${widget.product.title}" que vi en la Tienda Cultural de Disrupton.

Precio: ${widget.product.formattedPrice}
Ubicación: ${widget.product.location}

¿Podrías darme más información sobre disponibilidad y formas de pago?

Saludos,
    ''';

    final emailUrl =
        'mailto:${widget.product.artisanEmail}?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    try {
      await launchUrl(Uri.parse(emailUrl));
    } catch (e) {
      print('Error abriendo email: $e');
      _showErrorSnackBar('No se pudo abrir el cliente de email');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Función para mostrar el modal
void showProductDetail(BuildContext context, StoreProduct product) {
  showDialog(
    context: context,
    builder: (context) => ProductDetailModal(product: product),
  );
}
