import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/main_menu_screen.dart';
import '../screens/level_select_screen.dart';
import '../screens/game_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tutorial_screen.dart';
import '../models/level_data.dart';
import '../core/constants.dart';

/// 앱 라우터 구성
class AppRouter {
  static late final GoRouter router;

  /// 앱 시작 전 초기화 (튜토리얼 여부에 따라 초기 경로 결정)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final tutorialSeen = prefs.getBool('tutorial_seen') ?? false;

    router = GoRouter(
      initialLocation: tutorialSeen ? '/' : '/tutorial',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const MainMenuScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/tutorial',
          name: 'tutorial',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: TutorialScreen(
              onComplete: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('tutorial_seen', true);
                router.go('/');
              },
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/levels',
          name: 'levels',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LevelSelectScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/game',
          name: 'game',
          pageBuilder: (context, state) {
            final levelData = state.extra as LevelData;
            return CustomTransitionPage(
              key: state.pageKey,
              child: GameScreen(levelData: levelData),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            );
          },
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
      ],
    );
  }
}
