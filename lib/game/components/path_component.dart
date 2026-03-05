import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/level_data.dart';

class PathComponent extends PositionComponent with TapCallbacks {
  final PathData pathData;
  final double cellSize;
  final VoidCallback? onTap;
  late final Color color;
  
  bool _isRemoving = false;
  bool get isRemoving => _isRemoving;

  double _shakeOffset = 0.0;
  bool _isShaking = false;
  bool get isShaking => _isShaking;

  double _shakeTime = 0.0;
  double _opacity = 1.0;

  bool _isHinting = false;
  double _hintTime = 0.0;

  bool _isShooting = false;
  double _shootOffset = 0.0;
  VoidCallback? _onShootComplete;

  PathComponent({
    required this.pathData,
    required this.cellSize,
    this.onTap,
  }) {
    // Generate a color based on its colorIndex or id
    final colors = [
      Colors.redAccent, Colors.blueAccent, Colors.greenAccent,
      Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent,
      Colors.pinkAccent, Colors.amberAccent
    ];
    color = colors[pathData.colorIndex % colors.length];
  }

  @override
  Future<void> onLoad() async {
    // We will size this component to the entire board, handled by the parent
    anchor = Anchor.topLeft;
    position = Vector2.zero();
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    if (_isRemoving || _opacity <= 0) return false;
    
    // Convert point to row/col
    final c = (point.x / cellSize).floor();
    final r = (point.y / cellSize).floor();
    
    for (final seg in pathData.segments) {
      if (seg.row == r && seg.col == c) return true;
    }
    return false;
  }
  @override
  void update(double dt) {
    super.update(dt);
    
    if (_isShaking) {
      _shakeTime += dt;
      _shakeOffset = sin(_shakeTime * 60) * 4 * (1.0 - _shakeTime * 4);
      if (_shakeTime > 0.25) {
        _isShaking = false;
        _shakeOffset = 0;
        _shakeTime = 0;
      }
    }
    
    if (_isHinting) {
      _hintTime += dt;
      if (_hintTime > 1.5) {
        _isHinting = false;
        _hintTime = 0;
      }
    }

    if (_isShooting) {
      _shootOffset += dt * cellSize * 20.0; // 20 cells per second speed
      
      if (_shootOffset > cellSize * 15) {
        _opacity -= dt * 4.0;
        if (_opacity < 0) _opacity = 0.0;
      }
      
      if (_shootOffset > cellSize * 25 || _opacity <= 0) {
        _isShooting = false;
        _isRemoving = true;
        _onShootComplete?.call();
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if ((_isRemoving && _opacity <= 0) || pathData.segments.isEmpty) return;

    final fullTrack = Path();
    for (int i = 0; i < pathData.segments.length; i++) {
      final seg = pathData.segments[i];
      final cx = seg.col * cellSize + cellSize / 2 + _shakeOffset;
      final cy = seg.row * cellSize + cellSize / 2;
      
      if (i == 0) {
        fullTrack.moveTo(cx, cy);
      } else {
        fullTrack.lineTo(cx, cy);
      }
    }

    // 탈출용 경로 연장선 추가 전, 실제 몸통의 픽셀 길이를 미리 계산 (통나무처럼 압축되는 것 방지)
    double originalLength = 0;
    final originalMetrics = fullTrack.computeMetrics().toList();
    if (originalMetrics.isNotEmpty) {
      originalLength = originalMetrics.first.length;
    }

    if (_isShooting) {
      final head = pathData.segments.last;
      final cx = head.col * cellSize + cellSize / 2 + _shakeOffset;
      final cy = head.row * cellSize + cellSize / 2;
      final (dr, dc) = pathData.headDirection;
      fullTrack.lineTo(cx + dc * cellSize * 25, cy + dr * cellSize * 25);
    }

    Path pathToDraw = fullTrack;
    Offset headPos;
    double headAngle;

    if (_isShooting) {
      final metrics = fullTrack.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final snakeLength = max(0.1, originalLength);
        final start = _shootOffset;
        final end = start + snakeLength;
        pathToDraw = metric.extractPath(start, end);

        final endOffsetForTangent = min(end, metric.length);
        final tangent = metric.getTangentForOffset(endOffsetForTangent);
        if (tangent != null) {
          headPos = tangent.position;
          headAngle = tangent.vector.direction;
        } else {
          final headSeg = pathData.segments.last;
          headPos = Offset(headSeg.col * cellSize + cellSize / 2, headSeg.row * cellSize + cellSize / 2);
          headAngle = pathData.arrowDirection.rotationAngle;
        }
      } else {
        final headSeg = pathData.segments.last;
        headPos = Offset(headSeg.col * cellSize + cellSize / 2, headSeg.row * cellSize + cellSize / 2);
        headAngle = pathData.arrowDirection.rotationAngle;
      }
    } else {
      final headSeg = pathData.segments.last;
      headPos = Offset(headSeg.col * cellSize + cellSize / 2 + _shakeOffset, headSeg.row * cellSize + cellSize / 2);
      headAngle = pathData.arrowDirection.rotationAngle;
    }

    // 본체 선
    final bodyPaint = Paint()
      ..color = color.withValues(alpha: _opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pathToDraw, bodyPaint);

    // 머리(화살촉) 그리기
    _drawArrowHeadAt(canvas, headPos, headAngle);

    // 힌트 깜박임
    if (_isHinting) {
      final blinkAlpha = (sin(_hintTime * 4 * pi) * 0.5 + 0.5) * 0.6;
      final hintPaint = Paint()
        ..color = Colors.white.withValues(alpha: blinkAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(pathToDraw, hintPaint);
    }
  }

  void _drawArrowHeadAt(Canvas canvas, Offset position, double angle) {
    if (pathData.segments.length < 2) return;
    
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    
    // 화살표 머리: 선과 동일한 두께의 V자 꺾임
    const arrowSize = 5.0;
    
    final path = Path()
      ..moveTo(-arrowSize, -arrowSize)
      ..lineTo(0, 0)
      ..lineTo(-arrowSize, arrowSize);
      
    final paint = Paint()
      ..color = color.withValues(alpha: _opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  Vector2? _tapStartPosition;

  @override
  void onTapDown(TapDownEvent event) {
    _tapStartPosition = event.localPosition;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_tapStartPosition == null) return;
    
    // 터치한 지점에서 거의 움직이지 않았을 때만 탭으로 인정 (임계값 10px)
    final distance = _tapStartPosition!.distanceTo(event.localPosition);
    if (distance < 10) {
      onTap?.call();
    }
    _tapStartPosition = null;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _tapStartPosition = null;
  }

  void playShootAnimation(VoidCallback onComplete) {
    _isShooting = true;
    _shootOffset = 0.0;
    _onShootComplete = onComplete;
  }

  void playBlockedAnimation() {
    _isShaking = true;
    _shakeTime = 0;
  }

  void playHintAnimation() {
    _isHinting = true;
    _hintTime = 0;
  }
}
