import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/widgets/amount_text.dart';
import '../../shared/widgets/transaction_tile.dart';
import '../../shared/widgets/section_header.dart';
import 'dashboard_viewmodel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vm = ref.watch(dashboardViewModelProvider);
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ─── APP BAR ───────────────────────────────────────
          SliverAppBar(
            floating: true,
            toolbarHeight: 76,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            titleSpacing: AppSpacing.pagePadding,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'Halo, ${vm.userName}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('👋', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.coral,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      monthLabel,
                      style: AppTextStyles.h5.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.pagePadding),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.goNamed('settings'),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.coral.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: AppColors.coral,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ─── BALANCE CARD ────────────────────────────
                  _BalanceCard(vm: vm)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: AppSpacing.xxl),

                  // ─── INCOME / EXPENSE SUMMARY ─────────────────
                  _SummaryRow(vm: vm)
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: AppSpacing.xxl),

                  // ─── QUICK ACTIONS ───────────────────────────
                  _QuickActions()
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // ─── RECENT TRANSACTIONS ─────────────────────
                  SectionHeader(
                    title: 'Transaksi Terakhir',
                    actionLabel: 'Lihat Semua',
                    onAction: () => context.goNamed('transactions'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),

          // Transaction list
          if (vm.recentTransactions.isEmpty)
            SliverToBoxAdapter(
              child: _EmptyTransactions().animate().fadeIn(delay: 300.ms),
            )
          else
            SliverList.builder(
              itemCount: vm.recentTransactions.length,
              itemBuilder: (context, i) {
                final tx = vm.recentTransactions[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                    vertical: 4,
                  ),
                  child: TransactionTile(transaction: tx)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 300 + i * 60))
                      .slideX(begin: 0.1, end: 0),
                );
              },
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.bottomNavBuffer + 20),
          ),
        ],
      ),
    );
  }
}

// ─── BALANCE CARD ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final DashboardState vm;
  const _BalanceCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.forestGradient,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDark.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Glow Circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Main Card Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding * 1.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Total Saldo Utama',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'IDR 🇮🇩',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AmountText(
                  amount: vm.totalBalance,
                  currency: 'IDR',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _BalanceStat(
                        label: 'Pemasukan',
                        amount: vm.monthIncome,
                        icon: Icons.arrow_upward_rounded,
                        color: const Color(0xFF4ADE80),
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      _BalanceStat(
                        label: 'Pengeluaran',
                        amount: vm.monthExpense,
                        icon: Icons.arrow_downward_rounded,
                        color: const Color(0xFFF87171),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.white60),
                ),
                AmountText(
                  amount: amount,
                  currency: 'IDR',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: Colors.white),
                  compact: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SUMMARY ROW ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final DashboardState vm;
  const _SummaryRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final savings = vm.monthIncome - vm.monthExpense;
    final savingsRate = vm.monthIncome > 0
        ? (savings / vm.monthIncome * 100).clamp(0.0, 100.0)
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _MiniCard(
            title: 'Tabungan Bulan Ini',
            amount: savings,
            color: savings >= 0 ? AppColors.income : AppColors.expense,
            bgColor: savings >= 0
                ? AppColors.lightByType('income', isDark: isDark)
                : AppColors.lightByType('expense', isDark: isDark),
            subtitle: '${savingsRate.toStringAsFixed(0)}% dari pemasukan',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MiniCard(
            title: 'Budget Tersisa',
            amount: vm.budgetRemaining,
            color: AppColors.blue,
            bgColor: AppColors.lightByType('transfer', isDark: isDark),
            subtitle: '${vm.activeBudgetCount} budget aktif',
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final Color bgColor;
  final String subtitle;

  const _MiniCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.bgColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          AmountText(
            amount: amount,
            currency: 'IDR',
            style: AppTextStyles.amountSmall.copyWith(color: color),
            compact: true,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── QUICK ACTIONS ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aksi Cepat', style: AppTextStyles.h6.copyWith(color: theme.colorScheme.onSurface)),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _QuickActionBtn(
              label: 'Pengeluaran',
              icon: Icons.remove_rounded,
              color: AppColors.expense,
              bgColor: AppColors.lightByType('expense', isDark: isDark),
              onTap: () => context.pushNamed('add-transaction',
                  queryParameters: {'type': 'expense'}),
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickActionBtn(
              label: 'Pemasukan',
              icon: Icons.add_rounded,
              color: AppColors.income,
              bgColor: AppColors.lightByType('income', isDark: isDark),
              onTap: () => context.pushNamed('add-transaction',
                  queryParameters: {'type': 'income'}),
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickActionBtn(
              label: 'Transfer',
              icon: Icons.swap_horiz_rounded,
              color: AppColors.blue,
              bgColor: AppColors.lightByType('transfer', isDark: isDark),
              onTap: () => context.pushNamed('add-transaction',
                  queryParameters: {'type': 'transfer'}),
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickActionBtn(
              label: 'Laporan',
              icon: Icons.bar_chart_rounded,
              color: AppColors.sage,
              bgColor: isDark ? const Color(0xFF233023) : AppColors.sageLight,
              onTap: () => context.goNamed('analytics'),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── EMPTY STATE ──────────────────────────────────────────────────────────────

class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💸', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Belum ada transaksi', style: AppTextStyles.h6.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Mulai catat keuangan kamu\ndengan tombol + di bawah',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
