import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../../di/providers.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptAuth();
    });
  }

  Future<void> _promptAuth() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      bool authenticated = await BiometricAuthService.authenticate(
        context,
        reason: 'Verifikasi keamanan untuk membuka aplikasi',
      );

      if (!authenticated && mounted) {
        final pin = await BiometricAuthService.getCustomPin();
        if (pin != null && pin.isNotEmpty) {
          authenticated = await BiometricAuthService.showPinPadDialog(
            context,
            title: 'Masukkan PIN',
            subtitle: 'Aplikasi terkunci',
            correctPin: pin,
          );
        }
      }

      if (authenticated && mounted) {
        ref.read(appUnlockedProvider.notifier).unlock();
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2A22),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_rounded,
              color: AppColors.coral,
              size: 72,
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  duration: 1200.ms,
                ),
            const SizedBox(height: 24),
            Text(
              'Aplikasi Terkunci',
              style: AppTextStyles.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Gunakan Sidik Jari atau PIN untuk masuk',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isAuthenticating ? null : _promptAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sage,
                foregroundColor: AppColors.forestDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Buka Kunci',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
