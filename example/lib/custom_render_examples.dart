import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// 示例1：简单的自定义绘制组件 - 自定义进度条
class CustomProgressBar extends LeafRenderObjectWidget {
  const CustomProgressBar({
    Key? key,
    required this.progress,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.height = 8.0,
  })  : assert(progress >= 0.0 && progress <= 1.0),
        super(key: key);

  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double height;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomProgressBar(
      progress: progress,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      height: height,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCustomProgressBar renderObject) {
    renderObject
      ..progress = progress
      ..backgroundColor = backgroundColor
      ..progressColor = progressColor
      ..barHeight = height;
  }
}

class RenderCustomProgressBar extends RenderBox {
  RenderCustomProgressBar({
    required double progress,
    required Color backgroundColor,
    required Color progressColor,
    required double height,
  })  : _progress = progress,
        _backgroundColor = backgroundColor,
        _progressColor = progressColor,
        _height = height;

  double _progress;

  double get progress => _progress;

  set progress(double value) {
    if (_progress != value) {
      _progress = value;
      markNeedsPaint(); // 标记需要重绘
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

  Color _progressColor;

  Color get progressColor => _progressColor;

  set progressColor(Color value) {
    if (_progressColor != value) {
      _progressColor = value;
      markNeedsPaint();
    }
  }

  double _height;

  double get barHeight => _height;

  set barHeight(double value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout(); // 高度变化需要重新布局
    }
  }

  @override
  void performLayout() {
    // 布局算法：使用父组件的宽度约束，高度使用自定义值
    size = Size(
      constraints.maxWidth.isFinite ? constraints.maxWidth : 200.0,
      _height,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Rect rect = offset & size;

    // 绘制背景
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(_height / 2)),
      backgroundPaint,
    );

    // 绘制进度
    if (progress > 0) {
      final double progressWidth = rect.width * progress;
      final Rect progressRect = Rect.fromLTWH(
        rect.left,
        rect.top,
        progressWidth,
        rect.height,
      );

      final Paint progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(progressRect, Radius.circular(_height / 2)),
        progressPaint,
      );
    }
  }

  @override
  bool get sizedByParent => false;

  @override
  bool hitTestSelf(Offset position) => true;
}

/// 示例2：带动画的自定义组件 - 脉冲圆圈
class PulsingCircle extends StatefulWidget {
  const PulsingCircle({
    Key? key,
    this.color = Colors.blue,
    this.circleSize = 50.0,
    this.animationDuration = const Duration(seconds: 1),
  }) : super(key: key);

  final Color color;
  final double circleSize;
  final Duration animationDuration;

  @override
  State<PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<PulsingCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PulsingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.circleSize, widget.circleSize),
          painter: PulsingCirclePainter(
            color: widget.color,
            animationValue: _animation.value,
          ),
        );
      },
    );
  }
}

class PulsingCirclePainter extends CustomPainter {
  PulsingCirclePainter({
    required this.color,
    required this.animationValue,
  });

