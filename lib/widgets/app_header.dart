import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.actions,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface.withOpacity(0.92),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withOpacity(0.04),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              if (showBackButton) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 4),
              ] else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bolt,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle != null && !showBackButton)
                      Text(
                        subtitle!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: AppColors.secondary,
                        ),
                      ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (actions != null) ...actions!,
              if (actions == null && !showBackButton) ...[
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.tertiary),
                  onPressed: onNotificationTap ?? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No new notifications. Everything is running smoothly!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onProfileTap,
                  child: Builder(
                    builder: (context) {
                      final user = AppState().currentUser;
                      final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';
                      return Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryContainer.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: user.avatarUrl.isNotEmpty
                              ? Image.network(
                                  user.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: AppColors.secondaryFixed,
                                    child: Center(
                                      child: Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.secondaryFixed,
                                  child: Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
