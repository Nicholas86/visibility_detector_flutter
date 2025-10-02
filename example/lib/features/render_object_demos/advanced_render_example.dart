import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// 高级自定义RenderObject示例
/// 展示动画、事件处理和性能优化技术

/// 1. 高性能粒子系统 - 展示性能优化技术
class ParticleSystem extends LeafRenderObjectWidget {
  const ParticleSystem({
    Key? key,
    required this.particleCount,
    required this.animationController,
    this.particleColor = Colors.blue,
  }) : super(key: key);

  final int particleCount;
  final AnimationController animationController;
  final Color particleColor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParticleSystem(
      particleCount: particleCount,
      animationController: animationController,
      particleColor: particleColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderParticleSystem renderObject) {
    renderObject
      ..particleCount = particleCount
      ..particleColor = particleColor;
  }
}

class RenderParticleSystem extends RenderBox {
  RenderParticleSystem({
    required int particleCount,
    required AnimationController animationController,
    required Color particleColor,
  }) : _particleCount = particleCount,
       _animationController = animationController,
       _particleColor = particleColor {
    _initializeParticles();
    _animationController.addListener(_onAnimationUpdate);
  }

  int _particleCount;
  int get particleCount => _particleCount;
  set particleCount(int value) {
    if (_particleCount != value) {
      _particleCount = value;
      _initializeParticles();
      markNeedsPaint();
    }
  }

  final AnimationController _animationController;
  
  Color _particleColor;
  Color get particleColor => _particleColor;
  set particleColor(Color value) {
    if (_particleColor != value) {
      _particleColor = value;
      markNeedsPaint();
    }
  }

  List<Particle> _particles = [];
  final math.Random _random = math.Random();

  void _initializeParticles() {
    _particles = List.generate(_particleCount, (index) => Particle(
      position: Offset(_random.nextDouble() * 300, _random.nextDouble() * 300),
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 100,
        (_random.nextDouble() - 0.5) * 100,
      ),
      size: _random.nextDouble() * 4 + 1,
      life: _random.nextDouble(),
    ));
  }

  void _onAnimationUpdate() {
    final dt = 1.0 / 60.0; // 假设60fps
    
    // 更新粒子状态
    for (final particle in _particles) {
      particle.update(dt, size);
    }
    
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(300, 300));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = _particleColor
      ..style = PaintingStyle.fill;

    // 性能优化：批量绘制相同大小的粒子
    final particlesBySize = <double, List<Particle>>{};
    for (final particle in _particles) {
      particlesBySize.putIfAbsent(particle.size, () => []).add(particle);
    }

    // 为每个大小批量绘制
    for (final entry in particlesBySize.entries) {
      final size = entry.key;
      final particles = entry.value;
      
      for (final particle in particles) {
        paint.color = _particleColor.withOpacity(particle.life);
        canvas.drawCircle(
          offset + particle.position,
          size,
          paint,
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationUpdate);
    super.dispose();
  }
}

class Particle {
  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.life,
  });

  Offset position;
  Offset velocity;
  final double size;
  double life;

  void update(double dt, Size bounds) {
    // 更新位置
    position += velocity * dt;
    
    // 边界反弹
    if (position.dx < 0 || position.dx > bounds.width) {
      velocity = Offset(-velocity.dx, velocity.dy);
      position = Offset(
        position.dx.clamp(0, bounds.width),
        position.dy,
      );
    }
    
    if (position.dy < 0 || position.dy > bounds.height) {
      velocity = Offset(velocity.dx, -velocity.dy);
      position = Offset(
        position.dx,
        position.dy.clamp(0, bounds.height),
      );
    }
    
    // 生命周期衰减
    life = (life - dt * 0.5).clamp(0.0, 1.0);
    
    // 重生粒子
    if (life <= 0) {
      final random = math.Random();
      position = Offset(
        random.nextDouble() * bounds.width,
        random.nextDouble() * bounds.height,
      );
      velocity = Offset(
        (random.nextDouble() - 0.5) * 100,
        (random.nextDouble() - 0.5) * 100,
      );
      life = 1.0;
    }
  }
}

