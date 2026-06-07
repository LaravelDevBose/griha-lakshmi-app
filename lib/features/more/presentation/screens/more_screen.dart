import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_footer_nav.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../app/router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _openComingSoon(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return _ComingSoonScreen(
            title: title,
            icon: icon,
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Logout?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Are you sure you want to logout from FamilyFund?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                AppButton(
                  text: 'Logout',
                  icon: Icons.logout_rounded,
                  type: AppButtonType.danger,
                  onPressed: () => Navigator.pop(sheetContext, true),
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Cancel',
                  type: AppButtonType.outline,
                  onPressed: () => Navigator.pop(sheetContext, false),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logout flow will be connected with auth later.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Later when auth storage is ready:
    // await TokenStorage.clearToken();
    // Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useCustomHeader: true,
      showDrawer: true,
      showFooter: true,
      footerTab: AppFooterTab.more,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      body: ListView(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 96,
        ),
        children: [
          const _MoreHeaderCard(),
          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Account',
          ),
          const SizedBox(height: 8),
          _MoreMenuCard(
            children: [
              _MoreMenuTile(
                icon: Icons.person_rounded,
                title: 'Profile',
                subtitle: 'View and update your personal information',
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              ),
              _MoreMenuTile(
                icon: Icons.group_rounded,
                title: 'Family Members',
                subtitle: 'Manage family users and assigned members',
                onTap: () => _openComingSoon(
                  context,
                  title: 'Family Members',
                  icon: Icons.group_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionTitle(
            title: 'Finance Setup',
          ),
          const SizedBox(height: 8),
          _MoreMenuCard(
            children: [
              _MoreMenuTile(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Accounts',
                subtitle: 'Cash, bank, mobile banking, and card accounts',
                onTap: () => Navigator.pushNamed(context, AppRoutes.accounts),
              ),
              _MoreMenuTile(
                icon: Icons.category_rounded,
                title: 'Categories',
                subtitle: 'Manage income and expense categories',
                onTap: () => _openComingSoon(
                  context,
                  title: 'Categories',
                  icon: Icons.category_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionTitle(
            title: 'Preferences',
          ),
          const SizedBox(height: 8),
          _MoreMenuCard(
            children: [
              _MoreMenuTile(
                icon: Icons.notifications_rounded,
                title: 'Notifications',
                subtitle: 'Reminder, payment due, and budget alerts',
                onTap: () => _openComingSoon(
                  context,
                  title: 'Notifications',
                  icon: Icons.notifications_rounded,
                ),
              ),
              _MoreMenuTile(
                icon: Icons.settings_rounded,
                title: 'Settings',
                subtitle: 'App preferences and default options',
                onTap: () => _openComingSoon(
                  context,
                  title: 'Settings',
                  icon: Icons.settings_rounded,
                ),
              ),
              _MoreMenuTile(
                icon: Icons.security_rounded,
                title: 'Security',
                subtitle: 'PIN, biometrics, and account protection',
                onTap: () => _openComingSoon(
                  context,
                  title: 'Security',
                  icon: Icons.security_rounded,
                ),
              ),
              _MoreMenuTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'Change app language',
                onTap: () => _openComingSoon(
                  context,
                  title: 'Language',
                  icon: Icons.language_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionTitle(
            title: 'Support',
          ),
          const SizedBox(height: 8),
          _MoreMenuCard(
            children: [
              _MoreMenuTile(
                icon: Icons.help_rounded,
                title: 'Help',
                subtitle: 'FAQs, contact, and app guide',
                onTap: () => _openComingSoon(
                  context,
                  title: 'Help',
                  icon: Icons.help_rounded,
                ),
              ),
              _MoreMenuTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'Sign out from this device',
                iconColor: Colors.red,
                showDivider: false,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoreHeaderCard extends StatelessWidget {
  const _MoreHeaderCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.grid_view_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage profile, family setup, security, and app preferences.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreMenuCard extends StatelessWidget {
  const _MoreMenuCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.09),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.018),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _MoreMenuTile extends StatelessWidget {
  const _MoreMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color itemColor = iconColor ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: itemColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: 21,
                    color: itemColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.52,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 68),
              child: Divider(
                height: 1,
                thickness: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
      ),
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      showDrawer: false,
      showFooter: false,
      useCustomHeader: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      body: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(
                    alpha: 0.10,
                  ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: 0.10,
                      ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'This section will be connected in the next step.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.58),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 18),
              AppButton(
                text: 'Back',
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}