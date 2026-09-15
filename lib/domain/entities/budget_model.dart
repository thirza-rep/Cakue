class BudgetModel {
  final String uuid;
  final String userUuid;
  final String? categoryUuid;
  final double amount;
  final String periodType;
  final int createdAt;
  final int updatedAt;

  const BudgetModel({
    required this.uuid,
    required this.userUuid,
    this.categoryUuid,
    required this.amount,
    required this.periodType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> j) => BudgetModel(
        uuid: j['uuid'] as String,
        userUuid: j['user_uuid'] as String,
        categoryUuid: j['category_uuid'] as String?,
        amount: _toDouble(j['amount']),
        periodType: j['period_type'] as String? ?? 'monthly',
        createdAt: _toInt(j['created_at']),
        updatedAt: _toInt(j['updated_at']),
      );

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
