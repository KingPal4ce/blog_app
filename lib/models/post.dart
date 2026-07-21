import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.authorEmail,
    required this.title,
    required this.body,
    required this.coverImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(_flattenAuthor(json));

  final int id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'author_email')
  final String? authorEmail;

  final String title;

  final List<dynamic> body;

  @JsonKey(name: 'cover_image_path')
  final String? coverImagePath;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$PostToJson(this);

  static Map<String, dynamic> _flattenAuthor(Map<String, dynamic> json) {
    final Map<String, dynamic> flattened = Map<String, dynamic>.from(json);
    final Object? author = flattened.remove('users');
    if (author is Map<String, dynamic>) {
      flattened['author_email'] = author['email'];
    }
    return flattened;
  }
}
