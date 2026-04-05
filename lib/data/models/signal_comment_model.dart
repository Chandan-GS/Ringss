import 'package:get/get.dart';
import 'package:project_a_b/data/models/user_model.dart';

class SignalCommentModel {
  final String id;
  final String signalId;
  final String ownerId;
  final String? parentCommentId;
  final String commentType;
  final String? content;
  final DateTime createdAt;
  final String? mediaUrl;
  final bool isFromPet; // <-- ADD THIS

  // --- Joined Author Data ---
  final UserModel author;

  // --- Dynamic State ---
  final RxInt likeCount;
  final RxBool iHaveLiked;
  final RxList<SignalCommentModel> replies;

  SignalCommentModel({
    required this.id,
    required this.signalId,
    required this.ownerId,
    this.parentCommentId,
    required this.commentType,
    this.content,
    required this.createdAt,
    this.mediaUrl,
    required this.isFromPet, // <-- ADD THIS
    required this.author,
    required int initialLikeCount,
    required bool initialIHaveLiked,
  }) : likeCount = initialLikeCount.obs,
       iHaveLiked = initialIHaveLiked.obs,
       replies = <SignalCommentModel>[].obs;

  factory SignalCommentModel.fromMap(
    Map<String, dynamic> data,
    String currentUserId,
  ) {
    final authorData = data['profiles'];
    final likesData = data['signal_comment_likes'] as List;
    final bool iHaveLiked = likesData.any(
      (like) => like['user_id'] == currentUserId,
    );

    return SignalCommentModel(
      id: data['id'],
      signalId: data['signal_id'],
      ownerId: data['owner_id'],
      parentCommentId: data['parent_comment_id'],
      commentType: data['comment_type'],
      content: data['content'],
      createdAt: DateTime.parse(data['created_at']),
      mediaUrl: data['media_url'],
      isFromPet: data['is_from_pet'] ?? false, // <-- ADD THIS
      author: authorData != null
          ? UserModel.fromMap(authorData)
          : UserModel.fromMap({
              'id': 'unknown',
              'username': 'unknown',
              'display_name': 'Unknown User',
              'email': '',
              'created_at': DateTime.now().toIso8601String(),
            }),
      initialLikeCount: data['like_count'] ?? 0,
      initialIHaveLiked: iHaveLiked,
    );
  }
}
