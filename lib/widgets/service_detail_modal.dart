import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/tourism_service.dart';
import '../widgets/proxy_image.dart';
import '../core/theme/app_colors.dart';

class ServiceDetailModal extends StatefulWidget {
  final TourismService service;

  const ServiceDetailModal({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<ServiceDetailModal> createState() => _ServiceDetailModalState();
}

class _ServiceDetailModalState extends State<ServiceDetailModal>
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
                    _buildServiceInfo(),
                    const SizedBox(height: 16),
                    _buildServiceDetails(),
                    const SizedBox(height: 16),
                    _buildIncludedExcluded(),
                    const SizedBox(height: 16),
                    _buildRequirements(),
                    const SizedBox(height: 16),
                    _buildGuideInfo(),
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
          if (widget.service.images.isNotEmpty) ...[
            PageView.builder(
              controller: _imageController,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemCount: widget.service.images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: ProxyImage(
                    imageUrl: widget.service.images[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),

            // Indicadores de página
            if (widget.service.images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.service.images.asMap().entries.map((entry) {
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
                        widget.service.categoryIcon,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.service.categoryDisplayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildServiceInfo() {
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
                    widget.service.title,
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.service.location,
                          style: TextStyle(
                            fontSize: 13,
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
                  widget.service.formattedPrice,
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
                      colors: widget.service.isAvailable
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
                        color: (widget.service.isAvailable
                                ? AppColors.success
                                : AppColors.warning)
                            .withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.service.isAvailable ? 'Disponible' : 'No disponible',
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
            Flexible(
              child: Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < widget.service.rating.floor()
                          ? Icons.star
                          : (index < widget.service.rating
                              ? Icons.star_half
                              : Icons.star_border),
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                  const SizedBox(width: 6),
                  Text(
                    widget.service.formattedRating,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '(${widget.service.reviewCount} reviews)',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.service.viewCount} vistas',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
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
          widget.service.description,
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

  Widget _buildServiceDetails() {
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
            'Detalles del Servicio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.access_time_outlined,
                  label: 'Duración',
                  value: widget.service.formattedDuration,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.group_outlined,
                  label: 'Grupo máx.',
                  value: '${widget.service.maxGroupSize} personas',
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.trending_up_outlined,
                  label: 'Dificultad',
                  value: widget.service.difficultyDisplayName,
                  color: _getDifficultyColor(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Reservar con',
                  value: '${widget.service.advanceBookingDays} días',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          if (widget.service.languages.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDetailCard(
              icon: Icons.language_outlined,
              label: 'Idiomas',
              value: widget.service.languagesText,
              color: Colors.purple,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: fullWidth
          ? Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ],
            ),
    );
  }

  Widget _buildIncludedExcluded() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Incluido
        Expanded(
          child: _buildListSection(
            title: 'Incluido',
            icon: Icons.check_circle_outline,
            items: widget.service.included,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        // No incluido
        Expanded(
          child: _buildListSection(
            title: 'No incluido',
            icon: Icons.cancel_outlined,
            items: widget.service.notIncluded,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirements() {
    if (widget.service.requirements.isEmpty) return const SizedBox();

    return _buildListSection(
      title: 'Requisitos',
      icon: Icons.warning_amber_outlined,
      items: widget.service.requirements,
      color: AppColors.warning,
      fullWidth: true,
    );
  }

  Widget _buildListSection({
    required String title,
    IconData? icon,
    required List<String> items,
    required Color color,
    bool fullWidth = false,
  }) {
    if (items.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGuideInfo() {
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
                'Guía Turístico',
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
                    widget.service.guideName.isNotEmpty
                        ? widget.service.guideName[0].toUpperCase()
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
                      widget.service.guideName,
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
                      'Especialista en ${widget.service.categoryDisplayName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ubicación: ${widget.service.department}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            onPressed: () => _contactGuide(),
            icon: const Icon(Icons.chat_bubble_outline,
                color: Colors.white, size: 20),
            label: const Text(
              'Contactar Guía',
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
                  onPressed: () => _callGuide(),
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
                  onPressed: () => _emailGuide(),
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
    switch (widget.service.category.toUpperCase()) {
      case 'CULTURAL':
        return const Color(0xFF673AB7);
      case 'NATURALEZA':
        return const Color(0xFF4CAF50);
      case 'GASTRONOMICO':
        return const Color(0xFFFF5722);
      case 'AVENTURA':
        return const Color(0xFFFF9800);
      case 'MISTICO':
        return const Color(0xFF9C27B0);
      case 'ARQUEOLOGICO':
        return const Color(0xFF795548);
      default:
        return const Color(0xFF2196F3);
    }
  }

  Color _getDifficultyColor() {
    switch (widget.service.difficulty.toUpperCase()) {
      case 'FACIL':
        return AppColors.success;
      case 'MODERADO':
        return AppColors.warning;
      case 'DIFICIL':
        return AppColors.error;
      case 'EXTREMO':
        return AppColors.textPrimary;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _contactGuide() async {
    final message = '''
¡Hola ${widget.service.guideName}!

Me interesa el servicio "${widget.service.title}" que vi en la Tienda Cultural de Disrupton.

Ubicación: ${widget.service.location}
Precio: ${widget.service.formattedPrice}
Duración: ${widget.service.formattedDuration}
Grupo máximo: ${widget.service.maxGroupSize} personas
📅 Reserva anticipada: ${widget.service.advanceBookingDays} días

¿Podrías darme más información sobre disponibilidad y fechas?

¡Gracias!
    ''';

    final whatsappUrl =
        'https://wa.me/51${widget.service.guideContact.replaceAll(RegExp(r'[^0-9]'), '')}?text=${Uri.encodeComponent(message)}';

    try {
      await launchUrl(Uri.parse(whatsappUrl));
    } catch (e) {
      print('Error abriendo WhatsApp: $e');
      _showErrorSnackBar('No se pudo abrir WhatsApp');
    }
  }

  Future<void> _callGuide() async {
    final phoneUrl = 'tel:${widget.service.guideContact}';

    try {
      await launchUrl(Uri.parse(phoneUrl));
    } catch (e) {
      print('Error iniciando llamada: $e');
      _showErrorSnackBar('No se pudo iniciar la llamada');
    }
  }

  Future<void> _emailGuide() async {
    final subject = 'Consulta sobre ${widget.service.title}';
    final body = '''
Hola ${widget.service.guideName},

Me interesa el servicio "${widget.service.title}" que vi en la Tienda Cultural de Disrupton.

Detalles del servicio:
- Ubicación: ${widget.service.location}
- Precio: ${widget.service.formattedPrice}
- Duración: ${widget.service.formattedDuration}
- Grupo máximo: ${widget.service.maxGroupSize} personas
- Dificultad: ${widget.service.difficultyDisplayName}

¿Podrías darme más información sobre disponibilidad y fechas?

Saludos,
    ''';

    final emailUrl =
        'mailto:${widget.service.guideContact}?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

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
void showServiceDetail(BuildContext context, TourismService service) {
  showDialog(
    context: context,
    builder: (context) => ServiceDetailModal(service: service),
  );
}
