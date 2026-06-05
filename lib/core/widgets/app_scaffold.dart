import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showAppBar = true,
    this.safeArea = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final bool safeArea;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Widget pageBody = Padding(
      padding: padding,
      child: body,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              title: title == null ? null : Text(title!),
              actions: actions,
            )
          : null,
      body: safeArea ? SafeArea(child: pageBody) : pageBody,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}