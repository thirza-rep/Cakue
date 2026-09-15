class CategoryModel {
  final String uuid;
  final String? parentUuid;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final bool isSystem;
  final int createdAt;
  final int updatedAt;

  const CategoryModel({
    required this.uuid,
    this.parentUuid,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.isSystem = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
        uuid: j['uuid'] as String,
        parentUuid: j['parent_uuid'] as String?,
        name: j['name'] as String,
        type: j['type'] as String? ?? 'expense',
        icon: j['icon'] as String?,
        color: j['color'] as String?,
        isSystem: (j['is_system'] as dynamic) == 1 || j['is_system'] == true,
        createdAt: _toInt(j['created_at']),
        updatedAt: _toInt(j['updated_at']),
      );

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse('$v') ?? 0;
  }
}
