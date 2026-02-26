import 'package:flutter/material.dart';

/// 앱 색상 팔레트
class AppColors {
  // 배경
  static const Color bgDark = Color(0xFF0D1117);
  static const Color bgDarkSecondary = Color(0xFF161B22);
  static const Color bgCard = Color(0xFF1C2333);
  static const Color bgCardHover = Color(0xFF242D3D);

  // 네온 컬러
  static const Color neonBlue = Color(0xFF4FC3F7);
  static const Color neonGreen = Color(0xFF81C784);
  static const Color neonOrange = Color(0xFFFFB74D);
  static const Color neonPurple = Color(0xFFCE93D8);
  static const Color neonPink = Color(0xFFFF6B9D);
  static const Color neonCyan = Color(0xFF00E5FF);

  // 화살표 방향별 색상
  static const Color arrowUp = neonBlue;
  static const Color arrowRight = neonGreen;
  static const Color arrowDown = neonOrange;
  static const Color arrowLeft = neonPurple;

  // 텍스트
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF484F58);

  // UI
  static const Color gridLine = Color(0xFF21262D);
  static const Color success = Color(0xFF3FB950);
  static const Color error = Color(0xFFF85149);
  static const Color warning = neonOrange;

  /// 방향에 따른 색상 반환
  static Color colorForDirection(ArrowDirection direction) {
    switch (direction) {
      case ArrowDirection.up:
        return arrowUp;
      case ArrowDirection.right:
        return arrowRight;
      case ArrowDirection.down:
        return arrowDown;
      case ArrowDirection.left:
        return arrowLeft;
    }
  }
}

/// 화살표 방향
enum ArrowDirection {
  up,
  right,
  down,
  left;

  /// 방향에 따른 행/열 변화량
  (int dr, int dc) get delta {
    switch (this) {
      case ArrowDirection.up:
        return (-1, 0);
      case ArrowDirection.right:
        return (0, 1);
      case ArrowDirection.down:
        return (1, 0);
      case ArrowDirection.left:
        return (0, -1);
    }
  }

  /// 방향에 따른 회전 각도 (라디안)
  double get rotationAngle {
    switch (this) {
      case ArrowDirection.up:
        return -1.5708; // -90°
      case ArrowDirection.right:
        return 0;
      case ArrowDirection.down:
        return 1.5708; // 90°
      case ArrowDirection.left:
        return 3.1416; // 180°
    }
  }
}

/// 앱 크기 상수
class AppSizes {
  static const double gridPadding = 16.0;
  static const double cellSpacing = 2.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 56.0;
}
