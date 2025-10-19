import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/store_product.dart';
import '../widgets/proxy_image.dart';
import '../core/theme/app_colors.dart';

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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductInfo(),
                    const SizedBox(height: 16),
                    _buildSpecs(),
                    const SizedBox(height: 16),
                    _buildArtisanInfo(),
                    const SizedBox(height: 16),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.product.typeDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.product.isAvailable
                          ? [
                              AppColors.success,
                              AppColors.success.withOpacity(0.8)
                            ]
                          : [
                              AppColors.warning,
                              AppColors.warning.withOpacity(0.8)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.product.isAvailable
                                ? AppColors.success
                                : AppColors.warning)
                            .withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '(${widget.product.reviewCount} reviews)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Text(
              '${widget.product.viewCount} vistas',
              style: TextStyle(
                fontSize: 11,
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            height: 1.5,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildSpecs() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Especificaciones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildSpecRow(
              'Ubicación', widget.product.location, Icons.location_on_outlined),
          _buildSpecRow(
              'Departamento', widget.product.department, Icons.map_outlined),
          _buildSpecRow('Stock disponible', '${widget.product.stock} unidades',
              Icons.inventory_2_outlined),
          _buildSpecRow(
              'Moneda', widget.product.currency, Icons.payments_outlined),
          _buildSpecRow('Creado', _formatDate(widget.product.createdAt),
              Icons.calendar_today_outlined),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Artesano',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Especialista en ${widget.product.categoryDisplayName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
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
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _contactArtisan(),
            icon: const Icon(Icons.chat_bubble_outline,
                color: Colors.white, size: 20),
            label: const Text(
              'Contactar Artesano',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: AppColors.primary.withOpacity(0.5),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botones secundarios
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _callArtisan(),
                  icon: Icon(Icons.phone_outlined,
                      color: AppColors.primary, size: 20),
                  label: Text(
                    'Llamar',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _emailArtisan(),
                  icon: Icon(Icons.email_outlined,
                      color: AppColors.secondary, size: 20),
                  label: Text(
                    'Email',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.secondary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
