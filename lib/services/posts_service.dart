import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blog_app/models/post.dart';

class PostsService {
  PostsService([SupabaseClient? client]) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _bucket = 'post-images';
  static const String _table = 'posts';
  static const String _selectColumns = '*, users(email)';

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
        .range(start, end)
        .count(CountOption.exact);
    final List<Post> posts = response.data.map(Post.fromJson).toList();
    return (posts: posts, totalCount: response.count);
  }

  Future<Post> fetchPost(int id) async {
    final Map<String, dynamic> row = await _client.from(_table).select(_selectColumns).eq('id', id).single();
    return Post.fromJson(row);
  }

  Future<Post> createPost({
    required String userId,
    required String title,
    required List<dynamic> body,
    XFile? coverImage,
  }) async {
    final String? coverImagePath = coverImage == null ? null : await _uploadImage(coverImage, userId);
    final Map<String, dynamic> row = await _client
        .from(_table)
        .insert(<String, dynamic>{
          'user_id': userId,
          'title': title,
          'body': body,
          'cover_image_path': coverImagePath,
        })
        .select(_selectColumns)
        .single();
    return Post.fromJson(row);
  }

  Future<Post> updatePost(
    int id, {
    required String userId,
    required String title,
    required List<dynamic> body,
    String? existingCoverImagePath,
    XFile? newCoverImage,
    bool removeCoverImage = false,
  }) async {
    String? coverImagePath = existingCoverImagePath;
    if ((removeCoverImage || newCoverImage != null) && existingCoverImagePath != null) {
      await _client.storage.from(_bucket).remove(<String>[existingCoverImagePath]);
      coverImagePath = null;
    }
    if (newCoverImage != null) {
      coverImagePath = await _uploadImage(newCoverImage, userId);
    }
    final Map<String, dynamic> row = await _client
        .from(_table)
        .update(<String, dynamic>{
          'title': title,
          'body': body,
          'cover_image_path': coverImagePath,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select(_selectColumns)
        .single();
    return Post.fromJson(row);
  }

  Future<void> deletePost(int id, {String? coverImagePath}) async {
    if (coverImagePath != null) {
      await _client.storage.from(_bucket).remove(<String>[coverImagePath]);
    }
    await _client.from(_table).delete().eq('id', id);
  }

  String getPublicUrl(String path) => _client.storage.from(_bucket).getPublicUrl(path);

  Future<String> _uploadImage(XFile file, String userId) async {
    final Uint8List bytes = await file.readAsBytes();
    final String extension = file.name.contains('.') ? file.name.split('.').last : 'jpg';
    final String path = 'posts/$userId/${DateTime.now().microsecondsSinceEpoch}.$extension';
    await _client.storage
        .from(_bucket)
        .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: file.mimeType));
    return path;
  }
}
