import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_entity.freezed.dart';

@freezed
abstract class AccountEntity with _$AccountEntity {
  const factory AccountEntity({
    required String uuid,
    required String name,
    required AccountType type,
    required String currencyCode,
    required double initialBalance,
    required double currentBalance,
    String? color,
    String? icon,
    @Default(true) bool isActive,
    @Default(0) int sortOrder,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    @Default('pending') String syncStatus,
  }) = _AccountEntity;

  const AccountEntity._();

  double get balance => currentBalance;

  bool get isCredit => type == AccountType.credit;
}

enum AccountType {
  bank,
  cash,
  eWallet,
  investment,
  credit;

  String get label {
    switch (this) {
      case AccountType.bank: return 'Rekening Bank';
      case AccountType.cash: return 'Uang Tunai';
      case AccountType.eWallet: return 'Dompet Digital';
      case AccountType.investment: return 'Investasi';
      case AccountType.credit: return 'Kartu Kredit';
    }
  }

  String get value {
    switch (this) {
      case AccountType.bank: return 'bank';
      case AccountType.cash: return 'cash';
      case AccountType.eWallet: return 'e-wallet';
      case AccountType.investment: return 'investment';
      case AccountType.credit: return 'credit';
    }
  }

  String get icon {
    switch (this) {
      case AccountType.bank: return '🏦';
      case AccountType.cash: return '💵';
      case AccountType.eWallet: return '📱';
      case AccountType.investment: return '📈';
      case AccountType.credit: return '💳';
    }
  }

  static AccountType fromString(String s) {
    switch (s) {
      case 'bank': return AccountType.bank;
      case 'cash': return AccountType.cash;
      case 'e-wallet': return AccountType.eWallet;
      case 'investment': return AccountType.investment;
      case 'credit': return AccountType.credit;
      default: return AccountType.cash;
    }
  }
}