  final Color color;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width / 2) * animationValue;

    final Paint paint = Paint()
      ..color = color.withOpacity(1.0 - animationValue + 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(PulsingCirclePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}

/// 示例3：代理型RenderObject - 自定义边框装饰器
class CustomBorderDecorator extends SingleChildRenderObjectWidget {
  const CustomBorderDecorator({
    Key? key,
    required this.borderColor,
    this.borderWidth = 2.0,
    this.cornerRadius = 8.0,
    this.dashPattern,
    Widget? child,
  }) : super(key: key, child: child);

  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  final List<double>? dashPattern; // 虚线模式，如 [5, 3] 表示5像素实线，3像素空白

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomBorderDecorator(
      borderColor: borderColor,
      borderWidth: borderWidth,
      cornerRadius: cornerRadius,
      dashPattern: dashPattern,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCustomBorderDecorator renderObject) {
    renderObject
      ..borderColor = borderColor
      ..borderWidth = borderWidth
      ..cornerRadius = cornerRadius
      ..dashPattern = dashPattern;
  }
}

class RenderCustomBorderDecorator extends RenderProxyBox {
  RenderCustomBorderDecorator({
    required Color borderColor,
    required double borderWidth,
    required double cornerRadius,
    List<double>? dashPattern,
  })  : _borderColor = borderColor,
        _borderWidth = borderWidth,
        _cornerRadius = cornerRadius,
        _dashPattern = dashPattern;

  Color _borderColor;

  Color get borderColor => _borderColor;

  set borderColor(Color value) {
    if (_borderColor != value) {
      _borderColor = value;
      markNeedsPaint();
    }
  }

  double _borderWidth;

  double get borderWidth => _borderWidth;

  set borderWidth(double value) {
    if (_borderWidth != value) {
      _borderWidth = value;
      markNeedsPaint();
    }
  }

  double _cornerRadius;

  double get cornerRadius => _cornerRadius;

  set cornerRadius(double value) {
    if (_cornerRadius != value) {
      _cornerRadius = value;
      markNeedsPaint();
    }
  }

  List<double>? _dashPattern;

  List<double>? get dashPattern => _dashPattern;

  set dashPattern(List<double>? value) {
    if (_dashPattern != value) {
      _dashPattern = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // 先绘制子组件
    if (child != null) {
      context.paintChild(child!, offset);
    }

    // 然后绘制边框
    _paintBorder(context, offset);
  }

  void _paintBorder(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Rect rect = offset & size;

    final Paint paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final RRect rrect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth / 2),
      Radius.circular(cornerRadius),
    );

    if (dashPattern != null && dashPattern!.isNotEmpty) {
      _drawDashedRRect(canvas, rrect, paint, dashPattern!);
    } else {
      canvas.drawRRect(rrect, paint);
    }
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint, List<double> pattern) {
    final Path path = Path()..addRRect(rrect);
    final ui.PathMetrics pathMetrics = path.computeMetrics();

    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      int patternIndex = 0;

      while (distance < pathMetric.length) {
        final double segmentLength = pattern[patternIndex % pattern.length];
        final double nextDistance = math.min(distance + segmentLength, pathMetric.length);

        if (draw) {
          final Path segment = pathMetric.extractPath(distance, nextDistance);
          canvas.drawPath(segment, paint);
        }

        distance = nextDistance;
        draw = !draw;
        patternIndex++;
      }
    }
  }
}

/// 示例4：事件处理型RenderObject - 可拖拽的组件
class DraggableBox extends SingleChildRenderObjectWidget {
  const DraggableBox({
    Key? key,
    required this.onDrag,
    Widget? child,
  }) : super(key: key, child: child);

  final ValueChanged<Offset> onDrag;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderDraggableBox(onDrag: onDrag);
  }

  @override
  void updateRenderObject(BuildContext context, RenderDraggableBox renderObject) {
    renderObject.onDrag = onDrag;
  }
}

class RenderDraggableBox extends RenderProxyBox {
  RenderDraggableBox({required ValueChanged<Offset> onDrag}) : _onDrag = onDrag;

  ValueChanged<Offset> _onDrag;

  ValueChanged<Offset> get onDrag => _onDrag;

  set onDrag(ValueChanged<Offset> value) {
    _onDrag = value;
  }

  Offset? _lastPanPosition;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _lastPanPosition = event.localPosition;
    } else if (event is PointerMoveEvent && _lastPanPosition != null) {
      final Offset delta = event.localPosition - _lastPanPosition!;
      _onDrag(delta);
      _lastPanPosition = event.localPosition;
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _lastPanPosition = null;
    }
  }
}

/// 示例5：限制行数的Wrap组件 - LimitedWrap
/// 基于RenderObject实现的可以限制显示行数的Wrap组件

/// ParentData类，用于存储每个子组件的布局信息
class _LimitedWrapParentData extends ContainerBoxParentData<RenderBox> {
  /// 是否被限制显示（超出最大行数）
  bool _limit = false;
}

/// LimitedWrap组件，支持限制最大显示行数
class LimitedWrap extends MultiChildRenderObjectWidget {
  const LimitedWrap({
    Key? key,
    required this.children,
    this.maxLine = 0, // 0表示不限制行数
    this.spacing = 0.0, // 水平间距
    this.runSpacing = 0.0, // 垂直间距
    this.afterLayout, // 布局完成后的回调
  }) : super(key: key, children: children);

