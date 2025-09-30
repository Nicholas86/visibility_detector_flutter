import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// 外部传入的菜单项
class MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  MenuItem({required this.icon, required this.label, required this.onTap});
}

class ChatPopupMenu extends StatefulWidget {
  final List<MenuItem> items;
  final double arrowWidth;
  final double arrowHeight;
  final double borderRadius;
  final Color backgroundColor;

  const ChatPopupMenu({
    Key? key,
    required this.items,
    this.arrowWidth = 40,
    this.arrowHeight = 10,
    this.borderRadius = 8,
    this.backgroundColor = const Color(0xFF5E5F62),
  }) : super(key: key);

  @override
  State<ChatPopupMenu> createState() => _ChatPopupMenuState();
}

class _ChatPopupMenuState extends State<ChatPopupMenu> {
  ui.Image? _waveImage;

  @override
  void initState() {
    super.initState();
    _loadWaveImage();
  }

  Future<void> _loadWaveImage() async {
    try {
      print('Loading wave image...');
      final ByteData data = await rootBundle.load('assets/images/wave.png');
      print('Image data loaded: ${data.lengthInBytes} bytes');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      setState(() {
        _waveImage = frameInfo.image;
        print('Wave image loaded: ${_waveImage!.width}x${_waveImage!.height}');
      });
    } catch (e) {
      print('Failed to load wave image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building ChatPopupMenu, _waveImage: $_waveImage');
    return CustomPaint(
      painter: _PopupBackgroundPainter(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius,
        arrowWidth: widget.arrowWidth,
        arrowHeight: widget.arrowHeight,
        waveImage: _waveImage,
      ),
      child: Container(
        width: 208,
        height: 72,
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: widget.items.map((item) {
            return GestureDetector(
              onTap: item.onTap,
              behavior: HitTestBehavior.translucent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(item.icon, color: Colors.white, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 聊天弹出菜单演示页面
class ChatPopupMenuDemoPage extends StatefulWidget {
  const ChatPopupMenuDemoPage({Key? key}) : super(key: key);

  @override
  State<ChatPopupMenuDemoPage> createState() => _ChatPopupMenuDemoPageState();
}

class _ChatPopupMenuDemoPageState extends State<ChatPopupMenuDemoPage> {
  double _arrowWidth = 30;
  double _arrowHeight = 12;
  double _borderRadius = 12;
  Color _backgroundColor = const Color(0xFF5E5F62);
  String _selectedMessage = "点击了菜单项";

  final List<Color> _backgroundColors = [
    const Color(0xFF555555),
    const Color(0xFF2196F3),
    const Color(0xFF4CAF50),
    const Color(0xFFFF9800),
    const Color(0xFFF44336),
    const Color(0xFF9C27B0),
  ];

  void _showMessage(String message) {
    setState(() {
      _selectedMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天弹出菜单演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 实时预览区域
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ChatPopupMenu(
                    arrowWidth: _arrowWidth,
                    arrowHeight: _arrowHeight,
                    borderRadius: _borderRadius,
                    backgroundColor: _backgroundColor,
                    items: [
                      MenuItem(
                        icon: Icons.copy,
                        label: "复制",
                        onTap: () => _showMessage("复制消息"),
                      ),
                      MenuItem(
                        icon: Icons.format_quote,
                        label: "引用",
                        onTap: () => _showMessage("引用消息"),
                      ),
                      MenuItem(
                        icon: Icons.undo,
                        label: "撤回",
                        onTap: () => _showMessage("撤回消息"),
                      ),
                      MenuItem(
                        icon: Icons.delete,
                        label: "删除",
                        onTap: () => _showMessage("删除消息"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 控制面板
            const Text(
              '控制面板',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 箭头宽度控制
            Text('箭头宽度: ${_arrowWidth.toInt()}'),
            Slider(
              value: _arrowWidth,
              min: 10,
              max: 50,
              divisions: 40,
              onChanged: (value) {
                setState(() {
                  _arrowWidth = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // 箭头高度控制
            Text('箭头高度: ${_arrowHeight.toInt()}'),
            Slider(
              value: _arrowHeight,
              min: 5,
              max: 25,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  _arrowHeight = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // 圆角半径控制
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
            const SizedBox(height: 16),

            // 背景颜色选择
            const Text('背景颜色:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _backgroundColors.map((color) {
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
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _backgroundColor == color ? Colors.black : Colors.grey,
                        width: _backgroundColor == color ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 最后操作显示
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '最后操作:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_selectedMessage),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 功能说明
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '功能特性',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• 自定义 CustomPainter 绘制圆角矩形背景'),
                    Text('• 顶部圆头小三角箭头指示'),
                    Text('• 可配置箭头尺寸、圆角半径和背景颜色'),
                    Text('• 支持多个菜单项的水平排列'),
                    Text('• 每个菜单项包含图标和文字标签'),
                    Text('• 响应式点击交互'),
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

/// 绘制背景：圆角矩形 + 圆头小三角
class _PopupBackgroundPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double arrowWidth;
  final double arrowHeight;
  final ui.Image? waveImage;

  _PopupBackgroundPainter({
    required this.color,
    required this.borderRadius,
    required this.arrowWidth,
    required this.arrowHeight,
    this.waveImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // 获取图片实际高度（使用固定值）
    const imageHeight = 10.0;

    print('Canvas size: $size');

    // 先绘制wave.png图片在顶部
    if (waveImage != null) {
      _drawWaveImage(canvas, size);
    }

    // 矩形主体区域从图片下方开始
    final bodyRect = Rect.fromLTWH(0, imageHeight, size.width, size.height - imageHeight);
    final rrect = RRect.fromRectAndRadius(bodyRect, Radius.circular(borderRadius));

    canvas.drawRRect(rrect, paint);
  }

  void _drawWaveImage(Canvas canvas, Size size) {
    if (waveImage == null) return;

    print('Drawing wave image: ${waveImage!.width}x${waveImage!.height}');

    // 计算图片在画布中的居中位置
    const imageBoxWidth = 40.0;
    const imageBoxHeight = 10.0;

    // 水平居中：(画布宽度 - 图片宽度) / 2
    final centerX = (size.width - imageBoxWidth) / 2;
    // 垂直位置：保持在顶部
    final centerY = 0.0;

    final offset = Offset(centerX, centerY);

    print('Image offset: $offset, Canvas size: $size');

    // 绘制整个图片放在到指定区域
    // 如果 src 和 dst 的尺寸不同，会自动进行缩放
    canvas.drawImageRect(
      waveImage!,
      // src: 将图片资源的整个区域
      Rect.fromLTWH(0, 0, waveImage!.width.toDouble(), waveImage!.height.toDouble()),
      // dst: 绘制到画布顶部，图片放在宽: 40,高: 10的盒子内
      Rect.fromLTWH(centerX, 0, imageBoxWidth, imageBoxHeight),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
