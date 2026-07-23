import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';

class ExistingPickerImage {
  const ExistingPickerImage({required this.id, required this.url});

  final int id;
  final String url;
}

/// Manages a mix of already-uploaded images and newly-picked local files,
/// each individually removable, with a trailing tile to add more.
class MultiImagePicker extends StatefulWidget {
  const MultiImagePicker({
    required this.existingImages,
    required this.newImages,
    required this.onRemoveExisting,
    required this.onImagesAdded,
    required this.onRemoveNew,
    this.tileSize = 120,
    this.enabled = true,
    super.key,
  });

  final List<ExistingPickerImage> existingImages;
  final List<XFile> newImages;
  final ValueChanged<int> onRemoveExisting;
  final ValueChanged<List<XFile>> onImagesAdded;
  final ValueChanged<int> onRemoveNew;
  final double tileSize;
  final bool enabled;

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  final Map<XFile, Uint8List> _byteCache = <XFile, Uint8List>{};

  Future<void> _pickImages() async {
    final List<XFile> picked = await ImagePicker().pickMultiImage();
    if (picked.isEmpty) {
      return;
    }
    widget.onImagesAdded(picked);
  }

  Future<Uint8List> _bytesFor(XFile file) async {
    final Uint8List? cached = _byteCache[file];
    if (cached != null) {
      return cached;
    }
    final Uint8List bytes = await file.readAsBytes();
    _byteCache[file] = bytes;
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final ExistingPickerImage image in widget.existingImages)
          _ImageTile(
            size: widget.tileSize,
            image: Image.network(image.url, fit: BoxFit.cover),
            onRemove: widget.enabled ? () => widget.onRemoveExisting(image.id) : null,
          ),
        for (int i = 0; i < widget.newImages.length; i++)
          _ImageTile(
            size: widget.tileSize,
            image: FutureBuilder<Uint8List>(
              future: _bytesFor(widget.newImages[i]),
              builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                if (!snapshot.hasData) {
                  return const ColoredBox(color: AppColors.surfaceContainerLow);
                }
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              },
            ),
            onRemove: widget.enabled ? () => widget.onRemoveNew(i) : null,
          ),
        _AddTile(
          size: widget.tileSize,
          onTap: widget.enabled ? _pickImages : null,
        ),
      ],
    );
  }
}

class _ImageTile extends StatefulWidget {
  const _ImageTile({required this.size, required this.image, required this.onRemove});

  final double size;
  final Widget image;
  final VoidCallback? onRemove;

  @override
  State<_ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<_ImageTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              widget.image,
              if (_isHovering)
                const ColoredBox(color: Colors.black26),
              if (widget.onRemove != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: widget.onRemove,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                      child: const Icon(Icons.close, size: 14, color: AppColors.error),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTile extends StatefulWidget {
  const _AddTile({required this.size, required this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  State<_AddTile> createState() => _AddTileState();
}

class _AddTileState extends State<_AddTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final Color color = _isHovering ? AppColors.onSurface : AppColors.onSurfaceVariant;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _isHovering ? AppColors.outline : AppColors.outlineVariant),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onTap,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.add_photo_alternate_outlined, color: color, size: 28),
                  const SizedBox(height: 4),
                  Text('Add', style: AppTypography.labelSm.copyWith(color: color)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
