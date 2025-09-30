// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:math' show max;

import 'package:flutter/widgets.dart';

import 'render_visibility_detector.dart';

/// [VisibilityDetector] 组件在其可见性发生变化时触发指定的回调函数。
///
/// 回调函数不会在可见性变化时立即触发。相反，回调函数会被延迟和合并，
/// 使得每个 [VisibilityDetector] 的回调函数在每个
/// [VisibilityDetectorController.updateInterval] 周期内最多被调用一次
/// （除非被 [VisibilityDetectorController.notifyNow] 强制触发）。
/// *所有* [VisibilityDetector] 组件的回调函数会在帧之间同步地一起触发。
class VisibilityDetector extends SingleChildRenderObjectWidget {
  /// 构造函数。
  ///
  /// `key` 是必需的，用于正确识别此组件；它在所有 [VisibilityDetector] 
  /// 和 [SliverVisibilityDetector] 组件中必须是唯一的。
  ///
  /// `onVisibilityChanged` 可以为 `null` 来禁用此 [VisibilityDetector]。
  const VisibilityDetector({
    required Key key,
    required Widget child,
    required this.onVisibilityChanged,
  })  : assert(key != null),
        assert(child != null),
        super(key: key, child: child);

  /// 当此组件的可见性发生变化时要调用的回调函数。
  final VisibilityChangedCallback? onVisibilityChanged;

  /// 参见 [RenderObjectWidget.createRenderObject]。
  @override
  RenderVisibilityDetector createRenderObject(BuildContext context) {
    return RenderVisibilityDetector(
      key: key!,
      onVisibilityChanged: onVisibilityChanged,
    );
  }

  /// 参见 [RenderObjectWidget.updateRenderObject]。
  @override
  void updateRenderObject(
      BuildContext context, RenderVisibilityDetector renderObject) {
    assert(renderObject.key == key);
    renderObject.onVisibilityChanged = onVisibilityChanged;
  }
}

class SliverVisibilityDetector extends SingleChildRenderObjectWidget {
  /// 构造函数。
  ///
  /// `key` 是必需的，用于正确识别此组件；它在所有 [VisibilityDetector] 
  /// 和 [SliverVisibilityDetector] 组件中必须是唯一的。
  ///
  /// `onVisibilityChanged` 可以为 `null` 来禁用此 [SliverVisibilityDetector]。
  const SliverVisibilityDetector({
    required Key key,
    required Widget sliver,
    required this.onVisibilityChanged,
  })  : assert(key != null),
        assert(sliver != null),
        super(key: key, child: sliver);

  /// 当此组件的可见性发生变化时要调用的回调函数。
  final VisibilityChangedCallback? onVisibilityChanged;

  /// 参见 [RenderObjectWidget.createRenderObject]。
  @override
  RenderSliverVisibilityDetector createRenderObject(BuildContext context) {
    return RenderSliverVisibilityDetector(
      key: key!,
      onVisibilityChanged: onVisibilityChanged,
    );
  }

  /// 参见 [RenderObjectWidget.updateRenderObject]。
  @override
  void updateRenderObject(
      BuildContext context, RenderSliverVisibilityDetector renderObject) {
    assert(renderObject.key == key);
    renderObject.onVisibilityChanged = onVisibilityChanged;
  }
}

typedef VisibilityChangedCallback = void Function(VisibilityInfo info);

/// 传递给 [VisibilityDetector.onVisibilityChanged] 回调函数的数据。
@immutable
class VisibilityInfo {
  /// 构造函数。
  ///
  /// `key` 对应于用于构造相应 [VisibilityDetector] 组件的 [Key]。不能为 null。
  ///
  /// 如果省略 `size` 或 `visibleBounds`，[VisibilityInfo] 将分别初始化为 
  /// [Offset.zero] 或 [Rect.zero]。这将表示相应的组件完全隐藏。
  const VisibilityInfo({
    required this.key,
    this.size = Size.zero,
    this.visibleBounds = Rect.zero,
  }) : assert(key != null);

  /// 从组件边界和相应的裁剪矩形构造 [VisibilityInfo]。
  ///
  /// [widgetBounds] 和 [clipRect] 预期在同一坐标系中。
  factory VisibilityInfo.fromRects({
    required Key key,
    required Rect widgetBounds,
    required Rect clipRect,
  }) {
    assert(widgetBounds != null);
    assert(clipRect != null);

    final bool overlaps = widgetBounds.overlaps(clipRect);
    // 在组件的局部坐标中计算交集。
    final visibleBounds = overlaps
        ? widgetBounds.intersect(clipRect).shift(-widgetBounds.topLeft)
        : Rect.zero;

    return VisibilityInfo(
      key: key,
      size: widgetBounds.size,
      visibleBounds: visibleBounds,
    );
  }

  /// 对应 [VisibilityDetector] 组件的键。
  final Key key;

  /// 组件的大小。
  final Size size;

  /// 组件的可见部分，以组件的局部坐标表示。
  ///
  /// 边界使用组件的局部坐标报告，以避免在组件位置改变但保持相同可见性时
  /// 对 [VisibilityChangedCallback] 触发的期望。
  final Rect visibleBounds;

  /// 范围在 \[0, 1\] 内的分数，表示组件可见的比例（假设为矩形边界框）。
  ///
  /// 0 表示不可见；1 表示完全可见。
  double get visibleFraction {
    final visibleArea = _area(visibleBounds.size);
    final maxVisibleArea = _area(size);

    if (_floatNear(maxVisibleArea, 0)) {
      // 避免除零错误。
      return 0;
    }

    var visibleFraction = visibleArea / maxVisibleArea;

    if (_floatNear(visibleFraction, 0)) {
      visibleFraction = 0;
    } else if (_floatNear(visibleFraction, 1)) {
      // 浮点运算的不精确性意味着有时可见区域可能永远不等于最大区域
      // （甚至可能略大于最大值）。调整到最大值。
      visibleFraction = 1;
    }

    assert(visibleFraction >= 0);
    assert(visibleFraction <= 1);
    return visibleFraction;
  }

  /// 如果指定的 [VisibilityInfo] 对象与此对象具有等效的可见性，则返回 true。
  bool matchesVisibility(VisibilityInfo info) {
    // 我们不重写 `operator ==`，这样对象相等性可以与两个 [VisibilityInfo] 
    // 对象是否足够相似（不需要为两者都触发回调）分开。如果添加了其他属性，
    // 这可能是相关的。
    assert(info != null);
    return size == info.size && visibleBounds == info.visibleBounds;
  }

  @override
  String toString() {
    return 'VisibilityInfo(key: $key, size: $size visibleBounds: $visibleBounds)';
  }

  @override
  int get hashCode => Object.hash(key, size, visibleBounds);

  @override
  bool operator ==(Object other) {
    return other is VisibilityInfo &&
        other.key == key &&
        other.size == size &&
        other.visibleBounds == visibleBounds;
  }
}

/// 用于确定两个浮点值是否近似相等的容差。
const _kDefaultTolerance = 0.01;

/// 计算指定尺寸矩形的面积。
double _area(Size size) {
  assert(size != null);
  assert(size.width >= 0);
  assert(size.height >= 0);
  return size.width * size.height;
}

/// 如果两个浮点值在指定容差内近似相等，则返回 true。
bool _floatNear(double f1, double f2) {
  final absDiff = (f1 - f2).abs();
  return absDiff <= _kDefaultTolerance ||
      (absDiff / max(f1.abs(), f2.abs()) <= _kDefaultTolerance);
}
