import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

/// 创意RenderObject效果集合
/// 
/// 本文件包含多种创新的自定义RenderObject实现：
/// 1. 液体波浪效果 (LiquidWave)
/// 2. 粒子爆炸效果 (ParticleExplosion)
/// 3. 磁性吸附布局 (MagneticLayout)
/// 4. 3D翻转卡片 (FlipCard3D)
/// 5. 动态网格背景 (DynamicGridBackground)

/// 1. 液体波浪效果 - 模拟液体流动的动画效果
class LiquidWave extends LeafRenderObjectWidget {
  const LiquidWave({
    Key? key,
    required this.waveHeight,
    required this.waveSpeed,
    required this.waveColor,
    required this.backgroundColor,
    this.waveCount = 2,
    this.animationValue = 0.0,
  }) : super(key: key);

  final double waveHeight;
  final double waveSpeed;
  final Color waveColor;
  final Color backgroundColor;
  final int waveCount;
  final double animationValue;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLiquidWave(
      waveHeight: waveHeight,
      waveSpeed: waveSpeed,
      waveColor: waveColor,
      backgroundColor: backgroundColor,
      waveCount: waveCount,
      animationValue: animationValue,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderLiquidWave renderObject) {
    renderObject
      ..waveHeight = waveHeight
      ..waveSpeed = waveSpeed
      ..waveColor = waveColor
      ..backgroundColor = backgroundColor
      ..waveCount = waveCount
      ..animationValue = animationValue;
  }
}

class RenderLiquidWave extends RenderBox {
  RenderLiquidWave({
    required double waveHeight,
    required double waveSpeed,
    required Color waveColor,
    required Color backgroundColor,
    required int waveCount,
    required double animationValue,
  })  : _waveHeight = waveHeight,
        _waveSpeed = waveSpeed,
        _waveColor = waveColor,
        _backgroundColor = backgroundColor,
        _waveCount = waveCount,
        _animationValue = animationValue;

  double _waveHeight;
  double get waveHeight => _waveHeight;
  set waveHeight(double value) {
    if (_waveHeight != value) {
      _waveHeight = value;
      markNeedsPaint();
    }
  }

  double _waveSpeed;
  double get waveSpeed => _waveSpeed;
  set waveSpeed(double value) {
    if (_waveSpeed != value) {
      _waveSpeed = value;
      markNeedsPaint();
    }
  }

  Color _waveColor;
  Color get waveColor => _waveColor;
  set waveColor(Color value) {
    if (_waveColor != value) {
      _waveColor = value;
      markNeedsPaint();
    }
  }

  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  int _waveCount;
  int get waveCount => _waveCount;
  set waveCount(int value) {
    if (_waveCount != value) {
      _waveCount = value;
      markNeedsPaint();
    }
  }

  double _animationValue;
  double get animationValue => _animationValue;
  set animationValue(double value) {
    if (_animationValue != value) {
      _animationValue = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(double.infinity, 200));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);

    // 绘制背景
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(rect, backgroundPaint);

    // 绘制波浪
    final wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < waveCount; i++) {
      final path = Path();
      final waveOffset = (animationValue * waveSpeed + i * math.pi / waveCount) % (2 * math.pi);
      
      path.moveTo(offset.dx, offset.dy + size.height);
      
      for (double x = 0; x <= size.width; x += 2) {
        final y = offset.dy + size.height * 0.7 + 
                 math.sin((x / size.width * 4 * math.pi) + waveOffset) * waveHeight;
        path.lineTo(offset.dx + x, y);
      }
      
      path.lineTo(offset.dx + size.width, offset.dy + size.height);
      path.close();

      // 添加透明度变化
      wavePaint.color = waveColor.withOpacity(0.3 + 0.4 * (i + 1) / waveCount);
      canvas.drawPath(path, wavePaint);
    }
  }
}

