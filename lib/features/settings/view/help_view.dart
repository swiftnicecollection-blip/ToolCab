import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Help & support view.
class HelpView extends StatelessWidget {
  const HelpView({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            _HelpItem(
              icon: Icons.email_outlined,
              label: 'Contact Support',
              subtitle: AppConstants.supportEmail,
              onTap: () => _launchUrl('mailto:${AppConstants.supportEmail}'),
            ),
            _HelpItem(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () => _launchUrl(AppConstants.privacyPolicyUrl),
            ),
            _HelpItem(
              icon: Icons.description_outlined,
              label: 'Terms of Service',
              subtitle: 'Read our terms of service',
              onTap: () => _launchUrl(AppConstants.termsUrl),
            ),
            _HelpItem(
              icon: Icons.rate_review_outlined,
              label: 'Rate the App',
              subtitle: 'Share your feedback on the store',
              onTap: () => _launchUrl(AppConstants.playStoreUrl),
            ),
          ],
        ),
      ),
    );
  }
}

/// Help menu item.
class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
