import 'package:flutter/material.dart';

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    super.key,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _NavTextButton(
              icon: Icons.arrow_back,
              label: 'Previous',
              iconFirst: true,
              onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            ),
            Wrap(
              spacing: 8,
              children: <Widget>[
                for (final int page in List<int>.generate(totalPages, (int index) => index + 1))
                  _PageButton(
                    page: page,
                    selected: page == currentPage,
                    onPressed: () => onPageChanged(page),
                  ),
              ],
            ),
            _NavTextButton(
              icon: Icons.arrow_forward,
              label: 'Next',
              iconFirst: false,
              onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.page,
    required this.selected,
    required this.onPressed,
  });

  final int page;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(4);
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              '$page',
              style: AppTypography.labelMd.copyWith(
                color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTextButton extends StatelessWidget {
  const _NavTextButton({
    required this.icon,
    required this.label,
    required this.iconFirst,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool iconFirst;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final Color color = enabled ? AppColors.onSurface : AppColors.outlineVariant;
    final List<Widget> children = <Widget>[
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 8),
      Text(label, style: AppTypography.labelMd.copyWith(color: color)),
    ];
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: enabled ? AppColors.outlineVariant : Colors.transparent),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: iconFirst ? children : children.reversed.toList(),
      ),
    );
  }
}
