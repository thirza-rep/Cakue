class UserProfileModel {
  final String uuid;
  final String name;
  final String? email;
  final String? avatarUrl;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  const UserProfileModel({
    required this.uuid,
    required this.name,
    this.email,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> j) => UserProfileModel(
        uuid: j['uuid'] as String,
        name: j['name'] as String,
        email: j['email'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        isActive: (j['is_active'] as dynamic) == 1 || j['is_active'] == true,
        createdAt: _toInt(j['created_at']),
        updatedAt: _toInt(j['updated_at']),
      );

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse('$v') ?? 0;
  }
}
