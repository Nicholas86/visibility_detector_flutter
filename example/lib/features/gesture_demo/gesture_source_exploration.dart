// Flutter手势系统源码探索和机制分析
// 本文件用于探索和演示Flutter手势识别的核心机制

import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Flutter手势系统探索主页面
class GestureSourceExplorationPage extends StatefulWidget {
  const GestureSourceExplorationPage({Key? key}) : super(key: key);

  @override
  State<GestureSourceExplorationPage> createState() => _GestureSourceExplorationPageState();
}

class _GestureSourceExplorationPageState extends State<GestureSourceExplorationPage> {
  String _gestureInfo = '等待手势操作...';
  String _recognizerInfo = '手势识别器状态: 未激活';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter手势源码探索'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 手势系统架构说明
            _buildGestureTheorySection(),

            // 技术实现细节说明
            _buildTechnicalDetailsSection(),

            // 手势信息显示区域
            _buildGestureInfoSection(),

            // 手势识别器信息显示区域
            _buildRecognizerInfoSection(),

            // 自定义手势识别区域
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: RawGestureDetector(
                gestures: {
                  MultiTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<MultiTapGestureRecognizer>(
                    () => MultiTapGestureRecognizer(targetTapCount: 8),
                    (MultiTapGestureRecognizer instance) {
                      instance
                        ..onTapDown = (details, n) {
                          _updateGestureInfo('专业TapDown触发 - 第${n}击');
                          _updateRecognizerInfo('专业识别器: Down at ${details.globalPosition}, 击打次数: $n');
                        }
                        ..onTapCancel = (n) {
                          _updateGestureInfo('专业TapCancel触发');
                          _updateRecognizerInfo('专业识别器: Cancel at $n');
                        }
                        ..onMultiTapComplete = (n) {
                          _updateGestureInfo('🎉 ${n}连击触发! 🎉');
                          _updateRecognizerInfo('专业识别器: ${n}连击完成! (竞技机制)');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎉 恭喜！成功触发${n}连击！🎉\n使用了专业的手势竞技机制'),
                              backgroundColor: n >= 8 ? Colors.green : Colors.orange,
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        };
                    },
                  )
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.touch_app,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '🎯 专业手势识别区域',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '快速连续点击8次触发连击！',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '使用MultiTapGestureRecognizer',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 手势理论部分
  Widget _buildGestureTheorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flutter手势系统核心概念',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              '1. GestureBinding: 手势绑定层，连接底层指针事件和高层手势识别\n'
              '2. GestureArena: 手势竞技场，解决多个手势识别器的冲突\n'
              '3. GestureRecognizer: 手势识别器基类，定义手势识别的基本行为\n'
              '4. PointerEvent: 指针事件，包含触摸、鼠标等输入的原始数据\n'
              '5. HitTest: 命中测试，确定哪些组件应该接收指针事件',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建技术实现细节说明
  Widget _buildTechnicalDetailsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔧 核心技术实现细节',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTechnicalDetail(
              '状态管理',
              '_TapTracker类负责单指跟踪，包含pointer、entry、_initialPosition等关键状态',
            ),
            _buildTechnicalDetail(
              '竞技场策略',
              '使用GestureBinding.instance.gestureArena.hold()延迟决策，确保与其他手势识别器公平竞争',
            ),
            _buildTechnicalDetail(
              '时间控制',
              '_Countdown类实现精确的时间窗口控制，支持最小间隔和超时检测',
            ),
            _buildTechnicalDetail(
              '事件路由',
              'PointerRouter.addRoute()建立事件监听，实现精确的指针事件分发',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalDetail(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建手势信息显示区域
  Widget _buildGestureInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.green),
          const SizedBox(width: 8),
          const Text(
            '手势信息: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              _gestureInfo,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建识别器信息显示区域
  Widget _buildRecognizerInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings_input_component, color: Colors.orange),
          const SizedBox(width: 8),
          const Text(
            '识别器状态: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              _recognizerInfo,
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _updateGestureInfo(String info) {
    setState(() {
      _gestureInfo = info;
    });
  }

  void _updateRecognizerInfo(String info) {
    setState(() {
      _recognizerInfo = info;
    });
  }
}

typedef MultiTapDownCallback = void Function(TapDownDetails details, int tapCount);
typedef MultiTapCancelCallback = void Function(int tapCount);
typedef MultiTapCompleteCallback = void Function(int tapCount);

/// 支持 N 连击的手势识别器（默认 8 连击）
/// - 使用 GestureArena 参与手势竞技
/// - 支持最小间隔 / 最大间隔 / 位置容差
/// - 兼容多种输入设备
class MultiTapGestureRecognizer extends GestureRecognizer {
  MultiTapGestureRecognizer({
    Object? debugOwner,
    this.supportedDevices,
    this.targetTapCount = 8,
    this.onTapDown,
    this.onTapCancel,
    this.onMultiTapComplete,
  }) : super(debugOwner: debugOwner);

  /// 支持的输入设备类型（例如 {PointerDeviceKind.touch, PointerDeviceKind.mouse}）
  /// 如果为 null，则支持所有设备
  @override
  final Set<PointerDeviceKind>? supportedDevices;

  /// 目标连击数（默认 8）
  final int targetTapCount;

  MultiTapDownCallback? onTapDown;
  MultiTapCancelCallback? onTapCancel;
  MultiTapCompleteCallback? onMultiTapComplete;

  // ---------- 内部状态 ----------
  int _tapCount = 0;
  _TapTracker? _prevTap;
  final Map<int, _TapTracker> _trackers = <int, _TapTracker>{};
  Timer? _tapTimer;
  bool _disposed = false;

  // ---------- 常量 ----------
  static const Duration _minTapInterval = kDoubleTapMinTime; // 最小 40ms
  static const Duration _tapTimeout = kDoubleTapTimeout; // 最大 300ms
  static const double _globalSlop = kDoubleTapSlop; // 全局容差
  static const double _touchSlop = kDoubleTapTouchSlop; // 单次点击移动容差

  @override
  void addPointer(PointerDownEvent event) {
    // 设备过滤
    if (supportedDevices != null && !supportedDevices!.contains(event.kind)) {
      return;
    }

    final entry = GestureBinding.instance.gestureArena.add(event.pointer, this);
    final tracker = _TapTracker(
      event: event,
      entry: entry,
      minTime: _minTapInterval,
    );

    // 全局 slop 校验：检查新点击是否离上一次过远
    if (_prevTap != null && (event.position - _prevTap!._initialPosition).distance > _globalSlop) {
      _reject(tracker);
      return;
    }

    // 校验按钮一致性（鼠标/触控笔常用）
    if (_prevTap != null && !tracker.hasSameButton(event)) {
      _reject(tracker);
      return;
    }

    _trackers[event.pointer] = tracker;

    // 回调按下
    if (onTapDown != null) {
      final details = TapDownDetails(
        globalPosition: event.position,
        localPosition: event.localPosition,
        kind: event.kind,
      );
      invokeCallback<void>('onTapDown', () => onTapDown!(details, _tapCount + 1));
    }

    tracker.startTrackingPointer(_handleEvent, event.transform);
  }

  void _handleEvent(PointerEvent event) {
    if (_disposed) return;

    final tracker = _trackers[event.pointer];
    if (tracker == null) return;

    if (event is PointerMoveEvent) {
      // 单次点击的移动容差
      if (!tracker.isWithinTolerance(event, _touchSlop)) {
        _reject(tracker);
      }
    } else if (event is PointerUpEvent) {
      // 校验最小点击间隔
      if (!tracker.hasElapsedMinTime()) {
        _reject(tracker);
        return;
      }

      final upcoming = _tapCount + 1;
      if (_prevTap == null || upcoming != targetTapCount) {
        _registerTap(tracker);
      } else {
        _registerLastTap(tracker);
      }
    } else if (event is PointerCancelEvent) {
      _reject(tracker);
    }
  }

  @override
  void rejectGesture(int pointer) {
    _TapTracker? tracker = _trackers[pointer];
    if (tracker == null && _prevTap != null && _prevTap!.pointer == pointer) {
      tracker = _prevTap;
    }
    if (tracker != null) _reject(tracker);
  }

  @override
  void acceptGesture(int pointer) {
    // no-op
  }

  @override
  String get debugDescription => 'multi-tap($targetTapCount)';

  @override
  void dispose() {
    _disposed = true;
    _tapTimer?.cancel();
    _tapTimer = null;
    final copy = _trackers.values.toList();
    for (final t in copy) {
      _reject(t);
    }
    if (_prevTap != null) {
      try {
        _prevTap!.entry.resolve(GestureDisposition.rejected);
      } catch (_) {}
      _prevTap = null;
    }
    super.dispose();
  }

  // ---------- 内部处理 ----------

  void _registerTap(_TapTracker tracker) {
    _startTapTimer();
    GestureBinding.instance.gestureArena.hold(tracker.pointer);
    _freezeTracker(tracker);
    _trackers.remove(tracker.pointer);
    _clearTrackers();
    _prevTap = tracker;
    _tapCount++;
  }

  void _registerLastTap(_TapTracker tracker) {
    _tapCount++;
    tracker.entry.resolve(GestureDisposition.accepted);
    _freezeTracker(tracker);
    _trackers.remove(tracker.pointer);

    if (onMultiTapComplete != null) {
      invokeCallback<void>('onMultiTapComplete', () => onMultiTapComplete!(_tapCount));
    }

    _reset();
  }

  void _reject(_TapTracker tracker) {
    _trackers.remove(tracker.pointer);
    tracker.entry.resolve(GestureDisposition.rejected);
    _freezeTracker(tracker);

    if (_prevTap != null) {
      if (tracker == _prevTap) {
        _reset();
      } else {
        _checkCancel();
        if (_trackers.isEmpty) _reset();
      }
    }
  }

  void _clearTrackers() {
    final List<_TapTracker> copy = _trackers.values.toList();
    for (final t in copy) {
      _reject(t);
    }
  }

  void _freezeTracker(_TapTracker tracker) {
    tracker.stopTrackingPointer(_handleEvent);
  }

  void _startTapTimer() {
    _tapTimer?.cancel();
    _tapTimer = Timer(_tapTimeout, () {
      if (_disposed) return;
      _checkCancel();
      _reset();
    });
  }

  void _stopTapTimer() {
    _tapTimer?.cancel();
    _tapTimer = null;
  }

  void _checkCancel() {
    if (onTapCancel != null) {
      invokeCallback<void>('onTapCancel', () => onTapCancel!(_tapCount));
    }
  }

  void _reset() {
    _stopTapTimer();
    if (_prevTap != null) {
      final tracker = _prevTap!;
      _prevTap = null;
      if (_tapCount == 1) {
        tracker.entry.resolve(GestureDisposition.rejected);
      } else {
        tracker.entry.resolve(GestureDisposition.accepted);
      }
      _freezeTracker(tracker);
      GestureBinding.instance.gestureArena.release(tracker.pointer);
    }
    _clearTrackers();
    _tapCount = 0;
  }
}

/// 单指跟踪器
class _TapTracker {
  _TapTracker({
    required PointerDownEvent event,
    required this.entry,
    required Duration minTime,
  })  : pointer = event.pointer,
        _initialPosition = event.position,
        _buttons = event.buttons,
        _minDelay = _Countdown(minTime);

  final int pointer;
  final GestureArenaEntry entry;
  final Offset _initialPosition;
  final int _buttons;
  final _Countdown _minDelay;
  bool _tracking = false;

  void startTrackingPointer(PointerRoute route, [Matrix4? transform]) {
    if (!_tracking) {
      _tracking = true;
      GestureBinding.instance.pointerRouter.addRoute(pointer, route);
    }
  }

  void stopTrackingPointer(PointerRoute route) {
    if (_tracking) {
      _tracking = false;
      GestureBinding.instance.pointerRouter.removeRoute(pointer, route);
    }
  }

  bool isWithinTolerance(PointerEvent event, double tolerance) {
    final offset = event.position - _initialPosition;
    return offset.distance <= tolerance;
  }

  bool hasElapsedMinTime() => _minDelay.timeout;

  bool hasSameButton(PointerDownEvent event) => event.buttons == _buttons;
}

class _Countdown {
  _Countdown(Duration duration) {
    Timer(duration, _onTimeout);
  }

  bool timeout = false;

  void _onTimeout() => timeout = true;
}
