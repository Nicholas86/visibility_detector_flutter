import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 自定义 Widget
class BubbleText extends LeafRenderObjectWidget {
  final String text;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double borderRadius;
  final TextStyle style;

  const BubbleText({
    Key? key,
    required this.text,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.borderRadius = 12,
    this.style = const TextStyle(fontSize: 14, color: Colors.black87),
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBubbleText(
      text: text,
      backgroundColor: backgroundColor,
      padding: padding,
      borderRadius: borderRadius,
      style: style,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBubbleText renderObject) {
    renderObject
      ..text = text
      ..backgroundColor = backgroundColor
      ..padding = padding
      ..borderRadius = borderRadius
      ..style = style
      ..textDirection = Directionality.of(context);
  }
}

/// RenderObject 实现
class RenderBubbleText extends RenderBox {
  String _text;
  Color _backgroundColor;
  EdgeInsets _padding;
  double _borderRadius;
  TextStyle _style;
  TextDirection _textDirection;

  RenderBubbleText({
    required String text,
    required Color backgroundColor,
    required EdgeInsets padding,
    required double borderRadius,
    required TextStyle style,
    required TextDirection textDirection,
  })  : _text = text,
        _backgroundColor = backgroundColor,
        _padding = padding,
        _borderRadius = borderRadius,
        _style = style,
        _textDirection = textDirection {
    _updateTextPainter();
  }

  final TextPainter _textPainter = TextPainter();

  void _updateTextPainter() {
    _textPainter
      ..text = TextSpan(text: _text, style: _style)
      ..textDirection = _textDirection
      ..layout();
    markNeedsLayout();
  }

  // setters
  set text(String value) {
    if (_text != value) {
      _text = value;
      _updateTextPainter();
    }
  }

  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  set padding(EdgeInsets value) {
    if (_padding != value) {
      _padding = value;
      markNeedsLayout();
    }
  }

  set borderRadius(double value) {
    if (_borderRadius != value) {
      _borderRadius = value;
      markNeedsPaint();
    }
  }

  set style(TextStyle value) {
    if (_style != value) {
      _style = value;
      _updateTextPainter();
    }
  }

  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      _updateTextPainter();
    }
  }

  @override
  void performLayout() {
    _textPainter.layout(maxWidth: constraints.maxWidth - _padding.horizontal);
    size = Size(
      _textPainter.width + _padding.horizontal,
      _textPainter.height + _padding.vertical,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;

    // 绘制圆角背景
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(_borderRadius));
    final paint = Paint()..color = _backgroundColor;
    canvas.drawRRect(rrect, paint);

    // 绘制文字
    final textOffset = offset + Offset(_padding.left, _padding.top);
    _textPainter.paint(canvas, textOffset);
  }
}

/// BubbleText 演示页面
class BubbleTextDemoPage extends StatefulWidget {
  const BubbleTextDemoPage({Key? key}) : super(key: key);

  @override
  State<BubbleTextDemoPage> createState() => _BubbleTextDemoPageState();
}

class _BubbleTextDemoPageState extends State<BubbleTextDemoPage> {
  String _text = "这是一个优化后的 RenderObject 气泡文本。";
  Color _backgroundColor = const Color(0xFFE0E0E0);
  double _borderRadius = 12;
  double _fontSize = 14;
  Color _textColor = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BubbleText 演示'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 演示区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '演示效果',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: BubbleText(
                        text: _text,
                        backgroundColor: _backgroundColor,
                        borderRadius: _borderRadius,
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: _textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 控制面板
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '控制面板',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 文本输入
                    TextField(
                      decoration: const InputDecoration(
                        labelText: '文本内容',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _text = value.isEmpty ? "请输入文本" : value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // 背景颜色选择
                    const Text('背景颜色'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildColorButton(const Color(0xFFE0E0E0)),
                        _buildColorButton(Colors.blue.shade100),
                        _buildColorButton(Colors.green.shade100),
                        _buildColorButton(Colors.orange.shade100),
                        _buildColorButton(Colors.purple.shade100),
                        _buildColorButton(Colors.red.shade100),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 圆角半径
                    Text('圆角半径: ${_borderRadius.toInt()}'),
                    Slider(
                      value: _borderRadius,
                      min: 0,
                      max: 30,
                      divisions: 30,
                      onChanged: (value) {
                        setState(() {
                          _borderRadius = value;
                        });
                      },
                    ),

                    // 字体大小
                    Text('字体大小: ${_fontSize.toInt()}'),
                    Slider(
                      value: _fontSize,
                      min: 10,
                      max: 24,
                      divisions: 14,
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                      },
                    ),

                    // 文字颜色选择
                    const Text('文字颜色'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTextColorButton(Colors.black87),
                        _buildTextColorButton(Colors.white),
                        _buildTextColorButton(Colors.blue),
                        _buildTextColorButton(Colors.green),
                        _buildTextColorButton(Colors.orange),
                        _buildTextColorButton(Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 多个示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '多样式示例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        const BubbleText(
                          text: "默认样式",
                        ),
                        BubbleText(
                          text: "蓝色气泡",
                          backgroundColor: Colors.blue.shade100,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        BubbleText(
                          text: "圆形气泡",
                          backgroundColor: Colors.green.shade100,
                          borderRadius: 25,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                        BubbleText(
                          text: "大号文字",
                          backgroundColor: Colors.orange.shade100,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 说明文档
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '关于 BubbleText',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'BubbleText 是一个基于自定义 RenderObject 实现的气泡文本组件。'
                      '它直接继承自 LeafRenderObjectWidget，通过自定义的 RenderBubbleText '
                      '来实现高效的布局和绘制。',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '特性：',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• 自定义背景颜色和圆角半径\n'
                      '• 可调节的内边距\n'
                      '• 支持自定义文字样式\n'
                      '• 高效的布局和绘制性能\n'
                      '• 完整的属性更新机制',
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

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _backgroundColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: _backgroundColor == color ? Colors.black : Colors.grey,
            width: _backgroundColor == color ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildTextColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _textColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: _textColor == color ? Colors.black : Colors.grey,
            width: _textColor == color ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
