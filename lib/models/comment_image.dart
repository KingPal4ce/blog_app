import 'package:json_annotation/json_annotation.dart';

part 'comment_image.g.dart';

@JsonSerializable()
class CommentImage {
  const CommentImage({
    required this.id,
    required this.commentId,
    required this.imagePath,
    required this.sortOrder,
    required this.createdAt,
  });

  factory CommentImage.fromJson(Map<String, dynamic> json) => _$CommentImageFromJson(json);

  final int id;

  @JsonKey(name: 'comment_id')
  final int commentId;

  @JsonKey(name: 'image_path')
  final String imagePath;

  @JsonKey(name: 'sort_order')
  final int sortOrder;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$CommentImageToJson(this);
}
