import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';
import 'package:blog_app/models/post.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/posts_provider.dart';
import 'package:blog_app/widgets/pagination_bar.dart';
import 'package:blog_app/widgets/post_card.dart';

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
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Router.neglect(context, () => context.push('/posts/new')),
                      child: const Text('New Post'),
                    ),
                    TextButton(
                      onPressed: () => context.read<AuthProvider>().logout(),
                      child: const Text('Logout'),
                    ),
                  ],
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Router.neglect(context, () => context.replace('/auth')),
                    child: const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () => Router.neglect(context, () => context.replace('/auth')),
                    child: const Text('Join'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<PostsProvider>(
        builder: (BuildContext context, PostsProvider posts, Widget? child) {
          if (posts.isLoading && posts.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (posts.errorMessage != null && posts.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(posts.errorMessage!, style: AppTypography.bodyMd.copyWith(color: AppColors.error)),
                  const SizedBox(height: 16),
                  TextButton(onPressed: posts.refresh, child: const Text('Retry')),
                ],
              ),
            );
          }
          if (posts.posts.isEmpty) {
            return const Center(child: Text('No posts yet.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Latest Readings', style: AppTypography.display),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int columns = constraints.maxWidth >= 1024
                        ? 3
                        : constraints.maxWidth >= 640
                        ? 2
                        : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.posts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 32,
                        mainAxisSpacing: 64,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final Post post = posts.posts[index];
                        final String? imageUrl = post.coverImagePath == null
                            ? null
                            : posts.coverImageUrl(post.coverImagePath!);
                        return PostCard(
                          post: post,
                          imageUrl: imageUrl,
                          onTap: () => Router.neglect(context, () => context.push('/posts/${post.id}')),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                PaginationBar(
                  currentPage: posts.currentPage,
                  totalPages: posts.totalPages,
                  onPageChanged: posts.loadPage,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
