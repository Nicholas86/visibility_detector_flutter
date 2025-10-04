// 使用UniqueKey的有状态组件示例
// 演示UniqueKey在Flutter中的作用和使用场景

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// UniqueWidget演示页面
class UniqueWidgetDemoPage extends StatefulWidget {
  const UniqueWidgetDemoPage({Key? key}) : super(key: key);

  @override
  State<UniqueWidgetDemoPage> createState() => _UniqueWidgetDemoPageState();
}

class _UniqueWidgetDemoPageState extends State<UniqueWidgetDemoPage> {
  List<UniqueColorBox> _colorBoxes = [];
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _initializeColorBoxes();
  }

  void _initializeColorBoxes() {
    _colorBoxes = List.generate(5, (index) {
      return UniqueColorBox(
        key: UniqueKey(), // 使用UniqueKey确保每个组件的唯一性
        initialColor: _generateRandomColor(),
        title: '盒子 ${index + 1}',
      );
    });
  }

  Color _generateRandomColor() {
    final random = math.Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniqueKey组件演示'),
        backgroundColor: Colors.green.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTheorySection(),
            const SizedBox(height: 20),
            _buildControlSection(),
            const SizedBox(height: 20),
            _buildColorBoxesSection(),
            const SizedBox(height: 20),
            _buildUniqueKeyExplanation(),
          ],
        ),
      ),
    );
  }

  /// UniqueKey理论说明
  Widget _buildTheorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UniqueKey的作用和原理',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              '1. UniqueKey确保每个Widget实例的唯一性\n'
              '2. 防止Flutter在Widget树重建时错误地复用组件状态\n'
              '3. 在列表重排、动态添加删除组件时特别重要\n'
              '4. 每次调用UniqueKey()都会生成一个全新的唯一标识\n'
              '5. 适用于需要强制重建组件状态的场景',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// 控制按钮区域
  Widget _buildControlSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '操作控制',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _shuffleColorBoxes,
                  child: const Text('打乱顺序'),
                ),
                ElevatedButton(
                  onPressed: _addNewColorBox,
                  child: const Text('添加新盒子'),
                ),
                ElevatedButton(
                  onPressed: _removeLastColorBox,
                  child: const Text('删除最后一个'),
                ),
                ElevatedButton(
                  onPressed: _regenerateAllKeys,
                  child: const Text('重新生成所有Key'),
                ),
                ElevatedButton(
                  onPressed: _resetColorBoxes,
                  child: const Text('重置'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 彩色盒子展示区域
  Widget _buildColorBoxesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '彩色盒子列表 (${_colorBoxes.length}个)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (_colorBoxes.isEmpty)
              const Center(
                child: Text(
                  '没有彩色盒子',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colorBoxes,
              ),
          ],
        ),
      ),
    );
  }

  /// UniqueKey使用说明
  Widget _buildUniqueKeyExplanation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '实际应用场景',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              '• 动态列表项的重排和删除\n'
              '• 表单字段的动态添加和移除\n'
              '• 动画组件的状态管理\n'
              '• 避免组件状态混乱的场景\n'
              '• 强制触发组件重建的需求',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '注意：过度使用UniqueKey会导致不必要的组件重建，影响性能。'
                '只在确实需要强制重建组件状态时使用。',
                style: TextStyle(fontSize: 13, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 操作方法
  void _shuffleColorBoxes() {
    setState(() {
      _colorBoxes.shuffle();
    });
  }

  void _addNewColorBox() {
    setState(() {
      _counter++;
      _colorBoxes.add(
        UniqueColorBox(
          key: UniqueKey(),
          initialColor: _generateRandomColor(),
          title: '新盒子 $_counter',
        ),
      );
    });
  }

  void _removeLastColorBox() {
    if (_colorBoxes.isNotEmpty) {
      setState(() {
        _colorBoxes.removeLast();
      });
    }
  }

  void _regenerateAllKeys() {
    setState(() {
      _colorBoxes = _colorBoxes.map((box) {
        return UniqueColorBox(
          key: UniqueKey(), // 生成新的UniqueKey
          initialColor: box.currentColor,
          title: box.title,
        );
      }).toList();
    });
  }

  void _resetColorBoxes() {
    setState(() {
      _counter = 0;
      _initializeColorBoxes();
    });
  }
}

/// 使用UniqueKey的彩色盒子组件
class UniqueColorBox extends StatefulWidget {
  final Color initialColor;
  final String title;

  const UniqueColorBox({
    Key? key, // 接收UniqueKey
    required this.initialColor,
    required this.title,
  }) : super(key: key);

  // 获取当前颜色的getter（用于重新生成Key时保持颜色）
  Color get currentColor => _currentColor ?? initialColor;
  static Color? _currentColor;

  @override
  State<UniqueColorBox> createState() => _UniqueColorBoxState();
}

class _UniqueColorBoxState extends State<UniqueColorBox>
    with SingleTickerProviderStateMixin {
  late Color _color;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
    UniqueColorBox._currentColor = _color;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changeColor() {
    setState(() {
      _color = Color.fromARGB(
        255,
        math.Random().nextInt(256),
        math.Random().nextInt(256),
        math.Random().nextInt(256),
      );
      _tapCount++;
      UniqueColorBox._currentColor = _color;
    });
    
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _changeColor,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Key: ${widget.key.toString().substring(0, 20)}...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点击: $_tapCount次',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}