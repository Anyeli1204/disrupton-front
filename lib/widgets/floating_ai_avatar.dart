import 'package:flutter/material.dart';
import '../models/ai_chat_models.dart';

class FloatingAiAvatar extends StatefulWidget {
  final AvatarType avatarType;
  final VoidCallback onTap;
  final bool isActive;

  const FloatingAiAvatar({
    super.key,
    required this.avatarType,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<FloatingAiAvatar> createState() => _FloatingAiAvatarState();
}

class _FloatingAiAvatarState extends State<FloatingAiAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Animación de pulso sutil
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) {
          setState(() {
            _animationController.forward();
          });
        },
        onTapUp: (_) {
          setState(() {
            _animationController.reverse();
          });
        },
        onTapCancel: () {
          setState(() {
            _animationController.reverse();
          });
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isActive ? _scaleAnimation.value : 1.0,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    if (!widget.isActive)
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 20 * _pulseAnimation.value,
                        spreadRadius: 2 * _pulseAnimation.value,
                      ),
                  ],
                  border: Border.all(
                    color: widget.isActive
                        ? Colors.deepPurple.shade600
                        : Colors.deepPurple.shade300,
                    width: widget.isActive ? 3 : 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Avatar emoji
                    Center(
                      child: Text(
                        widget.avatarType.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),

                    // Indicador de actividad
                    if (widget.isActive)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Ripple effect cuando está activo
                    if (widget.isActive)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepPurple.withOpacity(0.1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Widget para mostrar información del avatar
class AvatarInfoPopup extends StatelessWidget {
  final AvatarType avatarType;

  const AvatarInfoPopup({
    super.key,
    required this.avatarType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                avatarType.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  avatarType.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AvatarConfig.descriptions[avatarType] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
