// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/foundation.dart';

import 'render_visibility_detector.dart';

/// [VisibilityDetectorController] 是一个单例对象，可以为所有 [VisibilityDetector] 
/// 小部件执行操作和更改配置。
class VisibilityDetectorController {
  static final _instance = VisibilityDetectorController();
  static VisibilityDetectorController get instance => _instance;

  /// 在触发可见性回调批次之间等待的最小时间量。
  ///
  /// 如果设置为 [Duration.zero]，回调将在每帧结束时触发。这对自动化测试很有用。
  ///
  /// 更改 [updateInterval] 不会影响任何待处理的回调。如果需要，
  /// 客户端应显式调用 [notifyNow] 来刷新它们。
  Duration updateInterval = const Duration(milliseconds: 500);

  /// 强制立即触发所有待处理的可见性回调。
  ///
  /// 这在拆除小部件树之前（例如切换视图或退出应用程序时）可能是理想的。
  void notifyNow() => RenderVisibilityDetectorBase.notifyNow();

  /// 忘记给定 [key] 的 [VisibilityDetector] 的任何待处理可见性回调。
  ///
  /// 如果小部件被附加/分离，回调将被重新调度。
  ///
  /// 此方法可用于在 [VisibilityDetector] 分离后取消计时器，
  /// 以避免测试中的待处理计时器。
  void forget(Key key) => RenderVisibilityDetectorBase.forget(key);

  int? get debugUpdateCount {
    if (!kDebugMode) {
      return null;
    }
    return RenderVisibilityDetectorBase.debugUpdateCount;
  }
}
