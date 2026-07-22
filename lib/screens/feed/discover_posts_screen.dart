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
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text('The Journal'),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(
            width: double.infinity,
            height: 1,
            child: ColoredBox(color: AppColors.outlineVariant),
          ),
        ),
        actions: <Widget>[
          Consumer<AuthProvider>(
            builder: (BuildContext context, AuthProvider auth, Widget? child) {
              if (auth.isAuthenticated) {
                return TextButton.icon(
                  icon: const Icon(Icons.logout, size: 20),
                  onPressed: () => context.read<AuthProvider>().logout(),
                  label: const Text('Logout'),
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Router.neglect(context, () => context.replace('/auth')),
                    child: const Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () => Router.neglect(context, () => context.replace('/auth?mode=join')),
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
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          final Widget title = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text('Latest Readings', style: AppTypography.display),
                              const SizedBox(height: 8),
                              Text(
                                'Discover the latest articles, discussions, and insights shared by our community!',
                                style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          );
                          final Widget? newPostButton = context.watch<AuthProvider>().isAuthenticated
                              ? ElevatedButton.icon(
                                  onPressed: () => Router.neglect(context, () => context.push('/posts/new')),
                                  icon: const Icon(Icons.add, size: 20),
                                  label: const Text('New Post'),
                                )
                              : null;
                          if (constraints.maxWidth < 640) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                title,
                                if (newPostButton != null) ...<Widget>[
                                  const SizedBox(height: 24),
                                  newPostButton,
                                ],
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(child: title),
                              if (newPostButton != null) ...<Widget>[
                                const SizedBox(width: 24),
                                newPostButton,
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 48),
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
                              childAspectRatio: 0.85,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              final Post post = posts.posts[index];
                              final String? imageUrl = post.coverImagePath == null ? null : posts.coverImageUrl(post.coverImagePath!);
                              return PostCard(
                                post: post,
                                imageUrl: imageUrl,
                                onTap: () => Router.neglect(context, () => context.push('/posts/${post.id}')),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 64),
                      PaginationBar(
                        currentPage: posts.currentPage,
                        totalPages: posts.totalPages,
                        onPageChanged: posts.loadPage,
                      ),
                    ],
                  ),
                ),
                const _DiscoverFooter(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DiscoverFooter extends StatelessWidget {
  const _DiscoverFooter();

  static const List<String> _links = <String>['About', 'Guidelines', 'Privacy', 'Terms', 'Contact'];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            const Widget brand = Text('The Journal', style: AppTypography.headlineMd);
            final Widget links = Wrap(
              spacing: 24,
              runSpacing: 8,
              children: <Widget>[
                for (final String link in _links) Text(link, style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            );
            const Widget copyright = Text(
              '© 2026 The Journal. All Rights Reserved.',
              style: AppTypography.labelMd,
            );
            if (constraints.maxWidth < 768) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  brand,
                  const SizedBox(height: 16),
                  links,
                  const SizedBox(height: 16),
                  copyright,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Expanded(child: brand),
                Expanded(child: Center(child: links)),
                const Expanded(
                  child: Align(alignment: Alignment.centerRight, child: copyright),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
