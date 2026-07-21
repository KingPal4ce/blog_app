import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blog_app/models/comment.dart';

class CommentsService {
  CommentsService([SupabaseClient? client]) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _bucket = 'post-images';
  static const String _table = 'comments';
  static const String _selectColumns = '*, users(email)';

  Future<List<Comment>> fetchComments(int postId) async {
    final List<Map<String, dynamic>> rows = await _client
        .from(_table)
        .select(_selectColumns)
        .eq('post_id', postId)
        .order('created_at');
    return rows.map(Comment.fromJson).toList();
  }

  Future<Comment> createComment({
    required int postId,
    required String userId,
    required String body,
    XFile? image,
  }) async {
    final String? imagePath = image == null ? null : await _uploadImage(image, userId);
    final Map<String, dynamic> row = await _client
        .from(_table)
        .insert(<String, dynamic>{
          'post_id': postId,
          'user_id': userId,
          'body': body,
          'image_path': imagePath,
        })
        .select(_selectColumns)
        .single();
    return Comment.fromJson(row);
  }

  Future<Comment> updateComment(
    int id, {
    required String userId,
    required String body,
    String? existingImagePath,
    XFile? newImage,
    bool removeImage = false,
  }) async {
    String? imagePath = existingImagePath;
    if ((removeImage || newImage != null) && existingImagePath != null) {
      await _client.storage.from(_bucket).remove(<String>[existingImagePath]);
      imagePath = null;
    }
    if (newImage != null) {
      imagePath = await _uploadImage(newImage, userId);
    }
    final Map<String, dynamic> row = await _client
        .from(_table)
        .update(<String, dynamic>{
          'body': body,
          'image_path': imagePath,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select(_selectColumns)
        .single();
    return Comment.fromJson(row);
  }

  Future<void> deleteComment(int id, {String? imagePath}) async {
    if (imagePath != null) {
      await _client.storage.from(_bucket).remove(<String>[imagePath]);
    }
    await _client.from(_table).delete().eq('id', id);
  }

  String getPublicUrl(String path) => _client.storage.from(_bucket).getPublicUrl(path);

  Future<String> _uploadImage(XFile file, String userId) async {
    final Uint8List bytes = await file.readAsBytes();
    final String extension = file.name.contains('.') ? file.name.split('.').last : 'jpg';
    final String path = 'comments/$userId/${DateTime.now().microsecondsSinceEpoch}.$extension';
    await _client.storage
        .from(_bucket)
        .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: file.mimeType));
    return path;
  }
}
