import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      // Intentar cargar desde el backend
      final comments = await MuralService.getMuralComments();
      setState(() {
        _comments = comments;
        _questions = MuralService.getSampleQuestions();
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
                        '${currentQuestion.commentCount} comentarios',
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
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return _buildCommentCard(comment);
      },
    );
  }

  Widget _buildCommentCard(Comment comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  backgroundColor: Colors.deepPurple[100],
                  child: Text(
                    comment.userName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 16,
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
                        comment.userName ?? 'Usuario',
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
            
            const SizedBox(height: 16),
            
            // Acciones del comentario
            Row(
              children: [
                // Like
                InkWell(
                  onTap: () => _handleLike(comment),
                  child: Row(
                    children: [
                      Icon(
                        comment.isLikedBy('currentUser') 
                            ? Icons.favorite 
                            : Icons.favorite_border,
                        color: comment.isLikedBy('currentUser') 
                            ? Colors.red 
                            : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.likes.length}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Dislike
                InkWell(
                  onTap: () => _handleDislike(comment),
                  child: Row(
                    children: [
                      Icon(
                        comment.isDislikedBy('currentUser') 
                            ? Icons.thumb_down 
                            : Icons.thumb_down_outlined,
                        color: comment.isDislikedBy('currentUser') 
                            ? Colors.blue 
                            : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.dislikes.length}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Responder
                InkWell(
                  onTap: () => _handleReply(comment),
                  child: Row(
                    children: [
                      Icon(
                        Icons.reply,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Responder',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Comentario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (commentController.text.trim().isEmpty) return;

              // Desactivar el botón para evitar múltiples envíos
              setState(() {});

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
                final authHeaders = authProvider.getAuthHeaders();
                final newComment = await MuralService.createMuralComment(
                  commentController.text.trim(),
                  user.userId, // Pasa el ID del usuario actual
                  authHeaders,
                  questionId: question.id,
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
              } finally {
                // Reactivar el botón
                if (mounted) {
                  setState(() {});
                }
              }
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
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
    final isLiked = comment.isLikedBy(userId);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Actualización optimista de la UI
    setState(() {
      if (isLiked) {
        comment.likes.remove(userId);
      } else {
        comment.likes.add(userId);
        // Si estaba en dislike, se quita
        comment.dislikes.remove(userId);
      }
    });

    try {
      if (isLiked) {
        await MuralService.unlikeComment(comment.id, userId);
      } else {
        await MuralService.likeComment(comment.id, userId);
      }
    } catch (e) {
      // Si falla, revertir el cambio en la UI
      setState(() {
        if (isLiked) {
          comment.likes.add(userId);
        } else {
          comment.likes.remove(userId);
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
    final isDisliked = comment.isDislikedBy(userId);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Actualización optimista de la UI
    setState(() {
      if (isDisliked) {
        comment.dislikes.remove(userId);
      } else {
        comment.dislikes.add(userId);
        // Si estaba en like, se quita
        comment.likes.remove(userId);
      }
    });

    try {
      if (isDisliked) {
        await MuralService.undislikeComment(comment.id, userId);
      } else {
        await MuralService.dislikeComment(comment.id, userId);
      }
    } catch (e) {
      // Si falla, revertir el cambio en la UI
      setState(() {
        if (isDisliked) {
          comment.dislikes.add(userId);
        } else {
          comment.dislikes.remove(userId);
        }
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al procesar el dislike: $e')),
      );
    }
  }

  void _handleReply(Comment comment) {
    // Implementar lógica de respuesta
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de respuesta en desarrollo'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
