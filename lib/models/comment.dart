import 'package:json_annotation/json_annotation.dart';

import 'package:blog_app/models/comment_image.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorEmail,
    required this.body,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(_normalize(json));

  final int id;

  @JsonKey(name: 'post_id')
  final int postId;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'author_email')
  final String? authorEmail;

  final String body;

  final List<CommentImage> images;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  static Map<String, dynamic> _normalize(Map<String, dynamic> json) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(json);
    final Object? author = normalized.remove('users');
    if (author is Map<String, dynamic>) {
      normalized['author_email'] = author['email'];
    }
    normalized['images'] = normalized.remove('comment_images') ?? <dynamic>[];
    return normalized;
  }
}
