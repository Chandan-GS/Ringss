class UserModel {
  final String id; // This MUST match the auth.users.id (UUID)
  final String username;
  final String displayName;
  final String email;
  final String? mobileNumber;
  final String? profilePicUrl;
  final String? bio;
  final DateTime createdAt; // Changed from Timestamp to DateTime
  final bool isPremium;
  final String? petType;
  final int? petLevel;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    this.mobileNumber,
    this.profilePicUrl,
    this.bio,
    required this.createdAt,
    this.isPremium = false,
    this.petType,
    this.petLevel,
  });

  // Factory to create a UserModel from a Supabase row (Map)
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'], // Assumes 'id' is in the map
      username: data['username'] ?? '',
      displayName: data['display_name'] ?? '',
      email: data['email'] ?? '',
      mobileNumber: data['mobile_number'],
      profilePicUrl: data['profile_pic_url'],
      bio: data['bio'],
      createdAt: DateTime.parse(
        data['created_at'],
      ), // Supabase timestamps are Strings
      isPremium: data['is_premium'] ?? false,
      petType: data['pet_type'],
      petLevel: data['pet_level'],
    );
  }

  // Method to convert a UserModel to a Map for Supabase
  // Note: We use snake_case for column names
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Send the ID on creation to link to auth.users
      'username': username,
      'display_name': displayName,
      'email': email,
      'mobile_number': mobileNumber,
      'profile_pic_url': profilePicUrl,
      'bio': bio,
      // 'created_at' is handled by Postgres with `now()`
      'is_premium': isPremium,
      'pet_type': petType,
      'pet_level': petLevel,
    };
  }
}
