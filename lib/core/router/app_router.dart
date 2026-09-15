import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/features/dashboard/dashboard_screen.dart';
import '../../presentation/features/transactions/transaction_list_screen.dart';
import '../../presentation/features/transactions/add_transaction_screen.dart';
import '../../presentation/features/analytics/analytics_screen.dart';
import '../../presentation/features/accounts/accounts_screen.dart';
import '../../presentation/features/settings/settings_screen.dart';
import '../../presentation/features/onboarding/onboarding_screen.dart';
import '../../presentation/features/budget/budget_screen.dart';
import '../../presentation/features/auth/lock_screen.dart';
import '../../presentation/shared/shell/main_shell.dart';
import '../../di/providers.dart';

/// Provider tanpa code generation - lebih kompatibel dengan semua versi Dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final isUnlocked = ref.watch(appUnlockedProvider);
  final biometricEnabledAsync = ref.watch(biometricEnabledProvider);
  final isBiometricEnabled = biometricEnabledAsync.value ?? false;

  return GoRouter(
    initialLocation: '/onboarding',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLockRoute = state.uri.path == '/lock';
      
      if (isBiometricEnabled && !isUnlocked) {
        if (!isLockRoute) {
          return '/lock';
        }
      } else if (isLockRoute && isUnlocked) {
        return '/dashboard'; // default after unlock
      }

      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: '/lock',
        name: 'lock',
        builder: (context, state) => const LockScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            builder: (context, state) => const TransactionListScreen(),
          ),
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/accounts',
            name: 'accounts',
            builder: (context, state) => const AccountsScreen(),
          ),
          GoRoute(
            path: '/budget',
            name: 'budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Modal routes (full screen, slide from bottom)
      GoRoute(
        path: '/add-transaction',
        name: 'add-transaction',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: AddTransactionScreen(
            initialType: state.uri.queryParameters['type'],
          ),
          transitionsBuilder: (context, animation, _, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      GoRoute(
        path: '/edit-transaction/:uuid',
        name: 'edit-transaction',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: AddTransactionScreen(
            transactionUuid: state.pathParameters['uuid'],
          ),
          transitionsBuilder: (context, animation, _, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
    ],
  );
});
