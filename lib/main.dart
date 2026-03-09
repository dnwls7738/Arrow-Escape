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
  
  // Firebase 초기화
  await Firebase.initializeApp();
  
  // 로그인 안 되어 있으면 자동 익명 로그인 (게스트 모드)
  if (AuthService().currentUser == null) {
    await AuthService().signInAnonymously();
    Logger.log('✅ Anonymous login: ${AuthService().currentUser?.uid}');
  } else {
    Logger.log('✅ Already logged in: ${AuthService().currentUser?.uid} (anonymous: ${AuthService().currentUser?.isAnonymous})');
  }
  
  // 로컬 저장소 및 계정, 설정 초기화
  await UserManager().init();
  await ScoreManager().init();
  await SettingsManager().init();
  await AudioManager().init();
  
  // 광고 초기화는 앱 시작을 막지 않도록 비동기로 바로 실행 (await 제거)
  AdManager().init();
  
  // 구글 로그인 유저면 프로필 정보(email/name) 자동 동기화
  final currentUser = AuthService().currentUser;
  if (currentUser != null && !currentUser.isAnonymous) {
    CloudSaveService().uploadProgress();
  }
  
  // Firestore에서 레벨 로딩 (실패 시 로컬 폴백)
  await LevelService().init();
  
  // 설정 변경 시 오디오 매니저에 알림
  SettingsManager().addListener(() => AudioManager().onSettingsChanged());
  
  // BGM 시작 (앱 전체에서 한 번만)
  AudioManager().startBgm();
  
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

  @override
  void initState() {
    super.initState();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tutorialSeen = prefs.getBool('tutorial_seen') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_tutorialSeen == null) {
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
