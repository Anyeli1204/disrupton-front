import 'package:flutter/material.dart';
import '../models/permission_models.dart' as pm;
import '../services/permission_service.dart';

class PermissionPopupScreen extends StatefulWidget {
  final pm.PermissionType permissionType;
  final VoidCallback? onComplete;

  const PermissionPopupScreen({
    super.key,
    required this.permissionType,
    this.onComplete,
  });

  @override
  State<PermissionPopupScreen> createState() => _PermissionPopupScreenState();
}

class _PermissionPopupScreenState extends State<PermissionPopupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handlePermissionChoice(
      bool allowWhileUsingApp, bool onlyThisTime) async {
    // Update permission state - this will handle the system permission request internally
    await PermissionService.updatePermissionChoice(
      widget.permissionType,
      allowWhileUsingApp,
      onlyThisTime,
    );

    // Close popup and call completion callback
    if (mounted) {
      Navigator.of(context).pop();
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  margin: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            PermissionService.getPermissionIcon(
                                widget.permissionType),
                            size: 40,
                            color: Colors.deepPurple.shade600,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Title
                        Text(
                          '"Disrupton" te solicita permiso para acceder a ${PermissionService.getPermissionName(widget.permissionType)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          PermissionService.getPermissionDescription(
                              widget.permissionType),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Buttons
                        Column(
                          children: [
                            // Allow while using app
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _handlePermissionChoice(true, false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade600,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Permitir mientras la aplicación esté en uso',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Allow only this time
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _handlePermissionChoice(false, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.grey.shade700,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Solo esta vez',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Deny
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () =>
                                    _handlePermissionChoice(false, false),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey.shade600,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'No permitir',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
