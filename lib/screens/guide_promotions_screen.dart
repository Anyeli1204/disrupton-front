import 'package:flutter/material.dart';
import '../models/role_models.dart';
import '../services/guide_service.dart';

class GuidePromotionsScreen extends StatefulWidget {
  const GuidePromotionsScreen({super.key});

  @override
  State<GuidePromotionsScreen> createState() => _GuidePromotionsScreenState();
}

class _GuidePromotionsScreenState extends State<GuidePromotionsScreen> {
  List<GuidePromotion> _promotions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final promotions = await GuideService.getMyPromotions();
      setState(() {
        _promotions = promotions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePromotionStatus(GuidePromotion promotion) async {
    final success = await GuideService.togglePromotionStatus(
      promotion.id,
      !promotion.isActive,
    );

    if (success) {
      _loadPromotions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            promotion.isActive ? 'Promoción desactivada' : 'Promoción activada',
          ),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  void _showCreatePromotionDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreatePromotionDialog(
        onCreated: () {
          Navigator.pop(context);
          _loadPromotions();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Promociones'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadPromotions,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePromotionDialog,
        backgroundColor: Colors.teal.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildPromotionsList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.teal.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar promociones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadPromotions,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionsList() {
    if (_promotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes promociones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera promoción para atraer turistas',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showCreatePromotionDialog,
              icon: const Icon(Icons.add),
              label: const Text('Crear Promoción'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPromotions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _promotions.length,
        itemBuilder: (context, index) {
          final promotion = _promotions[index];
          return _buildPromotionCard(promotion);
        },
      ),
    );
  }

  Widget _buildPromotionCard(GuidePromotion promotion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (promotion.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                promotion.imageUrls.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        promotion.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Switch(
                      value: promotion.isActive,
                      onChanged: (_) => _togglePromotionStatus(promotion),
                      activeColor: Colors.teal,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Price and location
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'S/ ${promotion.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        promotion.location,
                        style: TextStyle(color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  promotion.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Details
                Row(
                  children: [
                    _buildDetailChip(
                      Icons.access_time,
                      '${promotion.duration}h',
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      Icons.group,
                      '${promotion.maxParticipants} max',
                      Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Contact info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.contact_phone, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          promotion.contactInfo,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePromotionDialog extends StatefulWidget {
  final VoidCallback onCreated;

  const _CreatePromotionDialog({required this.onCreated});

  @override
  State<_CreatePromotionDialog> createState() => _CreatePromotionDialogState();
}

class _CreatePromotionDialogState extends State<_CreatePromotionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _maxParticipantsController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final promotion = GuidePromotion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      guideId: 'current_guide',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      currency: 'PEN',
      imageUrls: [], // TODO: Add image upload functionality
      location: _locationController.text.trim(),
      duration: int.parse(_durationController.text),
      maxParticipants: int.parse(_maxParticipantsController.text),
      highlights: [], // TODO: Add highlights functionality
      contactInfo: _contactController.text.trim(),
      isActive: true,
      createdAt: DateTime.now(),
    );

    final success = await GuideService.createPromotion(promotion);

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      widget.onCreated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promoción creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear la promoción'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Promoción'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    hintText: 'Ej: Tour Machu Picchu',
                  ),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'El título es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                    hintText: 'Describe tu tour o servicio',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'La descripción es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio (PEN) *',
                          hintText: '150',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'El precio es requerido';
                          }
                          if (double.tryParse(value!) == null) {
                            return 'Precio inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duración (horas) *',
                          hintText: '8',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'La duración es requerida';
                          }
                          if (int.tryParse(value!) == null) {
                            return 'Duración inválida';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación *',
                    hintText: 'Cusco, Perú',
                  ),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'La ubicación es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxParticipantsController,
                  decoration: const InputDecoration(
                    labelText: 'Máximo participantes *',
                    hintText: '12',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'El número máximo es requerido';
                    }
                    if (int.tryParse(value!) == null) {
                      return 'Número inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contacto *',
                    hintText: 'WhatsApp: +51 987 654 321',
                  ),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'La información de contacto es requerida';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade600,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }
}
