import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../di/providers.dart';
import '../../../data/services/excel_export_service.dart';
import '../../../core/services/biometric_auth_service.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(floating: true, title: Text('Pengaturan')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile section
                  _SettingsSection(
                    title: 'PROFIL',
                    children: [
                      _SettingsTile(
                        icon: Icons.person_rounded,
                        iconColor: AppColors.coral,
                        title: 'Kelola Pengguna / Onboarding',
                        subtitle: 'Lihat pengenalan aplikasi & profil',
                        onTap: () => context.goNamed('onboarding'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  _SettingsSection(
                    title: 'KEAMANAN & AKSES',
                    children: [
                      _SettingsTile(
                        icon: Icons.security_rounded,
                        iconColor: AppColors.sageDark,
                        title: 'Kunci Aplikasi',
                        subtitle: 'Gunakan Sidik Jari / PIN saat dibuka',
                        trailing: ref.watch(biometricEnabledProvider).when(
                              data: (isEnabled) => Switch(
                                value: isEnabled,
                                onChanged: (val) async {
                                  // Verify first before toggling off
                                  if (!val) {
                                    final verified = await BiometricAuthService.authenticate(
                                      context,
                                      reason: 'Verifikasi untuk mematikan kunci aplikasi',
                                    );
                                    if (!verified) return;
                                  } else {
                                    // Make sure PIN is set if enabling
                                    final pin = await BiometricAuthService.getCustomPin();
                                    if (pin == null || pin.isEmpty) {
                                      if (!context.mounted) return;
                                      final pinSet = await BiometricAuthService.showPinPadDialog(
                                        context,
                                        title: 'Buat PIN Baru',
                                        subtitle: 'Atur 4 digit PIN keamanan',
                                      );
                                      if (!pinSet) return;
                                    }
                                  }
                                  
                                  await BiometricAuthService.setBiometricEnabled(val);
                                  // ignore: unused_result
                                  ref.refresh(biometricEnabledProvider);
                                },
                                activeTrackColor: AppColors.coral,
                              ),
                              loading: () => const SizedBox(
                                  width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                              error: (_, __) => const SizedBox(),
                            ),
                        onTap: null,
                      ),
                      _SettingsTile(
                        icon: Icons.pin_rounded,
                        iconColor: AppColors.blue,
                        title: 'Ubah PIN 4-Digit',
                        subtitle: 'Buat atau ubah PIN keamanan lokal',
                        onTap: () async {
                           final currentPin = await BiometricAuthService.getCustomPin();
                           if (currentPin != null && currentPin.isNotEmpty) {
                             // verify current first
                             if (!context.mounted) return;
                             final verified = await BiometricAuthService.showPinPadDialog(
                               context,
                               title: 'Masukkan PIN Lama',
                               subtitle: 'Verifikasi PIN lama kamu',
                               correctPin: currentPin,
                             );
                             if (!verified) return;
                           }
                           if (context.mounted) {
                             BiometricAuthService.showPinPadDialog(
                               context,
                               title: 'PIN Keamanan Baru',
                               subtitle: 'Masukkan 4 digit PIN baru kamu',
                             );
                           }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),


                  _SettingsSection(
                    title: 'TAMPILAN',
                    children: [
                      _SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        iconColor: AppColors.forestDark,
                        title: 'Mode Gelap',
                        trailing: Switch(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (val) {
                            ref.read(themeModeProvider.notifier).state =
                                val ? ThemeMode.dark : ThemeMode.light;
                          },
                          activeTrackColor: AppColors.coral,
                        ),
                        onTap: null,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  _SettingsSection(
                    title: 'KEUANGAN',
                    children: [
                      _SettingsTile(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: AppColors.blue,
                        title: 'Anggaran',
                        subtitle: 'Kelola batas pengeluaran per kategori',
                        onTap: () => context.goNamed('budget'),
                      ),
                      _SettingsTile(
                        icon: Icons.category_rounded,
                        iconColor: AppColors.coral,
                        title: 'Kelola Kategori',
                        subtitle: 'Lihat & kelola kategori transaksi',
                        onTap: () => _showManageCategoriesSheet(context, ref),
                      ),
                      _SettingsTile(
                        icon: Icons.account_balance_rounded,
                        iconColor: AppColors.sageDark,
                        title: 'Kelola Rekening',
                        subtitle: 'Tambah & atur rekening bank/e-wallet',
                        onTap: () => context.goNamed('accounts'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  _SettingsSection(
                    title: 'DATA & SINKRONISASI',
                    children: [
                      _SettingsTile(
                        icon: Icons.cloud_sync_rounded,
                        iconColor: AppColors.blue,
                        title: 'Sinkronisasi & Backup',
                        subtitle: 'Data tersimpan lokal & aman',
                        onTap: () => _showSyncDriveDialog(context),
                      ),
                      _SettingsTile(
                        icon: Icons.download_rounded,
                        iconColor: AppColors.sage,
                        title: 'Export ke Excel',
                        subtitle: 'Ekspor data transaksi bulan ini',
                        onTap: () => _exportExcel(context, ref),
                      ),
                      _SettingsTile(
                        icon: Icons.calculate_rounded,
                        iconColor: AppColors.coral,
                        title: 'Hitung Ulang Saldo Rekening',
                        subtitle: 'Perbaiki saldo jika ada anomali perhitungan',
                        onTap: () => _recalculateBalances(context, ref),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  const _SettingsSection(
                    title: 'TENTANG',
                    children: [
                      _SettingsTile(
                        icon: Icons.info_rounded,
                        iconColor: AppColors.textTertiary,
                        title: 'Versi Aplikasi',
                        subtitle: 'v1.0.0 — Cakue (Catat Keuangan Gue)',
                        onTap: null,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.bottomNavBuffer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManageCategoriesSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoriesSheet(ref: ref),
    );
  }

  Future<void> _recalculateBalances(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Row(children: [
          SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          SizedBox(width: 12),
          Text('Menghitung ulang saldo rekening...'),
        ]),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final userUuid = ref.read(activeUserUuidProvider) ?? '';
      final repo = ref.read(transactionRepositoryProvider);
      await repo.recalculateAccountBalances(userUuid);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Saldo rekening berhasil dihitung ulang!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSyncDriveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: AppColors.forestDark),
            SizedBox(width: 10),
            Text('Backup & Keamanan'),
          ],
        ),
        content: const Text(
          'Aplikasi Cakue dirancang dengan prinsip Privacy First.\n\n'
          '• Semua database tersimpan secara privat & offline di SQLite lokal perangkat kamu.\n'
          '• Sinkronisasi otomatis menjaga data kamu tetap aman tanpa mengunggah ke server publik.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportExcel(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Row(children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          SizedBox(width: 12),
          Text('Menyiapkan file Excel...'),
        ]),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final transactions = await ref.read(currentMonthTransactionsProvider.future);
      final user = await ref.read(activeUserProvider.future);
      final now = DateTime.now();
      final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      await ExcelExportService.exportTransactions(
        transactions: transactions,
        userName: user?.name ?? 'Pengguna',
        yearMonth: yearMonth,
      );

      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Export berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(content: Text('❌ Export gagal: $e')),
      );
    }
  }
}

class _CategoriesSheet extends StatelessWidget {
  final WidgetRef ref;
  const _CategoriesSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseCategoriesAsync = ref.watch(categoriesProvider('expense'));
    final incomeCategoriesAsync = ref.watch(categoriesProvider('income'));

    return DefaultTabController(
      length: 2,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Kelola Kategori', style: AppTextStyles.h5.copyWith(color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            TabBar(
              labelColor: AppColors.coral,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: AppColors.coral,
              tabs: const [
                Tab(text: 'Pengeluaran 💸'),
                Tab(text: 'Pemasukan 💰'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _CategoryList(categoriesAsync: expenseCategoriesAsync),
                  _CategoryList(categoriesAsync: incomeCategoriesAsync),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final AsyncValue<List<dynamic>> categoriesAsync;
  const _CategoryList({required this.categoriesAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(child: Text('Belum ada kategori', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          itemCount: categories.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.outlineVariant),
          itemBuilder: (context, i) {
            final cat = categories[i];
            return ListTile(
              leading: Text(cat.icon ?? '📁', style: const TextStyle(fontSize: 22)),
              title: Text(cat.name, style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurface)),
              trailing: cat.isSystem == true
                  ? Chip(
                      label: Text('Sistem', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                      padding: EdgeInsets.zero,
                    )
                  : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: AppSpacing.sm, bottom: AppSpacing.md),
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              return Column(
                children: [
                  e.value,
                  if (e.key < children.length - 1)
                    Divider(
                      height: 1,
                      indent: 64,
                      color: theme.colorScheme.outlineVariant,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurface)),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall
                  .copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant, size: 20)
              : null),
    );
  }
}
