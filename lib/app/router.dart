import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/screens/auth/auth_screen.dart';
import 'package:blog_app/screens/feed/discover_posts_screen.dart';

GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (BuildContext context, GoRouterState state) {
      final bool onAuthScreen = state.matchedLocation == '/auth';
      if (authProvider.isAuthenticated && onAuthScreen) {
        return '/';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const DiscoverPostsScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (BuildContext context, GoRouterState state) => const AuthScreen(),
      ),
    ],
  );
}
