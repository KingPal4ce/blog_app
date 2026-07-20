import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:blog_app/providers/auth_provider.dart';

class DiscoverPostsScreen extends StatelessWidget {
  const DiscoverPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Posts'),
        actions: <Widget>[
          Consumer<AuthProvider>(
            builder: (BuildContext context, AuthProvider auth, Widget? child) {
              if (auth.isAuthenticated) {
                return TextButton(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  child: const Text('Logout'),
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () => context.replace('/auth'),
                    child: const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () => context.replace('/auth'),
                    child: const Text('Join'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const Center(child: Text('Posts will appear here.')),
    );
  }
}