/// 2. 交互式画布 - 展示复杂事件处理
class InteractiveCanvas extends LeafRenderObjectWidget {
  const InteractiveCanvas({
    Key? key,
    required this.onDrawingChanged,
  }) : super(key: key);

  final void Function(List<Offset> points) onDrawingChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderInteractiveCanvas(
      onDrawingChanged: onDrawingChanged,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderInteractiveCanvas renderObject) {
    renderObject.onDrawingChanged = onDrawingChanged;
  }
}

class RenderInteractiveCanvas extends RenderBox {
  RenderInteractiveCanvas({
    required void Function(List<Offset>) onDrawingChanged,
  }) : _onDrawingChanged = onDrawingChanged;

  void Function(List<Offset>) _onDrawingChanged;
  void Function(List<Offset>) get onDrawingChanged => _onDrawingChanged;
  set onDrawingChanged(void Function(List<Offset>) value) {
    _onDrawingChanged = value;
  }

  final List<Offset> _points = [];
  bool _isDrawing = false;

  @override
  void performLayout() {
    size = constraints.constrain(const Size(300, 200));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    
    // 绘制背景
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.fill;
    canvas.drawRect(offset & size, backgroundPaint);
    
    // 绘制边框
    final borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(offset & size, borderPaint);
    
    // 绘制路径
    if (_points.isNotEmpty) {
      final path = Path();
      path.moveTo(offset.dx + _points.first.dx, offset.dy + _points.first.dy);
      
      for (int i = 1; i < _points.length; i++) {
        path.lineTo(offset.dx + _points[i].dx, offset.dy + _points[i].dy);
      }
      
      final pathPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      
      canvas.drawPath(path, pathPaint);
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _isDrawing = true;
      _points.clear();
      _addPoint(event.localPosition);
    } else if (event is PointerMoveEvent && _isDrawing) {
      _addPoint(event.localPosition);
    } else if (event is PointerUpEvent) {
      _isDrawing = false;
      _onDrawingChanged(List.from(_points));
    }
  }

  void _addPoint(Offset point) {
    // 确保点在画布范围内
    final clampedPoint = Offset(
      point.dx.clamp(0, size.width),
      point.dy.clamp(0, size.height),
    );
    
    _points.add(clampedPoint);
    markNeedsPaint();
  }

  void clearCanvas() {
    _points.clear();
    markNeedsPaint();
    _onDrawingChanged([]);
  }
}

/// 3. 自适应网格布局 - 展示复杂布局算法
class AdaptiveGrid extends MultiChildRenderObjectWidget {
  const AdaptiveGrid({
    Key? key,
    required this.itemAspectRatio,
    required this.minItemWidth,
    required List<Widget> children,
  }) : super(key: key, children: children);

  final double itemAspectRatio;
  final double minItemWidth;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAdaptiveGrid(
      itemAspectRatio: itemAspectRatio,
      minItemWidth: minItemWidth,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAdaptiveGrid renderObject) {
    renderObject
      ..itemAspectRatio = itemAspectRatio
      ..minItemWidth = minItemWidth;
  }
}

