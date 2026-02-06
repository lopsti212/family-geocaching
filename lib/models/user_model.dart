enum UserRole { parent, child }

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? familyId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.familyId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] == 'parent' ? UserRole.parent : UserRole.child,
      familyId: json['family_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role == UserRole.parent ? 'parent' : 'child',
      'family_id': familyId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? familyId,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      familyId: familyId ?? this.familyId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
