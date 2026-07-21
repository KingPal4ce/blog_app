import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorEmail,
    required this.body,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(_flattenAuthor(json));

  final int id;

  @JsonKey(name: 'post_id')
  final int postId;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'author_email')
  final String? authorEmail;

  final String body;

  @JsonKey(name: 'image_path')
  final String? imagePath;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  static Map<String, dynamic> _flattenAuthor(Map<String, dynamic> json) {
    final Map<String, dynamic> flattened = Map<String, dynamic>.from(json);
    final Object? author = flattened.remove('users');
    if (author is Map<String, dynamic>) {
      flattened['author_email'] = author['email'];
    }
    return flattened;
  }
}
