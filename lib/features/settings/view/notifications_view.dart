import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Notifications settings view.
class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _remindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            SwitchListTile(
              secondary: const _NotificationIcon(
                icon: Icons.notifications_active_outlined,
              ),
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive alerts and updates'),
              value: _pushEnabled,
              onChanged: (bool value) {
                setState(() => _pushEnabled = value);
              },
            ),
            SwitchListTile(
              secondary: const _NotificationIcon(
                icon: Icons.email_outlined,
              ),
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive email summaries'),
              value: _emailEnabled,
              onChanged: (bool value) {
                setState(() => _emailEnabled = value);
              },
            ),
            SwitchListTile(
              secondary: const _NotificationIcon(
                icon: Icons.alarm,
              ),
              title: const Text('Reminders'),
              subtitle: const Text('Get reminded about scheduled tasks'),
              value: _remindersEnabled,
              onChanged: (bool value) {
                setState(() => _remindersEnabled = value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Notification icon container.
class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}