  /// 子组件列表
  final List<Widget> children;

  /// 最大显示行数，0表示不限制
  final int maxLine;

  /// 水平间距
  final double spacing;

  /// 垂直间距
  final double runSpacing;

  /// 布局完成后的回调，返回显示的子组件数量和行数
  final void Function(int displayChildCount, int displayLineCount)? afterLayout;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return LimitRenderWrap(
      maxLine: maxLine,
      runSpacing: runSpacing,
      spacing: spacing,
      afterLayout: afterLayout,
    );
  }

  @override
  void updateRenderObject(BuildContext context, LimitRenderWrap renderObject) {
    renderObject
      ..maxLine = maxLine
      ..runSpacing = runSpacing
      ..spacing = spacing
      ..afterLayout = afterLayout;
  }
}

/// LimitedWrap的RenderObject实现
class LimitRenderWrap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _LimitedWrapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _LimitedWrapParentData> {
  LimitRenderWrap({
    required int maxLine,
    required double runSpacing,
    required double spacing,
    void Function(int displayChildCount, int displayLineCount)? afterLayout,
  })  : _maxLine = maxLine,
        _runSpacing = runSpacing,
        _spacing = spacing,
        _afterLayout = afterLayout;

  int _maxLine;

  int get maxLine => _maxLine;

  set maxLine(int value) {
    if (_maxLine != value) {
      _maxLine = value;
      markNeedsLayout();
    }
  }

  double _runSpacing;

  double get runSpacing => _runSpacing;

  set runSpacing(double value) {
    if (_runSpacing != value) {
      _runSpacing = value;
      markNeedsLayout();
    }
  }

  double _spacing;

  double get spacing => _spacing;

  set spacing(double value) {
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  void Function(int displayChildCount, int displayLineCount)? _afterLayout;

  void Function(int displayChildCount, int displayLineCount)? get afterLayout => _afterLayout;

  set afterLayout(void Function(int displayChildCount, int displayLineCount)? value) {
    _afterLayout = value;
  }

  int _displayChildCount = 0;
  int _displayLineCount = 0;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _LimitedWrapParentData) {
      child.parentData = _LimitedWrapParentData();
    }
  }

  void _callBack() {
    if (_afterLayout != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _afterLayout!(_displayChildCount, _displayLineCount);
      });
    }
  }

  @override
  void performLayout() {
    RenderBox? child = firstChild;
    final constraints = this.constraints;
    _displayChildCount = 0;
    _displayLineCount = 0;

    if (child == null) {
      size = constraints.smallest;
      _callBack();
      return;
    }

    final mainAxisLimit = constraints.maxWidth;
    final spacing = this.spacing;
    final runSpacing = this.runSpacing;
    final maxLine = this.maxLine;
    final BoxConstraints childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);

    // 当前显示的是第几行
    int runLine = 0;
    // 当前行子元素的个数
    int childCount = 0;
    // 当前行横向占据的空间
    double runMainAxisExtent = 0.0;
    // 当前行最大的高度
    double runCrossAxisExtent = 0.0;
    // 计算size使用
    // 整个组件横向最大的空间
    double mainAxisExtent = 0.0;
    // 整个组件纵向最大的高度
    double crossAxisExtent = 0.0;

    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final childWidth = child.size.width;
      final childHeight = child.size.height;
      final childParentData = child.parentData! as _LimitedWrapParentData;

      if (childCount > 0 && runMainAxisExtent + spacing + childWidth > mainAxisLimit) {
        // 换行
        if (maxLine > 0 && runLine >= maxLine - 1) {
          // 当达到最大行数时，将当前及后续所有子组件标记为限制状态
          childParentData._limit = true;
          child = childParentData.nextSibling;
          // 继续遍历剩余的子组件，将它们都标记为限制状态
          while (child != null) {
            final nextChildParentData = child.parentData! as _LimitedWrapParentData;
            nextChildParentData._limit = true;
            child = nextChildParentData.nextSibling;
          }
          break;
        }

        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        crossAxisExtent += runCrossAxisExtent;
        if (runLine > 0) crossAxisExtent += runSpacing;
        // 保存当前行数
        runLine += 1;
        childCount = 0;
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
      }

      // 计算子组件的偏移量
      double dx = runMainAxisExtent;
      double dy = crossAxisExtent;
      if (childCount > 0) dx += spacing;
      if (runLine > 0) dy += runSpacing;
      childParentData.offset = Offset(dx, dy);

      // 记录当前行的最高、最宽
      runMainAxisExtent += childWidth;
      if (childCount > 0) runMainAxisExtent += spacing;
      runCrossAxisExtent = math.max(runCrossAxisExtent, childHeight);

      childCount += 1;
      childParentData._limit = false;
      child = childParentData.nextSibling;
      _displayChildCount += 1;
    }

    // 计算size
    if (childCount > 0) {
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      crossAxisExtent += runCrossAxisExtent;
      if (runLine > 0) crossAxisExtent += runSpacing;
    }

    _displayLineCount = runLine + (childCount > 0 ? 1 : 0);

    size = Size(
      constraints.constrainWidth(mainAxisExtent),
      constraints.constrainHeight(crossAxisExtent),
    );

    _callBack();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _LimitedWrapParentData;
      if (!childParentData._limit) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// LimitedWrap使用示例
