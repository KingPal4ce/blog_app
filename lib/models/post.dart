import 'package:json_annotation/json_annotation.dart';

import 'package:blog_app/models/post_image.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.authorEmail,
    required this.title,
    required this.body,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(_normalize(json));

  final int id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'author_email')
  final String? authorEmail;

  final String title;

  final List<dynamic> body;

  final List<PostImage> images;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$PostToJson(this);

  static Map<String, dynamic> _normalize(Map<String, dynamic> json) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(json);
    final Object? author = normalized.remove('users');
    if (author is Map<String, dynamic>) {
      normalized['author_email'] = author['email'];
    }
    normalized['images'] = normalized.remove('post_images') ?? <dynamic>[];
    return normalized;
  }
}
