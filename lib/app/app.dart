import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:blog_app/app/app_theme.dart';

class App extends StatelessWidget {
  const App({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'The Journal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
