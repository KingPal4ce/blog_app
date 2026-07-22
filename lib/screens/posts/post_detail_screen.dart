import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';
import 'package:blog_app/models/comment.dart';
import 'package:blog_app/models/post.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/comments_provider.dart';
import 'package:blog_app/providers/posts_provider.dart';
import 'package:blog_app/services/comments_service.dart';
import 'package:blog_app/utils/date_format.dart';
import 'package:blog_app/widgets/comment_tile.dart';
import 'package:blog_app/widgets/initials_avatar.dart';

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
    final bool success = await provider.deletePost(post.id, coverImagePath: post.coverImagePath);
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
          final String? imageUrl = post.coverImagePath == null ? null : postsProvider.coverImageUrl(post.coverImagePath!);

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
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 21 / 9,
                            child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
                          ),
                        ),
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
              imageUrl: comment.imagePath == null ? null : comments.imageUrl(comment.imagePath!),
              isOwner: currentUserId != null && currentUserId == comment.userId,
              onEdit: () => _editComment(context, comment),
              onDelete: () => comments.deleteComment(comment.id, imagePath: comment.imagePath),
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
  XFile? _image;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _image = image);
    }
  }

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
    final bool success = await comments.createComment(userId: userId, body: body, image: _image);
    if (success && mounted) {
      _bodyController.clear();
      setState(() {
        _image = null;
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
                  if (_image != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Attached: ${_image!.name}', style: AppTypography.labelSm),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: _isSubmitting ? null : _pickImage,
                        icon: const Icon(Icons.image_outlined),
                        tooltip: 'Attach Image',
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('Post Comment'),
                      ),
                    ],
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
  bool _removeImage = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

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
      existingImagePath: widget.comment.imagePath,
      removeImage: _removeImage,
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
    return AlertDialog(
      title: const Text('Edit comment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(controller: _bodyController, maxLines: 4),
          if (widget.comment.imagePath != null)
            CheckboxListTile(
              value: _removeImage,
              onChanged: (bool? value) => setState(() => _removeImage = value ?? false),
              title: const Text('Remove attached image'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
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
