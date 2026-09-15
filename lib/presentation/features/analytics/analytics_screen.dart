import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../di/providers.dart';
import '../../shared/widgets/amount_text.dart';
import '../../shared/widgets/section_header.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMonthOffset = 0; // 0 = current month

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentYearMonth {
    final now = DateTime.now();
    final target =
        DateTime(now.year, now.month - _selectedMonthOffset);
    return '${target.year}-${target.month.toString().padLeft(2, '0')}';
  }

  String get _monthLabel {
    final now = DateTime.now();
    final target =
        DateTime(now.year, now.month - _selectedMonthOffset);
    return DateFormat('MMMM yyyy', 'id_ID').format(target);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthTotals = ref.watch(monthTotalsProvider(_currentYearMonth));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Analitik'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Ringkasan'),
                  Tab(text: 'Tren'),
                ],
                indicatorColor: AppColors.coral,
                labelColor: AppColors.coral,
                unselectedLabelColor: AppColors.textSecondary,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                children: [
                  // Month selector
                  _MonthSelector(
                    label: _monthLabel,
                    onPrev: () =>
                        setState(() => _selectedMonthOffset++),
                    onNext: _selectedMonthOffset > 0
                        ? () => setState(() => _selectedMonthOffset--)
                        : null,
                  ).animate().fadeIn(),

                  const SizedBox(height: AppSpacing.xl),

                  // Income/Expense cards
                  monthTotals.when(
                    loading: () => const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Error: $e'),
                    data: (totals) => _SummaryCards(
                      income: totals['income'] ?? 0,
                      expense: totals['expense'] ?? 0,
                    ).animate().fadeIn(delay: 100.ms),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Pie chart placeholder
                  const SectionHeader(title: 'Pengeluaran per Kategori'),
                  const SizedBox(height: AppSpacing.lg),
                  _CategoryPieChart().animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: AppSpacing.bottomNavBuffer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  const _MonthSelector({
    required this.label,
    required this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded),
            color: theme.colorScheme.onSurfaceVariant,
          ),
          Text(label, style: AppTextStyles.h6.copyWith(color: theme.colorScheme.onSurface)),
          IconButton(
            onPressed: onNext,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: onNext != null
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final double income;
  final double expense;

  const _SummaryCards({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final savings = income - expense;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Pemasukan',
                amount: income,
                gradient: AppColors.incomeGradient,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                title: 'Total Pengeluaran',
                amount: expense,
                gradient: AppColors.expenseGradient,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _StatCard(
          title: savings >= 0 ? 'Tabungan Bulan Ini' : 'Defisit Bulan Ini',
          amount: savings.abs(),
          gradient: savings >= 0
              ? AppColors.forestGradient
              : AppColors.expenseGradient,
          icon: savings >= 0
              ? Icons.savings_rounded
              : Icons.warning_amber_rounded,
          wide: true,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final LinearGradient gradient;
  final IconData icon;
  final bool wide;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.gradient,
    required this.icon,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                AmountText(
                  amount: amount,
                  currency: 'IDR',
                  style: AppTextStyles.amountSmall
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

class _CategoryPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder data - akan diisi dari monthly_summaries
    final data = [
      const _PieData('Makanan', 45, AppColors.coral),
      const _PieData('Transport', 20, AppColors.blue),
      const _PieData('Belanja', 15, AppColors.sage),
      const _PieData('Hiburan', 12, AppColors.sageDark),
      _PieData('Lainnya', 8, theme.colorScheme.onSurfaceVariant),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: data.map((d) {
                  return PieChartSectionData(
                    value: d.percentage,
                    color: d.color,
                    title: '${d.percentage.toInt()}%',
                    radius: 80,
                    titleStyle: AppTextStyles.labelSmall
                        .copyWith(color: Colors.white),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: data.map((d) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: d.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(d.label,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PieData {
  final String label;
  final double percentage;
  final Color color;
  const _PieData(this.label, this.percentage, this.color);
}
