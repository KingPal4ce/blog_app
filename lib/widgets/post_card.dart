import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show Document;

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';
import 'package:blog_app/models/post.dart';
import 'package:blog_app/utils/date_format.dart';
import 'package:blog_app/widgets/initials_avatar.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    required this.imageUrl,
    required this.onTap,
    super.key,
  });

  final Post post;
  final String? imageUrl;
  final VoidCallback onTap;

  String get _excerpt {
    try {
      return Document.fromJson(post.body).toPlainText().trim();
    } on Object {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 4 / 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl == null
                    ? const ColoredBox(color: AppColors.surfaceContainerLow)
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) =>
                            const ColoredBox(color: AppColors.surfaceContainerLow),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 12),
                Text(formatDisplayDate(post.createdAt), style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Text(post.title, style: AppTypography.headlineMd, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(
                  _excerpt,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    InitialsAvatar(email: post.authorEmail, radius: 16),
                    const SizedBox(width: 8),
                    Text(post.authorEmail ?? 'Unknown', style: AppTypography.labelMd),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
