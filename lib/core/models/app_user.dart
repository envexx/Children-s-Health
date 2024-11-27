// lib/core/models/app_user.dart

import '../enums/user_role.dart';

class AppUser {
  final String uid;
  final String email;
  final UserRole role;
  final String? name;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.fromString(json['role'] ?? ''),
      name: json['name'],
    );
  }
}
