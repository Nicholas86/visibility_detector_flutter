import 'package:flutter/material.dart';
import 'custom_render_examples.dart';
import 'proxy_render_example.dart';
import 'advanced_render_example.dart';
import 'render_object_guide.dart';

class CustomRenderObjectDemoPage extends StatelessWidget {
  const CustomRenderObjectDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义 RenderObject 示例'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDemoCard(
            context,
            title: '基础 RenderObject 示例',
            description: '学习如何创建简单的自定义渲染对象',
            icon: Icons.widgets,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BasicRenderObjectDemoPage(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildDemoCard(
            context,
            title: '代理型 RenderObject 示例',
            description: '学习如何创建类似 RenderVisibilityDetector 的代理组件',
            icon: Icons.layers,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProxyRenderObjectDemoPage(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildDemoCard(
            context,
            title: '高级 RenderObject 示例',
            description: '展示动画、事件处理和性能优化技术',
            icon: Icons.auto_awesome,
            color: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedRenderObjectDemoPage(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // 完整指南
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '完整实现指南',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '查看详细的 RenderObject 实现指南，包括理论基础、实践步骤、最佳实践和常见问题解决方案。',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RenderObjectGuide(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.book),
                    label: const Text('查看完整指南'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '学习路径',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '1. 基础示例：了解 RenderObject 的基本概念和实现方式\n'
                    '2. 代理示例：学习如何创建透明的代理组件\n'
                    '3. 高级示例：掌握动画、事件和性能优化技术\n'
                    '4. 完整指南：深入理解实现原理和最佳实践\n'
                    '5. 对比分析：理解不同类型 RenderObject 的应用场景',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RenderObject 类型对比',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• RenderBox：适用于需要自定义绘制的叶子节点\n'
                    '• RenderProxyBox：适用于需要监听或修改子组件行为的代理节点\n'
                    '• RenderSliver：适用于可滚动组件中的自定义渲染\n'
                    '• MultiChildRenderObject：适用于需要管理多个子组件的复杂布局',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                   icon,
                   size: 32,
                   color: color,
                 ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BasicRenderObjectDemoPage extends StatefulWidget {
  const BasicRenderObjectDemoPage({Key? key}) : super(key: key);

  @override
  State<BasicRenderObjectDemoPage> createState() => _BasicRenderObjectDemoPageState();
}

class _BasicRenderObjectDemoPageState extends State<BasicRenderObjectDemoPage> {
  double _progressValue = 0.5;
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基础 RenderObject 示例'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. 自定义进度条 (CustomProgressBar)'),
            _buildProgressBarDemo(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('2. 脉冲动画圆圈 (PulsingCircle)'),
            _buildPulsingCircleDemo(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('3. 自定义边框装饰器 (CustomBorderDecorator)'),
            _buildBorderDecoratorDemo(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('4. 可拖拽组件 (DraggableBox)'),
            _buildDraggableBoxDemo(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('5. ShrinkWrap 示例'),
            _buildShrinkWrapDemo(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('6. 限制行数的Wrap组件 (LimitedWrap)'),
            _buildLimitedWrapDemo(),
            
            const SizedBox(height: 32),
            _buildImplementationNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildProgressBarDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '这是一个完全自定义绘制的进度条组件，展示了如何：\n'
          '• 继承 LeafRenderObjectWidget 和 RenderBox\n'
          '• 实现自定义布局算法 (performLayout)\n'
          '• 实现自定义绘制逻辑 (paint)\n'
          '• 处理属性变化和重绘标记',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        
        // 进度条示例
        CustomProgressBar(
          progress: _progressValue,
          backgroundColor: Colors.grey.shade300,
          progressColor: Colors.blue,
          height: 12.0,
        ),
        const SizedBox(height: 8),
        
        // 控制滑块
        Slider(
          value: _progressValue,
          onChanged: (value) {
            setState(() {
              _progressValue = value;
            });
          },
          label: '${(_progressValue * 100).toInt()}%',
        ),
        
        // 不同样式的进度条
        const SizedBox(height: 16),
        const Text('不同样式：', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        
        CustomProgressBar(
          progress: 0.3,
          backgroundColor: Colors.red.shade100,
          progressColor: Colors.red,
          height: 6.0,
        ),
        const SizedBox(height: 8),
        
        CustomProgressBar(
          progress: 0.7,
          backgroundColor: Colors.green.shade100,
          progressColor: Colors.green,
          height: 20.0,
        ),
      ],
    );
  }

  Widget _buildPulsingCircleDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '这个组件展示了如何在自定义组件中集成动画：\n'
          '• 使用 StatefulWidget + CustomPainter 的方式\n'
          '• 集成 AnimationController 和 Animation\n'
          '• 在绘制中应用动画值\n'
          '• 处理动画生命周期',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const PulsingCircle(
                  color: Colors.blue,
                  circleSize: 60,
                  animationDuration: Duration(milliseconds: 800),
                ),
                const SizedBox(height: 8),
                const Text('蓝色脉冲', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: [
                const PulsingCircle(
                  color: Colors.red,
                  circleSize: 80,
                  animationDuration: Duration(milliseconds: 1200),
                ),
                const SizedBox(height: 8),
                const Text('红色脉冲', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: [
                const PulsingCircle(
                  color: Colors.green,
                  circleSize: 50,
                  animationDuration: Duration(milliseconds: 600),
                ),
                const SizedBox(height: 8),
                const Text('绿色脉冲', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBorderDecoratorDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '这个组件展示了代理型 RenderObject 的实现：\n'
          '• 继承 SingleChildRenderObjectWidget 和 RenderProxyBox\n'
          '• 先绘制子组件，再添加装饰效果\n'
          '• 实现虚线绘制算法\n'
          '• 不影响子组件的布局',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: CustomBorderDecorator(
                borderColor: Colors.blue,
                borderWidth: 2.0,
                cornerRadius: 8.0,
                child: Container(
                  height: 80,
                  color: Colors.blue.shade50,
                  child: const Center(
                    child: Text('实线边框'),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomBorderDecorator(
                borderColor: Colors.red,
                borderWidth: 3.0,
                cornerRadius: 12.0,
                dashPattern: const [8, 4],
                child: Container(
                  height: 80,
                  color: Colors.red.shade50,
                  child: const Center(
                    child: Text('虚线边框'),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        CustomBorderDecorator(
          borderColor: Colors.purple,
          borderWidth: 4.0,
          cornerRadius: 16.0,
          dashPattern: const [12, 6, 4, 6],
          child: Container(
            height: 60,
            color: Colors.purple.shade50,
            child: const Center(
              child: Text('复杂虚线模式'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableBoxDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '这个组件展示了如何在 RenderObject 中处理触摸事件：\n'
          '• 重写 hitTestSelf 方法来接收事件\n'
          '• 重写 handleEvent 方法来处理指针事件\n'
          '• 区分不同类型的指针事件\n'
          '• 计算拖拽偏移量并回调',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        
        Text('拖拽偏移量: ${_dragOffset.dx.toStringAsFixed(1)}, ${_dragOffset.dy.toStringAsFixed(1)}'),
        const SizedBox(height: 8),
        
        Center(
          child: DraggableBox(
            onDrag: (delta) {
              setState(() {
                _dragOffset += delta;
              });
            },
            child: Transform.translate(
              offset: _dragOffset,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '拖拽我！',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _dragOffset = Offset.zero;
              });
            },
            child: const Text('重置位置'),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitedWrapDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '这个组件展示了如何实现一个可以限制显示行数的Wrap组件：\n'
          '• 继承 MultiChildRenderObjectWidget 管理多个子组件\n'
          '• 使用 ContainerBoxParentData 存储子组件布局信息\n'
          '• 在 performLayout 中实现换行逻辑和行数限制\n'
          '• 通过回调函数返回布局结果信息',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        
        // 简单的LimitedWrap示例
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('限制2行显示：', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              LimitedWrap(
                maxLine: 2,
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  '标签1', '标签2', '标签3', '标签4', '标签5',
                  '标签6', '标签7', '标签8', '标签9', '标签10'
                ].map((text) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(text, style: TextStyle(fontSize: 12)),
                )).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 完整示例按钮
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LimitedWrapExample(),
                ),
              );
            },
            icon: const Icon(Icons.launch),
            label: const Text('查看完整示例'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShrinkWrapDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ShrinkWrap 可展开收缩的流式布局',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '基于文章实现的可展开收缩的Wrap组件，支持maxLines参数限制显示行数，'
          '并提供总行数回调，类似美团外卖店铺标签的展示效果。',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('基本示例（限制1行）：', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ShrinkWrap(
                maxLines: 1,
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  '满减优惠', '新用户立减', '免配送费', '品质保证', '快速配送',
                  '24小时营业', '支持自取', '会员专享'
                ].map((text) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 完整示例按钮
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShrinkWrapExample(),
                ),
              );
            },
            icon: const Icon(Icons.launch),
            label: const Text('查看完整示例'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImplementationNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '实现要点总结',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. RenderObject 类型选择：\n'
              '   • LeafRenderObjectWidget + RenderBox：叶子节点，无子组件\n'
              '   • SingleChildRenderObjectWidget + RenderProxyBox：代理节点，有一个子组件\n'
              '   • MultiChildRenderObjectWidget + RenderBox：多子组件节点\n\n'
              
              '2. 核心方法实现：\n'
              '   • performLayout()：实现布局算法\n'
              '   • paint()：实现绘制逻辑\n'
              '   • hitTestSelf()：是否接收触摸事件\n'
              '   • handleEvent()：处理触摸事件\n\n'
              
              '3. 性能优化：\n'
              '   • 使用 markNeedsPaint() 标记重绘\n'
              '   • 使用 markNeedsLayout() 标记重布局\n'
              '   • 在属性 setter 中进行变化检测\n'
              '   • 合理使用 sizedByParent 属性\n\n'
              
              '4. 与 VisibilityDetector 的对比：\n'
              '   • VisibilityDetector 是透明代理，不改变布局和绘制\n'
              '   • 它在 paint 阶段收集变换信息，延迟到合成阶段计算可见性\n'
              '   • 这种设计避免了对现有 UI 结构的影响',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}