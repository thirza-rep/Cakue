import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../di/providers.dart';
import '../../../domain/entities/account_model.dart';
import '../../shared/widgets/amount_text.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsProvider);
    final totalAsync = ref.watch(totalBalanceProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Rekening'),
            actions: [
              IconButton(
                onPressed: () => _showAddAccount(context, ref),
                icon: const Icon(Icons.add_circle_outline_rounded),
                tooltip: 'Tambah Rekening',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                children: [
                  // Total balance
                  totalAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (total) => Container(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      decoration: BoxDecoration(
                        gradient: AppColors.coralGradient,
                        borderRadius:
                            BorderRadius.circular(AppRadius.xxl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coral.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total Semua Rekening',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          AmountText(
                            amount: total,
                            currency: 'IDR',
                            style: AppTextStyles.displaySmall
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Account list
                  accountsAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Error: $e')),
                    data: (accounts) {
                      if (accounts.isEmpty) {
                        return _EmptyAccounts(
                          onAdd: () => _showAddAccount(context, ref),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Daftar Rekening',
                                style: AppTextStyles.h6,
                              ),
                              TextButton.icon(
                                onPressed: () => _showAddAccount(context, ref),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Tambah'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ...accounts.asMap().entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md),
                              child: _AccountCard(
                                account: e.value,
                                onTap: () => _showEditAccount(context, ref, e.value),
                              )
                                  .animate()
                                  .fadeIn(
                                      delay: Duration(
                                          milliseconds: e.key * 80)),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ],
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

  void _showAddAccount(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddAccountSheet(ref: ref),
    );
  }

  void _showEditAccount(BuildContext context, WidgetRef ref, AccountModel account) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditAccountSheet(ref: ref, account: account),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback onTap;

  const _AccountCard({required this.account, required this.onTap});

  String get _accountEmoji {
    switch (account.type.toLowerCase()) {
      case 'bank': return '🏦';
      case 'e-wallet': return '📱';
      case 'cash': return '💵';
      case 'investment': return '📈';
      case 'credit': return '💳';
      default: return '👛';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Center(
                  child: Text(_accountEmoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name, style: AppTextStyles.h6.copyWith(color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 2),
                    Text(
                      account.type.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              AmountText(
                amount: account.currentBalance,
                currency: account.currencyCode,
                style: AppTextStyles.amountSmall.copyWith(
                  color: account.currentBalance >= 0
                      ? theme.colorScheme.onSurface
                      : AppColors.expense,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAccounts extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyAccounts({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text('🏦', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        const Text('Belum ada rekening', style: AppTextStyles.h5),
        const SizedBox(height: 8),
        Text(
          'Tambahkan rekening bank, dompet tunai,\natau e-wallet kamu',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah Rekening Pertama'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coral,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── ADD ACCOUNT BOTTOM SHEET ─────────────────────────────────────────

class _AddAccountSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddAccountSheet({required this.ref});

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  String _selectedType = 'bank';
  final List<Map<String, String>> _types = [
    {'key': 'bank', 'label': 'Bank 🏦'},
    {'key': 'e-wallet', 'label': 'E-Wallet 📱'},
    {'key': 'cash', 'label': 'Tunai 💵'},
    {'key': 'investment', 'label': 'Investasi 📈'},
    {'key': 'credit', 'label': 'Kartu Kredit 💳'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final rawBalance = _balanceController.text.replaceAll('.', '').replaceAll(',', '.').trim();
    final balance = double.tryParse(rawBalance) ?? 0.0;
    final userUuid = widget.ref.read(activeUserUuidProvider) ?? '';

    try {
      await widget.ref.read(accountApiProvider).insertAccount({
        'uuid': const Uuid().v4(),
        'user_uuid': userUuid,
        'name': name,
        'type': _selectedType,
        'currency_code': 'IDR',
        'initial_balance': balance,
        'current_balance': balance,
      });
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Rekening "$name" berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menambah rekening: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tambah Rekening Baru', style: AppTextStyles.h5),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Rekening',
                  hintText: 'Contoh: BCA Utama, GoPay, Dompet Saku',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Nama rekening harus diisi' : null,
              ),

              const SizedBox(height: 16),

              // Type Selector
              const Text('Tipe Rekening', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _types.map((type) {
                  final isSelected = _selectedType == type['key'];
                  return ChoiceChip(
                    label: Text(type['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedType = type['key']!);
                      }
                    },
                    selectedColor: AppColors.coralLight,
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Balance
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Saldo Awal (Rp)',
                  hintText: '0',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text('Simpan Rekening', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── EDIT ACCOUNT BOTTOM SHEET ────────────────────────────────────────

class _EditAccountSheet extends StatefulWidget {
  final WidgetRef ref;
  final AccountModel account;
  const _EditAccountSheet({required this.ref, required this.account});

  @override
  State<_EditAccountSheet> createState() => _EditAccountSheetState();
}

class _EditAccountSheetState extends State<_EditAccountSheet> {
  late TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    _balanceController = TextEditingController(
      text: widget.account.currentBalance.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _updateBalance() async {
    final rawBalance = _balanceController.text.replaceAll('.', '').replaceAll(',', '.').trim();
    final balance = double.tryParse(rawBalance);
    if (balance == null) return;

    try {
      await widget.ref
          .read(accountApiProvider)
          .updateBalance(widget.account.uuid, balance);
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Saldo berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal memperbarui saldo: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _delete() async {
    try {
      await widget.ref.read(accountApiProvider).softDelete(widget.account.uuid);
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ Rekening "${widget.account.name}" berhasil dihapus'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Gagal menghapus rekening: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Edit ${widget.account.name}', style: AppTextStyles.h5),
          const SizedBox(height: 20),
          TextFormField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Update Saldo (Rp)',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
                  label: const Text('Hapus', style: TextStyle(color: AppColors.expense)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.expense),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _updateBalance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Simpan Saldo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
