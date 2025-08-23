import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class CreateEditEventScreen extends StatefulWidget {
  final Event? eventToEdit;

  const CreateEditEventScreen({
    Key? key,
    this.eventToEdit,
  }) : super(key: key);

  @override
  _CreateEditEventScreenState createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _locationController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _tagsController;

  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;
  List<String> _tags = [];

  bool get _isEditing => widget.eventToEdit != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (_isEditing) {
      _loadEventData();
    }
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _imageUrlController = TextEditingController();
    _locationController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _tagsController = TextEditingController();
  }

  void _loadEventData() {
    final event = widget.eventToEdit!;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _imageUrlController.text = event.imageUrl ?? '';
    _locationController.text = event.location;
    _latitudeController.text = event.latitude?.toString() ?? '';
    _longitudeController.text = event.longitude?.toString() ?? '';
    _selectedDateTime = event.dateTime;
    _tags = List.from(event.tags);
    _tagsController.text = _tags.join(', ');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Evento' : 'Crear Evento'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteEvent,
              tooltip: 'Eliminar evento',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _saveEvent,
        backgroundColor: Colors.orange,
        icon: Icon(
          _isEditing ? Icons.save : Icons.add,
          color: Colors.white,
        ),
        label: Text(
          _isEditing ? 'Guardar' : 'Crear',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildDateTimeSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildImageSection(),
            const SizedBox(height: 24),
            _buildTagsSection(),
            const SizedBox(height: 100), // Espacio para FAB
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
            ),
            const SizedBox(height: 16),

            // Título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del evento *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es obligatorio';
                }
                if (value.trim().length < 3) {
                  return 'El título debe tener al menos 3 caracteres';
                }
                return null;
              },
              maxLength: 100,
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es obligatoria';
                }
                if (value.trim().length < 10) {
                  return 'La descripción debe tener al menos 10 caracteres';
                }
                return null;
              },
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha y Hora',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDateTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha y hora del evento',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(_selectedDateTime),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            if (_selectedDateTime.isBefore(DateTime.now()))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Advertencia: La fecha seleccionada es en el pasado',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                  ),
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
            Text(
              'Ubicación',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 16),

            // Dirección
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Dirección/Lugar *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La ubicación es obligatoria';
                }
                return null;
              },
              maxLength: 200,
            ),
            const SizedBox(height: 16),

            // Coordenadas (opcional)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitud (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lat = double.tryParse(value);
                        if (lat == null || lat < -90 || lat > 90) {
                          return 'Latitud inválida';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitud (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lng = double.tryParse(value);
                        if (lng == null || lng < -180 || lng > 180) {
                          return 'Longitud inválida';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Imagen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de imagen (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
                hintText: 'https://ejemplo.com/imagen.jpg',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasScheme) {
                    return 'URL inválida';
                  }
                }
                return null;
              },
            ),

            // Preview de imagen
            if (_imageUrlController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imageUrlController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, color: Colors.grey),
                            Text('No se pudo cargar la imagen',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categorías/Tags',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (separados por comas)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
                hintText: 'arte, cultura, música, festival',
              ),
              onChanged: _updateTags,
            ),

            // Mostrar tags actuales
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                          backgroundColor: Colors.green.withOpacity(0.1),
                          labelStyle: const TextStyle(color: Colors.green),
                          deleteIconColor: Colors.green,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares

  String _formatDateTime(DateTime dateTime) {
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

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day de $month de $year a las $hour:$minute';
  }

  void _updateTags(String value) {
    final newTags = value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    setState(() {
      _tags = newTags;
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _tagsController.text = _tags.join(', ');
    });
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now()
          .subtract(const Duration(days: 30)), // Permitir pasado para edición
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final latitude = _latitudeController.text.isNotEmpty
          ? double.tryParse(_latitudeController.text)
          : null;
      final longitude = _longitudeController.text.isNotEmpty
          ? double.tryParse(_longitudeController.text)
          : null;

      if (_isEditing) {
        // Actualizar evento existente
        final updateRequest = EventUpdateRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isNotEmpty
              ? _imageUrlController.text.trim()
              : null,
          dateTime: _selectedDateTime,
          location: _locationController.text.trim(),
          latitude: latitude,
          longitude: longitude,
          tags: _tags,
        );

        await _eventService.updateEvent(widget.eventToEdit!.id, updateRequest);
        _showSnackBar('Evento actualizado exitosamente');
      } else {
        // Crear nuevo evento
        final createRequest = EventCreateRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isNotEmpty
              ? _imageUrlController.text.trim()
              : null,
          dateTime: _selectedDateTime,
          location: _locationController.text.trim(),
          latitude: latitude,
          longitude: longitude,
          tags: _tags,
        );

        // Validar datos antes de enviar
        final validationError = _eventService.validateEventData(createRequest);
        if (validationError != null) {
          _showSnackBar(validationError);
          setState(() => _isLoading = false);
          return;
        }

        await _eventService.createEvent(createRequest);
        _showSnackBar('Evento creado exitosamente');
      }

      Navigator.pop(context, true); // Retornar true para indicar éxito
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEvent() async {
    if (!_isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar "${widget.eventToEdit!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _eventService.deleteEvent(widget.eventToEdit!.id);
      _showSnackBar('Evento eliminado exitosamente');
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Error al eliminar evento: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
