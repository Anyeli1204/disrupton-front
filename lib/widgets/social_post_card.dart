import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/social_post.dart';
import '../services/social_post_service.dart';
import '../widgets/proxy_image.dart';

class SocialPostCard extends StatefulWidget {
  final SocialPost post;
  final Function(SocialPost)? onLike;
  final Function(SocialPost)? onSave;
  final Function(SocialPost)? onComment;
  final Function(SocialPost)? onShare;
  final Function(String)? onUserTap;
  final Function(String)? onTagTap;

  const SocialPostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onSave,
    this.onComment,
    this.onShare,
    this.onUserTap,
    this.onTagTap,
  });

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard> {
  late SocialPost _post;
  bool _isLiking = false;
  bool _isSaving = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con avatar y info del usuario
          _buildHeader(),

          // Galería de imágenes
          _buildImageGallery(),

          // Botones de acción
          _buildActionButtons(),

          // Info de likes y estadísticas
          _buildLikesInfo(),

          // Descripción y caption
          _buildCaption(),

          // Ubicación si existe
          if (_post.hasLocation) _buildLocation(),

          // Tags
          if (_post.hasTags) _buildTags(),

          // Footer con comentarios
          _buildCommentsPreview(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar del usuario
          GestureDetector(
            onTap: () => widget.onUserTap?.call(_post.userId),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.orange.shade300,
              backgroundImage: _post.userProfileImage != null
                  ? NetworkImage(_post.userProfileImage!)
                  : null,
              child: _post.userProfileImage == null
                  ? Text(
                      _post.userName.isNotEmpty
                          ? _post.userName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // Info del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => widget.onUserTap?.call(_post.userId),
                      child: Text(
                        _post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (_post.userRole != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(_post.userRole!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getRoleLabel(_post.userRole!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  _post.timeAgo,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Menú de opciones
          IconButton(
            onPressed: _showPostOptions,
            icon: const Icon(Icons.more_vert),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Container(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: _post.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: ProxyImage(
                  imageUrl: _post.imageUrls[index],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),

          // Indicador de páginas si hay múltiples imágenes
          if (_post.imageUrls.length > 1) ...[
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${_post.imageUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Indicadores de puntos
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _post.imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == _currentImageIndex
                          ? Colors.white
                          : Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: _isLiking ? null : _handleLike,
            child: Row(
              children: [
                Icon(
                  _post.isLikedBy(_getCurrentUserId())
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _post.isLikedBy(_getCurrentUserId())
                      ? Colors.red
                      : Colors.grey.shade700,
                  size: 24,
                ),
                if (_isLiking) ...[
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Comment button
          GestureDetector(
            onTap: () => widget.onComment?.call(_post),
            child: Icon(
              Icons.chat_bubble_outline,
              color: Colors.grey.shade700,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Share button
          GestureDetector(
            onTap: () => widget.onShare?.call(_post),
            child: Icon(
              Icons.share_outlined,
              color: Colors.grey.shade700,
              size: 24,
            ),
          ),

          const Spacer(),

          // Save button
          GestureDetector(
            onTap: _isSaving ? null : _handleSave,
            child: Row(
              children: [
                Icon(
                  _post.isSavedBy(_getCurrentUserId())
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: _post.isSavedBy(_getCurrentUserId())
                      ? Colors.orange
                      : Colors.grey.shade700,
                  size: 24,
                ),
                if (_isSaving) ...[
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikesInfo() {
    if (_post.likeCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        _post.likeCount == 1 ? '1 me gusta' : '${_post.likeCount} me gusta',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 14,
            height: 1.3,
          ),
          children: [
            TextSpan(
              text: '${_post.userName} ',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: _post.description),
          ],
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 14,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            _post.formattedLocation,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: _post.tags.map((tag) {
          return GestureDetector(
            onTap: () => widget.onTagTap?.call(tag),
            child: Text(
              '#$tag',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCommentsPreview() {
    if (_post.commentCount == 0) return const SizedBox(height: 12);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: GestureDetector(
        onTap: () => widget.onComment?.call(_post),
        child: Text(
          _post.commentCount == 1
              ? 'Ver 1 comentario'
              : 'Ver los ${_post.commentCount} comentarios',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Métodos de interacción
  void _handleDoubleTap() {
    HapticFeedback.lightImpact();
    _handleLike();
  }

  Future<void> _handleLike() async {
    if (_isLiking) return;

    setState(() => _isLiking = true);

    try {
      HapticFeedback.lightImpact();

      final result = await SocialPostService.toggleLike(_post.id);

      if (mounted) {
        setState(() {
          _post = _post.copyWith(
            likeCount: result['likeCount'],
            likes: result['liked']
                ? [..._post.likes, _getCurrentUserId()]
                : _post.likes.where((id) => id != _getCurrentUserId()).toList(),
          );
        });
      }

      widget.onLike?.call(_post);
    } catch (e) {
      _showError('Error al dar like: $e');
    } finally {
      if (mounted) {
        setState(() => _isLiking = false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      HapticFeedback.lightImpact();

      final result = await SocialPostService.toggleSave(_post.id);

      if (mounted) {
        setState(() {
          _post = _post.copyWith(
            saves: result['saved']
                ? [..._post.saves, _getCurrentUserId()]
                : _post.saves.where((id) => id != _getCurrentUserId()).toList(),
          );
        });
      }

      widget.onSave?.call(_post);
    } catch (e) {
      _showError('Error al guardar: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Compartir'),
            onTap: () {
              Navigator.pop(context);
              widget.onShare?.call(_post);
            },
          ),
          ListTile(
            leading: Icon(
              _post.isSavedBy(_getCurrentUserId())
                  ? Icons.bookmark_remove
                  : Icons.bookmark_add,
            ),
            title: Text(
              _post.isSavedBy(_getCurrentUserId())
                  ? 'Quitar de guardados'
                  : 'Guardar',
            ),
            onTap: () {
              Navigator.pop(context);
              _handleSave();
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Reportar'),
            onTap: () {
              Navigator.pop(context);
              _showReportDialog();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar publicación'),
        content: const Text(
            '¿Estás seguro de que quieres reportar esta publicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess('Publicación reportada');
            },
            child: const Text('Reportar'),
          ),
        ],
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

  // Helpers
  String _getCurrentUserId() {
    // TODO: Obtener del AuthProvider real
    return 'current_user_id';
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'artesano':
        return Colors.brown;
      case 'guia':
        return Colors.green;
      case 'moderador':
        return Colors.orange;
      case 'admin':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'artesano':
        return 'Artesano';
      case 'guia':
        return 'Guía';
      case 'moderador':
        return 'Mod';
      case 'admin':
        return 'Admin';
      default:
        return 'Usuario';
    }
  }
}
