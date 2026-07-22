import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/screens/auth/auth_screen.dart';
import 'package:blog_app/screens/feed/discover_posts_screen.dart';
import 'package:blog_app/screens/posts/create_edit_post_screen.dart';
import 'package:blog_app/screens/posts/post_detail_screen.dart';

GoRouter buildRouter(AuthProvider authProvider) {
  String? requireAuth(BuildContext context, GoRouterState state) {
    return authProvider.isAuthenticated ? null : '/auth';
  }

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
        builder: (BuildContext context, GoRouterState state) =>
            AuthScreen(initialMode: state.uri.queryParameters['mode']),
      ),
      GoRoute(
        path: '/posts/new',
        redirect: requireAuth,
        builder: (BuildContext context, GoRouterState state) => const CreateEditPostScreen(),
      ),
      GoRoute(
        path: '/posts/:id',
        builder: (BuildContext context, GoRouterState state) =>
            PostDetailScreen(postId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/posts/:id/edit',
        redirect: requireAuth,
        builder: (BuildContext context, GoRouterState state) =>
            CreateEditPostScreen(postId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
}
