import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';
import 'package:blog_app/models/comment.dart';
import 'package:blog_app/models/comment_image.dart';
import 'package:blog_app/models/post.dart';
import 'package:blog_app/models/post_image.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/comments_provider.dart';
import 'package:blog_app/providers/posts_provider.dart';
import 'package:blog_app/services/comments_service.dart';
import 'package:blog_app/utils/date_format.dart';
import 'package:blog_app/widgets/comment_tile.dart';
import 'package:blog_app/widgets/initials_avatar.dart';
import 'package:blog_app/widgets/multi_image_picker.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({required this.postId, super.key});

  final int postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<Post> _postFuture;

  @override
  void initState() {
    super.initState();
    _postFuture = context.read<PostsProvider>().fetchPost(widget.postId);
  }

  Future<void> _deletePost(Post post) async {
    final PostsProvider provider = context.read<PostsProvider>();
    final bool success = await provider.deletePost(post.id, images: post.images);
    if (success && mounted) {
      Router.neglect(context, () => context.go('/'));
    }
  }

  Future<void> _confirmDelete(Post post) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This cannot be undone.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await _deletePost(post);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GestureDetector(
            onTap: () => Router.neglect(context, () => context.go('/')),
            child: const Text('The Journal'),
          ),
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
                spacing: 8,
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
      body: FutureBuilder<Post>(
        future: _postFuture,
        builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Post not found.'));
          }
          final Post post = snapshot.data!;
          final AuthProvider auth = context.watch<AuthProvider>();
          final PostsProvider postsProvider = context.read<PostsProvider>();
          final bool isOwner = auth.currentUser?.id == post.userId;
          final List<String> imageUrls = post.images.map((PostImage image) => postsProvider.imageUrl(image.imagePath)).toList();

          return ChangeNotifierProvider<CommentsProvider>(
            create: (BuildContext context) => CommentsProvider(CommentsService(), postId: post.id),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Router.neglect(context, () => context.go('/')),
                          icon: const Icon(Icons.arrow_back, size: 20),
                          label: const Text('Back'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(post.title, style: AppTypography.display, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'By ${post.authorEmail ?? 'Unknown'} • ${formatDisplayDate(post.createdAt)}',
                          style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                      if (isOwner) ...<Widget>[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            OutlinedButton.icon(
                              onPressed: () => Router.neglect(context, () => context.push('/posts/${post.id}/edit')),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit Post'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => _confirmDelete(post),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      if (imageUrls.isNotEmpty) _PostImageGallery(imageUrls: imageUrls),
                      const SizedBox(height: 32),
                      QuillEditor.basic(
                        controller: QuillController(
                          document: Document.fromJson(post.body),
                          selection: const TextSelection.collapsed(offset: 0),
                          readOnly: true,
                        ),
                        config: const QuillEditorConfig(scrollable: false, padding: EdgeInsets.zero),
                      ),
                      const SizedBox(height: 48),
                      const Divider(),
                      const SizedBox(height: 24),
                      _CommentsSection(currentUserId: auth.currentUser?.id, isAuthenticated: auth.isAuthenticated),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PostImageGallery extends StatefulWidget {
  const _PostImageGallery({required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<_PostImageGallery> createState() => _PostImageGalleryState();
}

class _PostImageGalleryState extends State<_PostImageGallery> {
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMultiple = widget.imageUrls.length > 1;
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 21 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (int page) => setState(() => _page = page),
                  itemBuilder: (BuildContext context, int index) =>
                      Image.network(widget.imageUrls[index], fit: BoxFit.cover),
                ),
                if (hasMultiple) ...<Widget>[
                  if (_page > 0)
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(child: _GalleryArrowButton(icon: Icons.chevron_left, onTap: () => _goTo(_page - 1))),
                    ),
                  if (_page < widget.imageUrls.length - 1)
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(child: _GalleryArrowButton(icon: Icons.chevron_right, onTap: () => _goTo(_page + 1))),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (hasMultiple) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < widget.imageUrls.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _goTo(i),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page ? AppColors.primary : AppColors.outlineVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _GalleryArrowButton extends StatelessWidget {
  const _GalleryArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}

class _CommentsSection extends StatelessWidget {
  const _CommentsSection({required this.currentUserId, required this.isAuthenticated});

  final String? currentUserId;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final CommentsProvider comments = context.watch<CommentsProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Discussion (${comments.comments.length})', style: AppTypography.headlineMd),
        const SizedBox(height: 24),
        if (isAuthenticated)
          const _CommentComposer()
        else
          Text(
            'Sign in to join the discussion.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        const SizedBox(height: 24),
        if (comments.isLoading && comments.comments.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          for (final Comment comment in comments.comments)
            CommentTile(
              comment: comment,
              imageUrls: comment.images.map((CommentImage image) => comments.imageUrl(image.imagePath)).toList(),
              isOwner: currentUserId != null && currentUserId == comment.userId,
              onEdit: () => _editComment(context, comment),
              onDelete: () => comments.deleteComment(comment.id, images: comment.images),
            ),
      ],
    );
  }

  Future<void> _editComment(BuildContext context, Comment comment) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => _CommentEditDialog(comment: comment),
    );
  }
}

class _CommentComposer extends StatefulWidget {
  const _CommentComposer();

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final TextEditingController _bodyController = TextEditingController();
  List<XFile> _images = <XFile>[];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  void _onImagesAdded(List<XFile> images) => setState(() => _images = <XFile>[..._images, ...images]);

  void _onRemoveNew(int index) => setState(() => _images = List<XFile>.of(_images)..removeAt(index));

  Future<void> _submit() async {
    final String body = _bodyController.text.trim();
    if (body.isEmpty) {
      return;
    }
    setState(() => _isSubmitting = true);
    final AuthProvider auth = context.read<AuthProvider>();
    final CommentsProvider comments = context.read<CommentsProvider>();
    final String? userId = auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isSubmitting = false);
      return;
    }
    final bool success = await comments.createComment(userId: userId, body: body, images: _images);
    if (success && mounted) {
      _bodyController.clear();
      setState(() {
        _images = <XFile>[];
        _isSubmitting = false;
      });
    } else if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InitialsAvatar(email: auth.currentUser?.email, radius: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _bodyController,
                    maxLines: 3,
                    style: AppTypography.bodyMd,
                    decoration: const InputDecoration(
                      hintText: 'Add to the discussion...',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  MultiImagePicker(
                    existingImages: const <ExistingPickerImage>[],
                    newImages: _images,
                    onRemoveExisting: (_) {},
                    onImagesAdded: _onImagesAdded,
                    onRemoveNew: _onRemoveNew,
                    tileSize: 72,
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Post Comment'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentEditDialog extends StatefulWidget {
  const _CommentEditDialog({required this.comment});

  final Comment comment;

  @override
  State<_CommentEditDialog> createState() => _CommentEditDialogState();
}

class _CommentEditDialogState extends State<_CommentEditDialog> {
  late final TextEditingController _bodyController = TextEditingController(text: widget.comment.body);
  final Set<int> _removedImageIds = <int>{};
  List<XFile> _newImages = <XFile>[];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  void _onRemoveExisting(int id) => setState(() => _removedImageIds.add(id));

  void _onImagesAdded(List<XFile> images) => setState(() => _newImages = <XFile>[..._newImages, ...images]);

  void _onRemoveNew(int index) => setState(() => _newImages = List<XFile>.of(_newImages)..removeAt(index));

  Future<void> _submit() async {
    final String body = _bodyController.text.trim();
    if (body.isEmpty) {
      return;
    }
    setState(() => _isSubmitting = true);
    final AuthProvider auth = context.read<AuthProvider>();
    final CommentsProvider comments = context.read<CommentsProvider>();
    final String? userId = auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isSubmitting = false);
      return;
    }
    final bool success = await comments.updateComment(
      widget.comment.id,
      userId: userId,
      body: body,
      existingImages: widget.comment.images,
      removedImageIds: _removedImageIds.toList(),
      newImages: _newImages,
    );
    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final CommentsProvider comments = context.read<CommentsProvider>();
    final List<ExistingPickerImage> existingPickerImages = widget.comment.images
        .where((CommentImage image) => !_removedImageIds.contains(image.id))
        .map((CommentImage image) => ExistingPickerImage(id: image.id, url: comments.imageUrl(image.imagePath)))
        .toList();
    return AlertDialog(
      title: const Text('Edit comment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(controller: _bodyController, maxLines: 4),
          const SizedBox(height: 12),
          MultiImagePicker(
            existingImages: existingPickerImages,
            newImages: _newImages,
            onRemoveExisting: _onRemoveExisting,
            onImagesAdded: _onImagesAdded,
            onRemoveNew: _onRemoveNew,
            tileSize: 72,
            enabled: !_isSubmitting,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _isSubmitting ? null : _submit, child: const Text('Save')),
      ],
    );
  }
}
