import 'package:project_a_b/data/models/user_model.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type; // 'ping_request', 'ping_accepted'
  final String? relatedPingId;
  bool isRead;
  final DateTime createdAt;

  // Joined Data
  final UserModel actor; // The user who caused the notification

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.relatedPingId,
    required this.isRead,
    required this.createdAt,
    required this.actor,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['id'],
      userId: data['user_id'],
      type: data['type'],
      relatedPingId: data['related_ping_id'],
      isRead: data['is_read'],
      createdAt: DateTime.parse(data['created_at']),
      actor: UserModel.fromMap(data['actor']),
    );
  }
}
