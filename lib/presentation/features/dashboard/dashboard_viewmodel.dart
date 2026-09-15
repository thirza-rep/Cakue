import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../di/providers.dart';

class DashboardState {
  final String userName;
  final double totalBalance;
  final double monthIncome;
  final double monthExpense;
  final double budgetRemaining;
  final int activeBudgetCount;
  final List<TransactionEntity> recentTransactions;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.userName = 'Pengguna',
    this.totalBalance = 0,
    this.monthIncome = 0,
    this.monthExpense = 0,
    this.budgetRemaining = 0,
    this.activeBudgetCount = 0,
    this.recentTransactions = const [],
    this.isLoading = true,
    this.error,
  });

  DashboardState copyWith({
    String? userName,
    double? totalBalance,
    double? monthIncome,
    double? monthExpense,
    double? budgetRemaining,
    int? activeBudgetCount,
    List<TransactionEntity>? recentTransactions,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      userName: userName ?? this.userName,
      totalBalance: totalBalance ?? this.totalBalance,
      monthIncome: monthIncome ?? this.monthIncome,
      monthExpense: monthExpense ?? this.monthExpense,
      budgetRemaining: budgetRemaining ?? this.budgetRemaining,
      activeBudgetCount: activeBudgetCount ?? this.activeBudgetCount,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier untuk dashboard — mengagregasi data dari beberapa stream secara reaktif
class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    final userAsync = ref.watch(activeUserProvider);
    final balanceAsync = ref.watch(totalBalanceProvider);
    final recentTxsAsync = ref.watch(recentTransactionsProvider);
    
    final now = DateTime.now();
    final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final totalsAsync = ref.watch(monthTotalsProvider(yearMonth));

    // Watch budgets for statistics
    final budgetsAsync = ref.watch(budgetsProvider);
    final budgetListAsync = ref.watch(budgetListProvider);

    final userName = userAsync.value?.name ?? 'Pengguna';
    final totalBalance = balanceAsync.value ?? 0.0;
    final recentTransactions = recentTxsAsync.value ?? const [];
    
    final totals = totalsAsync.value ?? const {};
    final monthIncome = totals['income'] ?? 0.0;
    final monthExpense = totals['expense'] ?? 0.0;

    // Calculate budget statistics
    final budgets = budgetsAsync.value ?? const [];
    final budgetList = budgetListAsync.value ?? const [];
    
    final activeBudgetCount = budgets.length;
    double budgetRemaining = 0.0;
    for (final b in budgetList) {
      final amount = b['amount'] as double? ?? 0.0;
      final spent = b['spent'] as double? ?? 0.0;
      budgetRemaining += (amount - spent).clamp(0.0, double.infinity);
    }

    final isLoading = userAsync.isLoading ||
        balanceAsync.isLoading ||
        recentTxsAsync.isLoading ||
        totalsAsync.isLoading ||
        budgetsAsync.isLoading ||
        budgetListAsync.isLoading;

    final error = userAsync.hasError
        ? userAsync.error.toString()
        : balanceAsync.hasError
            ? balanceAsync.error.toString()
            : recentTxsAsync.hasError
                ? recentTxsAsync.error.toString()
                : totalsAsync.hasError
                    ? totalsAsync.error.toString()
                    : budgetsAsync.hasError
                        ? budgetsAsync.error.toString()
                        : budgetListAsync.hasError
                            ? budgetListAsync.error.toString()
                            : null;

    return DashboardState(
      userName: userName,
      totalBalance: totalBalance,
      monthIncome: monthIncome,
      monthExpense: monthExpense,
      budgetRemaining: budgetRemaining,
      activeBudgetCount: activeBudgetCount,
      recentTransactions: recentTransactions,
      isLoading: isLoading,
      error: error,
    );
  }
}

/// Provider untuk DashboardNotifier
final dashboardViewModelProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});
