import 'package:flutter/material.dart';
import '../models/collection_models.dart';
import '../models/ai_chat_models.dart';
import '../widgets/safe_network_image.dart';
import '../widgets/floating_ai_avatar.dart';
import '../widgets/ai_chat_widget.dart';
import '../services/ai_chat_service.dart';

class CulturalObjectDetailScreen extends StatefulWidget {
  final CulturalObject object;

  const CulturalObjectDetailScreen({
    super.key,
    required this.object,
  });

  @override
  State<CulturalObjectDetailScreen> createState() =>
      _CulturalObjectDetailScreenState();
}

class _CulturalObjectDetailScreenState
    extends State<CulturalObjectDetailScreen> {
  bool _isChatOpen = false;
  late AvatarType _selectedAvatar;

  @override
  void initState() {
    super.initState();
    // Obtener el avatar recomendado para este objeto
    _selectedAvatar = AiChatService.getRecommendedAvatar(widget.object);
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }

  void _closeChat() {
    setState(() {
      _isChatOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenido principal del objeto cultural
          CustomScrollView(
            slivers: [
              // App Bar con imagen
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.deepPurple.shade600,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade600,
                        ],
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Imagen real del objeto
                        SafeNetworkImage(
                          imageUrl: widget.object.imageUrl,
                          regionId: widget.object.departmentId,
                          category: widget.object.category,
                          fit: BoxFit.cover,
                        ),

                        // Overlay gradiente
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareObject(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () => _toggleFavorite(context),
                  ),
                ],
              ),

              // Contenido
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y categoría
                      Text(
                        widget.object.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.object.category,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Descripción
                      _buildSection(
                        title: 'Descripción',
                        icon: Icons.description,
                        child: Text(
                          widget.object.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Información adicional
                      if (widget.object.additionalInfo != null &&
                          widget.object.additionalInfo!.isNotEmpty)
                        _buildAdditionalInfo(),

                      const SizedBox(height: 24),

                      // Información del departamento
                      _buildSection(
                        title: 'Origen',
                        icon: Icons.place,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Departamento de ${_getDepartmentName(widget.object.departmentId)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Registrado el ${_formatDate(widget.object.createdAt)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botones de acción
                      _buildActionButtons(context),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Avatar flotante de IA (solo si el chat no está abierto)
          if (!_isChatOpen)
            FloatingAiAvatar(
              avatarType: _selectedAvatar,
              onTap: _toggleChat,
              isActive: false,
            ),

          // Chat overlay (cuando está abierto)
          if (_isChatOpen)
            Positioned.fill(
              child: Column(
                children: [
                  // Parte superior: vista minimizada del objeto cultural
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: _closeChat,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black54,
                              Colors.black26,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Imagen de fondo del objeto
                            Positioned.fill(
                              child: SafeNetworkImage(
                                imageUrl: widget.object.imageUrl,
                                regionId: widget.object.departmentId,
                                category: widget.object.category,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Overlay oscuro
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            // Información del objeto
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.object.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 1),
                                            blurRadius: 3,
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        widget.object.category,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.touch_app,
                                          color: Colors.white.withOpacity(0.8),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Toca para volver al objeto',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Parte inferior: chat
                  AiChatWidget(
                    avatarType: _selectedAvatar,
                    culturalObject: widget.object,
                    onClose: _closeChat,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.deepPurple.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return _buildSection(
      title: 'Información adicional',
      icon: Icons.info,
      child: Column(
        children: widget.object.additionalInfo!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '${_capitalize(entry.key)}:',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _viewInAR(context),
            icon: const Icon(Icons.view_in_ar),
            label: const Text(
              'Ver en Realidad Aumentada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showMoreInfo(context),
                icon: const Icon(Icons.info_outline),
                label: const Text('Más información'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple.shade600,
                  side: BorderSide(color: Colors.deepPurple.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addToCollection(context),
                icon: const Icon(Icons.bookmark_add),
                label: const Text('Guardar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple.shade600,
                  side: BorderSide(color: Colors.deepPurple.shade600),
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

  String _getDepartmentName(String departmentId) {
    // Mapeo simplificado de IDs a nombres
    final departmentNames = {
      'amazonas': 'Amazonas',
      'ancash': 'Áncash',
      'apurimac': 'Apurímac',
      'arequipa': 'Arequipa',
      'ayacucho': 'Ayacucho',
      'cajamarca': 'Cajamarca',
      'callao': 'Callao',
      'cusco': 'Cusco',
      'huancavelica': 'Huancavelica',
      'huanuco': 'Huánuco',
      'ica': 'Ica',
      'junin': 'Junín',
      'la_libertad': 'La Libertad',
      'lambayeque': 'Lambayeque',
      'lima': 'Lima',
      'loreto': 'Loreto',
      'madre_de_dios': 'Madre de Dios',
      'moquegua': 'Moquegua',
      'pasco': 'Pasco',
      'piura': 'Piura',
      'puno': 'Puno',
      'san_martin': 'San Martín',
      'tacna': 'Tacna',
      'tumbes': 'Tumbes',
    };

    return departmentNames[departmentId] ?? departmentId;
  }

  String _formatDate(DateTime date) {
    final months = [
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

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _shareObject(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir en desarrollo'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleFavorite(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Agregado a favoritos'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewInAR(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Realidad Aumentada'),
        content: const Text(
          'Esta función abrirá el objeto en modo AR. '
          'Asegúrate de tener permisos de cámara activados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí iría la navegación al viewer AR
            },
            child: const Text('Abrir AR'),
          ),
        ],
      ),
    );
  }

  void _showMoreInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.object.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${widget.object.id}'),
              const SizedBox(height: 8),
              Text('Categoría: ${widget.object.category}'),
              const SizedBox(height: 8),
              Text(
                  'Departamento: ${_getDepartmentName(widget.object.departmentId)}'),
              const SizedBox(height: 8),
              Text(
                  'Fecha de registro: ${_formatDate(widget.object.createdAt)}'),
              if (widget.object.additionalInfo != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Información adicional:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.object.additionalInfo!.entries.map(
                  (entry) => Text('${_capitalize(entry.key)}: ${entry.value}'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _addToCollection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.object.name} guardado en tu colección'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver colección',
          onPressed: () {
            // Navegar a la colección personal del usuario
          },
        ),
      ),
    );
  }
}
