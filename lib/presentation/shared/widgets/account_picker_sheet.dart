import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../di/providers.dart';
import 'amount_text.dart';

/// Bottom sheet untuk memilih rekening
class AccountPickerSheet extends ConsumerWidget {
  final String? excludeUuid;
  final void Function(String uuid, String name) onSelected;

  const AccountPickerSheet({
    super.key,
    this.excludeUuid,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text('Pilih Rekening', style: AppTextStyles.h5.copyWith(color: theme.colorScheme.onSurface)),
          ),
          accountsAsync.when(
            loading: () =>
                const SizedBox(height: 100,
                    child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error: $e'),
            ),
            data: (accounts) {
              final filtered = accounts
                  .where((a) => a.uuid != excludeUuid)
                  .toList();

              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Text(
                    'Tidak ada rekening tersedia.\nTambah rekening di menu Rekening.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.sm,
                ),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                itemBuilder: (context, i) {
                  final acc = filtered[i];
                  return ListTile(
                    onTap: () {
                      onSelected(acc.uuid, acc.name);
                      Navigator.pop(context);
                    },
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('🏦', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    title: Text(acc.name, style: AppTextStyles.labelLarge.copyWith(color: theme.colorScheme.onSurface)),
                    subtitle: Text(
                      acc.type,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: AmountText(
                      amount: acc.currentBalance,
                      currency: acc.currencyCode,
                      style: AppTextStyles.amountSmall.copyWith(color: theme.colorScheme.onSurface),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 4,
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
