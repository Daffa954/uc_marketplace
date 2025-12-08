part of 'model.dart';
// --- 1. USER MODEL ---
class UserModel {
  final int? userId;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? token;
  final bool isVerified;
  final DateTime? createdAt;

  UserModel({
    this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.role = UserRole.USER,
    this.token,
    this.isVerified = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: enumFromString(UserRole.values, json['role']),
      token: json['token'],
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'role': role.toString().split('.').last, // Kirim string ke Supabase
    'token': token,
    'is_verified': isVerified,
  };
}