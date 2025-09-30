import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// 自定义代理型RenderObject示例 - 类似于RenderVisibilityDetector
/// 这个示例展示如何创建一个透明的代理组件，监听子组件的状态变化

/// 1. 透明边界检测器 - 检测子组件是否超出边界
class BoundaryDetector extends SingleChildRenderObjectWidget {
  const BoundaryDetector({
    Key? key,
    required this.onBoundaryChanged,
    this.threshold = 0.1,
    Widget? child,
  }) : super(key: key, child: child);

  /// 边界变化回调
  final void Function(bool isWithinBounds, Rect childBounds, Rect parentBounds) onBoundaryChanged;

  /// 阈值：子组件超出父组件多少比例时触发回调
  final double threshold;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBoundaryDetector(
      onBoundaryChanged: onBoundaryChanged,
      threshold: threshold,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBoundaryDetector renderObject) {
    renderObject
      ..onBoundaryChanged = onBoundaryChanged
      ..threshold = threshold;
  }
}

class RenderBoundaryDetector extends RenderProxyBox {
  RenderBoundaryDetector({
    required void Function(bool, Rect, Rect) onBoundaryChanged,
    required double threshold,
    RenderBox? child,
  })  : _onBoundaryChanged = onBoundaryChanged,
        _threshold = threshold,
        super(child);

  void Function(bool, Rect, Rect) _onBoundaryChanged;

  void Function(bool, Rect, Rect) get onBoundaryChanged => _onBoundaryChanged;

  set onBoundaryChanged(void Function(bool, Rect, Rect) value) {
    if (_onBoundaryChanged != value) {
      _onBoundaryChanged = value;
      _scheduleCheck();
    }
  }

  double _threshold;

  double get threshold => _threshold;

  set threshold(double value) {
    if (_threshold != value) {
      _threshold = value;
      _scheduleCheck();
    }
  }

  bool _checkScheduled = false;
  bool? _lastWithinBounds;

  @override
  void performLayout() {
    super.performLayout();
    _scheduleCheck();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    _scheduleCheck();
  }

  void _scheduleCheck() {
    if (!_checkScheduled && attached) {
      _checkScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _checkScheduled = false;
        _checkBoundary();
      });
    }
  }

  void _checkBoundary() {
    if (!attached || child == null) return;

    final childBounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final parentBounds = _getParentBounds();

    if (parentBounds == null) return;

    // 计算子组件在父组件中的可见区域
    final intersection = childBounds.intersect(parentBounds);
    final visibleRatio =
        intersection.isEmpty ? 0.0 : (intersection.width * intersection.height) / (childBounds.width * childBounds.height);

    final isWithinBounds = visibleRatio >= (1.0 - _threshold);

    if (_lastWithinBounds != isWithinBounds) {
      _lastWithinBounds = isWithinBounds;
      _onBoundaryChanged(isWithinBounds, childBounds, parentBounds);
    }
  }

  Rect? _getParentBounds() {
    RenderObject? current = parent;
    while (current != null) {
      if (current is RenderBox && current.hasSize) {
        // 获取父组件的全局位置
        final transform = getTransformTo(current);
        final localBounds = Rect.fromLTWH(0, 0, size.width, size.height);
        return MatrixUtils.transformRect(transform, localBounds);
      }
      current = current.parent;
    }
    return null;
  }

  @override
  void dispose() {
    _checkScheduled = false;
    super.dispose();
  }
}

/// 2. 性能监控代理 - 监控子组件的绘制性能
class PerformanceMonitor extends SingleChildRenderObjectWidget {
  const PerformanceMonitor({
    Key? key,
    required this.onPerformanceUpdate,
    this.sampleSize = 10,
    Widget? child,
  }) : super(key: key, child: child);

  final void Function(double averageLayoutTime, double averagePaintTime) onPerformanceUpdate;
  final int sampleSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPerformanceMonitor(
      onPerformanceUpdate: onPerformanceUpdate,
      sampleSize: sampleSize,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPerformanceMonitor renderObject) {
    renderObject
      ..onPerformanceUpdate = onPerformanceUpdate
      ..sampleSize = sampleSize;
  }
}

class RenderPerformanceMonitor extends RenderProxyBox {
  RenderPerformanceMonitor({
    required void Function(double, double) onPerformanceUpdate,
    required int sampleSize,
    RenderBox? child,
  })  : _onPerformanceUpdate = onPerformanceUpdate,
        _sampleSize = sampleSize,
        super(child);

  void Function(double, double) _onPerformanceUpdate;

  void Function(double, double) get onPerformanceUpdate => _onPerformanceUpdate;

  set onPerformanceUpdate(void Function(double, double) value) {
    _onPerformanceUpdate = value;
  }

  int _sampleSize;

  int get sampleSize => _sampleSize;

  set sampleSize(int value) {
    if (_sampleSize != value) {
      _sampleSize = value;
      _layoutTimes.clear();
      _paintTimes.clear();
    }
  }

  final List<double> _layoutTimes = [];
  final List<double> _paintTimes = [];

  @override
  void performLayout() {
    final stopwatch = Stopwatch()..start();
    super.performLayout();
    stopwatch.stop();

    _addLayoutTime(stopwatch.elapsedMicroseconds / 1000.0); // 转换为毫秒
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final stopwatch = Stopwatch()..start();
    super.paint(context, offset);
    stopwatch.stop();

    _addPaintTime(stopwatch.elapsedMicroseconds / 1000.0); // 转换为毫秒
  }

  void _addLayoutTime(double time) {
    _layoutTimes.add(time);
    if (_layoutTimes.length > _sampleSize) {
      _layoutTimes.removeAt(0);
    }
    _updatePerformance();
  }

