import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/usecases/transactions/add_transaction_usecase.dart';
import '../../../di/providers.dart';
import '../../shared/widgets/category_picker_sheet.dart';
import '../../shared/widgets/account_picker_sheet.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? initialType;
  final String? transactionUuid;

  const AddTransactionScreen({
    super.key,
    this.initialType,
    this.transactionUuid,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with TickerProviderStateMixin {
  late TabController _typeController;

  TransactionType get _selectedType {
    switch (_typeController.index) {
      case 0:
        return TransactionType.income;
      case 2:
        return TransactionType.transfer;
      case 1:
      default:
        return TransactionType.expense;
    }
  }

  String _amountStr = '';
  String? _selectedAccountUuid;
  String? _toAccountUuid;
  String? _selectedCategoryUuid;
  String? _categoryName;
  String? _categoryIcon;
  String? _accountName;
  String? _toAccountName;
  DateTime _selectedDate = DateTime.now();
  final _noteController = TextEditingController();
  final _merchantController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _typeController = TabController(length: 3, vsync: this);
    if (widget.initialType != null) {
      final initType = TransactionType.fromString(widget.initialType!);
      _typeController.index = initType == TransactionType.income
          ? 0
          : initType == TransactionType.expense
              ? 1
              : 2;
    } else {
      _typeController.index = 1; // default expense
    }
    _typeController.addListener(() {
      setState(() {
        _selectedCategoryUuid = null;
        _categoryName = null;
        _categoryIcon = null;
      });
    });
  }

  @override
  void dispose() {
    _typeController.dispose();
    _noteController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  Color get _typeColor {
    switch (_selectedType) {
      case TransactionType.income: return AppColors.income;
      case TransactionType.expense: return AppColors.expense;
      case TransactionType.transfer: return AppColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // ─── HEADER ──────────────────────────────────────
          _buildHeader(context),

          // ─── AMOUNT INPUT ────────────────────────────────
          _buildAmountSection(),

          // ─── FORM ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                children: [
                  _buildFormCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSaveButton(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _typeColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white24,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.transactionUuid != null
                        ? 'Edit Transaksi'
                        : 'Tambah Transaksi',
                    style: AppTextStyles.h5.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Type selector tabs
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: TabBar(
                controller: _typeController,
                tabs: const [
                  Tab(text: 'Pemasukan'),
                  Tab(text: 'Pengeluaran'),
                  Tab(text: 'Transfer'),
                ],
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: _typeColor,
                unselectedLabelColor: Colors.white70,
                labelStyle: AppTextStyles.labelMedium,
                dividerColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: _typeColor,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding, 0, AppSpacing.pagePadding, 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rp',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: GestureDetector(
                  onTap: _showNumPad,
                  child: Text(
                    _amountStr.isEmpty
                        ? '0'
                        : _formatAmount(_amountStr),
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ketuk untuk memasukkan nominal',
            style: AppTextStyles.caption.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Rekening
          _FormRow(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppColors.sage,
            label: 'Dari Rekening',
            value: _accountName ?? 'Pilih rekening',
            hasValue: _accountName != null,
            onTap: () => _showAccountPicker(isSource: true),
          ),

          if (_selectedType == TransactionType.transfer) ...[
            _Divider(),
            _FormRow(
              icon: Icons.arrow_forward_rounded,
              iconColor: AppColors.blue,
              label: 'Ke Rekening',
              value: _toAccountName ?? 'Pilih rekening tujuan',
              hasValue: _toAccountName != null,
              onTap: () => _showAccountPicker(isSource: false),
            ),
          ],

          if (_selectedType != TransactionType.transfer) ...[
            _Divider(),
            _FormRow(
              icon: Icons.category_rounded,
              iconColor: AppColors.coral,
              label: 'Kategori',
              value: _categoryName != null
                  ? '$_categoryIcon $_categoryName'
                  : 'Pilih kategori',
              hasValue: _categoryName != null,
              onTap: _showCategoryPicker,
            ),
          ],

          _Divider(),
          _FormRow(
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.blue,
            label: 'Tanggal',
            value: DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                .format(_selectedDate),
            hasValue: true,
            onTap: _pickDate,
          ),

          _Divider(),
          _FormRow(
            icon: Icons.store_rounded,
            iconColor: AppColors.sageDark,
            label: 'Nama Toko / Merchant',
            value: _merchantController.text.isEmpty
                ? 'Opsional'
                : _merchantController.text,
            hasValue: _merchantController.text.isNotEmpty,
            onTap: () {},
            trailing: TextField(
              controller: _merchantController,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'cth: Indomaret, Grab...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          _Divider(),
          _FormRow(
            icon: Icons.note_rounded,
            iconColor: AppColors.textSecondary,
            label: 'Catatan',
            value: _noteController.text.isEmpty ? 'Opsional' : _noteController.text,
            hasValue: _noteController.text.isNotEmpty,
            onTap: () {},
            trailing: TextField(
              controller: _noteController,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Tambahkan catatan...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final isValid = _amountStr.isNotEmpty &&
        double.tryParse(_amountStr.replaceAll('.', '')) != null &&
        _selectedAccountUuid != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isValid
              ? LinearGradient(colors: [_typeColor.withOpacity(0.85), _typeColor])
              : null,
          color: isValid ? null : AppColors.borderLight,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: isValid
              ? [
                  BoxShadow(
                    color: _typeColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isValid && !_isSaving ? _save : null,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Simpan Transaksi',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isValid ? Colors.white : AppColors.textTertiary,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── ACTIONS ─────────────────────────────────────────────────────────────

  void _showNumPad() {
    showModalBottomSheet(
      context: context,
      builder: (_) => _NumPad(
        initial: _amountStr,
        onConfirm: (val) => setState(() => _amountStr = val),
      ),
      isScrollControlled: true,
    );
  }

  void _showCategoryPicker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CategoryPickerSheet(
        type: _selectedType.value,
        onSelected: (uuid, name, icon) {
          setState(() {
            _selectedCategoryUuid = uuid;
            _categoryName = name;
            _categoryIcon = icon;
          });
        },
      ),
    );
  }

  void _showAccountPicker({required bool isSource}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AccountPickerSheet(
        excludeUuid: isSource ? null : _selectedAccountUuid,
        onSelected: (uuid, name) {
          setState(() {
            if (isSource) {
              _selectedAccountUuid = uuid;
              _accountName = name;
            } else {
              _toAccountUuid = uuid;
              _toAccountName = name;
            }
          });
        },
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountStr.replaceAll('.', ''));
    if (amount == null) return;

    setState(() => _isSaving = true);
    try {
      final useCase = ref.read(addTransactionUseCaseProvider);
      final userUuid = ref.read(activeUserUuidProvider) ?? '';

      await useCase.execute(AddTransactionParams(
        userUuid: userUuid,
        type: _selectedType,
        accountUuid: _selectedAccountUuid!,
        toAccountUuid: _toAccountUuid,
        categoryUuid: _selectedCategoryUuid,
        amount: amount,
        currencyCode: 'IDR',
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        merchant: _merchantController.text.trim().isEmpty
            ? null
            : _merchantController.text.trim(),
      ));

      if (mounted) {
        HapticFeedback.mediumImpact();
        context.pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  String _formatAmount(String raw) {
    final num = int.tryParse(raw.replaceAll('.', '')) ?? 0;
    return NumberFormat('#,###', 'id_ID').format(num).replaceAll(',', '.');
  }
}

// ─── FORM ROW WIDGET ──────────────────────────────────────────────────────────

class _FormRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool hasValue;
  final VoidCallback onTap;
  final Widget? trailing;

  const _FormRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: trailing == null ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  trailing ??
                      Text(
                        value,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: hasValue
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                ],
              ),
            ),
            if (trailing == null)
              Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 76,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

// ─── NUMPAD ───────────────────────────────────────────────────────────────────

class _NumPad extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onConfirm;

  const _NumPad({required this.initial, required this.onConfirm});

  @override
  State<_NumPad> createState() => _NumPadState();
}

class _NumPadState extends State<_NumPad> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  void _press(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == '⌫') {
        if (_value.isNotEmpty) _value = _value.substring(0, _value.length - 1);
      } else if (key == '000') {
        _value += '000';
      } else {
        if (_value.length < 12) _value += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = _value.isEmpty
        ? '0'
        : NumberFormat('#,###', 'id_ID')
            .format(int.tryParse(_value) ?? 0)
            .replaceAll(',', '.');

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Rp $display',
              style: AppTextStyles.displayMedium.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            childAspectRatio: 2.2,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: ['1','2','3','4','5','6','7','8','9','000','0','⌫']
                .map((k) => _NumKey(label: k, onTap: () => _press(k)))
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  widget.onConfirm(_value);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('Konfirmasi', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: label == '⌫'
              ? (isDark ? const Color(0xFF3D1F24) : AppColors.expenseLight)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.h5.copyWith(
              color: label == '⌫' ? AppColors.expense : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
