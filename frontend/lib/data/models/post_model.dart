class PostModel {
  final String postId;
  final String content;  final String? imageUrl;
  final int likesCount;
  final String createdAt;
  final String authorName;
  final String? authorId;
  bool isLiked;

  PostModel({
    required this.postId,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.createdAt,
    required this.authorName,
    this.authorId,
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        postId:     json['postId']     as String,
        content:    json['content']    as String,
        imageUrl:   json['imageUrl']   as String?,
        likesCount: (json['likesCount'] as num).toInt(),
        createdAt:  json['createdAt']  as String,
        authorName: json['authorName'] as String,
        authorId:   json['authorId']   as String?,
        isLiked:    json['isLiked']    as bool? ?? false,
      );

  PostModel copyWith({int? likesCount, bool? isLiked}) => PostModel(
        postId:     postId,
        content:    content,
        imageUrl:   imageUrl,
        likesCount: likesCount ?? this.likesCount,
        createdAt:  createdAt,
        authorName: authorName,
        authorId:   authorId,
        isLiked:    isLiked ?? this.isLiked,
      );
}
