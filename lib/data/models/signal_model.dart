import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_a_b/data/models/user_model.dart';

// Enum for the signal type
enum SignalType { faint, steady, blazing }

class SignalModel {
  final String id;
  final String ownerId;
  final String ringType;
  final String? title;
  final String content;
  final DateTime createdAt;
  final String? imageUrl; // <-- ADD THIS

  // --- Joined Author Data ---
  final UserModel author; // The user who posted the signal

  // --- Dynamic UI State (Reactive) ---
  final RxInt score;
  final RxInt myVote; // -1 (dampen), 0 (no vote), 1 (amplify)
  final RxBool isSaved;
  final RxBool isResignaled;

  SignalModel({
    required this.id,
    required this.ownerId,
    required this.ringType,
    this.title,
    required this.content,
    required this.createdAt,
    this.imageUrl, // <-- ADD THIS
    required this.author,
    // Dynamic values
    required int initialScore,
    required int initialMyVote,
    required bool initialIsSaved,
    required bool initialIsResignaled,
  }) : score = initialScore.obs,
       myVote = initialMyVote.obs,
       isSaved = initialIsSaved.obs,
       isResignaled = initialIsResignaled.obs;

  // --- Computed (Reactive) Properties ---

  // Get the type (Faint, Steady, Blazing) based on the score
  SignalType get signalType {
    final s = score.value;
    if (s >= 70) return SignalType.blazing;
    if (s >= 40) return SignalType.steady;
    return SignalType.faint;
  }

  // Get the header color based on the type
  Color get headerColor {
    switch (signalType) {
      case SignalType.blazing:
        return const Color.fromARGB(255, 255, 110, 110);
      case SignalType.steady:
        return const Color.fromARGB(255, 255, 160, 160);
      case SignalType.faint:
      default:
        return const Color.fromARGB(255, 255, 200, 200);
    }
  }

  // Get the name for the signal type
  String get signalTypeName {
    switch (signalType) {
      case SignalType.blazing:
        return "Blazing";
      case SignalType.steady:
        return "Steady";
      case SignalType.faint:
      default:
        return "Faint";
    }
  }

  // Factory constructor from Supabase data
  factory SignalModel.fromMap(Map<String, dynamic> data, String currentUserId) {
    return SignalModel(
      id: data['id'],
      ownerId: data['owner_id'],
      ringType: data['ring_type'],
      title: data['title'],
      content: data['content'],
      createdAt: DateTime.parse(data['created_at']),
      imageUrl: data['image_url'], // <-- ADD THIS
      author: UserModel.fromMap(data['profiles']),

      // Dynamic data (will be fetched)
      initialScore: data['score'] ?? 0,
      initialMyVote: data['my_vote'] ?? 0,
      initialIsSaved: data['is_saved'] ?? false,
      initialIsResignaled: data['is_resignaled'] ?? false,
    );
  }
}
