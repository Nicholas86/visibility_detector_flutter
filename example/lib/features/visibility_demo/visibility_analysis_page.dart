import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// 用于分析VisibilityDetector的页面
class VisibilityAnalysisPage extends StatefulWidget {
  const VisibilityAnalysisPage({Key? key}) : super(key: key);

  @override
  State<VisibilityAnalysisPage> createState() => _VisibilityAnalysisPageState();
}

class _VisibilityAnalysisPageState extends State<VisibilityAnalysisPage> {
  String _visibilityInfo = '等待检测可见性...';
  double _visibleFraction = 0.0;
  bool _isVisible = false;

  void _onVisibilityChanged(VisibilityInfo info) {
    print('---✅视图可见性info: ${info.visibleFraction}✅---');
    if (!mounted) return;
    setState(() {
      _visibleFraction = info.visibleFraction;
      _isVisible = info.visibleFraction > 0;
      _visibilityInfo = '''
可见性信息:
- 可见比例: ${(info.visibleFraction * 100).toStringAsFixed(1)}%
- 是否可见: ${_isVisible ? '是' : '否'}
- 组件大小: ${info.size}
- 可见区域: ${info.visibleBounds}
      ''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VisibilityDetector 分析'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明文本
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VisibilityDetector 原理分析',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'VisibilityDetector 是一个用于检测 Widget 可见性的组件。'
                      '它通过监听滚动事件和布局变化来计算组件在屏幕中的可见比例。'
                      '下面的红色容器被 VisibilityDetector 包裹，滚动页面观察可见性变化。',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 可见性信息显示
            Card(
              color: _isVisible ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '实时可见性数据',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_visibilityInfo),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _visibleFraction,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isVisible ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 一些占位内容，用于滚动
            ...List.generate(
                3,
                (index) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      height: 100,
                      color: Colors.grey[200],
                      child: Center(
                        child: Text('占位内容 ${index + 1}'),
                      ),
                    )),

            // 被VisibilityDetector包裹的目标组件
            VisibilityDetector(
              key: const Key('analysis-target'),
              onVisibilityChanged: _onVisibilityChanged,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red[300],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '被监测的组件',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '滚动页面观察可见性变化',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 更多占位内容
            ...List.generate(
                5,
                (index) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      height: 120,
                      color: Colors.blue[100],
                      child: Center(
                        child: Text('更多内容 ${index + 1}'),
                      ),
                    )),

            // 源码分析说明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VisibilityDetector 源码要点',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. 使用 RenderVisibilityDetector 自定义渲染对象\n'
                      '2. 通过 VisibilityDetectorController 管理全局状态\n'
                      '3. 监听滚动和布局变化事件\n'
                      '4. 计算组件在视口中的可见区域和比例\n'
                      '5. 通过回调函数通知可见性变化',
                      style: TextStyle(fontSize: 14),
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
}