  void _addPaintTime(double time) {
    _paintTimes.add(time);
    if (_paintTimes.length > _sampleSize) {
      _paintTimes.removeAt(0);
    }
    _updatePerformance();
  }

  void _updatePerformance() {
    if (_layoutTimes.isNotEmpty && _paintTimes.isNotEmpty) {
      final avgLayout = _layoutTimes.reduce((a, b) => a + b) / _layoutTimes.length;
      final avgPaint = _paintTimes.reduce((a, b) => a + b) / _paintTimes.length;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _onPerformanceUpdate(avgLayout, avgPaint);
      });
    }
  }
}

/// 3. 变换监听器 - 监听子组件的变换矩阵变化
class TransformListener extends SingleChildRenderObjectWidget {
  const TransformListener({
    Key? key,
    required this.onTransformChanged,
    Widget? child,
  }) : super(key: key, child: child);

  final void Function(Matrix4 transform, Offset globalPosition) onTransformChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTransformListener(
      onTransformChanged: onTransformChanged,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTransformListener renderObject) {
    renderObject.onTransformChanged = onTransformChanged;
  }
}

class RenderTransformListener extends RenderProxyBox {
  RenderTransformListener({
    required void Function(Matrix4, Offset) onTransformChanged,
    RenderBox? child,
  })  : _onTransformChanged = onTransformChanged,
        super(child);

  void Function(Matrix4, Offset) _onTransformChanged;

  void Function(Matrix4, Offset) get onTransformChanged => _onTransformChanged;

  set onTransformChanged(void Function(Matrix4, Offset) value) {
    _onTransformChanged = value;
  }

  Matrix4? _lastTransform;
  Offset? _lastGlobalPosition;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    _checkTransform();
  }

  void _checkTransform() {
    if (!attached) return;

    try {
      // 获取到根节点的变换矩阵
      final transform = getTransformTo(null);
      final globalPosition = localToGlobal(Offset.zero);

      // 检查是否有变化
      bool hasChanged = false;
      if (_lastTransform == null || !_matricesEqual(_lastTransform!, transform)) {
        _lastTransform = Matrix4.copy(transform);
        hasChanged = true;
      }

      if (_lastGlobalPosition != globalPosition) {
        _lastGlobalPosition = globalPosition;
        hasChanged = true;
      }

      if (hasChanged) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _onTransformChanged(transform, globalPosition);
        });
      }
    } catch (e) {
      // 在某些情况下可能无法获取变换矩阵，忽略错误
    }
  }

  bool _matricesEqual(Matrix4 a, Matrix4 b) {
    for (int i = 0; i < 16; i++) {
      if ((a.storage[i] - b.storage[i]).abs() > 0.001) {
        return false;
      }
    }
    return true;
  }
}

/// 演示页面
class ProxyRenderObjectDemoPage extends StatefulWidget {
  const ProxyRenderObjectDemoPage({Key? key}) : super(key: key);

  @override
  State<ProxyRenderObjectDemoPage> createState() => _ProxyRenderObjectDemoPageState();
}

class _ProxyRenderObjectDemoPageState extends State<ProxyRenderObjectDemoPage> with TickerProviderStateMixin {
  String _boundaryStatus = '边界状态：未知';
  String _performanceInfo = '性能信息：收集中...';
  String _transformInfo = '变换信息：未知';

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('代理型 RenderObject 示例'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('状态信息', [
              _boundaryStatus,
              _performanceInfo,
              _transformInfo,
            ]),
            const SizedBox(height: 20),
            const Text(
              '1. 边界检测器',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: BoundaryDetector(
                threshold: 0.2,
                onBoundaryChanged: (isWithinBounds, childBounds, parentBounds) {
                  setState(() {
                    _boundaryStatus = '边界状态：${isWithinBounds ? "在边界内" : "超出边界"}';
                  });
                },
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_animation.value * 100, _animation.value * 50),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.red.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('移动的盒子', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '2. 性能监控器',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PerformanceMonitor(
              sampleSize: 5,
              onPerformanceUpdate: (avgLayout, avgPaint) {
                setState(() {
                  _performanceInfo = '性能信息：布局 ${avgLayout.toStringAsFixed(2)}ms, '
                      '绘制 ${avgPaint.toStringAsFixed(2)}ms';
                });
              },
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade300, Colors.blue.shade300],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ComplexShapePainter(_animation.value),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '3. 变换监听器',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TransformListener(
              onTransformChanged: (transform, globalPosition) {
                setState(() {
                  _transformInfo = '变换信息：位置 (${globalPosition.dx.toStringAsFixed(1)}, '
                      '${globalPosition.dy.toStringAsFixed(1)})';
                });
              },
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value * 2 * 3.14159,
                    child: Transform.scale(
                      scale: 0.5 + _animation.value * 0.5,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade300,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Center(
                          child: Text(
                            '旋转缩放',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildExplanationCard(),
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

  Widget _buildExplanationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '代理型 RenderObject 的特点',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• 继承自 RenderProxyBox，作为透明的中间层\n'
              '• 不改变子组件的布局和绘制行为\n'
              '• 在 performLayout 和 paint 方法中收集信息\n'
              '• 使用 SchedulerBinding 延迟执行回调\n'
              '• 类似于 RenderVisibilityDetector 的工作原理',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// 复杂形状绘制器，用于性能测试
class ComplexShapePainter extends CustomPainter {
  final double progress;

  ComplexShapePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 绘制复杂的动画图形
    for (int i = 0; i < 20; i++) {
      final radius = (i + 1) * 5.0 + progress * 20;
      final center = Offset(
        size.width / 2 + (i % 3 - 1) * progress * 30,
        size.height / 2 + (i % 2) * progress * 20,
      );
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(ComplexShapePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