class RenderAdaptiveGrid extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, GridParentData>,
         RenderBoxContainerDefaultsMixin<RenderBox, GridParentData> {
  
  RenderAdaptiveGrid({
    required double itemAspectRatio,
    required double minItemWidth,
  }) : _itemAspectRatio = itemAspectRatio,
       _minItemWidth = minItemWidth;

  double _itemAspectRatio;
  double get itemAspectRatio => _itemAspectRatio;
  set itemAspectRatio(double value) {
    if (_itemAspectRatio != value) {
      _itemAspectRatio = value;
      markNeedsLayout();
    }
  }

  double _minItemWidth;
  double get minItemWidth => _minItemWidth;
  set minItemWidth(double value) {
    if (_minItemWidth != value) {
      _minItemWidth = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! GridParentData) {
      child.parentData = GridParentData();
    }
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.constrain(Size.zero);
      return;
    }

    // 计算网格参数
    final availableWidth = constraints.maxWidth;
    final columnsCount = math.max(1, (availableWidth / _minItemWidth).floor());
    final itemWidth = availableWidth / columnsCount;
    final itemHeight = itemWidth / _itemAspectRatio;
    
    final rowsCount = (childCount / columnsCount).ceil();
    final totalHeight = rowsCount * itemHeight;

    size = constraints.constrain(Size(availableWidth, totalHeight));

    // 布局子组件
    RenderBox? child = firstChild;
    int index = 0;
    
    while (child != null) {
      final parentData = child.parentData as GridParentData;
      
      final row = index ~/ columnsCount;
      final col = index % columnsCount;
      
      final childConstraints = BoxConstraints.tight(Size(itemWidth, itemHeight));
      child.layout(childConstraints);
      
      parentData.offset = Offset(col * itemWidth, row * itemHeight);
      
      child = parentData.nextSibling;
      index++;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class GridParentData extends ContainerBoxParentData<RenderBox> {}

/// 演示页面
class AdvancedRenderObjectDemoPage extends StatefulWidget {
  const AdvancedRenderObjectDemoPage({Key? key}) : super(key: key);

  @override
  State<AdvancedRenderObjectDemoPage> createState() => _AdvancedRenderObjectDemoPageState();
}

class _AdvancedRenderObjectDemoPageState extends State<AdvancedRenderObjectDemoPage>
    with TickerProviderStateMixin {
  
  late AnimationController _particleController;
  final GlobalKey<_InteractiveCanvasWidgetState> _canvasKey = GlobalKey();
  
  int _particleCount = 50;
  String _drawingInfo = '绘制信息：等待绘制...';

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _particleController.repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高级 RenderObject 示例'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('实时信息', [
              '粒子数量：$_particleCount',
              _drawingInfo,
            ]),
            
            const SizedBox(height: 20),
            
            const Text(
              '1. 高性能粒子系统',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ParticleSystem(
                      particleCount: _particleCount,
                      animationController: _particleController,
                      particleColor: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('粒子数量：'),
                        Expanded(
                          child: Slider(
                            value: _particleCount.toDouble(),
                            min: 10,
                            max: 200,
                            divisions: 19,
                            onChanged: (value) {
                              setState(() {
                                _particleCount = value.round();
                              });
                            },
                          ),
                        ),
                        Text('$_particleCount'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              '2. 交互式画布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _InteractiveCanvasWidget(
              key: _canvasKey,
              onDrawingChanged: (points) {
                setState(() {
                  _drawingInfo = '绘制信息：${points.length} 个点';
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              '3. 自适应网格布局',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AdaptiveGrid(
                  itemAspectRatio: 1.0,
                  minItemWidth: 80,
                  children: List.generate(12, (index) => Container(
                    decoration: BoxDecoration(
                      color: Colors.primaries[index % Colors.primaries.length].shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildTechniquesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...info.map((text) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(text, style: const TextStyle(fontSize: 14)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTechniquesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '高级技术要点',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• 性能优化：批量绘制、对象池、避免频繁分配\n'
              '• 事件处理：hitTestSelf、handleEvent、复杂手势\n'
              '• 动画集成：AnimationController、自定义插值\n'
              '• 布局算法：多子组件布局、约束传递、ParentData\n'
              '• 内存管理：及时清理监听器、避免内存泄漏',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _canvasKey.currentState?.clearCanvas();
                    },
                    child: const Text('清除画布'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _particleCount = 50;
                      });
                    },
                    child: const Text('重置粒子'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 交互式画布包装器
class _InteractiveCanvasWidget extends StatefulWidget {
  const _InteractiveCanvasWidget({
    Key? key,
    required this.onDrawingChanged,
  }) : super(key: key);

  final void Function(List<Offset> points) onDrawingChanged;

  @override
  State<_InteractiveCanvasWidget> createState() => _InteractiveCanvasWidgetState();
}

class _InteractiveCanvasWidgetState extends State<_InteractiveCanvasWidget> {
  final GlobalKey _canvasKey = GlobalKey();

  void clearCanvas() {
    final renderObject = _canvasKey.currentContext?.findRenderObject() as RenderInteractiveCanvas?;
    renderObject?.clearCanvas();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InteractiveCanvas(
              key: _canvasKey,
              onDrawingChanged: widget.onDrawingChanged,
            ),
            const SizedBox(height: 8),
            const Text(
              '在上方区域绘制，支持触摸和鼠标操作',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}