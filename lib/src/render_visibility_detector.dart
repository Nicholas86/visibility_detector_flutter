// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'visibility_detector.dart';
import 'visibility_detector_controller.dart';

mixin RenderVisibilityDetectorBase on RenderObject {
  static int? get debugUpdateCount {
    if (!kDebugMode) {
      return null;
    }
    return _updates.length;
  }

  static Map<Key, VoidCallback> _updates = <Key, VoidCallback>{};
  static Map<Key, VisibilityInfo> _lastVisibility = <Key, VisibilityInfo>{};

  /// 参见 [VisibilityDetectorController.notifyNow]。
  static void notifyNow() {
    print('🚀 [VisibilityDetector] notifyNow() called - cancelling timer and processing callbacks immediately');
    _timer?.cancel();
    _timer = null;
    _processCallbacks();
  }

  static void forget(Key key) {
    print('🗑️ [VisibilityDetector] forget() called for key: $key');
    _updates.remove(key);
    _lastVisibility.remove(key);

    if (_updates.isEmpty) {
      print('⏹️ [VisibilityDetector] forget() - no more updates, cancelling timer');
      _timer?.cancel();
      _timer = null;
    }
  }

  static Timer? _timer;
  static void _handleTimer() {
    print('⏰ [VisibilityDetector] _handleTimer() called - timer expired, scheduling callback processing');
    _timer = null;
    // 确保工作在帧之间完成，以便从一致的状态执行计算。我们在这里使用 `scheduleTask<T>`
    // 而不是 `addPostFrameCallback` 或 `scheduleFrameCallback`，这样即使没有安排新帧
    // 也会完成工作，并且不会不必要地安排新帧。
    SchedulerBinding.instance.scheduleTask<void>(
      _processCallbacks,
      Priority.touch,
    );
  }

  /// 为所有更新的实例执行可见性回调。
  static void _processCallbacks() {
    print('📋 [VisibilityDetector] _processCallbacks() called - processing ${_updates.length} callbacks');
    for (final entry in _updates.entries) {
      print('▶️ [VisibilityDetector] _processCallbacks() - executing callback for key: ${entry.key}');
      entry.value();
    }
    _updates.clear();
    print('✅ [VisibilityDetector] _processCallbacks() completed - all callbacks processed and cleared');
  }

  void _fireCallback(ContainerLayer? layer, Rect bounds) {
    print('🔥 [VisibilityDetector] _fireCallback() called for key: $key, bounds: $bounds, layer: ${layer?.runtimeType}');
    
    final oldInfo = _lastVisibility[key];
    print('📊 [VisibilityDetector] _fireCallback() - oldInfo: ${oldInfo?.toString() ?? 'null'}');
    
    final info = _determineVisibility(layer, bounds);
    print('📈 [VisibilityDetector] _fireCallback() - newInfo: $info');
    
    final visible = !info.visibleBounds.isEmpty;
    print('👁️ [VisibilityDetector] _fireCallback() - visible: $visible');

    if (oldInfo == null) {
      if (!visible) {
        print('⏭️ [VisibilityDetector] _fireCallback() - no oldInfo and not visible, returning early');
        return;
      }
    } else if (info.matchesVisibility(oldInfo)) {
      print('⏭️ [VisibilityDetector] _fireCallback() - visibility unchanged, returning early');
      return;
    }

    if (visible) {
      print('💾 [VisibilityDetector] _fireCallback() - storing visibility info for key: $key');
      _lastVisibility[key] = info;
    } else {
      // 仅跟踪可见项目，这样映射不会无限增长。
      print('🗑️ [VisibilityDetector] _fireCallback() - removing visibility info for key: $key (not visible)');
      _lastVisibility.remove(key);
    }

    print('📞 [VisibilityDetector] _fireCallback() - calling onVisibilityChanged callback');
    onVisibilityChanged?.call(info);
  }

  /// 对应 [VisibilityDetector] 小部件的键。
  Key get key;

  VoidCallback? _compositionCallbackCanceller;

  VisibilityChangedCallback? _onVisibilityChanged;

  /// 参见 [VisibilityDetector.onVisibilityChanged]。
  VisibilityChangedCallback? get onVisibilityChanged => _onVisibilityChanged;

  /// 由 [VisibilityDetector.updateRenderObject] 使用。
  set onVisibilityChanged(VisibilityChangedCallback? value) {
    print('⚙️ [VisibilityDetector] onVisibilityChanged setter called for key: $key, value: ${value != null ? 'non-null callback' : 'null'}');
    
    if (_onVisibilityChanged == value) {
      print('⏭️ [VisibilityDetector] onVisibilityChanged setter - value unchanged, returning early');
      return;
    }
    
    _compositionCallbackCanceller?.call();
    _compositionCallbackCanceller = null;
    _onVisibilityChanged = value;

    if (value == null) {
      // 移除所有缓存数据，这样当计时器到期时我们不会触发可见性回调，
      // 或者下次获得过时的旧信息。
      print('🗑️ [VisibilityDetector] onVisibilityChanged setter - callback is null, forgetting key: $key');
      forget(key);
    } else {
      print('🎨 [VisibilityDetector] onVisibilityChanged setter - callback is non-null, marking needs paint and scheduling update');
      markNeedsPaint();
      // 如果正在进行更新且某个祖先不再绘制此 RO，上面的 markNeedsPaint 
      // 永远不会导致组合回调触发，我们可能会错过隐藏事件。如果调用了 paint，
      // 此调度将被 paint 中的后续更新覆盖。
      _scheduleUpdate();
    }
  }

  int _debugScheduleUpdateCount = 0;

  /// 从 [Layer.addCompositionCallback] 调用调度更新回调的次数。
  ///
  /// 这用于测试，在调试模式之外始终返回 null。
  @visibleForTesting
  int? get debugScheduleUpdateCount {
    if (kDebugMode) {
      return _debugScheduleUpdateCount;
    }
    return null;
  }

  void _scheduleUpdate([ContainerLayer? layer]) {
    print('📅 [VisibilityDetector] _scheduleUpdate() called for key: $key, layer: ${layer?.runtimeType}');
    
    if (kDebugMode) {
      _debugScheduleUpdateCount += 1;
      print('🔢 [VisibilityDetector] _scheduleUpdate() - debug count incremented to: $_debugScheduleUpdateCount');
    }
    
    bool isFirstUpdate = _updates.isEmpty;
    print('🆕 [VisibilityDetector] _scheduleUpdate() - isFirstUpdate: $isFirstUpdate');
    
    _updates[key] = () {
      print('🎯 [VisibilityDetector] _scheduleUpdate() - executing scheduled callback for key: $key');
      if (bounds == null) {
        // 如果调用了 set onVisibilityChanged 并传入非空值，但此渲染对象尚未布局，
        // 就会发生这种情况。在这种情况下，它没有大小或几何形状，我们不应该担心触发
        // 更新，因为它从未可见过。
        print('❌ [VisibilityDetector] _scheduleUpdate() - bounds is null, skipping callback');
        return;
      }
      print('✅ [VisibilityDetector] _scheduleUpdate() - bounds available: $bounds, firing callback');
      _fireCallback(layer, bounds!);
    };
    
    final updateInterval = VisibilityDetectorController.instance.updateInterval;
    print('⏱️ [VisibilityDetector] _scheduleUpdate() - updateInterval: $updateInterval');
    
    if (updateInterval == Duration.zero) {
      // 即使使用 [Duration.zero]，我们仍然希望将回调延迟到帧结束，
      // 以便从一致的状态处理它们。这也确保它们在我们处于帧中间时不会改变小部件树。
      if (isFirstUpdate) {
        // 我们即将渲染一帧，所以帧后回调保证会触发，
        // 这比 `scheduleTask<T>` 提供更好的即时性。
        print('🖼️ [VisibilityDetector] _scheduleUpdate() - scheduling post-frame callback (Duration.zero)');
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          print('🎬 [VisibilityDetector] _scheduleUpdate() - post-frame callback triggered');
          _processCallbacks();
        });
      }
    } else if (_timer == null) {
      // 我们使用普通的 [Timer] 而不是 [RestartableTimer]，
      // 这样更新持续时间的更改将自动被采用。
      print('⏰ [VisibilityDetector] _scheduleUpdate() - creating new timer with interval: $updateInterval');
      _timer = Timer(updateInterval, _handleTimer);
    } else {
      print('⏸️ [VisibilityDetector] _scheduleUpdate() - timer already active, not creating new one');
      assert(_timer!.isActive);
    }
  }

  VisibilityInfo _determineVisibility(ContainerLayer? layer, Rect bounds) {
    print('🔍 [VisibilityDetector] _determineVisibility() called for key: $key, bounds: $bounds, layer: ${layer?.runtimeType}');
    
    if (_disposed || layer == null || layer.attached == false || !attached) {
      // layer 已分离，因此不可见。
      print('💀 [VisibilityDetector] _determineVisibility() - disposed/detached state, returning invisible');
      return VisibilityInfo(
        key: key,
        size: _lastVisibility[key]?.size ?? Size.zero,
      );
    }
    
    final transform = Matrix4.identity();
    print('🔧 [VisibilityDetector] _determineVisibility() - initialized transform matrix');

    // 检查是否有任何祖先决定跳过绘制此 RenderObject。
    if (parent != null) {
      print('👨‍👩‍👧‍👦 [VisibilityDetector] _determineVisibility() - checking ancestor paint chain');
      RenderObject ancestor = parent! as RenderObject;
      RenderObject child = this;
      while (ancestor.parent != null) {
        if (!ancestor.paintsChild(child)) {
          print('🚫 [VisibilityDetector] _determineVisibility() - ancestor ${ancestor.runtimeType} does not paint child, returning invisible');
          return VisibilityInfo(key: key, size: bounds.size);
        }
        child = ancestor;
        ancestor = ancestor.parent! as RenderObject;
      }
      print('✅ [VisibilityDetector] _determineVisibility() - all ancestors paint their children');
    }

    // 创建从 layer 到根的 Layer 列表，排除根，因为根具有 DPR 变换，
    // 我们希望使用逻辑像素。添加一个额外的叶子层，以便我们可以将 `layer` 的变换应用到矩阵。
    ContainerLayer? ancestor = layer;
    final List<ContainerLayer> ancestors = <ContainerLayer>[ContainerLayer()];
    while (ancestor != null && ancestor.parent != null) {
      ancestors.add(ancestor);
      ancestor = ancestor.parent;
    }
    print('🏗️ [VisibilityDetector] _determineVisibility() - built ancestor chain with ${ancestors.length} layers');

    Rect clip = Rect.largest;
    for (int index = ancestors.length - 1; index > 0; index -= 1) {
      final parent = ancestors[index];
      final child = ancestors[index - 1];
      Rect? parentClip = parent.describeClipBounds();
      if (parentClip != null) {
        clip = clip.intersect(MatrixUtils.transformRect(transform, parentClip));
        print('✂️ [VisibilityDetector] _determineVisibility() - applied clip from layer ${parent.runtimeType}: $parentClip');
      }
      parent.applyTransform(child, transform);
    }

    // 应用绘制时画布上的任何变换/裁剪。
    if (_lastPaintClipBounds != null) {
      clip = clip.intersect(MatrixUtils.transformRect(
        transform,
        _lastPaintClipBounds!,
      ));
      print('🎨 [VisibilityDetector] _determineVisibility() - applied paint clip bounds: $_lastPaintClipBounds');
    }
    if (_lastPaintTransform != null) {
      transform.multiply(_lastPaintTransform!);
      print('🔄 [VisibilityDetector] _determineVisibility() - applied paint transform');
    }
    
    final result = VisibilityInfo.fromRects(
      key: key,
      widgetBounds: MatrixUtils.transformRect(transform, bounds),
      clipRect: clip,
    );
    
    print('📊 [VisibilityDetector] _determineVisibility() - calculated visibility: $result');
    return result;
  }

  /// 用于在需要更新客户端可见性时获取渲染对象的边界。
  ///
  /// null 值表示边界不可用。
  Rect? get bounds;

  Matrix4? _lastPaintTransform;
  Rect? _lastPaintClipBounds;

  @override
  void paint(PaintingContext context, Offset offset) {
    print('🎨 [VisibilityDetector] paint() called for key: $key, offset: $offset');
    
    if (onVisibilityChanged != null) {
      print('👁️ [VisibilityDetector] paint() - onVisibilityChanged is not null, capturing paint context');
      
      _lastPaintClipBounds = context.canvas.getLocalClipBounds();
      _lastPaintTransform =
          Matrix4.fromFloat64List(context.canvas.getTransform())
            ..translate(offset.dx, offset.dy, 0);

      print('📐 [VisibilityDetector] paint() - captured clip bounds: $_lastPaintClipBounds');
      print('🔄 [VisibilityDetector] paint() - captured transform with offset: $offset');

      _compositionCallbackCanceller?.call();
      _compositionCallbackCanceller =
          context.addCompositionCallback((Layer layer) {
        print('🎭 [VisibilityDetector] paint() - composition callback triggered for layer: ${layer.runtimeType}');
        assert(!debugDisposed!);
        final ContainerLayer? container =
            layer is ContainerLayer ? layer : layer.parent;
        print('📦 [VisibilityDetector] paint() - scheduling update with container: ${container?.runtimeType}');
        _scheduleUpdate(container);
      });
      
      print('✅ [VisibilityDetector] paint() - composition callback registered');
    } else {
      print('❌ [VisibilityDetector] paint() - onVisibilityChanged is null, skipping visibility tracking');
    }
    
    super.paint(context, offset);
    print('🏁 [VisibilityDetector] paint() completed for key: $key');
  }

  bool _disposed = false;
  @override
  void dispose() {
    print('🗑️ [VisibilityDetector] dispose() called for key: $key');
    
    _compositionCallbackCanceller?.call();
    _compositionCallbackCanceller = null;
    _disposed = true;
    
    print('✅ [VisibilityDetector] dispose() - cancelled composition callback and marked as disposed');
    super.dispose();
  }
}

