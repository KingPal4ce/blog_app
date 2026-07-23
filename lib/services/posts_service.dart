import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blog_app/models/post.dart';
import 'package:blog_app/models/post_image.dart';

class PostsService {
  PostsService([SupabaseClient? client]) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _bucket = 'post-images';
  static const String _table = 'posts';
  static const String _imagesTable = 'post_images';
  static const String _selectColumns = '*, users(email), post_images(id, post_id, image_path, sort_order, created_at)';

  Future<({List<Post> posts, int totalCount})> fetchPosts({
    required int page,
    required int pageSize,
  }) async {
    final int start = (page - 1) * pageSize;
    final int end = start + pageSize - 1;
    final PostgrestResponse<PostgrestList> response = await _client
        .from(_table)
        .select(_selectColumns)
        .order('created_at', ascending: false)
        .order('sort_order', referencedTable: _imagesTable)
        .range(start, end)
        .count(CountOption.exact);
    final List<Post> posts = response.data.map(Post.fromJson).toList();
    return (posts: posts, totalCount: response.count);
  }

  Future<Post> fetchPost(int id) async {
    final Map<String, dynamic> row = await _client
        .from(_table)
        .select(_selectColumns)
        .eq('id', id)
        .order('sort_order', referencedTable: _imagesTable)
        .single();
    return Post.fromJson(row);
  }

  Future<Post> createPost({
    required String userId,
    required String title,
    required List<dynamic> body,
    List<XFile> images = const <XFile>[],
  }) async {
    final Map<String, dynamic> row = await _client
        .from(_table)
        .insert(<String, dynamic>{
          'user_id': userId,
          'title': title,
          'body': body,
        })
        .select(_selectColumns)
        .single();
    final int postId = row['id'] as int;
    await _insertImages(postId: postId, userId: userId, images: images, startOrder: 0);
    return fetchPost(postId);
  }

  Future<Post> updatePost(
    int id, {
    required String userId,
    required String title,
    required List<dynamic> body,
    List<PostImage> existingImages = const <PostImage>[],
    List<int> removedImageIds = const <int>[],
    List<XFile> newImages = const <XFile>[],
  }) async {
    if (removedImageIds.isNotEmpty) {
      final List<String> removedPaths = existingImages
          .where((PostImage image) => removedImageIds.contains(image.id))
          .map((PostImage image) => image.imagePath)
          .toList();
      if (removedPaths.isNotEmpty) {
        await _client.storage.from(_bucket).remove(removedPaths);
      }
      await _client.from(_imagesTable).delete().inFilter('id', removedImageIds);
    }
    final int nextOrder = existingImages
            .where((PostImage image) => !removedImageIds.contains(image.id))
            .fold(-1, (int max, PostImage image) => image.sortOrder > max ? image.sortOrder : max) +
        1;
    await _insertImages(postId: id, userId: userId, images: newImages, startOrder: nextOrder);
    await _client
        .from(_table)
        .update(<String, dynamic>{
          'title': title,
          'body': body,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
    return fetchPost(id);
  }

  Future<void> deletePost(int id, {List<PostImage> images = const <PostImage>[]}) async {
    if (images.isNotEmpty) {
      await _client.storage.from(_bucket).remove(images.map((PostImage image) => image.imagePath).toList());
    }
    await _client.from(_table).delete().eq('id', id);
  }

  String getPublicUrl(String path) => _client.storage.from(_bucket).getPublicUrl(path);

  Future<void> _insertImages({
    required int postId,
    required String userId,
    required List<XFile> images,
    required int startOrder,
  }) async {
    if (images.isEmpty) {
      return;
    }
    final List<String> paths = await Future.wait(
      images.asMap().entries.map((MapEntry<int, XFile> entry) => _uploadImage(entry.value, userId, entry.key)),
    );
    await _client.from(_imagesTable).insert(<Map<String, dynamic>>[
      for (int i = 0; i < paths.length; i++)
        <String, dynamic>{
          'post_id': postId,
          'image_path': paths[i],
          'sort_order': startOrder + i,
        },
    ]);
  }

  Future<String> _uploadImage(XFile file, String userId, int index) async {
    final Uint8List bytes = await file.readAsBytes();
    final String extension = file.name.contains('.') ? file.name.split('.').last : 'jpg';
    final String path = 'posts/$userId/${DateTime.now().microsecondsSinceEpoch}_$index.$extension';
    await _client.storage
        .from(_bucket)
        .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: file.mimeType));
    return path;
  }
}