/// 2. 粒子爆炸效果 - 点击时产生粒子爆炸动画
class ParticleExplosion extends LeafRenderObjectWidget {
  const ParticleExplosion({
    Key? key,
    required this.particles,
    required this.explosionCenter,
    required this.animationValue,
    this.particleColor = Colors.orange,
    this.particleSize = 4.0,
  }) : super(key: key);

  final List<Particle> particles;
  final Offset explosionCenter;
  final double animationValue;
  final Color particleColor;
  final double particleSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParticleExplosion(
      particles: particles,
      explosionCenter: explosionCenter,
      animationValue: animationValue,
      particleColor: particleColor,
      particleSize: particleSize,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderParticleExplosion renderObject) {
    renderObject
      ..particles = particles
      ..explosionCenter = explosionCenter
      ..animationValue = animationValue
      ..particleColor = particleColor
      ..particleSize = particleSize;
  }
}

class Particle {
  final Offset initialPosition;
  final Offset velocity;
  final double life;
  final Color color;

  Particle({
    required this.initialPosition,
    required this.velocity,
    required this.life,
    required this.color,
  });
}

class RenderParticleExplosion extends RenderBox {
  RenderParticleExplosion({
    required List<Particle> particles,
    required Offset explosionCenter,
    required double animationValue,
    required Color particleColor,
    required double particleSize,
  })  : _particles = particles,
        _explosionCenter = explosionCenter,
        _animationValue = animationValue,
        _particleColor = particleColor,
        _particleSize = particleSize;

  List<Particle> _particles;
  List<Particle> get particles => _particles;
  set particles(List<Particle> value) {
    _particles = value;
    markNeedsPaint();
  }

  Offset _explosionCenter;
  Offset get explosionCenter => _explosionCenter;
  set explosionCenter(Offset value) {
    if (_explosionCenter != value) {
      _explosionCenter = value;
      markNeedsPaint();
    }
  }

  double _animationValue;
  double get animationValue => _animationValue;
  set animationValue(double value) {
    if (_animationValue != value) {
      _animationValue = value;
      markNeedsPaint();
    }
  }

  Color _particleColor;
  Color get particleColor => _particleColor;
  set particleColor(Color value) {
    if (_particleColor != value) {
      _particleColor = value;
      markNeedsPaint();
    }
  }

