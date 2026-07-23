import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';
import 'package:blog_app/models/post.dart';
import 'package:blog_app/models/post_image.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/posts_provider.dart';
import 'package:blog_app/widgets/multi_image_picker.dart';

class CreateEditPostScreen extends StatefulWidget {
  const CreateEditPostScreen({this.postId, super.key});

  final int? postId;

  @override
  State<CreateEditPostScreen> createState() => _CreateEditPostScreenState();
}

class _CreateEditPostScreenState extends State<CreateEditPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  late final QuillController _quillController = QuillController.basic();

  List<PostImage> _existingImages = <PostImage>[];
  final Set<int> _removedImageIds = <int>{};
  List<XFile> _newImages = <XFile>[];
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
      _existingImages = post.images;
    } on Object {
      _loadError = 'Failed to load post.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onRemoveExisting(int id) => setState(() => _removedImageIds.add(id));

  void _onImagesAdded(List<XFile> images) => setState(() => _newImages = <XFile>[..._newImages, ...images]);

  void _onRemoveNew(int index) => setState(() => _newImages = List<XFile>.of(_newImages)..removeAt(index));

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
            existingImages: _existingImages,
            removedImageIds: _removedImageIds.toList(),
            newImages: _newImages,
          )
        : await postsProvider.createPost(
            userId: userId,
            title: title,
            body: body,
            images: _newImages,
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
    final PostsProvider postsProvider = context.read<PostsProvider>();
    final List<ExistingPickerImage> existingPickerImages = _existingImages
        .where((PostImage image) => !_removedImageIds.contains(image.id))
        .map((PostImage image) => ExistingPickerImage(id: image.id, url: postsProvider.imageUrl(image.imagePath)))
        .toList();
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
                Text('Images', style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 12),
                MultiImagePicker(
                  existingImages: existingPickerImages,
                  newImages: _newImages,
                  onRemoveExisting: _onRemoveExisting,
                  onImagesAdded: _onImagesAdded,
                  onRemoveNew: _onRemoveNew,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _titleController,
                  style: AppTypography.headlineLgMobile,
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Post title',
                    hintStyle: AppTypography.headlineLgMobile.copyWith(
                      color: AppColors.outline,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 24),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: QuillSimpleToolbar(
                      controller: _quillController,
                      config: QuillSimpleToolbarConfig(
                        multiRowsDisplay: false,
                        showFontFamily: false,
                        showFontSize: false,
                        showSmallButton: false,
                        showLineHeightButton: false,
                        showInlineCode: false,
                        showColorButton: false,
                        showBackgroundColorButton: false,
                        showClearFormat: false,
                        showAlignmentButtons: false,
                        showListCheck: false,
                        showCodeBlock: false,
                        showIndent: false,
                        showDirection: false,
                        showSearchButton: false,
                        showSubscript: false,
                        showSuperscript: false,
                        sectionDividerColor: AppColors.outlineVariant,
                        iconTheme: QuillIconTheme(
                          iconButtonUnselectedData: const IconButtonData(
                            color: AppColors.onSurfaceVariant,
                            iconSize: 18,
                          ),
                          iconButtonSelectedData: IconButtonData(
                            color: AppColors.primary,
                            iconSize: 18,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceContainerHigh,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 400),
                  child: QuillEditor.basic(
                    controller: _quillController,
                    config: QuillEditorConfig(
                      scrollable: false,
                      padding: EdgeInsets.zero,
                      placeholder: 'Start writing your story...',
                      customStyles: DefaultStyles(
                        paragraph: DefaultTextBlockStyle(
                          AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
                          HorizontalSpacing.zero,
                          const VerticalSpacing(0, 12),
                          VerticalSpacing.zero,
                          null,
                        ),
                        placeHolder: DefaultTextBlockStyle(
                          AppTypography.bodyLg.copyWith(color: AppColors.outline),
                          HorizontalSpacing.zero,
                          VerticalSpacing.zero,
                          VerticalSpacing.zero,
                          null,
                        ),
                      ),
                    ),
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
