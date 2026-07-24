import 'package:flutter/material.dart';

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';
import 'package:blog_app/models/comment.dart';
import 'package:blog_app/utils/date_format.dart';
import 'package:blog_app/widgets/initials_avatar.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    required this.comment,
    required this.imageUrls,
    required this.isOwner,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Comment comment;
  final List<String> imageUrls;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final String? displayEmail = comment.isDeleted ? 'anonymous' : comment.authorEmail;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHighest)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24, top: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InitialsAvatar(email: displayEmail, radius: 20, highlighted: isOwner),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          displayEmail ?? 'Unknown',
                          style: AppTypography.labelMd.copyWith(color: AppColors.secondary),
                        ),
                      ),
                      Text(
                        formatDisplayDate(comment.createdAt),
                        style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (comment.isDeleted)
                    Text(
                      'This comment has been deleted.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else ...<Widget>[
                    Text(comment.body, style: AppTypography.bodyMd),
                    if (imageUrls.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          for (final String url in imageUrls)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                width: 96,
                                height: 96,
                                child: Image.network(url, fit: BoxFit.cover),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (isOwner) ...<Widget>[
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          IconButton(
                            iconSize: 18,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: onEdit,
                          ),
                          IconButton(
                            iconSize: 18,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete_outline),
                            color: AppColors.error,
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
