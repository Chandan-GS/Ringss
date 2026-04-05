import 'package:flutter/material.dart' show Color, Colors;
import 'package:get/get.dart';
import 'package:project_a_b/data/models/user_model.dart';

class UserRingModel {
  final String id; // The ring's unique ID (UUID)
  final String ownerId; // Foreign key to profiles.id
  String ringName; // This is mutable
  final String ringType; // 'inner', 'middle', 'outer'

  // --- UI-ONLY PROPERTIES (Derived) ---
  final Color color;
  final double size;
  final double thickness;

  // --- UI-ONLY DATA (Fetched by Controller) ---
  final RxList<UserModel> members = <UserModel>[].obs;

  // Getter for member count
  int get memberCount => members.length;

  UserRingModel({
    required this.id,
    required this.ownerId,
    required this.ringName,
    required this.ringType,
    required this.color,
    required this.size,
    required this.thickness,
  });

  // Factory to create a UserRingModel from a Supabase row (Map)
  factory UserRingModel.fromMap(Map<String, dynamic> data) {
    final String type = data['ring_type'] ?? 'inner';

    // Derive UI properties from ringType
    Color color;
    double size;
    double thickness;

    switch (type) {
      case 'inner':
        color = const Color.fromARGB(255, 255, 200, 200);
        size = 300;
        thickness = 100;
        break;
      case 'middle':
        color = const Color.fromARGB(255, 255, 160, 160);
        size = 500;
        thickness = 100;
        break;
      case 'outer':
        color = const Color.fromARGB(255, 255, 110, 110);
        size = 700;
        thickness = 100;
        break;
      default:
        color = Colors.grey;
        size = 300;
        thickness = 100;
    }

    return UserRingModel(
      id: data['id'],
      ownerId: data['owner_id'],
      ringName: data['ring_name'] ?? '',
      ringType: type,
      color: color,
      size: size,
      thickness: thickness,
    );
  }
}