  double _particleSize;
  double get particleSize => _particleSize;
  set particleSize(double value) {
    if (_particleSize != value) {
      _particleSize = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final progress = animationValue;
      final currentPosition = Offset(
        particle.initialPosition.dx + particle.velocity.dx * progress,
        particle.initialPosition.dy + particle.velocity.dy * progress,
      );

      // 计算粒子的生命周期和透明度
      final life = 1.0 - progress;
      final alpha = (life * 255).clamp(0, 255).toInt();
      
      paint.color = particle.color.withAlpha(alpha);
      
      // 绘制粒子
      canvas.drawCircle(
        offset + currentPosition,
        particleSize * life,
        paint,
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;
}

/// 3. 磁性吸附布局 - 子组件会被"磁性"吸引到特定位置
class MagneticLayout extends MultiChildRenderObjectWidget {
  const MagneticLayout({
    Key? key,
    required this.magneticPoints,
    required this.magneticStrength,
    required List<Widget> children,
  }) : super(key: key, children: children);

  final List<Offset> magneticPoints;
  final double magneticStrength;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMagneticLayout(
      magneticPoints: magneticPoints,
      magneticStrength: magneticStrength,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderMagneticLayout renderObject) {
    renderObject
      ..magneticPoints = magneticPoints
      ..magneticStrength = magneticStrength;
  }
}

class MagneticParentData extends ContainerBoxParentData<RenderBox> {
  Offset? targetPosition;
}

class RenderMagneticLayout extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, MagneticParentData>,
         RenderBoxContainerDefaultsMixin<RenderBox, MagneticParentData> {
  
  RenderMagneticLayout({
    required List<Offset> magneticPoints,
    required double magneticStrength,
  })  : _magneticPoints = magneticPoints,
        _magneticStrength = magneticStrength;

  List<Offset> _magneticPoints;
  List<Offset> get magneticPoints => _magneticPoints;
  set magneticPoints(List<Offset> value) {
    if (_magneticPoints != value) {
      _magneticPoints = value;
      markNeedsLayout();
    }
  }

  double _magneticStrength;
  double get magneticStrength => _magneticStrength;
  set magneticStrength(double value) {
    if (_magneticStrength != value) {
      _magneticStrength = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MagneticParentData) {
      child.parentData = MagneticParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    
    RenderBox? child = firstChild;
    int childIndex = 0;
    
    while (child != null) {
      final childParentData = child.parentData! as MagneticParentData;
      
      // 布局子组件
      child.layout(constraints.loosen(), parentUsesSize: true);
      
      // 计算磁性吸附位置
      if (childIndex < magneticPoints.length) {
        final magneticPoint = magneticPoints[childIndex];
        final distance = (magneticPoint - Offset(child.size.width / 2, child.size.height / 2)).distance;
        
        if (distance < magneticStrength) {
          // 在磁性范围内，吸附到磁性点
          childParentData.offset = Offset(
            magneticPoint.dx - child.size.width / 2,
            magneticPoint.dy - child.size.height / 2,
          );
        } else {
          // 超出磁性范围，使用原始位置
          childParentData.offset = Offset(
            childIndex * (size.width / (magneticPoints.length + 1)),
            size.height / 2 - child.size.height / 2,
          );
        }
      }
      
      child = childParentData.nextSibling;
      childIndex++;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // 绘制磁性点（调试用）
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    for (final point in magneticPoints) {
      context.canvas.drawCircle(offset + point, magneticStrength / 4, paint);
    }
    
    // 绘制子组件
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// 4. 3D翻转卡片效果 - 模拟3D翻转动画
class FlipCard3D extends SingleChildRenderObjectWidget {
  const FlipCard3D({
    Key? key,
    required this.flipProgress,
    required this.frontChild,
    required this.backChild,
    this.flipAxis = Axis.horizontal,
    Widget? child,
  }) : super(key: key, child: child);

  final double flipProgress; // 0.0 到 1.0
  final Widget frontChild;
  final Widget backChild;
  final Axis flipAxis;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlipCard3D(
      flipProgress: flipProgress,
      flipAxis: flipAxis,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlipCard3D renderObject) {
    renderObject
      ..flipProgress = flipProgress
      ..flipAxis = flipAxis;
  }
}

class RenderFlipCard3D extends RenderProxyBox {
  RenderFlipCard3D({
    required double flipProgress,
    required Axis flipAxis,
  })  : _flipProgress = flipProgress,
        _flipAxis = flipAxis;

  double _flipProgress;
  double get flipProgress => _flipProgress;
  set flipProgress(double value) {
    if (_flipProgress != value) {
      _flipProgress = value;
      markNeedsPaint();
    }
  }

  Axis _flipAxis;
  Axis get flipAxis => _flipAxis;
  set flipAxis(Axis value) {
    if (_flipAxis != value) {
      _flipAxis = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final canvas = context.canvas;
    final centerX = offset.dx + size.width / 2;
    final centerY = offset.dy + size.height / 2;

    canvas.save();

    // 移动到中心点
    canvas.translate(centerX, centerY);

    // 应用3D变换
    final angle = flipProgress * math.pi;
    
    if (flipAxis == Axis.horizontal) {
      // 水平翻转
      canvas.transform(Float64List.fromList([
        math.cos(angle), 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
      ]));
    } else {
      // 垂直翻转
      canvas.transform(Float64List.fromList([
        1, 0, 0, 0,
        0, math.cos(angle), 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
      ]));
    }

    // 移回原位置
    canvas.translate(-size.width / 2, -size.height / 2);

    // 根据翻转进度决定显示哪一面
    if (flipProgress < 0.5) {
      // 显示正面
      context.paintChild(child!, Offset.zero);
    } else {
      // 显示背面（需要镜像）
      canvas.scale(-1, 1);
      canvas.translate(-size.width, 0);
      context.paintChild(child!, Offset.zero);
    }

    canvas.restore();
  }
}

/// 5. 动态网格背景 - 可交互的动态网格背景效果
class DynamicGridBackground extends LeafRenderObjectWidget {
  const DynamicGridBackground({
    Key? key,
    required this.gridSize,
    required this.lineColor,
    required this.highlightColor,
    required this.animationValue,
    this.interactionPoint,
    this.interactionRadius = 100.0,
  }) : super(key: key);

  final double gridSize;
  final Color lineColor;
  final Color highlightColor;
  final double animationValue;
  final Offset? interactionPoint;
  final double interactionRadius;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderDynamicGridBackground(
      gridSize: gridSize,
      lineColor: lineColor,
      highlightColor: highlightColor,
      animationValue: animationValue,
      interactionPoint: interactionPoint,
      interactionRadius: interactionRadius,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderDynamicGridBackground renderObject) {
    renderObject
      ..gridSize = gridSize
      ..lineColor = lineColor
      ..highlightColor = highlightColor
      ..animationValue = animationValue
      ..interactionPoint = interactionPoint
      ..interactionRadius = interactionRadius;
  }
}

class RenderDynamicGridBackground extends RenderBox {
  RenderDynamicGridBackground({
    required double gridSize,
    required Color lineColor,
    required Color highlightColor,
    required double animationValue,
    Offset? interactionPoint,
    required double interactionRadius,
  })  : _gridSize = gridSize,
        _lineColor = lineColor,
        _highlightColor = highlightColor,
        _animationValue = animationValue,
        _interactionPoint = interactionPoint,
        _interactionRadius = interactionRadius;

  double _gridSize;
  double get gridSize => _gridSize;
  set gridSize(double value) {
    if (_gridSize != value) {
      _gridSize = value;
      markNeedsPaint();
    }
  }

  Color _lineColor;
  Color get lineColor => _lineColor;
  set lineColor(Color value) {
    if (_lineColor != value) {
      _lineColor = value;
      markNeedsPaint();
    }
  }

  Color _highlightColor;
  Color get highlightColor => _highlightColor;
  set highlightColor(Color value) {
    if (_highlightColor != value) {
      _highlightColor = value;
      markNeedsPaint();
    }
  }

  double _animationValue;
  double get animationValue => _animationValue;
  set animationValue(double value) {
    if (_animationValue != value) {
      _animationValue = value;
      markNeedsPaint();
    }
  }

  Offset? _interactionPoint;
  Offset? get interactionPoint => _interactionPoint;
  set interactionPoint(Offset? value) {
    if (_interactionPoint != value) {
      _interactionPoint = value;
      markNeedsPaint();
    }
  }

  double _interactionRadius;
  double get interactionRadius => _interactionRadius;
  set interactionRadius(double value) {
    if (_interactionRadius != value) {
      _interactionRadius = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final paint = Paint()..strokeWidth = 1.0;

    // 绘制基础网格
    paint.color = lineColor;
    
    // 垂直线
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(offset.dx + x, offset.dy),
        Offset(offset.dx + x, offset.dy + size.height),
        paint,
      );
    }
    
    // 水平线
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(offset.dx, offset.dy + y),
        Offset(offset.dx + size.width, offset.dy + y),
        paint,
      );
    }

    // 绘制交互效果
    if (interactionPoint != null) {
      paint.color = highlightColor;
      paint.strokeWidth = 2.0;
      
      final center = offset + interactionPoint!;
      final radius = interactionRadius * (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi));
      
      // 绘制高亮圆圈
      paint.style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius, paint);
      
      // 绘制辐射线
      for (int i = 0; i < 8; i++) {
        final angle = i * math.pi / 4 + animationValue * math.pi;
        final start = center + Offset(
          math.cos(angle) * radius * 0.8,
          math.sin(angle) * radius * 0.8,
        );
        final end = center + Offset(
          math.cos(angle) * radius * 1.2,
          math.sin(angle) * radius * 1.2,
        );
        canvas.drawLine(start, end, paint);
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;
}