/// 对应 [VisibilityDetector] 小部件的 [RenderObject]。
class RenderVisibilityDetector extends RenderProxyBox
    with RenderVisibilityDetectorBase {
  /// 构造函数。参数详情请参见相应的属性。
  RenderVisibilityDetector({
    RenderBox? child,
    required this.key,
    required VisibilityChangedCallback? onVisibilityChanged,
  })  : assert(key != null),
        super(child) {
    _onVisibilityChanged = onVisibilityChanged;
  }

  @override
  final Key key;

  @override
  Rect? get bounds => hasSize ? semanticBounds : null;
}

/// 对应 [SliverVisibilityDetector] 小部件的 [RenderObject]。
///
/// [RenderSliverVisibilityDetector] 是 [SliverVisibilityDetector] 
/// 和 [VisibilityDetectorLayer] 之间的桥梁。
class RenderSliverVisibilityDetector extends RenderProxySliver
    with RenderVisibilityDetectorBase {
  /// 构造函数。参数详情请参见相应的属性。
  RenderSliverVisibilityDetector({
    RenderSliver? sliver,
    required this.key,
    required VisibilityChangedCallback? onVisibilityChanged,
  }) : super(sliver) {
    _onVisibilityChanged = onVisibilityChanged;
  }

  @override
  final Key key;

  @override
  Rect? get bounds {
    if (geometry == null) {
      return null;
    }

    Size widgetSize;
    Offset widgetOffset;
    switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      case AxisDirection.down:
        widgetOffset = Offset(0, -constraints.scrollOffset);
        widgetSize = Size(constraints.crossAxisExtent, geometry!.scrollExtent);
        break;
      case AxisDirection.up:
        final startOffset = geometry!.paintExtent +
            constraints.scrollOffset -
            geometry!.scrollExtent;
        widgetOffset = Offset(0, math.min(startOffset, 0));
        widgetSize = Size(constraints.crossAxisExtent, geometry!.scrollExtent);
        break;
      case AxisDirection.right:
        widgetOffset = Offset(-constraints.scrollOffset, 0);
        widgetSize = Size(geometry!.scrollExtent, constraints.crossAxisExtent);
        break;
      case AxisDirection.left:
        final startOffset = geometry!.paintExtent +
            constraints.scrollOffset -
            geometry!.scrollExtent;
        widgetOffset = Offset(math.min(startOffset, 0), 0);
        widgetSize = Size(geometry!.scrollExtent, constraints.crossAxisExtent);
        break;
    }
    return widgetOffset & widgetSize;
  }
}
