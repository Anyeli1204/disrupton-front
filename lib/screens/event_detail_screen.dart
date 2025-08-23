import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildEventDetails(),
          ),
        ],
      ),
      floatingActionButton: widget.event.isPastEvent
          ? null
          : FloatingActionButton.extended(
              onPressed: _shareEvent,
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text(
                'Compartir',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.orange,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.event.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black45,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo
            widget.event.imageUrl != null
                ? Image.network(
                    widget.event.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderBackground(),
                  )
                : _buildPlaceholderBackground(),

            // Gradiente para mejorar la legibilidad del título
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // Badge de estado
            Positioned(
              top: 100,
              right: 16,
              child: _buildStatusBadge(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange[300]!,
            Colors.orange[600]!,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.event,
          size: 80,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.event.isPastEvent ? Colors.grey[600] : Colors.green,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.event.isPastEvent ? 'Finalizado' : 'Próximamente',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEventDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeSection(),
          const SizedBox(height: 24),
          _buildLocationSection(),
          const SizedBox(height: 24),
          _buildDescriptionSection(),
          const SizedBox(height: 24),
          _buildTagsSection(),
          const SizedBox(height: 24),
          _buildAdditionalInfo(),
          const SizedBox(height: 100), // Espacio para el FAB
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Fecha y Hora',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fecha formateada
            Text(
              _formatEventDate(widget.event.dateTime),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),

            // Tiempo restante o estado
            Text(
              widget.event.isPastEvent
                  ? 'Este evento ya ha finalizado'
                  : 'Faltan ${widget.event.timeUntilEvent}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        widget.event.isPastEvent ? Colors.grey : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ubicación',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.event.location,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (widget.event.latitude != null &&
                widget.event.longitude != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _openLocation,
                icon: const Icon(Icons.map),
                label: const Text('Ver en mapa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Colors.purple,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Descripción',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.event.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    if (widget.event.tags.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.label,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Categorías',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.event.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide(color: Colors.green.withOpacity(0.3)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información adicional',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.people,
              label: 'Asistentes registrados',
              value: '${widget.event.attendeesCount}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Creado',
              value: _formatDate(widget.event.createdAt),
            ),
            if (widget.event.updatedAt != widget.event.createdAt) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.edit,
                label: 'Última actualización',
                value: _formatDate(widget.event.updatedAt),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _formatEventDate(DateTime dateTime) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];

    const weekdays = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo'
    ];

    final weekday = weekdays[dateTime.weekday - 1];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$weekday, $day de $month de $year a las $hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;

    return '$day/$month/$year';
  }

  void _openLocation() async {
    if (widget.event.latitude != null && widget.event.longitude != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${widget.event.latitude},${widget.event.longitude}';

      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          _showSnackBar('No se pudo abrir el mapa');
        }
      } catch (e) {
        _showSnackBar('Error al abrir el mapa');
      }
    }
  }

  void _shareEvent() {
    // TODO: Implementar share nativo cuando se agregue la dependencia
    final eventInfo =
        '${widget.event.title} - ${widget.event.location} - ${_formatEventDate(widget.event.dateTime)}';
    print('Compartiendo evento: $eventInfo'); // Para debugging
    _showSnackBar('Función de compartir próximamente disponible');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
