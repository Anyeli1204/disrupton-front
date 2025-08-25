import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_models.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';
import 'home_screen.dart';
import 'permission_flow_manager.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selected;

  final Map<UserRole, _RoleStyle> _roleStyles = {
    UserRole.user: _RoleStyle(Icons.person_outline, Colors.indigo),
    UserRole.guide: _RoleStyle(Icons.map_outlined, Colors.teal),
    UserRole.artisan: _RoleStyle(Icons.brush_outlined, Colors.purple),
  };

  final Map<UserRole, String> _labels = const {
    UserRole.user: 'Usuario regular',
    UserRole.guide: 'Guía turístico',
    UserRole.artisan: 'Artesano',
  };

  final Map<UserRole, String> _descriptions = const {
    UserRole.user: 'Explora contenidos y vive experiencias AR a tu ritmo.',
    UserRole.guide: 'Crea rutas y acompaña a visitantes con experiencias AR.',
    UserRole.artisan: 'Exhibe tus piezas y comparte su historia con AR.',
  };

  @override
  Widget build(BuildContext context) {
    final roles = UserRole.selectableRoles;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Selecciona tu rol'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elige tu rol para personalizar tu experiencia',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta elección definirá tu experiencia en la plataforma.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: roles.length,
                  itemBuilder: (_, index) {
                    final role = roles[index];
                    final style = _roleStyles[role]!;
                    final selected = _selected == role;
                    return _RoleCard(
                      icon: style.icon,
                      title: _labels[role]!,
                      subtitle: _descriptions[role]!,
                      color: style.color,
                      selected: selected,
                      onTap: () => setState(() => _selected = role),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () async {
                          final auth =
                              Provider.of<AuthProvider>(context, listen: false);
                          await auth.setUserRole(_selected!);
                          if (!mounted) return;

                          // Check if we need to show permissions or tutorial for new users
                          final permissionsNeeded = await PermissionService
                              .getPermissionsNeedingPopup();
                          final tutorialCompleted =
                              await PermissionService.isTutorialCompleted();

                          if (permissionsNeeded.isNotEmpty ||
                              !tutorialCompleted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const PermissionFlowManager(
                                  isNewUser:
                                      true, // New user completing onboarding
                                ),
                              ),
                              (route) => false,
                            );
                            return;
                          }

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Confirmar rol',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleStyle {
  final IconData icon;
  final Color color;
  const _RoleStyle(this.icon, this.color);
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.25,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? color : Colors.grey.shade400,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