class LimitedWrapExample extends StatefulWidget {
  const LimitedWrapExample({Key? key}) : super(key: key);

  @override
  State<LimitedWrapExample> createState() => _LimitedWrapExampleState();
}

class _LimitedWrapExampleState extends State<LimitedWrapExample> {
  int maxLines = 2;
  int displayChildCount = 0;
  int displayLineCount = 0;
  bool showAll = false;

  final List<String> tags = [
    '限时优惠',
    '新品上市',
    '热销商品',
    '包邮',
    '7天退换',
    '正品保证',
    '快速发货',
    '优质服务',
    '品质保障',
    '用户好评',
    '推荐商品',
    '特价促销',
    '买一送一',
    '满减活动',
    '会员专享'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LimitedWrap 示例'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '商品标签展示：',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LimitedWrap(
                    maxLine: showAll ? 0 : maxLines,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    afterLayout: (childCount, lineCount) {
                      debugPrint('布局完成后的回调childCount: $childCount,lineCount:$lineCount');
                      setState(() {
                        displayChildCount = childCount;
                        displayLineCount = lineCount;
                      });
                    },
                    children: tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.blue.shade300),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  if (!showAll && displayChildCount < tags.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showAll = true;
                          });
                        },
                        child: Text(
                          '展开更多 (${tags.length - displayChildCount})',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  if (showAll)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showAll = false;
                            // 重置显示状态，确保收起时正确显示
                            displayChildCount = 0;
                            displayLineCount = 0;
                          });
                        },
                        child: Text(
                          '收起',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('显示信息：'),
            Text('显示子组件数量: $displayChildCount / ${tags.length}'),
            Text('显示行数: $displayLineCount'),
            const SizedBox(height: 20),
            const Text('控制选项：'),
            Row(
              children: [
                const Text('最大行数: '),
                DropdownButton<int>(
                  value: maxLines,
                  items: [1, 2, 3, 4, 5].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: showAll
                      ? null
                      : (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              maxLines = newValue;
                            });
                          }
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============== ShrinkWrap Implementation ==============
// 基于文章 https://juejin.cn/post/7124726731641978916 实现的可展开收缩的流式布局

/// ShrinkWrap的父数据类，用于存储每个子组件的布局信息
class _ShrinkWrapParentData extends ContainerBoxParentData<RenderBox> {
  int? _runIndex;
}

/// 可展开收缩的流式布局组件
/// 支持maxLines参数来限制显示行数，并提供总行数回调
class ShrinkWrap extends MultiChildRenderObjectWidget {
  const ShrinkWrap({
    Key? key,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.spacing = 0.0,
    this.runAlignment = WrapAlignment.start,
    this.runSpacing = 0.0,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.clipBehavior = Clip.none,
    this.maxLines = 0, // 0表示不限制行数
    this.onLayoutComplete, // 布局完成后的回调，返回总行数
    List<Widget> children = const <Widget>[],
  }) : super(key: key, children: children);

  /// 主轴方向
  final Axis direction;

  /// 主轴对齐方式
  final WrapAlignment alignment;

  /// 主轴间距
  final double spacing;

  /// 交叉轴对齐方式
  final WrapAlignment runAlignment;

  /// 交叉轴间距
  final double runSpacing;

  /// 子组件在交叉轴上的对齐方式
  final WrapCrossAlignment crossAxisAlignment;

  /// 文本方向
  final TextDirection? textDirection;

  /// 垂直方向
  final VerticalDirection verticalDirection;

  /// 裁剪行为
  final Clip clipBehavior;

  /// 最大行数，0表示不限制
  final int maxLines;

  /// 布局完成后的回调，返回总行数
  final ValueChanged<int>? onLayoutComplete;

  @override
  RenderShrinkWrap createRenderObject(BuildContext context) {
    return RenderShrinkWrap(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      verticalDirection: verticalDirection,
      clipBehavior: clipBehavior,
      maxLines: maxLines,
      onLayoutComplete: onLayoutComplete,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderShrinkWrap renderObject) {
    renderObject
      ..direction = direction
      ..alignment = alignment
      ..spacing = spacing
      ..runAlignment = runAlignment
      ..runSpacing = runSpacing
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context)
      ..verticalDirection = verticalDirection
      ..clipBehavior = clipBehavior
      ..maxLines = maxLines
      ..onLayoutComplete = onLayoutComplete;
  }
}

/// ShrinkWrap的渲染对象
class RenderShrinkWrap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ShrinkWrapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ShrinkWrapParentData> {
  RenderShrinkWrap({
    List<RenderBox>? children,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    Clip clipBehavior = Clip.none,
    int maxLines = 0,
    ValueChanged<int>? onLayoutComplete,
  })  : _direction = direction,
        _alignment = alignment,
        _spacing = spacing,
        _runAlignment = runAlignment,
        _runSpacing = runSpacing,
        _crossAxisAlignment = crossAxisAlignment,
        _textDirection = textDirection,
        _verticalDirection = verticalDirection,
        _clipBehavior = clipBehavior,
        _maxLines = maxLines,
        _onLayoutComplete = onLayoutComplete {
    addAll(children);
  }

  Axis _direction;

  Axis get direction => _direction;

  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      markNeedsLayout();
    }
  }

  WrapAlignment _alignment;

  WrapAlignment get alignment => _alignment;

  set alignment(WrapAlignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  double _spacing;

  double get spacing => _spacing;

  set spacing(double value) {
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  WrapAlignment _runAlignment;

  WrapAlignment get runAlignment => _runAlignment;

  set runAlignment(WrapAlignment value) {
    if (_runAlignment != value) {
      _runAlignment = value;
      markNeedsLayout();
    }
  }

  double _runSpacing;

  double get runSpacing => _runSpacing;

  set runSpacing(double value) {
    if (_runSpacing != value) {
      _runSpacing = value;
      markNeedsLayout();
    }
  }

  WrapCrossAlignment _crossAxisAlignment;

  WrapCrossAlignment get crossAxisAlignment => _crossAxisAlignment;

  set crossAxisAlignment(WrapCrossAlignment value) {
    if (_crossAxisAlignment != value) {
      _crossAxisAlignment = value;
      markNeedsLayout();
    }
  }

  TextDirection? _textDirection;

  TextDirection? get textDirection => _textDirection;

  set textDirection(TextDirection? value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  VerticalDirection _verticalDirection;

  VerticalDirection get verticalDirection => _verticalDirection;

  set verticalDirection(VerticalDirection value) {
    if (_verticalDirection != value) {
      _verticalDirection = value;
      markNeedsLayout();
    }
  }

  Clip _clipBehavior;

  Clip get clipBehavior => _clipBehavior;

  set clipBehavior(Clip value) {
    if (_clipBehavior != value) {
      _clipBehavior = value;
      markNeedsPaint();
    }
  }

  int _maxLines;

  int get maxLines => _maxLines;

  set maxLines(int value) {
    if (_maxLines != value) {
      _maxLines = value;
      markNeedsLayout();
    }
  }

  ValueChanged<int>? _onLayoutComplete;

  ValueChanged<int>? get onLayoutComplete => _onLayoutComplete;

  set onLayoutComplete(ValueChanged<int>? value) {
    if (_onLayoutComplete != value) {
      _onLayoutComplete = value;
    }
  }

  int _totalLines = 0;

  int get totalLines => _totalLines;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ShrinkWrapParentData) {
      child.parentData = _ShrinkWrapParentData();
    }
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.smallest;
      _totalLines = 0;
      _onLayoutComplete?.call(_totalLines);
      return;
    }

    double mainAxisLimit = direction == Axis.horizontal ? constraints.maxWidth : constraints.maxHeight;
    bool flipMainAxis = !(_textDirection == TextDirection.ltr || _textDirection == null);
    bool flipCrossAxis = _verticalDirection == VerticalDirection.up;

    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;

    List<List<RenderBox>> runs = <List<RenderBox>>[];
    List<double> runMainAxisExtents = <double>[];
    List<double> runCrossAxisExtents = <double>[];

    RenderBox? child = firstChild;
    List<RenderBox> currentRun = <RenderBox>[];

    // 第一阶段：测量所有子组件并分组到行中
    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      final Size childSize = child.size;
      final double childMainAxisExtent = direction == Axis.horizontal ? childSize.width : childSize.height;
      final double childCrossAxisExtent = direction == Axis.horizontal ? childSize.height : childSize.width;

      if (currentRun.isNotEmpty && runMainAxisExtent + spacing + childMainAxisExtent > mainAxisLimit) {
        // 开始新行
        runs.add(currentRun);
        runMainAxisExtents.add(runMainAxisExtent);
        runCrossAxisExtents.add(runCrossAxisExtent);

        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        crossAxisExtent += runCrossAxisExtent;
        if (runs.length > 1) {
          crossAxisExtent += runSpacing;
        }

        currentRun = <RenderBox>[child];
        runMainAxisExtent = childMainAxisExtent;
        runCrossAxisExtent = childCrossAxisExtent;
      } else {
        // 添加到当前行
        if (currentRun.isNotEmpty) {
          runMainAxisExtent += spacing;
        }
        currentRun.add(child);
        runMainAxisExtent += childMainAxisExtent;
        runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      }

      final _ShrinkWrapParentData childParentData = child.parentData! as _ShrinkWrapParentData;
      childParentData._runIndex = runs.length;
      child = childParentData.nextSibling;
    }

    // 添加最后一行
    if (currentRun.isNotEmpty) {
      runs.add(currentRun);
      runMainAxisExtents.add(runMainAxisExtent);
      runCrossAxisExtents.add(runCrossAxisExtent);
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      crossAxisExtent += runCrossAxisExtent;
      if (runs.length > 1) {
        crossAxisExtent += runSpacing;
      }
    }

    _totalLines = runs.length;

    // 应用maxLines限制
    if (maxLines > 0 && runs.length > maxLines) {
      runs = runs.take(maxLines).toList();
      runMainAxisExtents = runMainAxisExtents.take(maxLines).toList();
      runCrossAxisExtents = runCrossAxisExtents.take(maxLines).toList();

      // 重新计算尺寸
      crossAxisExtent = 0.0;
      for (int i = 0; i < runs.length; i++) {
        crossAxisExtent += runCrossAxisExtents[i];
        if (i > 0) {
          crossAxisExtent += runSpacing;
        }
      }
    }

    // 设置组件尺寸
    final double containerMainAxisExtent = direction == Axis.horizontal ? constraints.maxWidth : constraints.maxHeight;
    final double containerCrossAxisExtent = direction == Axis.horizontal ? crossAxisExtent : mainAxisExtent;

    size = constraints.constrain(direction == Axis.horizontal
        ? Size(containerMainAxisExtent, containerCrossAxisExtent)
        : Size(containerCrossAxisExtent, containerMainAxisExtent));

    // 第二阶段：定位子组件
    double crossAxisOffset = 0.0;
    for (int runIndex = 0; runIndex < runs.length; runIndex++) {
      final List<RenderBox> run = runs[runIndex];
      final double runMainAxisExtent = runMainAxisExtents[runIndex];
      final double runCrossAxisExtent = runCrossAxisExtents[runIndex];

      double mainAxisOffset = 0.0;
      switch (alignment) {
        case WrapAlignment.start:
          mainAxisOffset = 0.0;
          break;
        case WrapAlignment.end:
          mainAxisOffset = containerMainAxisExtent - runMainAxisExtent;
          break;
        case WrapAlignment.center:
          mainAxisOffset = (containerMainAxisExtent - runMainAxisExtent) / 2.0;
          break;
        case WrapAlignment.spaceBetween:
          mainAxisOffset = 0.0;
          break;
        case WrapAlignment.spaceAround:
          mainAxisOffset = (containerMainAxisExtent - runMainAxisExtent) / (run.length * 2);
          break;
        case WrapAlignment.spaceEvenly:
          mainAxisOffset = (containerMainAxisExtent - runMainAxisExtent) / (run.length + 1);
          break;
      }

      for (int childIndex = 0; childIndex < run.length; childIndex++) {
        final RenderBox child = run[childIndex];
        final _ShrinkWrapParentData childParentData = child.parentData! as _ShrinkWrapParentData;

        double childCrossAxisOffset = 0.0;
        switch (crossAxisAlignment) {
          case WrapCrossAlignment.start:
            childCrossAxisOffset = 0.0;
            break;
          case WrapCrossAlignment.end:
            childCrossAxisOffset = runCrossAxisExtent - (direction == Axis.horizontal ? child.size.height : child.size.width);
            break;
          case WrapCrossAlignment.center:
            childCrossAxisOffset =
                (runCrossAxisExtent - (direction == Axis.horizontal ? child.size.height : child.size.width)) / 2.0;
            break;
        }

        if (flipCrossAxis) {
          childCrossAxisOffset =
              runCrossAxisExtent - childCrossAxisOffset - (direction == Axis.horizontal ? child.size.height : child.size.width);
        }

        double childMainAxisOffset = mainAxisOffset;
        if (alignment == WrapAlignment.spaceBetween && run.length > 1) {
          childMainAxisOffset += childIndex * (containerMainAxisExtent - runMainAxisExtent) / (run.length - 1);
        } else if (alignment == WrapAlignment.spaceAround) {
          childMainAxisOffset += childIndex * 2 * (containerMainAxisExtent - runMainAxisExtent) / (run.length * 2);
        } else if (alignment == WrapAlignment.spaceEvenly) {
          childMainAxisOffset += (childIndex + 1) * (containerMainAxisExtent - runMainAxisExtent) / (run.length + 1);
        } else {
          if (childIndex > 0) {
            childMainAxisOffset += spacing;
          }
          for (int i = 0; i < childIndex; i++) {
            childMainAxisOffset += direction == Axis.horizontal ? run[i].size.width : run[i].size.height;
            if (i > 0 &&
                alignment != WrapAlignment.spaceBetween &&
                alignment != WrapAlignment.spaceAround &&
                alignment != WrapAlignment.spaceEvenly) {
              childMainAxisOffset += spacing;
            }
          }
        }

        if (flipMainAxis) {
          childMainAxisOffset = containerMainAxisExtent -
              childMainAxisOffset -
              (direction == Axis.horizontal ? child.size.width : child.size.height);
        }

        childParentData.offset = direction == Axis.horizontal
            ? Offset(childMainAxisOffset, crossAxisOffset + childCrossAxisOffset)
            : Offset(crossAxisOffset + childCrossAxisOffset, childMainAxisOffset);
      }

      crossAxisOffset += runCrossAxisExtent + runSpacing;
    }

    // 隐藏超出maxLines的子组件
    if (maxLines > 0) {
      child = firstChild;
      while (child != null) {
        final _ShrinkWrapParentData childParentData = child.parentData! as _ShrinkWrapParentData;
        if (childParentData._runIndex != null && childParentData._runIndex! >= maxLines) {
          childParentData.offset = const Offset(-10000, -10000); // 移到屏幕外
        }
        child = childParentData.nextSibling;
      }
    }

    // 调用布局完成回调
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _onLayoutComplete?.call(_totalLines);
    });
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (clipBehavior != Clip.none) {
      context.pushClipRect(needsCompositing, offset, Offset.zero & size, defaultPaint);
    } else {
      defaultPaint(context, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

// ============== ShrinkWrap Example ==============

/// ShrinkWrap使用示例
class ShrinkWrapExample extends StatefulWidget {
  const ShrinkWrapExample({Key? key}) : super(key: key);

  @override
  State<ShrinkWrapExample> createState() => _ShrinkWrapExampleState();
}

class _ShrinkWrapExampleState extends State<ShrinkWrapExample> {
  bool _isExpanded = false;
  int _totalLines = 0;
  bool _showManualToggle = true; // 添加手动切换开关

  final List<String> _tags = [
    '满减优惠',
    '新用户立减',
    '免配送费',
    '品质保证',
    '快速配送',
    '24小时营业',
    '支持自取',
    '会员专享',
    '限时特价',
    '买一送一',
    '第二份半价',
    '满额包邮',
    '积分兑换',
    '生日优惠',
    '学生优惠'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShrinkWrap 展开收缩示例'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ShrinkWrap 可展开收缩的流式布局',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '类似美团外卖店铺标签的展示效果，支持设置最大行数和展开/收缩功能。',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 示例1：基本用法
            _buildSection(
              title: '基本用法 - 限制1行显示',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 手动切换开关
                    Row(
                      children: [
                        const Text('手动展开/收起模式: '),
                        Switch(
                          value: _showManualToggle,
                          onChanged: (value) {
                            setState(() {
                              _showManualToggle = value;
                              if (!value) {
                                _isExpanded = false; // 关闭手动模式时重置为收起状态
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ShrinkWrap(
                            spacing: 8,
                            runSpacing: 8,
                            maxLines: _isExpanded ? 0 : 1,
                            onLayoutComplete: (totalLines) {
                              if (mounted) {
                                setState(() {
                                  _totalLines = totalLines;
                                });
                              }
                            },
                            children: _tags.map((tag) => _buildTag(tag)).toList(),
                          ),
                        ),
                        // 显示展开/收起按钮的条件：手动模式开启 或 自动检测到多行
                        if (_showManualToggle || _totalLines > 1) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isExpanded ? '收起' : '展开',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Icon(
                                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: Colors.blue.shade700,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              '总行数: $_totalLines | 当前状态: ${_isExpanded ? "展开" : "收缩"}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),

            const SizedBox(height: 32),

            // 示例2：不同对齐方式
            _buildSection(
              title: '不同对齐方式',
              child: Column(
                children: [
                  _buildAlignmentExample('左对齐', WrapAlignment.start),
                  const SizedBox(height: 12),
                  _buildAlignmentExample('居中对齐', WrapAlignment.center),
                  const SizedBox(height: 12),
                  _buildAlignmentExample('右对齐', WrapAlignment.end),
                  const SizedBox(height: 12),
                  _buildAlignmentExample('两端对齐', WrapAlignment.spaceBetween),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 示例3：不限制行数
            _buildSection(
              title: '不限制行数 (maxLines = 0)',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ShrinkWrap(
                  spacing: 8,
                  runSpacing: 8,
                  maxLines: 0, // 不限制行数
                  children: _tags.take(8).map((tag) => _buildTag(tag)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildAlignmentExample(String title, WrapAlignment alignment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ShrinkWrap(
            alignment: alignment,
            spacing: 6,
            runSpacing: 6,
            maxLines: 2,
            children: _tags.take(6).map((tag) => _buildSmallTag(tag)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
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
    );
  }

  Widget _buildSmallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blue.shade700,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ... existing code ...
