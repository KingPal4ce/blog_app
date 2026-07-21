import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blog_app/models/comment.dart';
import 'package:blog_app/services/comments_service.dart';

class CommentsProvider extends ChangeNotifier {
  CommentsProvider(this._service, {required this.postId}) {
    unawaited(loadComments());
  }

  final CommentsService _service;
  final int postId;

  List<Comment> _comments = <Comment>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<Comment> get comments => _comments;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String imageUrl(String path) => _service.getPublicUrl(path);

  Future<void> loadComments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _comments = await _service.fetchComments(postId);
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createComment({
    required String userId,
    required String body,
    XFile? image,
  }) {
    return _mutate(() async {
      await _service.createComment(postId: postId, userId: userId, body: body, image: image);
      await loadComments();
    });
  }

  Future<bool> updateComment(
    int id, {
    required String userId,
    required String body,
    String? existingImagePath,
    XFile? newImage,
    bool removeImage = false,
  }) {
    return _mutate(() async {
      await _service.updateComment(
        id,
        userId: userId,
        body: body,
        existingImagePath: existingImagePath,
        newImage: newImage,
        removeImage: removeImage,
      );
      await loadComments();
    });
  }

  Future<bool> deleteComment(int id, {String? imagePath}) {
    return _mutate(() async {
      await _service.deleteComment(id, imagePath: imagePath);
      await loadComments();
    });
  }

  Future<bool> _mutate(Future<void> Function() action) async {
    _errorMessage = null;
    try {
      await action();
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on StorageException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
