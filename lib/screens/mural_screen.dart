import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/mural_question.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../services/mural_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/proxy_image.dart';

class MuralScreen extends StatefulWidget {
  const MuralScreen({super.key});

  @override
  State<MuralScreen> createState() => _MuralScreenState();
}

class _MuralScreenState extends State<MuralScreen> {
  List<MuralQuestion> _questions = [];
  List<Comment> _comments = [];
  bool _isLoading = false;
  final Set<String> _expandedReplies = {};
  final ImagePicker _imagePicker = ImagePicker();

  // 🚀 OPTIMIZACIÓN: Cache para evitar recargas innecesarias
  static DateTime? _lastLoadTime;
  static const Duration _cacheTimeout = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    _loadDataWithCache();
  }

  Future<void> _loadDataWithCache() async {
    // 🚀 Verificar si los datos están en cache y son recientes
    final now = DateTime.now();
    if (_lastLoadTime != null &&
        now.difference(_lastLoadTime!).inMinutes < _cacheTimeout.inMinutes &&
        _comments.isNotEmpty) {
      print('📋 Usando datos en cache del mural');
      return;
    }

    await _loadData();
    _lastLoadTime = now;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.userId;

      // 🚀 OPTIMIZACIÓN: Ejecutar ambas llamadas en paralelo
      final results = await Future.wait([
        MuralService.getActiveMuralQuestion(),
        MuralService.getMuralComments(userId: userId),
      ]);

      if (!mounted) return;

      final activeQuestion = results[0] as MuralQuestion?;
      final comments = results[1] as List<Comment>;

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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando mural cultural...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Esto puede tomar unos segundos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Center(
        child: Text(
          'No hay preguntas activas',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final question = _questions.first;
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildQuestionCard(question),
            const SizedBox(height: 24),
            _buildCommentInputSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsTab() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando comentarios...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Filtrar solo comentarios principales (sin parentCommentId)
    final mainComments =
        _comments.where((c) => c.parentCommentId == null).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: mainComments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '¡Sé el primero en comentar!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mainComments.length,
              itemBuilder: (context, index) {
                return _buildCommentCard(mainComments[index]);
              },
            ),
    );
  }

  Widget _buildQuestionCard(MuralQuestion question) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.help_outline,
                      color: Colors.deepPurple.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pregunta de la Semana',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                        Text(
                          question.formattedRemainingTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              if (question.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  question.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: Colors.deepPurple.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_comments.length} comentarios',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInputSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💭 ¿Qué opinas?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(height: 12),
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    final TextEditingController commentController = TextEditingController();
    List<File> selectedImages = [];

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Comparte tu respuesta a la pregunta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple.shade400),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            if (selectedImages.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              selectedImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
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
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    await _pickImage(selectedImages, setState);
                  },
                  icon: Icon(
                    Icons.image,
                    color: Colors.deepPurple.shade600,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isNotEmpty) {
                      await _submitComment(
                        commentController.text.trim(),
                        selectedImages,
                      );
                      commentController.clear();
                      setState(() {
                        selectedImages.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Comentar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(
      List<File> selectedImages, StateSetter setState) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _submitComment(String content, List<File> images) async {
    try {
      HapticFeedback.lightImpact();

      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.userId ?? 'user_demo';
      final currentUser = authProvider.currentUser;

      // Obtener headers de autenticación de forma asíncrona
      final authHeaders = await authProvider.getAuthHeadersAsync();

      // Subir imágenes reales si existen
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        try {
          imageUrls = await MuralService.uploadCommentImages(images, userId,
              DateTime.now().millisecondsSinceEpoch.toString(), authHeaders);
          print('Imágenes subidas exitosamente: ${imageUrls.length}');
        } catch (e) {
          print('Error subiendo imágenes: $e');
          // Continuar sin imágenes si falla la subida
        }
      }

      // Convertir User de auth_models a User de models/user
      final User? muralUser = currentUser != null
          ? User(
              userId: currentUser.userId,
              name: currentUser.displayName,
              email: currentUser.email,
              role: currentUser.role.code,
              profileImageUrl: '',
              isActive: currentUser.isActive,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : null;

      await MuralService.createMuralComment(
        content,
        userId,
        authHeaders,
        imageUrls: imageUrls,
        user: muralUser,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Comentario enviado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData(); // Recargar datos
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar comentario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCommentCard(Comment comment) {
    // Buscar respuestas a este comentario
    final replies =
        _comments.where((c) => c.parentCommentId == comment.id).toList();
    final bool hasReplies = replies.isNotEmpty;
    final bool isExpanded = _expandedReplies.contains(comment.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del comentario
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text(
                    (comment.userName?.isNotEmpty == true)
                        ? comment.userName![0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDateTime(comment.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Contenido del comentario
            Text(
              comment.text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),

            // Imágenes del comentario
            if (comment.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: comment.imageUrls.length,
                  itemBuilder: (context, index) {
                    print('Mostrando imagen: ${comment.imageUrls[index]}');
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ProxyImage(
                          imageUrl: comment.imageUrls[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Acciones del comentario
            Row(
              children: [
                _buildReactionButton(
                  comment,
                  'like',
                  Icons.thumb_up,
                  Icons.thumb_up_outlined,
                  comment.likeCount,
                ),
                const SizedBox(width: 8),
                _buildReactionButton(
                  comment,
                  'dislike',
                  Icons.thumb_down,
                  Icons.thumb_down_outlined,
                  comment.dislikeCount,
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _showReplyDialog(comment),
                  icon: Icon(
                    Icons.reply,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  label: Text(
                    'Responder',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (hasReplies) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedReplies.remove(comment.id);
                        } else {
                          _expandedReplies.add(comment.id);
                        }
                      });
                    },
                    child: Text(
                      isExpanded
                          ? 'Ocultar respuestas'
                          : 'Ver ${replies.length} respuestas',
                      style: TextStyle(
                        color: Colors.deepPurple.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Respuestas
            if (hasReplies && isExpanded) ...[
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.only(left: 20),
                padding: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  children:
                      replies.map((reply) => _buildReplyCard(reply)).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton(
    Comment comment,
    String reactionType,
    IconData filledIcon,
    IconData outlinedIcon,
    int count,
  ) {
    final bool isUserReaction = comment.userReaction == reactionType;

    return GestureDetector(
      onTap: () => _toggleReaction(comment, reactionType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isUserReaction ? Colors.deepPurple.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUserReaction
                ? Colors.deepPurple.shade300
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUserReaction ? filledIcon : outlinedIcon,
              size: 16,
              color: isUserReaction
                  ? Colors.deepPurple.shade600
                  : Colors.grey.shade600,
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: isUserReaction
                      ? Colors.deepPurple.shade600
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(Comment reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  (reply.userName?.isNotEmpty == true)
                      ? reply.userName![0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reply.userName ?? 'Usuario Anónimo',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                _formatDateTime(reply.createdAt),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.text,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildReactionButton(
                reply,
                'like',
                Icons.thumb_up,
                Icons.thumb_up_outlined,
                reply.likeCount,
              ),
              const SizedBox(width: 8),
              _buildReactionButton(
                reply,
                'dislike',
                Icons.thumb_down,
                Icons.thumb_down_outlined,
                reply.dislikeCount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleReaction(Comment comment, String reactionType) async {
    try {
      HapticFeedback.lightImpact();

      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.userId ?? 'user_demo';

      await MuralService.reactToComment(
        comment.id,
        userId,
        reactionType,
      );

      await _loadData(); // Recargar para obtener las reacciones actualizadas
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar reacción: $e')),
        );
      }
    }
  }

  Future<void> _showReplyDialog(Comment parentComment) async {
    final TextEditingController replyController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Responder comentario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Respondiendo a: "${parentComment.text}"',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: replyController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escribe tu respuesta...',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = replyController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context, text);
              }
            },
            child: const Text('Responder'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _submitReply(parentComment.id, result);
    }
  }

  Future<void> _submitReply(String parentCommentId, String content) async {
    try {
      HapticFeedback.lightImpact();

      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.userId ?? 'user_demo';
      final currentUser = authProvider.currentUser;

      // Obtener headers de autenticación de forma asíncrona
      final authHeaders = await authProvider.getAuthHeadersAsync();

      // Convertir User de auth_models a User de models/user
      final User? muralUser = currentUser != null
          ? User(
              userId: currentUser.userId,
              name: currentUser.displayName,
              email: currentUser.email,
              role: currentUser.role.code,
              profileImageUrl: '',
              isActive: currentUser.isActive,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : null;

      await MuralService.createMuralComment(
        content,
        userId,
        authHeaders,
        parentCommentId: parentCommentId,
        user: muralUser,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Respuesta enviada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );

        await _loadData(); // Recargar datos
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar respuesta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }
}
