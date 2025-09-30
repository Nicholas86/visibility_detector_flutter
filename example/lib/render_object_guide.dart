import 'package:flutter/material.dart';

/// 自定义 RenderObject 实现完整指南
/// 
/// 本文件提供了实现自定义 RenderObject 的完整指南，包括：
/// 1. 基本概念和架构
/// 2. 实现步骤和最佳实践
/// 3. 常见问题和解决方案
/// 4. 性能优化技巧
/// 5. 测试和调试方法

class RenderObjectGuide extends StatelessWidget {
  const RenderObjectGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RenderObject 实现指南'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. 基本架构',
              '''
Flutter 渲染系统采用三层架构：

Widget 层：
• 描述 UI 的配置信息
• 不可变（immutable）
• 轻量级，可以频繁重建

Element 层：
• Widget 的实例化
• 管理 Widget 的生命周期
• 维护 Widget 树的结构

RenderObject 层：
• 实际的渲染和布局逻辑
• 处理绘制、事件、语义等
• 性能敏感的核心部分
''',
            ),
            
            _buildSection(
              '2. RenderObject 类型',
              '''
RenderBox：
• 适用于矩形区域的组件
• 实现 performLayout() 和 paint()
• 用于叶子节点或简单容器

RenderProxyBox：
• 继承自 RenderBox
• 透明代理，不改变子组件行为
• 适用于添加监听或装饰功能

RenderSliver：
• 适用于可滚动组件
• 处理滚动相关的布局逻辑
• 如 ListView、GridView 等

MultiChildRenderObject：
• 管理多个子组件
• 实现复杂的布局算法
• 如 Flex、Stack 等
''',
            ),
            
            _buildSection(
              '3. 实现步骤',
              '''
步骤 1：创建 Widget
class MyCustomWidget extends LeafRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) {
    return MyRenderObject();
  }
  
  @override
  void updateRenderObject(BuildContext context, MyRenderObject renderObject) {
    // 更新 RenderObject 的属性
  }
}

步骤 2：实现 RenderObject
class MyRenderObject extends RenderBox {
  @override
  void performLayout() {
    // 计算组件大小
    size = constraints.constrain(Size(100, 100));
  }
  
  @override
  void paint(PaintingContext context, Offset offset) {
    // 绘制组件
    final canvas = context.canvas;
    // ... 绘制逻辑
  }
}

步骤 3：处理约束
• 理解 BoxConstraints
• 正确设置 size
• 遵循约束传递规则

步骤 4：实现绘制
• 使用 Canvas API
• 注意坐标系转换
• 优化绘制性能
''',
            ),
            
            _buildSection(
              '4. 事件处理',
              '''
实现触摸事件：
@override
bool hitTestSelf(Offset position) => true;

@override
void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
  if (event is PointerDownEvent) {
    // 处理按下事件
  } else if (event is PointerMoveEvent) {
    // 处理移动事件
  } else if (event is PointerUpEvent) {
    // 处理抬起事件
  }
}

手势识别：
• 结合 GestureDetector
• 自定义手势识别器
• 处理手势冲突
''',
            ),
            
            _buildSection(
              '5. 动画集成',
              '''
与 AnimationController 集成：
class AnimatedRenderObject extends RenderBox {
  AnimatedRenderObject(this.animation) {
    animation.addListener(markNeedsPaint);
  }
  
  final Animation<double> animation;
  
  @override
  void paint(PaintingContext context, Offset offset) {
    // 使用 animation.value 进行绘制
  }
  
  @override
  void dispose() {
    animation.removeListener(markNeedsPaint);
    super.dispose();
  }
}

性能优化：
• 只在必要时调用 markNeedsPaint
• 使用 RepaintBoundary 隔离重绘
• 避免在动画中创建新对象
''',
            ),
            
            _buildSection(
              '6. 性能优化',
              '''
布局优化：
• 缓存计算结果
• 避免不必要的重新布局
• 使用 relayoutBoundary

绘制优化：
• 批量绘制相似元素
• 使用 Canvas.clipRect 减少绘制区域
• 预计算复杂路径

内存优化：
• 及时清理监听器
• 使用对象池
• 避免内存泄漏
''',
            ),
            
            _buildSection(
              '7. 调试技巧',
              '''
调试工具：
• Flutter Inspector
• debugPaintSizeEnabled
• debugRepaintRainbowEnabled

常用调试方法：
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  super.debugFillProperties(properties);
  properties.add(DoubleProperty('value', value));
}

性能分析：
• Timeline 工具
• 测量 performLayout 和 paint 耗时
• 监控内存使用
''',
            ),
            
            _buildSection(
              '8. 最佳实践',
              '''
设计原则：
• 单一职责：每个 RenderObject 只做一件事
• 最小化状态：减少可变状态
• 遵循约束：正确处理布局约束

代码规范：
• 及时调用 markNeedsLayout/markNeedsPaint
• 正确实现 dispose 方法
• 添加适当的断言检查

测试策略：
• 单元测试布局逻辑
• 集成测试交互行为
• 性能测试关键路径
''',
            ),
            
            _buildSection(
              '9. 常见问题',
              '''
问题 1：布局约束错误
解决：理解 BoxConstraints 的工作原理，确保 size 符合约束

问题 2：绘制坐标错误
解决：注意 offset 参数，正确处理坐标变换

问题 3：事件处理不生效
解决：检查 hitTestSelf 返回值，确保组件可以接收事件

问题 4：动画性能问题
解决：优化绘制逻辑，使用 RepaintBoundary

问题 5：内存泄漏
解决：及时清理监听器，正确实现 dispose
''',
            ),
            
            _buildSection(
              '10. 进阶主题',
              '''
自定义布局算法：
• 实现 MultiChildRenderObject
• 处理 ParentData
• 优化布局性能

Layer 系统：
• 理解 Layer 的作用
• 自定义 Layer 类型
• 优化合成性能

可访问性支持：
• 实现 SemanticsNode
• 添加语义信息
• 支持屏幕阅读器

平台集成：
• 与原生代码交互
• 处理平台特定逻辑
• 优化不同平台的表现
''',
            ),
            
            const SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '总结',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '实现自定义 RenderObject 需要深入理解 Flutter 的渲染机制。'
                      '从简单的绘制开始，逐步掌握布局、事件处理和性能优化。'
                      '通过实践和调试，你将能够创建高性能的自定义组件。',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('返回示例'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content.trim(),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 测试用例示例
class RenderObjectTestExamples {
  /// 测试自定义进度条的布局
  static void testCustomProgressBarLayout() {
    // 这里展示如何为自定义 RenderObject 编写测试
    /*
    testWidgets('CustomProgressBar layout test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomProgressBar(
              progress: 0.5,
              barHeight: 20,
            ),
          ),
        ),
      );
      
      final progressBarFinder = find.byType(CustomProgressBar);
      expect(progressBarFinder, findsOneWidget);
      
      final RenderBox renderBox = tester.renderObject(progressBarFinder);
      expect(renderBox.size.height, equals(20));
    });
    */
  }
  
  /// 测试事件处理
  static void testInteractiveCanvasEvents() {
    /*
    testWidgets('InteractiveCanvas touch test', (WidgetTester tester) async {
      List<Offset> capturedPoints = [];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveCanvas(
              onDrawingChanged: (points) {
                capturedPoints = points;
              },
            ),
          ),
        ),
      );
      
      // 模拟触摸事件
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();
      
      expect(capturedPoints.isNotEmpty, isTrue);
    });
    */
  }
  
  /// 性能测试示例
  static void testParticleSystemPerformance() {
    /*
    testWidgets('ParticleSystem performance test', (WidgetTester tester) async {
      final animationController = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParticleSystem(
              particleCount: 100,
              animationController: animationController,
            ),
          ),
        ),
      );
      
      // 测量渲染时间
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 60; i++) {
        animationController.value = i / 60.0;
        await tester.pump();
      }
      
      stopwatch.stop();
      
      // 确保渲染时间在合理范围内
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      animationController.dispose();
    });
    */
  }
}

/// 使用示例和最佳实践
class RenderObjectUsageExamples {
  /// 示例 1：创建简单的自定义组件
  static Widget createSimpleCustomWidget() {
    return Container(
      width: 200,
      height: 100,
      child: const SimpleCustomProgressBar(
        progress: 0.7,
        barHeight: 20,
      ),
    );
  }
  
  /// 示例 2：结合动画使用
  static Widget createAnimatedCustomWidget(AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SimpleCustomProgressBar(
          progress: controller.value,
          barHeight: 20,
        );
      },
    );
  }
  
  /// 示例 3：处理用户交互
  static Widget createInteractiveWidget() {
    return InteractiveCanvas(
      onDrawingChanged: (points) {
        print('绘制了 ${points.length} 个点');
      },
    );
  }
  
  /// 示例 4：性能优化的复杂组件
  static Widget createOptimizedWidget(AnimationController controller) {
    return RepaintBoundary(
      child: ParticleSystem(
        particleCount: 50,
        animationController: controller,
        particleColor: Colors.blue,
      ),
    );
  }
}

// 为了编译通过，这里添加必要的类声明
class SimpleCustomProgressBar extends StatelessWidget {
  const SimpleCustomProgressBar({
    Key? key,
    required this.progress,
    required this.barHeight,
  }) : super(key: key);
  
  final double progress;
  final double barHeight;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(barHeight / 2),
      ),
      child: FractionallySizedBox(
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(barHeight / 2),
          ),
        ),
      ),
    );
  }
}

class InteractiveCanvas extends StatelessWidget {
  const InteractiveCanvas({
    Key? key,
    required this.onDrawingChanged,
  }) : super(key: key);
  
  final void Function(List<Offset> points) onDrawingChanged;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      color: Colors.grey.shade100,
      child: const Center(
        child: Text('交互式画布占位符'),
      ),
    );
  }
}

class ParticleSystem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      color: Colors.black12,
      child: Center(
        child: Text('粒子系统占位符\n粒子数量: $particleCount'),
      ),
    );
  }
}