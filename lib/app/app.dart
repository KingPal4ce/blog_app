import 'package:flutter/material.dart';

import 'package:blog_app/app/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Journal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Placeholder(),
    );
  }
}
