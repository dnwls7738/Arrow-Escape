import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants.dart';
import 'core/app_router.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:arrow_escape/l10n/app_localizations.dart';

import 'data/user_manager.dart';
import 'data/score_manager.dart';
import 'data/settings_manager.dart';
import 'data/audio_manager.dart';
import 'data/ad_manager.dart';
import 'data/level_service.dart';
import 'data/auth_service.dart';
import 'data/cloud_save_service.dart';
import 'data/providers.dart';

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
  await AdManager().init();
  
  // 구글 로그인 유저면 프로필 정보(email/name) 자동 동기화
  final currentUser = AuthService().currentUser;
  if (currentUser != null && !currentUser.isAnonymous) {
    CloudSaveService().uploadProgress();
  }
  
  // JSON 에셋에서 레벨 로딩
  await LevelService().init();
  
  // 설정 변경 시 오디오 매니저에 알림
  SettingsManager().addListener(() => AudioManager().onSettingsChanged());
  
  // BGM 시작 (앱 전체에서 한 번만)
  AudioManager().startBgm();
  
  // GoRouter 초기화
  await AppRouter.init();
  
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

  runApp(const ProviderScope(child: ArrowEscapeApp()));
}

class ArrowEscapeApp extends ConsumerWidget {
  const ArrowEscapeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: 'ARROW ESCAPE',
      debugShowCheckedModeBanner: false,
      
      // Localization Setup
      locale: Locale(settings.languageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],

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
    );
  }
}
