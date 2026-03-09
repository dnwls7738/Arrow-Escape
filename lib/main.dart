import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants.dart';
import 'screens/main_menu_screen.dart';
import 'screens/tutorial_screen.dart';

import 'data/user_manager.dart';
import 'data/score_manager.dart';
import 'data/settings_manager.dart';
import 'data/audio_manager.dart';
import 'data/ad_manager.dart';
import 'data/level_service.dart';
import 'data/auth_service.dart';
import 'data/cloud_save_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 로컬 저장소 및 계정, 설정 초기화 (순수 로컬 캐시는 빠른 로딩 지원)
  await UserManager().init();
  await ScoreManager().init();
  await SettingsManager().init();
  
  // 설정 변경 시 오디오 매니저에 알림
  SettingsManager().addListener(() => AudioManager().onSettingsChanged());
  
  // 상태바 투명, 다크 모드
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 세로 모드 고정 (모바일)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ArrowEscapeApp());
}

class ArrowEscapeApp extends StatelessWidget {
  const ArrowEscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrow Puzzle Escape',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: ColorScheme.dark(
          primary: AppColors.neonCyan,
          surface: AppColors.bgDark,
        ),
      ),
      home: const _AppStarter(),
    );
  }
}

/// 첫 실행 감지: tutorial_seen 플래그에 따라 튜토리얼 또는 메인 메뉴 표시
class _AppStarter extends StatefulWidget {
  const _AppStarter();

  @override
  State<_AppStarter> createState() => _AppStarterState();
}

class _AppStarterState extends State<_AppStarter> {
  bool? _tutorialSeen;
  bool _isServicesInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAppServices();
  }

  Future<void> _initAppServices() async {
    try {
      // 1. Firebase 초기화
      await Firebase.initializeApp();
      
      // 2. 로그인 체킹 (네트워크 지연 우려)
      if (AuthService().currentUser == null) {
        await AuthService().signInAnonymously();
        Logger.log('✅ Anonymous login: ${AuthService().currentUser?.uid}');
      } else {
        Logger.log('✅ Already logged in: ${AuthService().currentUser?.uid}');
      }

      // 구글 로그인 유저면 프로필 정보(email/name) 자동 동기화
      final currentUser = AuthService().currentUser;
      if (currentUser != null && !currentUser.isAnonymous) {
        CloudSaveService().uploadProgress();
      }

      // 오디오 및 광고 지연 초기화
      AudioManager().init();
      AdManager().init();

      // Firestore에서 레벨 로딩
      await LevelService().init();
      
      AudioManager().startBgm();

    } catch (e) {
      Logger.log('Service Init Error: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    
    setState(() {
      _tutorialSeen = prefs.getBool('tutorial_seen') ?? false;
      _isServicesInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isServicesInitialized || _tutorialSeen == null) {
      // 로딩 중
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.neonCyan)),
      );
    }

    if (!_tutorialSeen!) {
      return TutorialScreen(
        onComplete: () {
          setState(() => _tutorialSeen = true);
        },
      );
    }

    return const MainMenuScreen();
  }
}
