import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';
import 'package:blog_app/models/post.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/posts_provider.dart';

class CreateEditPostScreen extends StatefulWidget {
  const CreateEditPostScreen({this.postId, super.key});

  final int? postId;

  @override
  State<CreateEditPostScreen> createState() => _CreateEditPostScreenState();
}

class _CreateEditPostScreenState extends State<CreateEditPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  late final QuillController _quillController = QuillController.basic();
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _newCoverImage;
  Uint8List? _newCoverImageBytes;
  String? _existingCoverImagePath;
  bool _removeCoverImage = false;
  bool _isSubmitting = false;
  bool _isLoading = false;
  String? _loadError;

  bool get _isEditing => widget.postId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      unawaited(_loadExistingPost());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPost() async {
    setState(() => _isLoading = true);
    try {
      final Post post = await context.read<PostsProvider>().fetchPost(widget.postId!);
      _titleController.text = post.title;
      _quillController.document = Document.fromJson(post.body);
      _existingCoverImagePath = post.coverImagePath;
    } on Object {
      _loadError = 'Failed to load post.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickCoverImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    final Uint8List bytes = await image.readAsBytes();
    setState(() {
      _newCoverImage = image;
      _newCoverImageBytes = bytes;
      _removeCoverImage = false;
    });
  }

  void _removeCoverImagePressed() {
    setState(() {
      _newCoverImage = null;
      _newCoverImageBytes = null;
      _removeCoverImage = true;
    });
  }

  Future<void> _publish() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title is required.')));
      return;
    }
    final AuthProvider auth = context.read<AuthProvider>();
    final String? userId = auth.currentUser?.id;
    if (userId == null) {
      return;
    }
    setState(() => _isSubmitting = true);
    final PostsProvider postsProvider = context.read<PostsProvider>();
    final List<dynamic> body = _quillController.document.toDelta().toJson();

    final Post? result = _isEditing
        ? await postsProvider.updatePost(
            widget.postId!,
            userId: userId,
            title: title,
            body: body,
            existingCoverImagePath: _existingCoverImagePath,
            newCoverImage: _newCoverImage,
            removeCoverImage: _removeCoverImage,
          )
        : await postsProvider.createPost(
            userId: userId,
            title: title,
            body: body,
            coverImage: _newCoverImage,
          );

    if (!mounted) {
      return;
    }
    if (result != null) {
      Router.neglect(context, () => context.go('/posts/${result.id}'));
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(postsProvider.errorMessage ?? 'Failed to publish post.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadError != null) {
      return Scaffold(body: Center(child: Text(_loadError!)));
    }
    return Scaffold(
      appBar: AppBar(
        leading: TextButton.icon(
          onPressed: _isSubmitting ? null : () => Router.neglect(context, () => context.pop()),
          icon: const Icon(Icons.close),
          label: const Text('Cancel'),
        ),
        leadingWidth: 120,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: _isSubmitting ? null : _publish,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const StadiumBorder(),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                    )
                  : const Text('Publish'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _CoverImagePicker(
                  existingImageUrl: _existingCoverImagePath == null || _removeCoverImage
                      ? null
                      : context.read<PostsProvider>().coverImageUrl(_existingCoverImagePath!),
                  newImageBytes: _newCoverImageBytes,
                  onPick: _pickCoverImage,
                  onRemove: _removeCoverImagePressed,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _titleController,
                  style: AppTypography.headlineLgMobile,
                  decoration: const InputDecoration(
                    hintText: 'Post title',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 24),
                QuillSimpleToolbar(controller: _quillController),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 320),
                  child: QuillEditor.basic(
                    controller: _quillController,
                    config: const QuillEditorConfig(scrollable: false, padding: EdgeInsets.zero),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverImagePicker extends StatelessWidget {
  const _CoverImagePicker({
    required this.existingImageUrl,
    required this.newImageBytes,
    required this.onPick,
    required this.onRemove,
  });

  final String? existingImageUrl;
  final Uint8List? newImageBytes;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  bool get _hasImage => existingImageUrl != null || newImageBytes != null;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 21 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (newImageBytes != null)
                Image.memory(newImageBytes!, fit: BoxFit.cover)
              else if (existingImageUrl != null)
                CachedNetworkImage(imageUrl: existingImageUrl!, fit: BoxFit.cover)
              else
                InkWell(
                  onTap: onPick,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.add_photo_alternate_outlined, color: AppColors.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text(
                          'Add a cover image',
                          style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_hasImage)
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                      onPressed: onRemove,
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
