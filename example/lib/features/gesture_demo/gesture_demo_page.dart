// 手势演示主页面
// 整合所有手势相关的示例和探索内容

import 'package:flutter/material.dart';
import 'gesture_source_exploration.dart';
import 'pointer_signal_resolver_demo.dart';

/// 手势演示主页面
class GestureDemoPage extends StatefulWidget {
  const GestureDemoPage({Key? key}) : super(key: key);

  @override
  State<GestureDemoPage> createState() => _GestureDemoPageState();
}

class _GestureDemoPageState extends State<GestureDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter手势系统演示'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroductionSection(),
            const SizedBox(height: 20),
            _buildDemoList(),
          ],
        ),
      ),
    );
  }

  /// 介绍部分
  Widget _buildIntroductionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flutter手势系统全面探索',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Flutter的手势系统是一个复杂而强大的输入处理框架，'
              '它能够识别和处理各种用户交互，包括触摸、鼠标、键盘等输入。'
              '本演示将带您深入了解Flutter手势系统的核心机制和实际应用。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 提示：每个演示都包含详细的源码分析和实际应用场景，'
                '帮助您更好地理解Flutter手势系统的工作原理。',
                style: TextStyle(fontSize: 13, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 演示列表
  Widget _buildDemoList() {
    final demos = [
      DemoItem(
        title: 'Flutter手势源码探索',
        description: '深入探索Flutter手势系统的核心机制，包括GestureBinding、'
            'GestureArena、GestureRecognizer等核心组件的工作原理',
        icon: Icons.explore,
        color: Colors.blue,
        onTap: () => _navigateToDemo(const GestureSourceExplorationPage()),
      ),
      DemoItem(
        title: 'PointerSignalResolver演示',
        description: '展示PointerSignalResolver的使用方法，'
            '解决多个组件竞争指针信号的冲突问题',
        icon: Icons.touch_app,
        color: Colors.orange,
        onTap: () => _navigateToDemo(const PointerSignalResolverExampleApp()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '演示列表',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...demos.map((demo) => _buildDemoCard(demo)).toList(),
      ],
    );
  }

  /// 构建演示卡片
  Widget _buildDemoCard(DemoItem demo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: demo.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: demo.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  demo.icon,
                  color: demo.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      demo.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      demo.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 导航到演示页面
  void _navigateToDemo(Widget demoPage) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => demoPage),
    );
  }
}

/// 演示项目数据类
class DemoItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DemoItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}