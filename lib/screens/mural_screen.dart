import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/mural_question.dart';
import '../models/comment.dart';
import '../services/mural_service.dart';
import '../providers/auth_provider.dart'; // Para obtener el usuario actual

class MuralScreen extends StatefulWidget {
  const MuralScreen({super.key});

  @override
  State<MuralScreen> createState() => _MuralScreenState();
}

class _MuralScreenState extends State<MuralScreen> {
  List<MuralQuestion> _questions = [];
  List<Comment> _comments = [];
  bool _isLoading = false;
  final Set<String> _expandedReplies = {}; // IDs de comentarios con respuestas expandidas
  final Set<String> _collapsedReplies = {}; // IDs de comentarios que el usuario ha colapsado manualmente
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar pregunta activa del backend
      final activeQuestion = await MuralService.getActiveMuralQuestion();
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.userId;
      final comments = await MuralService.getMuralComments(userId: userId);
      
      setState(() {
        _comments = comments;
        if (activeQuestion != null) {
          _questions = [activeQuestion];
        } else {
          _questions = MuralService.getSampleQuestions();
        }
        _isLoading = false;
      });
    } catch (e) {
      // Si falla, usar datos de ejemplo
      setState(() {
        _questions = MuralService.getSampleQuestions();
        _comments = MuralService.getSampleComments();
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usando datos de ejemplo: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mural Cultural'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pregunta Semanal'),
              Tab(text: 'Comentarios'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            _buildWeeklyQuestionTab(),
            _buildCommentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyQuestionTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_questions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.question_mark, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay preguntas activas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Mostrar la pregunta más reciente
    final currentQuestion = _questions.firstWhere(
      (q) => q.isCurrent,
      orElse: () => _questions.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pregunta actual
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de la pregunta
                  Row(
                    children: [
                      Icon(
                        Icons.question_answer,
                        color: Colors.deepPurple[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pregunta de la Semana',
                          style: TextStyle(
                            color: Colors.deepPurple[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: currentQuestion.isCurrent
                              ? Colors.green[100]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          currentQuestion.isCurrent
                              ? 'Activa'
                              : 'Expirada',
                          style: TextStyle(
                            color: currentQuestion.isCurrent
                                ? Colors.green[700]
                                : Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Pregunta
                  Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  if (currentQuestion.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      currentQuestion.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // Imágenes de la pregunta
                  if (currentQuestion.imagenes != null && currentQuestion.imagenes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: currentQuestion.imagenes!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[200]!.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                currentQuestion.imagenes![index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 48,
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // Información adicional
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        currentQuestion.formattedRemainingTime,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chat_bubble, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${_comments.length} comentarios',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tags
                  if (currentQuestion.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentQuestion.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.deepPurple[50],
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Botón para comentar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddCommentDialog(currentQuestion),
                      icon: const Icon(Icons.add_comment),
                      label: const Text('Agregar Comentario'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Comentarios de la pregunta actual
          Text(
            'Comentarios de la Comunidad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de comentarios
          ..._comments
              .where((comment) => comment.objectId == currentQuestion.id)
              .map((comment) => _buildCommentCard(comment)),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay comentarios aún',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '¡Sé el primero en comentar!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _getVisibleComments().length,
      itemBuilder: (context, index) {
        final comment = _getVisibleComments()[index];
        return _buildCommentCard(comment);
      },
    );
  }

  List<Comment> _getVisibleComments() {
    List<Comment> visibleComments = [];
    
    // Primero agregar todos los comentarios principales
    List<Comment> mainComments = _comments.where((c) => c.parentCommentId == null || c.parentCommentId!.isEmpty).toList();
    
    for (Comment mainComment in mainComments) {
      visibleComments.add(mainComment);
      
      // Obtener respuestas para este comentario
      List<Comment> replies = _comments.where((c) => c.parentCommentId == mainComment.id).toList();
      
      if (replies.isNotEmpty) {
        // Mostrar respuestas solo si el usuario expandió explícitamente
        if (_expandedReplies.contains(mainComment.id)) {
          replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          visibleComments.addAll(replies);
        }
      }
    }
    
    return visibleComments;
  }

  Widget _buildCommentCard(Comment comment) {
    final bool isReply = comment.parentCommentId != null && comment.parentCommentId!.isNotEmpty;
    
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
        left: isReply ? 32 : 0, // Indentar respuestas
      ),
      child: Card(
        elevation: isReply ? 1 : 2,
        color: isReply ? Colors.grey[50] : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isReply ? BorderSide(color: Colors.grey[300]!, width: 1) : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador de respuesta
              if (isReply) ...[
                Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Respuesta',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Header del comentario
              Row(
                children: [
                  CircleAvatar(
                    radius: isReply ? 16 : 20,
                    backgroundColor: Colors.deepPurple[100],
                    child: Text(
                      comment.userName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: isReply ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName ?? 'Usuario Anónimo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (comment.isEdited)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Editado',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Texto del comentario
            Text(
              comment.text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            
            // Mostrar imágenes si las hay
            if (comment.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImageGallery(comment.imageUrls),
            ],
            
            const SizedBox(height: 12),
            
            // Acciones del comentario
            Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: () => _handleLike(comment),
                  child: Row(
                    children: [
                      Icon(
                        comment.userReaction == 'like' ? Icons.favorite : Icons.favorite_border,
                        color: comment.userReaction == 'like' ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.likeCount}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Dislike button
                GestureDetector(
                  onTap: () => _handleDislike(comment),
                  child: Row(
                    children: [
                      Icon(
                        comment.userReaction == 'dislike' ? Icons.thumb_down : Icons.thumb_down_outlined,
                        color: comment.userReaction == 'dislike' ? Colors.blue : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.dislikeCount}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Ver respuestas y Responder (solo en comentarios principales)
                if (comment.parentCommentId == null) ...[
                  _buildViewRepliesButton(comment),
                  IconButton(
                    tooltip: 'Responder',
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Colors.grey[600],
                      size: 22,
                    ),
                    onPressed: () => _handleReply(comment),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildViewRepliesButton(Comment comment) {
    // Contar respuestas para este comentario
    final replyCount = _comments.where((c) => c.parentCommentId == comment.id).length;
    if (replyCount == 0) return const SizedBox.shrink();

    final isExpanded = _expandedReplies.contains(comment.id);
    return IconButton(
      tooltip: isExpanded
          ? 'Ocultar respuestas'
          : 'Ver respuestas ($replyCount)',
      icon: Icon(
        isExpanded ? Icons.forum : Icons.forum_outlined,
        color: Colors.deepPurple,
      ),
      onPressed: () => _toggleRepliesVisibility(comment.id),
    );
  }

  Widget _buildImageGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: index < imageUrls.length - 1 ? 8 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 50,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'ahora mismo';
    }
  }

  void _showAddCommentDialog(MuralQuestion question) {
    final commentController = TextEditingController();
    List<File> selectedImages = [];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Comentario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pregunta: ${question.question}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu comentario...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botón para agregar imágenes
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _selectImages(setDialogState, selectedImages),
                      icon: const Icon(Icons.photo_library, size: 20),
                      label: const Text('Seleccionar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        elevation: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _selectImageFromCamera(setDialogState, selectedImages),
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text('Cámara'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (selectedImages.isNotEmpty)
                      Text(
                        '${selectedImages.length} imagen${selectedImages.length > 1 ? 'es' : ''}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                
                // Preview de imágenes seleccionadas
                if (selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImages[index],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (commentController.text.trim().isEmpty) return;

              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final user = authProvider.currentUser;

              if (user == null) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Debes iniciar sesión para comentar'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                List<String>? imageUrls;
                
                // Subir imágenes si hay alguna seleccionada
                if (selectedImages.isNotEmpty) {
                  final tempCommentId = DateTime.now().millisecondsSinceEpoch.toString();
                  imageUrls = await MuralService.uploadCommentImages(
                    selectedImages, 
                    user.userId, 
                    tempCommentId
                  );
                }

                final authHeaders = authProvider.getAuthHeaders();
                final newComment = await MuralService.createMuralComment(
                  commentController.text.trim(),
                  user.userId,
                  authHeaders,
                  questionId: question.id,
                  user: user,
                  imageUrls: imageUrls,
                );

                if (mounted && newComment != null) {
                  setState(() {
                    _comments.insert(0, newComment);
                  });
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Comentario publicado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error al publicar: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Publicar'),
          ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImages(StateSetter setDialogState, List<File> selectedImages) async {
    try {
      // Usar selección individual desde galería para mayor compatibilidad
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        try {
          final file = File(image.path);
          
          // Verificar que el archivo existe
          if (await file.exists()) {
            // Verificar que es un archivo de imagen válido
            final bytes = await file.readAsBytes();
            if (bytes.isNotEmpty && selectedImages.length < 5) {
              setDialogState(() {
                selectedImages.add(file);
              });
            } else if (bytes.isEmpty) {
              throw Exception('La imagen seleccionada está vacía');
            } else {
              throw Exception('Máximo 5 imágenes permitidas');
            }
          } else {
            throw Exception('No se pudo acceder a la imagen seleccionada');
          }
        } catch (fileError) {
          throw Exception('Error al procesar la imagen: $fileError');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _selectImageFromCamera(StateSetter setDialogState, List<File> selectedImages) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        try {
          final file = File(image.path);
          
          // Verificar que el archivo existe y es válido
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            if (bytes.isNotEmpty && selectedImages.length < 5) {
              setDialogState(() {
                selectedImages.add(file);
              });
            } else if (bytes.isEmpty) {
              throw Exception('La imagen capturada está vacía');
            } else {
              throw Exception('Máximo 5 imágenes permitidas');
            }
          } else {
            throw Exception('No se pudo acceder a la imagen capturada');
          }
        } catch (fileError) {
          throw Exception('Error al procesar la imagen: $fileError');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al capturar imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _toggleRepliesVisibility(String commentId) {
    setState(() {
      if (_expandedReplies.contains(commentId)) {
        _expandedReplies.remove(commentId);
        _collapsedReplies.add(commentId); // Marcar como colapsado manualmente
      } else {
        _expandedReplies.add(commentId);
        _collapsedReplies.remove(commentId); // Quitar de colapsados si se expande
      }
    });
  }

  void _handleLike(Comment comment) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para reaccionar')),
      );
      return;
    }

    final userId = user.userId;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Validación: Un usuario solo puede tener una reacción a la vez
    final currentReaction = comment.userReaction;
    
    // Calcular nuevos valores basado en la lógica de toggle y exclusividad con validación de negativos
    int newLikeCount;
    int newDislikeCount;
    String? newUserReaction;
    
    if (currentReaction == 'like') {
      // Si ya tiene like, lo quita (asegurar que no sea negativo)
      newLikeCount = (comment.likeCount - 1).clamp(0, double.infinity).toInt();
      newDislikeCount = comment.dislikeCount;
      newUserReaction = null;
    } else if (currentReaction == 'dislike') {
      // Si tiene dislike, lo cambia a like
      newLikeCount = comment.likeCount + 1;
      newDislikeCount = (comment.dislikeCount - 1).clamp(0, double.infinity).toInt();
      newUserReaction = 'like';
    } else {
      // Si no tiene reacción, agrega like
      newLikeCount = comment.likeCount + 1;
      newDislikeCount = comment.dislikeCount;
      newUserReaction = 'like';
    }
    
    // Guardar estado original para posible reversión
    final originalComment = comment;
    
    // Actualizar UI inmediatamente
    setState(() {
      final index = _comments.indexWhere((c) => c.id == comment.id);
      if (index != -1) {
        _comments[index] = comment.copyWith(
          likeCount: newLikeCount,
          dislikeCount: newDislikeCount,
          userReaction: newUserReaction,
        );
      }
    });
    
    try {
      // Enviar al backend y obtener conteos reales
      final response = await MuralService.reactToComment(comment.id, userId, 'like');
      
      // Sincronizar con los conteos reales del backend
      if (response.containsKey('likeCount') && response.containsKey('dislikeCount')) {
        setState(() {
          final index = _comments.indexWhere((c) => c.id == comment.id);
          if (index != -1) {
            _comments[index] = _comments[index].copyWith(
              likeCount: response['likeCount'] ?? 0,
              dislikeCount: response['dislikeCount'] ?? 0,
            );
          }
        });
      }
    } catch (e) {
      // Revertir cambios en caso de error
      setState(() {
        final index = _comments.indexWhere((c) => c.id == comment.id);
        if (index != -1) {
          _comments[index] = originalComment;
        }
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al procesar el like: $e')),
      );
    }
  }

  void _handleDislike(Comment comment) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para reaccionar')),
      );
      return;
    }

    final userId = user.userId;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Validación: Un usuario solo puede tener una reacción a la vez
    final currentReaction = comment.userReaction;
    
    // Calcular nuevos valores basado en la lógica de toggle y exclusividad con validación de negativos
    int newLikeCount;
    int newDislikeCount;
    String? newUserReaction;
    
    if (currentReaction == 'dislike') {
      // Si ya tiene dislike, lo quita (asegurar que no sea negativo)
      newLikeCount = comment.likeCount;
      newDislikeCount = (comment.dislikeCount - 1).clamp(0, double.infinity).toInt();
      newUserReaction = null;
    } else if (currentReaction == 'like') {
      // Si tiene like, lo cambia a dislike
      newLikeCount = (comment.likeCount - 1).clamp(0, double.infinity).toInt();
      newDislikeCount = comment.dislikeCount + 1;
      newUserReaction = 'dislike';
    } else {
      // Si no tiene reacción, agrega dislike
      newLikeCount = comment.likeCount;
      newDislikeCount = comment.dislikeCount + 1;
      newUserReaction = 'dislike';
    }
    
    // Guardar estado original para posible reversión
    final originalComment = comment;
    
    // Actualizar UI inmediatamente
    setState(() {
      final index = _comments.indexWhere((c) => c.id == comment.id);
      if (index != -1) {
        _comments[index] = comment.copyWith(
          likeCount: newLikeCount,
          dislikeCount: newDislikeCount,
          userReaction: newUserReaction,
        );
      }
    });
    
    try {
      // Enviar al backend y obtener conteos reales
      final response = await MuralService.reactToComment(comment.id, userId, 'dislike');
      
      // Sincronizar con los conteos reales del backend
      if (response.containsKey('likeCount') && response.containsKey('dislikeCount')) {
        setState(() {
          final index = _comments.indexWhere((c) => c.id == comment.id);
          if (index != -1) {
            _comments[index] = _comments[index].copyWith(
              likeCount: response['likeCount'] ?? 0,
              dislikeCount: response['dislikeCount'] ?? 0,
            );
          }
        });
      }
    } catch (e) {
      // Revertir cambios en caso de error
      setState(() {
        final index = _comments.indexWhere((c) => c.id == comment.id);
        if (index != -1) {
          _comments[index] = originalComment;
        }
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al procesar el dislike: $e')),
      );
    }
  }

  void _handleReply(Comment comment) {
    final commentController = TextEditingController();
    List<File> selectedImages = [];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Responder a ${comment.userName ?? 'Usuario Anónimo'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar el comentario original
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName ?? 'Usuario Anónimo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu respuesta...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botón para agregar imágenes
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _selectImages(setDialogState, selectedImages),
                      icon: const Icon(Icons.photo_library, size: 20),
                      label: const Text('Seleccionar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        elevation: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _selectImageFromCamera(setDialogState, selectedImages),
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text('Cámara'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (selectedImages.isNotEmpty)
                      Text(
                        '${selectedImages.length} imagen${selectedImages.length > 1 ? 'es' : ''}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                
                // Preview de imágenes seleccionadas
                if (selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImages[index],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) return;

                // Capturar referencias antes de operaciones asíncronas
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final user = authProvider.currentUser;

                if (user == null) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Debes iniciar sesión para responder'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Validación redundante removida; ya validamos user arriba
                  
                  // Las respuestas NO permiten imágenes
                  await MuralService.createMuralComment(
                    commentController.text.trim(),
                    user.userId,
                    authProvider.getAuthHeaders(),
                    questionId: _questions.isNotEmpty ? _questions.first.id : '',
                    parentCommentId: comment.id,
                  );
                  
                  if (mounted) {
                    navigator.pop();
                    
                    scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Respuesta publicada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                    // Recargar comentarios y expandir automáticamente las respuestas
                    await _loadData();
                    setState(() {
                      _expandedReplies.add(comment.id);
                      _collapsedReplies.remove(comment.id);
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error al publicar respuesta: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Responder'),
            ),
          ],
        ),
      ),
    );
  }
}
