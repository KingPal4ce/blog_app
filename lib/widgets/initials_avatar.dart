import 'package:flutter/material.dart';

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';
import 'package:blog_app/utils/avatar_initials.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    required this.email,
    this.radius = 16,
    this.highlighted = false,
    super.key,
  });

  final String? email;
  final double radius;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: highlighted ? AppColors.secondaryContainer : AppColors.surfaceContainerHigh,
      child: Text(
        avatarInitials(email),
        style: AppTypography.labelSm.copyWith(
          color: highlighted ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
