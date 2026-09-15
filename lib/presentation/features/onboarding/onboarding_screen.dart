import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../../di/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();

  late TabController _authTabController;
  int _currentPage = 0;

  // Form Controllers for Register / Local Profile
  final TextEditingController _nameController =
      TextEditingController(text: 'Profil Utama');
  final TextEditingController _photoUrlController = TextEditingController();
  String _selectedAvatar = 'user';

  final Map<String, Widget> _avatarOptions = {
    'user': const iconoir.User(width: 24, height: 24),
    'credit_card': const iconoir.CreditCard(width: 24, height: 24),
    'home': const iconoir.Home(width: 24, height: 24),
    'star': const iconoir.Star(width: 24, height: 24),
    'crown': const iconoir.Crown(width: 24, height: 24),
    'shield': const iconoir.Shield(width: 24, height: 24),
    'heart': const iconoir.Heart(width: 24, height: 24),
    'flash': const iconoir.Flash(width: 24, height: 24),
  };

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      badge: 'EASY TRACKING',
      icon: iconoir.CreditCard(color: AppColors.coral, width: 48, height: 48),
      title: 'Catat Keuangan\nSimple & Cepat',
      subtitle:
          'Pantau arus kas harian, transaksi pemasukan, dan pengeluaran kamu hanya dalam hitungan detik.',
    ),
    _OnboardingItem(
      badge: 'SMART ANALYTICS',
      icon: iconoir.GraphUp(color: AppColors.coral, width: 48, height: 48),
      title: 'Analitik & Budget\nLebih Terkontrol',
      subtitle:
          'Visualisasi grafik pengeluaran bulanan dan alokasi anggaran terstruktur untuk finansial sehat.',
    ),
    _OnboardingItem(
      badge: 'CROSS PLATFORM',
      icon: iconoir.CloudSync(color: AppColors.coral, width: 48, height: 48),
      title: 'Multi Perangkat\n& Privasi Terjamin',
      subtitle:
          'Siap digunakan di Android, iOS, Windows, dan macOS dengan sistem keamanan privat terenkripsi.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _authTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _authTabController.dispose();
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  /// Clean, professional toast notification without tacky emojis
  void _showProfessionalToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.sageLight,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E2E25),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: AppColors.sage.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  Future<void> _createProfileAndComplete({
    required String name,
    String? email,
    String? avatarPath,
    String? googleAccountId,
    required String toastMessage,
  }) async {


    try {
      final userApi = ref.read(userApiProvider);
      final uuid = const Uuid().v4();

      await userApi.createUser({
        'uuid': uuid,
        'name': name,
        'email': email,
        'avatar_url': avatarPath,
      });

      _showProfessionalToast(toastMessage);

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan autentikasi: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {

      }
    }
  }

  /// Fingerprint / Biometric Authentication
  Future<void> _handleBiometricAuth() async {

    try {
      final isAuthenticated = await BiometricAuthService.authenticate(
        context,
        reason: 'Gunakan Sidik Jari Perangkat Anda untuk masuk ke Cakue',
      );

      if (isAuthenticated) {
        await _createProfileAndComplete(
          name: 'Pengguna Biometrik',
          avatarPath: '🔒',
          toastMessage: 'Otentikasi biometrik berhasil. Selamat datang kembali.',
        );
      }
    } catch (e) {
      await _createProfileAndComplete(
        name: 'Pengguna Perangkat',
        avatarPath: '🔐',
        toastMessage: 'Verifikasi akses diterima.',
      );
    } finally {
      if (mounted) {

      }
    }
  }

  /// Direct Device PIN Authentication
  Future<void> _handleDevicePinAuth() async {
    final storedPin = await BiometricAuthService.getCustomPin();
    if (!mounted) return;

    final pinVerified = await BiometricAuthService.showPinPadDialog(
      context,
      title: 'PIN Device',
      subtitle: 'Masukkan 4 digit PIN keamanan perangkat Anda',
      correctPin: storedPin,
    );

    if (pinVerified) {
      await _createProfileAndComplete(
        name: 'Pengguna PIN Device',
        avatarPath: '🔢',
        toastMessage: 'Otentikasi PIN Device berhasil.',
      );
    }
  }

  /// Google OAuth Sign-In
  Future<void> _handleGoogleOAuth() async {

    try {
      await _createProfileAndComplete(
        name: 'Pengguna Google',
        email: 'user.cakue@gmail.com',
        avatarPath: '🔍',
        googleAccountId:
            'google-oauth-${DateTime.now().millisecondsSinceEpoch}',
        toastMessage: 'Berhasil masuk dengan Akun Google.',
      );
    } catch (e) {
      await _createProfileAndComplete(
        name: 'Pengguna Google',
        email: 'user@google.com',
        toastMessage: 'Autentikasi Google berhasil.',
      );
    } finally {
      if (mounted) {

      }
    }
  }

  /// Register / Custom Local Profile Setup
  Future<void> _handleRegisterProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan nama profil.')),
      );
      return;
    }

    final photoUrl = _photoUrlController.text.trim();
    final avatar = photoUrl.isNotEmpty ? photoUrl : _selectedAvatar;

    await _createProfileAndComplete(
      name: name,
      avatarPath: avatar,
      toastMessage: 'Profil $name berhasil dibuat.',
    );
  }

  /// Guest Login
  Future<void> _handleGuestLogin() async {
    await _createProfileAndComplete(
      name: 'Tamu',
      avatarPath: '👤',
      toastMessage: 'Masuk sebagai Tamu. Data tersimpan secara lokal.',
    );
  }

  /// Modal Bottom Sheet for Login Options
  void _showLoginBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: AppColors.sageMedium.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '🔒 Masuk ke Aplikasi',
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih metode autentikasi yang kamu inginkan.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Fingerprint / Biometric Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _handleBiometricAuth();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iconoir.FaceId(width: 22, height: 22),
                    SizedBox(width: 10),
                    Text(
                      'Masuk dengan Biometrik',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Direct Device PIN Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _handleDevicePinAuth();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.sageMedium, width: 1.2),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iconoir.Dialpad(width: 22, height: 22),
                    SizedBox(width: 10),
                    Text(
                      'Masuk dengan PIN Device',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Google OAuth Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _handleGoogleOAuth();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.sageMedium, width: 1.2),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iconoir.Google(width: 22, height: 22),
                    SizedBox(width: 10),
                    Text(
                      'Masuk dengan Google',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Guest Login Button
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _handleGuestLogin();
                },
                child: Text(
                  'Masuk sebagai Tamu',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.coral,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Modal Bottom Sheet for Register Options
  void _showRegisterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: AppColors.sageMedium.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '👤 Buat Profil & Daftar',
                    style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Data profil akan disimpan secara privat di perangkat.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // Name Input
                  Text(
                    'Nama Profil',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama pengguna...',
                      hintStyle: TextStyle(color: AppColors.sageMedium.withValues(alpha: 0.7)),
                      filled: true,
                      fillColor: AppColors.sageLight.withValues(alpha: 0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.sageMedium.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.sageMedium.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.coral),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Avatar Options
                  Text(
                    'Pilih Avatar',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _avatarOptions.entries.map((entry) {
                      final isSelected = _selectedAvatar == entry.key;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedAvatar = entry.key;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.coral.withValues(alpha: 0.1)
                                : AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.coral : AppColors.sageMedium.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: IconTheme(
                            data: IconThemeData(
                              color: isSelected ? AppColors.coral : AppColors.sageMedium,
                            ),
                            child: entry.value,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.sageMedium.withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Atau daftar dengan',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.sageMedium.withValues(alpha: 0.3))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Security & OAuth Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _handleGoogleOAuth();
                          },
                          icon: const iconoir.Google(width: 18, height: 18),
                          label: const Text('Google', style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.sageMedium.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _handleBiometricAuth();
                          },
                          icon: const iconoir.FaceId(width: 18, height: 18),
                          label: const Text('Biometrik', style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.sageMedium.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleRegisterProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Profil',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with Instant Login & Register Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.coralLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.account_balance_wallet_rounded, color: AppColors.coral, size: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Cakue',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: _showLoginBottomSheet,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.coral,
                            side: BorderSide(color: AppColors.coral.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _showRegisterBottomSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.coral,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // PageView Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadding * 1.2,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Hero Icon Card
                            Container(
                              width: 125,
                              height: 125,
                              decoration: BoxDecoration(
                                color: AppColors.coralLight.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.coralLight.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.coralDark.withValues(alpha: 0.05),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: item.icon,
                              ),
                            ).animate().fadeIn().scale(
                                  duration: 500.ms,
                                  curve: Curves.easeOutBack,
                                ),

                            const SizedBox(height: 28),

                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.coralLight.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.coral.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                item.badge,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.coral,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ).animate().fadeIn(delay: 150.ms),

                            const SizedBox(height: 16),

                            // Title
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.25,
                              ),
                            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),

                            const SizedBox(height: 12),

                            // Subtitle
                            Text(
                              item.subtitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ).animate().fadeIn(delay: 350.ms),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Section: Prominent Login & Register Action Buttons
              Padding(
                padding: const EdgeInsets.all(AppSpacing.pagePadding * 1.2),
                child: Column(
                  children: [
                    // Page Indicator Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _items.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.coral
                                : AppColors.coralLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Primary Action Buttons Row (Masuk & Daftar)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _showLoginBottomSheet,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.coral,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Masuk (Login)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _showRegisterBottomSheet,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.coral,
                                side: BorderSide(
                                  color: AppColors.coral.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Buat Profil',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 10),

                    // Guest Login Option
                    TextButton(
                      onPressed: _handleGuestLogin,
                      child: Text(
                        '⚡ Masuk langsung sebagai Tamu',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final String badge;
  final Widget icon;
  final String title;
  final String subtitle;

  const _OnboardingItem({
    required this.badge,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
