import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/level_data.dart';

/// 화살표 하나를 나타내는 Flame 컴포넌트
class ArrowComponent extends PositionComponent with TapCallbacks {
  final ArrowData arrowData;
  final double cellSize;
  final VoidCallback? onTap;
  final Color _color;
  
  bool _isRemoving = false;
  double _glowIntensity = 0.0;
  double _glowDirection = 1.0;
  double _shakeOffset = 0.0;
  bool _isShaking = false;
  double _shakeTime = 0.0;
  double _opacity = 1.0;

  ArrowComponent({
    required this.arrowData,
    required this.cellSize,
    this.onTap,
  }) : _color = AppColors.colorForDirection(arrowData.direction);

  @override
  Future<void> onLoad() async {
    size = Vector2.all(cellSize);
    position = Vector2(
      arrowData.col * cellSize,
      arrowData.row * cellSize,
    );
    anchor = Anchor.topLeft;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // 글로우 애니메이션
    _glowIntensity += dt * _glowDirection * 1.5;
    if (_glowIntensity > 1.0) {
      _glowIntensity = 1.0;
      _glowDirection = -1.0;
    } else if (_glowIntensity < 0.0) {
      _glowIntensity = 0.0;
      _glowDirection = 1.0;
    }
    
    // 쉐이크 애니메이션
    if (_isShaking) {
      _shakeTime += dt;
      _shakeOffset = sin(_shakeTime * 60) * 4 * (1.0 - _shakeTime * 4);
      if (_shakeTime > 0.25) {
        _isShaking = false;
        _shakeOffset = 0;
        _shakeTime = 0;
      }
    }
    
    // 힌트 깜박임 애니메이션 (1.5초 동안 3회 깜박)
    if (_isHinting) {
      _hintTime += dt;
      if (_hintTime > 1.5) {
        _isHinting = false;
        _hintTime = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_isRemoving && _opacity <= 0) return;
    
    final rect = Rect.fromLTWH(
      4 + _shakeOffset,
      4,
      cellSize - 8,
      cellSize - 8,
    );
    
    // 배경 네온 글로우
    final glowOpacity = (0.1 + _glowIntensity * 0.15) * _opacity;
    final glowPaint = Paint()
      ..color = _color.withValues(alpha: glowOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      glowPaint,
    );
    
    // 셀 배경
    final bgPaint = Paint()
      ..color = AppColors.bgCard.withValues(alpha: 0.8 * _opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      bgPaint,
    );
    
    // 셀 테두리
    final borderPaint = Paint()
      ..color = _color.withValues(alpha: (0.4 + _glowIntensity * 0.3) * _opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      borderPaint,
    );
    
    // 화살표 그리기
    _drawArrow(canvas, rect);
    
    // 힌트 하이라이트 오버레이
    if (_isHinting) {
      final blinkAlpha = (sin(_hintTime * 4 * pi) * 0.5 + 0.5) * 0.4;
      final hintPaint = Paint()
        ..color = Colors.white.withValues(alpha: blinkAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        hintPaint,
      );
    }
  }

  void _drawArrow(Canvas canvas, Rect cellRect) {
    final center = cellRect.center;
    final arrowSize = cellSize * 0.3;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    
    // 화살표 방향에 따라 회전
    canvas.rotate(arrowData.direction.rotationAngle);
    
    final paint = Paint()
      ..color = _color.withValues(alpha: _opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // 화살표 본체 (→ 방향: 기본)
    final path = Path();
    // 줄기
    path.moveTo(-arrowSize, 0);
    path.lineTo(arrowSize, 0);
    // 화살촉
    path.moveTo(arrowSize * 0.5, -arrowSize * 0.6);
    path.lineTo(arrowSize, 0);
    path.lineTo(arrowSize * 0.5, arrowSize * 0.6);
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap?.call();
  }

  /// 발사(제거) 애니메이션 실행
  void playShootAnimation(VoidCallback onComplete) {
    _isRemoving = true;
    
    final (dr, dc) = arrowData.direction.delta;
    final targetOffset = Vector2(dc * cellSize * 6.0, dr * cellSize * 6.0);
    
    add(
      MoveEffect.by(
        targetOffset,
        EffectController(
          duration: 0.35,
          curve: Curves.easeIn,
        ),
      ),
    );
    
    // 페이드 아웃 (수동)
    add(
      FadeOutEffect(
        EffectController(
          duration: 0.35,
          curve: Curves.easeIn,
        ),
        onEffectComplete: () {
          onComplete();
          removeFromParent();
        },
        onEffectProgress: (progress) {
          _opacity = 1.0 - progress;
        },
      ),
    );
  }

  /// 차단 쉐이크 애니메이션 실행
  void playBlockedAnimation() {
    _isShaking = true;
    _shakeTime = 0;
  }

  /// 힌트 애니메이션: 3번 깜빡이는 밝은 하이라이트
  bool _isHinting = false;
  double _hintTime = 0;

  void playHintAnimation() {
    _isHinting = true;
    _hintTime = 0;
  }
}

/// 커스텀 이펙트: progress 콜백을 받는 범용 이펙트
class FadeOutEffect extends Effect {
  final void Function(double progress)? onEffectProgress;
  final VoidCallback? onEffectComplete;
  bool _isDone = false;

  FadeOutEffect(
    EffectController controller, {
    this.onEffectProgress,
    this.onEffectComplete,
  }) : super(controller);

  @override
  void apply(double progress) {
    onEffectProgress?.call(progress);
    if (progress >= 1.0 && !_isDone) {
      _isDone = true;
      onEffectComplete?.call();
    }
  }
}
