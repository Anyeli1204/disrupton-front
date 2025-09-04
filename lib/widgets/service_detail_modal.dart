import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/tourism_service.dart';
import '../widgets/proxy_image.dart';

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
        constraints: const BoxConstraints(maxHeight: 700),
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
                    _buildServiceInfo(),
                    const SizedBox(height: 20),
                    _buildServiceDetails(),
                    const SizedBox(height: 20),
                    _buildIncludedExcluded(),
                    const SizedBox(height: 20),
                    _buildRequirements(),
                    const SizedBox(height: 20),
                    _buildGuideInfo(),
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.service.location,
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
                  widget.service.formattedPrice,
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
                    color: widget.service.isAvailable
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
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
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < widget.service.rating.floor()
                      ? Icons.star
                      : (index < widget.service.rating
                          ? Icons.star_half
                          : Icons.star_border),
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              widget.service.formattedRating,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${widget.service.reviewCount} reviews)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            Text(
              '${widget.service.viewCount} vistas',
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
          widget.service.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDetails() {
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
            'Detalles del Servicio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.access_time,
                  label: 'Duración',
                  value: widget.service.formattedDuration,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.group,
                  label: 'Grupo máx.',
                  value: '${widget.service.maxGroupSize} personas',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.trending_up,
                  label: 'Dificultad',
                  value: widget.service.difficultyDisplayName,
                  color: _getDifficultyColor(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailCard(
                  icon: Icons.calendar_today,
                  label: 'Reservar con',
                  value: '${widget.service.advanceBookingDays} días',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          if (widget.service.languages.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailCard(
              icon: Icons.language,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: fullWidth
          ? Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
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
            title: '✅ Incluido',
            items: widget.service.included,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        // No incluido
        Expanded(
          child: _buildListSection(
            title: '❌ No incluido',
            items: widget.service.notIncluded,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirements() {
    if (widget.service.requirements.isEmpty) return const SizedBox();

    return _buildListSection(
      title: '⚠️ Requisitos',
      items: widget.service.requirements,
      color: Colors.orange,
      fullWidth: true,
    );
  }

  Widget _buildListSection({
    required String title,
    required List<String> items,
    required Color color,
    bool fullWidth = false,
  }) {
    if (items.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• $item',
                  style: const TextStyle(fontSize: 14),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGuideInfo() {
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
            '🧭 Guía Turístico',
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Especialista en ${widget.service.categoryDisplayName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ubicación: ${widget.service.department}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
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
            onPressed: () => _contactGuide(),
            icon: const Icon(Icons.message, color: Colors.white),
            label: const Text(
              'Contactar Guía',
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
                onPressed: () => _callGuide(),
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
                onPressed: () => _emailGuide(),
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
        return Colors.green;
      case 'MODERADO':
        return Colors.orange;
      case 'DIFICIL':
        return Colors.red;
      case 'EXTREMO':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  Future<void> _contactGuide() async {
    final message = '''
¡Hola ${widget.service.guideName}!

Me interesa el servicio "${widget.service.title}" que vi en la Tienda Cultural de Disrupton.

📍 Ubicación: ${widget.service.location}
💰 Precio: ${widget.service.formattedPrice}
⏰ Duración: ${widget.service.formattedDuration}
👥 Grupo máximo: ${widget.service.maxGroupSize} personas
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
