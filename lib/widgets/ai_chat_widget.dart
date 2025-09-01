import 'package:flutter/material.dart';
import '../models/ai_chat_models.dart';
import '../models/collection_models.dart';
import '../services/ai_chat_service.dart';

class AiChatWidget extends StatefulWidget {
  final AvatarType avatarType;
  final CulturalObject culturalObject;
  final VoidCallback onClose;

  const AiChatWidget({
    super.key,
    required this.avatarType,
    required this.culturalObject,
    required this.onClose,
  });

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isServiceHealthy = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _checkServiceHealth();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _checkServiceHealth() async {
    final isHealthy = await AiChatService.isServiceHealthy();
    if (mounted) {
      setState(() {
        _isServiceHealthy = isHealthy;
      });
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content:
          'Hola! ${AvatarConfig.descriptions[widget.avatarType]} ¿En qué puedo ayudarte con "${widget.culturalObject.name}"?',
      isFromUser: false,
      timestamp: DateTime.now(),
      avatarType: widget.avatarType,
    );

    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Agregar mensaje del usuario
    final userChatMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: userMessage,
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userChatMessage);
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Enviar mensaje al servicio de IA
      final response = await AiChatService.sendMessage(
        avatarType: widget.avatarType,
        message: userMessage,
        contextObject: widget.culturalObject,
      );

      if (response.success && response.response != null) {
        final aiMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response.response!,
          isFromUser: false,
          timestamp: DateTime.now(),
          avatarType: widget.avatarType,
        );

        setState(() {
          _messages.add(aiMessage);
        });
      } else {
        _addErrorMessage(response.error ?? 'No se pudo obtener una respuesta');
      }
    } catch (e) {
      _addErrorMessage('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _addErrorMessage(String error) {
    final errorMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content:
          'Lo siento, ocurrió un error: $error. Por favor, intenta de nuevo.',
      isFromUser: false,
      timestamp: DateTime.now(),
      avatarType: widget.avatarType,
    );

    setState(() {
      _messages.add(errorMessage);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendSuggestedQuestion(String question) {
    _messageController.text = question;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            if (!_isServiceHealthy) _buildServiceWarning(),
            Expanded(child: _buildMessagesList()),
            _buildSuggestedQuestions(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Text(
            widget.avatarType.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.avatarType.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                Text(
                  'Asistente cultural',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepPurple.shade500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              Icons.close,
              color: Colors.deepPurple.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceWarning() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'El servicio de IA no está disponible. Funcionando en modo limitado.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildLoadingMessage();
        }

        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isFromUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple.shade100,
              child: Text(
                message.avatarType?.emoji ?? widget.avatarType.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isUser ? Colors.deepPurple.shade600 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.blue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.deepPurple.shade100,
            child: Text(
              widget.avatarType.emoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple.shade400,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Escribiendo...',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    if (_messages.length > 2) return const SizedBox.shrink();

    final suggestions = AiChatService.getSuggestedQuestions(
      widget.avatarType,
      widget.culturalObject,
    );

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              onPressed: () => _sendSuggestedQuestion(suggestions[index]),
              label: Text(
                suggestions[index],
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.deepPurple.shade50,
              labelStyle: TextStyle(
                color: Colors.deepPurple.shade700,
              ),
              side: BorderSide(
                color: Colors.deepPurple.shade200,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Pregunta sobre ${widget.culturalObject.name}...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isLoading,
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor:
                _isLoading ? Colors.grey.shade300 : Colors.deepPurple.shade600,
            mini: true,
            child: Icon(
              _isLoading ? Icons.hourglass_empty : Icons.send,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
