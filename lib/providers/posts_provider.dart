import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blog_app/models/post.dart';
import 'package:blog_app/services/posts_service.dart';

class PostsProvider extends ChangeNotifier {
  PostsProvider(this._service) {
    unawaited(loadPage(1));
  }

  final PostsService _service;

  static const int pageSize = 9;

  List<Post> _posts = <Post>[];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<Post> get posts => _posts;

  int get currentPage => _currentPage;

  int get totalPages {
    final int computed = (_totalCount / pageSize).ceil();
    return computed < 1 ? 1 : computed;
  }

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> loadPage(int page) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final ({List<Post> posts, int totalCount}) result = await _service.fetchPosts(
        page: page,
        pageSize: pageSize,
      );
      _posts = result.posts;
      _totalCount = result.totalCount;
      _currentPage = page;
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadPage(_currentPage);

  String coverImageUrl(String path) => _service.getPublicUrl(path);

  Future<Post> fetchPost(int id) => _service.fetchPost(id);

  Future<Post?> createPost({
    required String userId,
    required String title,
    required List<dynamic> body,
    XFile? coverImage,
  }) {
    return _mutate(() async {
      final Post post = await _service.createPost(
        userId: userId,
        title: title,
        body: body,
        coverImage: coverImage,
      );
      await loadPage(1);
      return post;
    });
  }

  Future<Post?> updatePost(
    int id, {
    required String userId,
    required String title,
    required List<dynamic> body,
    String? existingCoverImagePath,
    XFile? newCoverImage,
    bool removeCoverImage = false,
  }) {
    return _mutate(() async {
      final Post post = await _service.updatePost(
        id,
        userId: userId,
        title: title,
        body: body,
        existingCoverImagePath: existingCoverImagePath,
        newCoverImage: newCoverImage,
        removeCoverImage: removeCoverImage,
      );
      await refresh();
      return post;
    });
  }

  Future<bool> deletePost(int id, {String? coverImagePath}) async {
    final bool? result = await _mutate(() async {
      await _service.deletePost(id, coverImagePath: coverImagePath);
      await refresh();
      return true;
    });
    return result ?? false;
  }

  Future<T?> _mutate<T>(Future<T> Function() action) async {
    _errorMessage = null;
    try {
      return await action();
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } on StorageException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    }
  }
}
