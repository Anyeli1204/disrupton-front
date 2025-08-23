import 'package:flutter/material.dart';
import '../models/permission_models.dart' as pm;
import '../services/permission_service.dart';
import '../screens/permission_popup_screen.dart';
import '../screens/tutorial_screen.dart';
import '../screens/home_screen.dart';

class PermissionFlowManager extends StatefulWidget {
  final bool isNewUser;
  final pm.PermissionType? specificPermission;

  const PermissionFlowManager({
    super.key,
    this.isNewUser = false,
    this.specificPermission,
  });

  @override
  State<PermissionFlowManager> createState() => _PermissionFlowManagerState();
}

class _PermissionFlowManagerState extends State<PermissionFlowManager> {
  List<pm.PermissionType> _pendingPermissions = [];
  int _currentPermissionIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePermissionFlow();
  }

  Future<void> _initializePermissionFlow() async {
    if (widget.specificPermission != null) {
      // Handle specific permission request
      _pendingPermissions = [widget.specificPermission!];
    } else {
      // Get all permissions that need popup
      _pendingPermissions =
          await PermissionService.getPermissionsNeedingPopup();
    }

    setState(() {
      _isLoading = false;
    });

    // Start permission flow
    _showNextPermission();
  }

  void _showNextPermission() {
    if (_currentPermissionIndex < _pendingPermissions.length) {
      final permission = _pendingPermissions[_currentPermissionIndex];

      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              PermissionPopupScreen(
            permissionType: permission,
            onComplete: _onPermissionComplete,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
          barrierDismissible: false,
          opaque: false,
        ),
      );
    } else {
      // All permissions handled, proceed to next step
      _proceedToNextStep();
    }
  }

  void _onPermissionComplete() {
    _currentPermissionIndex++;
    _showNextPermission();
  }

  Future<void> _proceedToNextStep() async {
    if (widget.isNewUser) {
      // Check if tutorial is needed
      final tutorialCompleted = await PermissionService.isTutorialCompleted();

      if (!tutorialCompleted && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const TutorialScreen(),
          ),
        );
        return;
      }
    }

    // Go to home screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.deepPurple.shade600,
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // If no permissions to show, proceed directly
    if (_pendingPermissions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _proceedToNextStep();
      });
    }

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade600,
      body: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}
