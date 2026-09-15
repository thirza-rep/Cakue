import 'dart:async';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/biometric_auth_service.dart';
import '../data/remote/api_client.dart';
import '../data/remote/repositories/transaction_repository_mysql.dart';
import '../domain/entities/transaction_entity.dart';
import '../domain/entities/account_model.dart';
import '../domain/entities/category_model.dart';
import '../domain/entities/budget_model.dart';
import '../domain/entities/user_profile_model.dart';
import '../domain/usecases/transactions/add_transaction_usecase.dart';

// ─── API CLIENT ────────────────────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// ─── TRANSACTION REPOSITORY ───────────────────────────────────────────────────

final transactionRepositoryProvider = Provider<TransactionRepositoryMysql>((ref) {
  return TransactionRepositoryMysql(ref.watch(apiClientProvider));
});

final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  return AddTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

// ─── ACTIVE USER ──────────────────────────────────────────────────────────────

final activeUserProvider = FutureProvider<UserProfileModel?>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final data = await api.get('/users/active');
    if (data == null) return null;
    return UserProfileModel.fromJson(data as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});

final activeUserUuidProvider = Provider<String?>((ref) {
  return ref.watch(activeUserProvider).value?.uuid;
});

// ─── ACCOUNTS ─────────────────────────────────────────────────────────────────

/// Polling-based stream for accounts (refreshes after mutations)
final accountsProvider = StreamProvider<List<AccountModel>>((ref) {
  final api = ref.watch(apiClientProvider);
  final controller = StreamController<List<AccountModel>>.broadcast();

  Future<void> fetch() async {
    try {
      final data = await api.get('/accounts');
      final accounts = (data as List)
          .map((j) => AccountModel.fromJson(j as Map<String, dynamic>))
          .toList();
      if (!controller.isClosed) controller.add(accounts);
    } catch (e) {
      if (!controller.isClosed) controller.addError(e);
    }
  }

  // Initial fetch
  fetch();

  // Listen to mutation events to refresh
  final sub = TransactionRepositoryMysql.invalidateStream.listen((_) => fetch());

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});

final totalBalanceProvider = StreamProvider<double>((ref) async* {
  final accounts = ref.watch(accountsProvider).value ?? [];
  yield accounts.fold(0.0, (sum, acc) => sum + acc.currentBalance);
});

// ─── ACCOUNT ACTIONS ──────────────────────────────────────────────────────────

final accountApiProvider = Provider<AccountApi>((ref) {
  return AccountApi(ref.watch(apiClientProvider));
});

class AccountApi {
  final ApiClient _api;
  AccountApi(this._api);

  Future<void> insertAccount(Map<String, dynamic> data) async {
    await _api.post('/accounts', data);
    TransactionRepositoryMysql.invalidate();
  }

  Future<void> updateBalance(String uuid, double balance) async {
    await _api.put('/accounts/$uuid/balance', {'balance': balance});
    TransactionRepositoryMysql.invalidate();
  }

  Future<void> softDelete(String uuid) async {
    await _api.delete('/accounts/$uuid');
    TransactionRepositoryMysql.invalidate();
  }
}

// ─── RECENT TRANSACTIONS ──────────────────────────────────────────────────────

final recentTransactionsProvider = StreamProvider<List<TransactionEntity>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final userUuid = ref.watch(activeUserUuidProvider) ?? '';
  return repo.watchRecentTransactions(userUuid: userUuid);
});

final monthTotalsProvider = StreamProvider.family<Map<String, double>, String>((ref, yearMonth) {
  final repo = ref.watch(transactionRepositoryProvider);
  final userUuid = ref.watch(activeUserUuidProvider) ?? '';
  return repo.watchMonthTotals(userUuid: userUuid, yearMonth: yearMonth);
});

// ─── CATEGORIES ───────────────────────────────────────────────────────────────

final categoriesProvider = FutureProvider.family<List<CategoryModel>, String?>((ref, type) async {
  final api = ref.watch(apiClientProvider);
  final params = <String, String>{};
  if (type != null) params['type'] = type;
  final data = await api.get('/categories', queryParams: params.isNotEmpty ? params : null);
  return (data as List).map((j) => CategoryModel.fromJson(j as Map<String, dynamic>)).toList();
});

// ─── BUDGETS ─────────────────────────────────────────────────────────────────

final budgetsProvider = FutureProvider<List<BudgetModel>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final userUuid = ref.watch(activeUserUuidProvider) ?? '';
  final data = await api.get('/budgets', queryParams: {'userUuid': userUuid});
  return (data as List).map((j) => BudgetModel.fromJson(j as Map<String, dynamic>)).toList();
});

final budgetApiProvider = Provider<BudgetApi>((ref) => BudgetApi(ref.watch(apiClientProvider)));

class BudgetApi {
  final ApiClient _api;
  BudgetApi(this._api);

  Future<void> upsert(Map<String, dynamic> data) => _api.post('/budgets', data);
  Future<void> delete(String uuid) => _api.delete('/budgets/$uuid');
}

final budgetListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final budgets = await ref.watch(budgetsProvider.future);
  final repo = ref.watch(transactionRepositoryProvider);
  final userUuid = ref.watch(activeUserUuidProvider) ?? '';
  final now = DateTime.now();
  final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

  final result = <Map<String, dynamic>>[];
  for (final b in budgets) {
    final totals = await repo.getMonthTotals(userUuid: userUuid, yearMonth: yearMonth);
    result.add({
      'uuid': b.uuid,
      'category_name': b.categoryUuid ?? 'Semua Pengeluaran',
      'amount': b.amount,
      'spent': totals['expense'] ?? 0.0,
      'period': b.periodType,
    });
  }
  return result;
});

/// Transaksi bulan ini untuk export Excel
final currentMonthTransactionsProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final userUuid = ref.watch(activeUserUuidProvider) ?? '';
  final now = DateTime.now();
  return repo.getTransactionsByDateRange(
    userUuid: userUuid,
    start: DateTime(now.year, now.month, 1),
    end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
  );
});

// ─── USER ACTIONS ─────────────────────────────────────────────────────────────

final userApiProvider = Provider<UserApi>((ref) => UserApi(ref.watch(apiClientProvider)));

class UserApi {
  final ApiClient _api;
  UserApi(this._api);

  Future<String> createUser(Map<String, dynamic> data) async {
    final result = await _api.post('/users', data);
    return result['uuid'] as String;
  }

  Future<void> activateUser(String uuid) => _api.put('/users/$uuid/activate', {});
}

// ─── AUTHENTICATION / LOCK ────────────────────────────────────────────────────

final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  return BiometricAuthService.isBiometricEnabled();
});

class AppUnlockedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void unlock() => state = true;
  void lock() => state = false;
}

final appUnlockedProvider =
    NotifierProvider<AppUnlockedNotifier, bool>(AppUnlockedNotifier.new);

// ─── THEME ────────────────────────────────────────────────────────────────────

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  @override
  set state(ThemeMode value) => super.state = value;
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
