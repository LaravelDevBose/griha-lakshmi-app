import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'app_footer_nav.dart';
import 'app_header.dart';
import 'app_sidebar_drawer.dart';
import 'quick_action_fab.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showQuickActionFab = false,
    this.onIncomeSaved,
    this.showAppBar = true,
    this.showDrawer = false,
    this.showFooter = false,
    this.footerTab,
    this.safeArea = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.useCustomHeader = false,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  /// Set true only on pages where the global quick action button is needed.
  ///
  /// Example:
  /// Dashboard, Transactions.
  ///
  /// Keep false on Add/Edit pages.
  final bool showQuickActionFab;

  /// Callback from QuickActionFab after income is saved.
  ///
  /// Example:
  /// Transactions page -> reload transactions.
  /// Dashboard page -> reload dashboard.
  final VoidCallback? onIncomeSaved;

  final bool showAppBar;
  final bool showDrawer;
  final bool showFooter;
  final AppFooterTab? footerTab;
  final bool safeArea;
  final EdgeInsetsGeometry padding;
  final bool useCustomHeader;

  @override
  Widget build(BuildContext context) {
    final Widget pageBody = Padding(
      padding: padding,
      child: body,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      drawerScrimColor: AppColors.black.withValues(alpha: 0.38),
      drawer: showDrawer ? const AppSidebarDrawer() : null,
      appBar: showAppBar
          ? useCustomHeader
              ? const AppHeader()
              : AppBar(
                  title: title == null ? null : Text(title!),
                  actions: actions,
                  backgroundColor: AppColors.background,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                )
          : null,
      body: safeArea ? SafeArea(child: pageBody) : pageBody,
      bottomNavigationBar: showFooter
          ? AppFooterNav(
              currentTab: footerTab ?? AppFooterTab.home,
            )
          : bottomNavigationBar,
      floatingActionButton: floatingActionButton ??
          (showQuickActionFab
              ? QuickActionFab(
                  onIncomeSaved: onIncomeSaved,
                )
              : null),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}