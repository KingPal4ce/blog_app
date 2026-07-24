import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blog_app/models/comment.dart';
import 'package:blog_app/models/comment_image.dart';

class CommentsService {
  CommentsService([SupabaseClient? client]) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _bucket = 'post-images';
  static const String _table = 'comments';
  static const String _imagesTable = 'comment_images';
  static const String _selectColumns = '*, users(email), comment_images(id, comment_id, image_path, sort_order, created_at)';

  Future<List<Comment>> fetchComments(int postId) async {
    final List<Map<String, dynamic>> rows = await _client
        .from(_table)
        .select(_selectColumns)
        .eq('post_id', postId)
        .order('created_at')
        .order('sort_order', referencedTable: _imagesTable);
    return rows.map(Comment.fromJson).toList();
  }

  Future<Comment> createComment({
    required int postId,
    required String userId,
    required String body,
    List<XFile> images = const <XFile>[],
  }) async {
    final Map<String, dynamic> row = await _client
        .from(_table)
        .insert(<String, dynamic>{
          'post_id': postId,
          'user_id': userId,
          'body': body,
        })
        .select(_selectColumns)
        .single();
    final int commentId = row['id'] as int;
    await _insertImages(commentId: commentId, userId: userId, images: images, startOrder: 0);
    return fetchComment(commentId);
  }

  Future<Comment> updateComment(
    int id, {
    required String userId,
    required String body,
    List<CommentImage> existingImages = const <CommentImage>[],
    List<int> removedImageIds = const <int>[],
    List<XFile> newImages = const <XFile>[],
  }) async {
    if (removedImageIds.isNotEmpty) {
      final List<String> removedPaths = existingImages
          .where((CommentImage image) => removedImageIds.contains(image.id))
          .map((CommentImage image) => image.imagePath)
          .toList();
      if (removedPaths.isNotEmpty) {
        await _client.storage.from(_bucket).remove(removedPaths);
      }
      await _client.from(_imagesTable).delete().inFilter('id', removedImageIds);
    }
    final int nextOrder = existingImages
            .where((CommentImage image) => !removedImageIds.contains(image.id))
            .fold(-1, (int max, CommentImage image) => image.sortOrder > max ? image.sortOrder : max) +
        1;
    await _insertImages(commentId: id, userId: userId, images: newImages, startOrder: nextOrder);
    await _client
        .from(_table)
        .update(<String, dynamic>{
          'body': body,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
    return fetchComment(id);
  }

  Future<void> deleteComment(int id, {List<CommentImage> images = const <CommentImage>[]}) async {
    if (images.isNotEmpty) {
      await _client.storage.from(_bucket).remove(images.map((CommentImage image) => image.imagePath).toList());
    }
    await _client.from(_imagesTable).delete().eq('comment_id', id);
    await _client
        .from(_table)
        .update(<String, dynamic>{
          'body': '',
          'deleted_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  String getPublicUrl(String path) => _client.storage.from(_bucket).getPublicUrl(path);

  Future<Comment> fetchComment(int id) async {
    final Map<String, dynamic> row = await _client
        .from(_table)
        .select(_selectColumns)
        .eq('id', id)
        .order('sort_order', referencedTable: _imagesTable)
        .single();
    return Comment.fromJson(row);
  }

  Future<void> _insertImages({
    required int commentId,
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
          'comment_id': commentId,
          'image_path': paths[i],
          'sort_order': startOrder + i,
        },
    ]);
  }

  Future<String> _uploadImage(XFile file, String userId, int index) async {
    final Uint8List bytes = await file.readAsBytes();
    final String extension = file.name.contains('.') ? file.name.split('.').last : 'jpg';
    final String path = 'comments/$userId/${DateTime.now().microsecondsSinceEpoch}_$index.$extension';
    await _client.storage
        .from(_bucket)
        .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: file.mimeType));
    return path;
  }
}
