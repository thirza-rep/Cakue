/// Plain Dart model menggantikan Drift-generated Account class
class AccountModel {
  final String uuid;
  final String? userUuid;
  final String name;
  final String type;
  final String currencyCode;
  final double initialBalance;
  final double currentBalance;
  final String? color;
  final String? icon;
  final bool isActive;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String syncStatus;

  const AccountModel({
    required this.uuid,
    this.userUuid,
    required this.name,
    required this.type,
    required this.currencyCode,
    required this.initialBalance,
    required this.currentBalance,
    this.color,
    this.icon,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = 'pending',
  });

  factory AccountModel.fromJson(Map<String, dynamic> j) => AccountModel(
        uuid: j['uuid'] as String,
        userUuid: j['user_uuid'] as String?,
        name: j['name'] as String,
        type: j['type'] as String? ?? 'bank',
        currencyCode: j['currency_code'] as String? ?? 'IDR',
        initialBalance: _toDouble(j['initial_balance']),
        currentBalance: _toDouble(j['current_balance']),
        color: j['color'] as String?,
        icon: j['icon'] as String?,
        isActive: (j['is_active'] as dynamic) == 1 || j['is_active'] == true,
        createdAt: _toInt(j['created_at']),
        updatedAt: _toInt(j['updated_at']),
        deletedAt: j['deleted_at'] != null ? _toInt(j['deleted_at']) : null,
        syncStatus: j['sync_status'] as String? ?? 'pending',
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'user_uuid': userUuid,
        'name': name,
        'type': type,
        'currency_code': currencyCode,
        'initial_balance': initialBalance,
        'current_balance': currentBalance,
        'color': color,
        'icon': icon,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'sync_status': syncStatus,
      };

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse('$v') ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse('$v') ?? 0;
  }
}
