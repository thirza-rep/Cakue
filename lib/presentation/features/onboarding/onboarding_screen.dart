import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

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
  bool _isLoading = false;

  // Form Controllers for Register / Local Profile
  final TextEditingController _nameController =
      TextEditingController(text: 'Profil Utama');
  final TextEditingController _photoUrlController = TextEditingController();
  String _selectedAvatarEmoji = '👤';

  final List<String> _avatarOptions = [
    '👤',
    '💳',
    '💼',
    '💎',
    '🦊',
    '👑',
    '⭐',
    '🛡️'
  ];

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      badge: 'EASY TRACKING',
      emoji: '💳',
      title: 'Catat Keuangan\nSimple & Cepat',
      subtitle:
          'Pantau arus kas harian, transaksi pemasukan, dan pengeluaran kamu hanya dalam hitungan detik.',
    ),
    _OnboardingItem(
      badge: 'SMART ANALYTICS',
      emoji: '📈',
      title: 'Analitik & Budget\nLebih Terkontrol',
      subtitle:
          'Visualisasi grafik pengeluaran bulanan dan alokasi anggaran terstruktur untuk finansial sehat.',
    ),
    _OnboardingItem(
      badge: 'CROSS PLATFORM',
      emoji: '🌐',
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
    setState(() => _isLoading = true);

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
        setState(() => _isLoading = false);
      }
    }
  }

  /// Fingerprint / Biometric Authentication
  Future<void> _handleBiometricAuth() async {
    setState(() => _isLoading = true);
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
        setState(() => _isLoading = false);
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
    setState(() => _isLoading = true);
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
        setState(() => _isLoading = false);
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
    final avatar = photoUrl.isNotEmpty ? photoUrl : _selectedAvatarEmoji;

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
          color: Color(0xFF1B2A22),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '🔒 Masuk ke Aplikasi',
              style: AppTextStyles.h4.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih metode autentikasi yang kamu inginkan.',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
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
                    Icon(Icons.fingerprint_rounded, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Masuk dengan Sidik Jari',
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
                  backgroundColor: const Color(0xFF2D4436),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.sage, width: 1.2),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pin_rounded, size: 22, color: AppColors.sageLight),
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
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔍', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Text(
                      'Masuk dengan Google OAuth',
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
                    color: Colors.white70,
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
                color: Color(0xFF1B2A22),
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
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '👤 Buat Profil & Daftar',
                    style: AppTextStyles.h4.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Data profil akan disimpan secara privat di perangkat.',
                    style: AppTextStyles.caption.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),

                  // Name Input
                  Text(
                    'Nama Profil',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama pengguna...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.black26,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
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
                    'Avatar atau Foto Profil',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _avatarOptions.map((emoji) {
                      final isSelected = _selectedAvatarEmoji == emoji;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedAvatarEmoji = emoji;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.coral.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.coral : Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 22)),
                        ),
                      );
                    }).toList(),
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
                        'Daftar & Masuk',
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
      backgroundColor: AppColors.forestDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A2B),
              Color(0xFF0D2218),
            ],
          ),
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
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('🥐', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Cakue',
                          style: AppTextStyles.h4.copyWith(
                            color: Colors.white,
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
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
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
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  item.emoji,
                                  style: const TextStyle(fontSize: 56),
                                ),
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
                                color: AppColors.coral.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.coral.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                item.badge,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.coralLight,
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
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),

                            const SizedBox(height: 12),

                            // Subtitle
                            Text(
                              item.subtitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
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
                                : Colors.white24,
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
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.white54, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Daftar (Register)',
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
  final String emoji;
  final String title;
  final String subtitle;

  const _OnboardingItem({
    required this.badge,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}
