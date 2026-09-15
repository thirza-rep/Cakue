import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../di/providers.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ─── APP BAR ───────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            title: Text('Anggaran', style: AppTextStyles.h5.copyWith(color: theme.colorScheme.onSurface)),
            actions: [
              Padding(
                padding:
                    const EdgeInsets.only(right: AppSpacing.pagePadding),
                child: FilledButton.icon(
                  onPressed: () => _showAddBudgetSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    textStyle: AppTextStyles.labelMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ─── TOTAL OVERVIEW ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.lg,
                AppSpacing.pagePadding,
                AppSpacing.lg,
              ),
              child: _BudgetOverviewCard(currency: _currency)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.1, end: 0),
            ),
          ),

          // ─── BUDGET LIST ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding),
            sliver: ref.watch(budgetListProvider).when(
                  data: (budgets) {
                    if (budgets.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _EmptyBudget(
                          onAdd: () => _showAddBudgetSheet(context),
                        ),
                      );
                    }
                    return SliverList.separated(
                      itemCount: budgets.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) => _BudgetCard(
                        budget: budgets[i],
                        currency: _currency,
                        onDelete: () => _deleteBudget(budgets[i]['uuid'] as String),
                      ).animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.05, end: 0),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xxxl),
                        child: CircularProgressIndicator(color: AppColors.coral),
                      ),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Text('Error: $e')),
                  ),
                ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.bottomNavBuffer),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddBudgetSheet(
        onSave: (categoryUuid, amount, period) async {
          final user = await ref.read(activeUserProvider.future);
          if (user == null) return;
          await ref.read(budgetApiProvider).upsert({
                'uuid': const Uuid().v4(),
                'user_uuid': user.uuid,
                'category_uuid': categoryUuid,
                'amount': amount,
                'period_type': period,
              });
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _deleteBudget(String uuid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Anggaran'),
        content: const Text('Apakah kamu yakin ingin menghapus anggaran ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(budgetApiProvider).delete(uuid);
    }
  }
}

// ─── OVERVIEW CARD ─────────────────────────────────────────────────────────

class _BudgetOverviewCard extends ConsumerWidget {
  final NumberFormat currency;
  const _BudgetOverviewCard({required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.coral, AppColors.coral.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.coral.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Anggaran Bulan Ini',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            currency.format(5000000),
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _OverviewStat(
                label: 'Terpakai',
                value: currency.format(2300000),
                color: Colors.white,
              ),
              const SizedBox(width: AppSpacing.xl),
              _OverviewStat(
                label: 'Sisa',
                value: currency.format(2700000),
                color: Colors.white,
              ),
            ],
          ),

        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _OverviewStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: color.withValues(alpha: 0.7))),
        Text(value,
            style: AppTextStyles.bodyMedium
                .copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ─── BUDGET CARD ───────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final Map<String, dynamic> budget;
  final NumberFormat currency;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.currency,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final amount = (budget['amount'] as num).toDouble();
    final spent = (budget['spent'] as num?)?.toDouble() ?? 0.0;
    final remaining = amount - spent;
    final progress = amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > amount;

    final progressColor = isOver
        ? Colors.red
        : progress > 0.8
            ? Colors.orange
            : AppColors.coral;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.category_rounded,
                    color: AppColors.coral, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget['category_name'] as String? ?? 'Semua Kategori',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                    ),
                    Text(
                      budget['period'] as String? ?? 'Bulanan',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded,
                    color: theme.colorScheme.onSurfaceVariant, size: 20),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currency.format(spent)} / ${currency.format(amount)}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              Text(
                isOver
                    ? 'Melebihi ${currency.format(spent - amount)}'
                    : 'Sisa ${currency.format(remaining)}',
                style: AppTextStyles.labelMedium.copyWith(color: progressColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.outlineVariant,
              color: progressColor,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── EMPTY STATE ───────────────────────────────────────────────────────────

class _EmptyBudget extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyBudget({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.coral, size: 36),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Belum ada anggaran',
                style: AppTextStyles.h6
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Buat anggaran untuk mengontrol\npengeluaran kamu setiap bulan',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buat Anggaran'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ADD BUDGET SHEET ──────────────────────────────────────────────────────

class _AddBudgetSheet extends StatefulWidget {
  final Future<void> Function(String? categoryUuid, double amount, String period)
      onSave;

  const _AddBudgetSheet({required this.onSave});

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _amountController = TextEditingController();
  String _selectedPeriod = 'monthly';
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl + bottomInset,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Tambah Anggaran', style: AppTextStyles.h5.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(height: AppSpacing.xxl),

          // Amount field
          Text('Nominal Anggaran',
              style: AppTextStyles.labelMedium
                  .copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: AppTextStyles.h5.copyWith(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.coral),
              hintText: '0',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide:
                    const BorderSide(color: AppColors.coral, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Period selector
          Text('Periode',
              style: AppTextStyles.labelMedium
                  .copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _PeriodChip(
                label: 'Bulanan',
                value: 'monthly',
                selected: _selectedPeriod == 'monthly',
                onTap: () => setState(() => _selectedPeriod = 'monthly'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PeriodChip(
                label: 'Mingguan',
                value: 'weekly',
                selected: _selectedPeriod == 'weekly',
                onTap: () => setState(() => _selectedPeriod = 'weekly'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PeriodChip(
                label: 'Tahunan',
                value: 'yearly',
                selected: _selectedPeriod == 'yearly',
                onTap: () => setState(() => _selectedPeriod = 'yearly'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Save button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Simpan Anggaran', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final text =
        _amountController.text.replaceAll('.', '').replaceAll(',', '');
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan nominal yang valid')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.onSave(null, amount, _selectedPeriod);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _PeriodChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.coral : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? AppColors.coral : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
