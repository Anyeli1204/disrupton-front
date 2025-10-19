import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/social_post.dart';
import '../services/social_post_service.dart';

class CreatePostModal extends StatefulWidget {
  final Function(SocialPost)? onPostCreated;

  const CreatePostModal({
    super.key,
    this.onPostCreated,
  });

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();

  final List<File> _selectedImages = [];

  bool _isCreating = false;
  String _visibility = 'public';
  bool _allowComments = true;
  bool _allowSharing = true;

  final _maxImages = 10;
  final _maxDescriptionLength = 280;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🔥 CreatePostModal build called');
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        // Removemos borderRadius ya que ModalBottomSheet lo maneja
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 16),
                  _buildDescriptionSection(),
                  const SizedBox(height: 16),
                  _buildLocationSection(),
                  const SizedBox(height: 16),
                  _buildTagsSection(),
                  const SizedBox(height: 16),
                  _buildPrivacySection(),
                  const SizedBox(height: 32),
                  _buildPreview(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: _isCreating ? null : () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Nuevo post',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'RobotoMono',
                letterSpacing: -0.3,
                color: Color(0xFF111827),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: (_canPublish() && !_isCreating)
                    ? LinearGradient(
                        colors: [Color(0xFF39E079), Color(0xFF2BC965)],
                      )
                    : null,
                color:
                    (_canPublish() && !_isCreating) ? null : Color(0xFFD1D5DB),
                boxShadow: (_canPublish() && !_isCreating)
                    ? [
                        BoxShadow(
                          color: Color(0xFF39E079).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: (_canPublish() && !_isCreating) ? _createPost : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.white.withOpacity(0.6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  minimumSize: Size.zero,
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Publicar',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.camera_alt, color: Color(0xFF39E079)),
            const SizedBox(width: 8),
            const Text(
              'Fotos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'RobotoMono',
              ),
            ),
            const Text(
              ' (requerido)',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
                fontFamily: 'RobotoMono',
              ),
            ),
            const Spacer(),
            Text(
              '${_selectedImages.length}/$_maxImages',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Grid de imágenes seleccionadas
        if (_selectedImages.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length +
                (_selectedImages.length < _maxImages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return _buildAddImageButton();
              }
              return _buildImageItem(_selectedImages[index], index);
            },
          ),
        ] else ...[
          _buildImageDropZone(),
        ],
      ],
    );
  }

  Widget _buildImageDropZone() {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFF39E079).withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Color(0xFFE8FBF0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 48,
              color: Color(0xFF39E079),
            ),
            const SizedBox(height: 12),
            Text(
              'Toca para agregar fotos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mínimo 1 foto, máximo $_maxImages',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF39E079).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
          color: Color(0xFFE8FBF0),
        ),
        child: Icon(
          Icons.add,
          color: Color(0xFF2BC965),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildImageItem(File image, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit, color: Color(0xFF39E079)),
            const SizedBox(width: 8),
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'RobotoMono',
              ),
            ),
            const Spacer(),
            Text(
              '${_descriptionController.text.length}/$_maxDescriptionLength',
              style: TextStyle(
                color:
                    _descriptionController.text.length > _maxDescriptionLength
                        ? Colors.red
                        : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: _maxDescriptionLength,
          decoration: InputDecoration(
            hintText:
                '¿Qué quieres compartir? Usa #hashtags para llegar a más personas...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            counterText: '',
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF39E079)),
            const SizedBox(width: 8),
            const Text(
              'Ubicación',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'RobotoMono',
              ),
            ),
            const Text(
              ' (opcional)',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Ej: Cusco, Perú',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: const Icon(Icons.search),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tag, color: Color(0xFF39E079)),
            const SizedBox(width: 8),
            const Text(
              'Etiquetas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'RobotoMono',
              ),
            ),
            const Text(
              ' (opcional)',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _tagsController,
          decoration: InputDecoration(
            hintText: 'arte, cultura, tradición (separados por comas)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.security, color: Color(0xFF39E079)),
            const SizedBox(width: 8),
            const Text(
              'Configuración',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'RobotoMono',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Visibilidad
        Row(
          children: [
            const Text('Visibilidad:'),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                value: _visibility,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Público')),
                  DropdownMenuItem(
                      value: 'followers', child: Text('Seguidores')),
                  DropdownMenuItem(value: 'private', child: Text('Privado')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _visibility = value);
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Permitir comentarios
        Row(
          children: [
            Checkbox(
              value: _allowComments,
              onChanged: (value) {
                setState(() => _allowComments = value ?? true);
              },
            ),
            const Text('Permitir comentarios'),
          ],
        ),

        // Permitir compartir
        Row(
          children: [
            Checkbox(
              value: _allowSharing,
              onChanged: (value) {
                setState(() => _allowSharing = value ?? true);
              },
            ),
            const Text('Permitir compartir'),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    if (_selectedImages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vista previa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header simulado
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF39E079),
                    child: const Text(
                      'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'RobotoMono',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu nombre',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        'ahora',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Primera imagen de preview
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    image: FileImage(_selectedImages.first),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              if (_descriptionController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _descriptionController.text,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Métodos de interacción
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Tomar foto'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Elegir de galería'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();

      if (source == ImageSource.gallery &&
          _selectedImages.length < _maxImages) {
        // Permitir selección múltiple desde galería
        final List<XFile> images = await picker.pickMultipleMedia(
          limit: _maxImages - _selectedImages.length,
        );

        for (final image in images) {
          _selectedImages.add(File(image.path));
        }
      } else {
        // Selección individual desde cámara
        final XFile? image = await picker.pickImage(source: source);
        if (image != null && _selectedImages.length < _maxImages) {
          _selectedImages.add(File(image.path));
        }
      }

      setState(() {});
    } catch (e) {
      _showError('Error al seleccionar imagen: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  bool _canPublish() {
    return _selectedImages.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _descriptionController.text.length <= _maxDescriptionLength;
  }

  Future<void> _createPost() async {
    if (!_canPublish() || _isCreating) return;

    setState(() => _isCreating = true);

    try {
      // 1. Subir imágenes
      _showUploadProgress();
      final imageUrls = await SocialPostService.uploadPostImages(
        _selectedImages,
        _getCurrentUserId(),
      );

      // Cerrar diálogo de carga de imágenes
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Mostrar diálogo de creación de post
      _showCreatingPostProgress();

      // 2. Preparar tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // 3. Crear request
      final request = CreatePostRequest(
        imageUrls: imageUrls,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        tags: tags,
        visibility: _visibility,
        allowComments: _allowComments,
        allowSharing: _allowSharing,
      );

      // 4. Crear post
      final post = await SocialPostService.createPost(request);

      // Cerrar diálogo de creación de post
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // 5. Notificar éxito
      _showSuccess('¡Publicación creada exitosamente!');

      // 6. Notificar al parent y cerrar
      widget.onPostCreated?.call(post);

      if (mounted) {
        Navigator.pop(context, post);
      }
    } catch (e) {
      _showError('Error al crear publicación: $e');
    } finally {
      setState(() => _isCreating = false);
    }
  }

  void _showCreatingPostProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Creando publicación...'),
          ],
        ),
      ),
    );
  }

  void _showUploadProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Subiendo imágenes...'),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getCurrentUserId() {
    // TODO: Obtener del AuthProvider real
    return 'current_user_id';
  }
}
