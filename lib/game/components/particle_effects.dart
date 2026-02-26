import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// 레벨 클리어 시 화면 전체에 폭발하는 축하 파티클
class CelebrationParticle extends PositionComponent {
  final Random _rng = Random();
  final List<_Particle> _particles = [];
  double _elapsed = 0;
  static const double duration = 2.5;

  CelebrationParticle({required Vector2 screenSize}) {
    size = screenSize;
    position = Vector2.zero();

    // 네온 색상의 파티클 60개 생성
    final colors = [
      AppColors.neonCyan,
      AppColors.neonPurple,
      AppColors.neonGreen,
      AppColors.neonOrange,
      AppColors.neonBlue,
      AppColors.neonPink,
      Colors.white,
    ];

    final centerX = screenSize.x / 2;
    final centerY = screenSize.y / 2;

    for (int i = 0; i < 60; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 150 + _rng.nextDouble() * 300;
      _particles.add(_Particle(
        x: centerX,
        y: centerY,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 100, // 위로 튀는 느낌
        color: colors[_rng.nextInt(colors.length)],
        size: 3 + _rng.nextDouble() * 5,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 10,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 200 * dt; // 중력
      p.rotation += p.rotationSpeed * dt;
      p.opacity = (1.0 - _elapsed / duration).clamp(0.0, 1.0);
    }

    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      if (p.opacity <= 0) continue;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      // 글로우 효과
      final glowPaint = Paint()
        ..color = p.color.withValues(alpha: p.opacity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size * 2, height: p.size * 2),
        glowPaint,
      );

      // 본체
      final paint = Paint()..color = p.color.withValues(alpha: p.opacity);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
        paint,
      );

      canvas.restore();
    }
  }
}

/// 화살표 발사 시 잔상 트레일
class ShootTrail extends PositionComponent {
  final double startX;
  final double startY;
  final double dirX;
  final double dirY;
  final Color color;
  final double cellSize;
  double _elapsed = 0;
  static const double duration = 0.5;
  final Random _rng = Random();
  final List<_TrailDot> _dots = [];

  ShootTrail({
    required this.startX,
    required this.startY,
    required this.dirX,
    required this.dirY,
    required this.color,
    required this.cellSize,
  }) {
    // 트레일 도트 20개 생성
    for (int i = 0; i < 20; i++) {
      final spread = (_rng.nextDouble() - 0.5) * cellSize * 0.3;
      _dots.add(_TrailDot(
        x: startX + (dirX > 0 ? 1 : dirX < 0 ? -1 : 0) * spread,
        y: startY + (dirY > 0 ? 1 : dirY < 0 ? -1 : 0) * spread,
        offsetX: spread * (dirY.abs() > 0 ? 1 : 0),
        offsetY: spread * (dirX.abs() > 0 ? 1 : 0),
        delay: i * 0.015,
        size: 2 + _rng.nextDouble() * 3,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    for (final dot in _dots) {
      final t = (_elapsed - dot.delay).clamp(0.0, duration);
      if (t <= 0) continue;

      final progress = t / duration;
      final alpha = (1.0 - progress * 2).clamp(0.0, 0.8);
      if (alpha <= 0) continue;

      // 네온 트레일 도트 위치
      final x = dot.x + dirX * cellSize * 4 * progress + dot.offsetX;
      final y = dot.y + dirY * cellSize * 4 * progress + dot.offsetY;

      // 글로우
      final glowPaint = Paint()
        ..color = color.withValues(alpha: alpha * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), dot.size * 1.5, glowPaint);

      // 본체
      final paint = Paint()..color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), dot.size * (1 - progress * 0.5), paint);
    }
  }
}

class _Particle {
  double x, y, vx, vy;
  final Color color;
  final double size;
  double rotation;
  final double rotationSpeed;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotationSpeed,
  })  : rotation = 0,
        opacity = 1.0;
}

class _TrailDot {
  double x, y;
  final double offsetX, offsetY;
  final double delay;
  final double size;

  _TrailDot({
    required this.x,
    required this.y,
    required this.offsetX,
    required this.offsetY,
    required this.delay,
    required this.size,
  });
}
