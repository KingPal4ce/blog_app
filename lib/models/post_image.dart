import 'package:json_annotation/json_annotation.dart';

part 'post_image.g.dart';

@JsonSerializable()
class PostImage {
  const PostImage({
    required this.id,
    required this.postId,
    required this.imagePath,
    required this.sortOrder,
    required this.createdAt,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) => _$PostImageFromJson(json);

  final int id;

  @JsonKey(name: 'post_id')
  final int postId;

  @JsonKey(name: 'image_path')
  final String imagePath;

  @JsonKey(name: 'sort_order')
  final int sortOrder;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$PostImageToJson(this);
}
