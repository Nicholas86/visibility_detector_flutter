/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-14 16:22:36
 */

/// 瀑布流交替播放视频演示页面
/// 基于 https://juejin.cn/post/7243240589293142077 实现
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'waterfall_flow_grid_item_view.dart';
import 'waterfall_flow_swipe_view.dart';
import 'waterfall_flow_type.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:faker/faker.dart';

class WaterfallFlowPage extends StatefulWidget {
  const WaterfallFlowPage({Key? key}) : super(key: key);

  @override
  State<WaterfallFlowPage> createState() => WaterfallFlowPageState();
}

class WaterfallFlowPageState extends State<WaterfallFlowPage> {
  // 视频资源URL列表
  static const List<String> videoUrls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  ];

  // Faker实例用于生成测试数据
  final faker = Faker();

  BuildContext? grid1Context;
  BuildContext? grid2Context;
  BuildContext? swipeContext;

  BuildContext? firstChildCtxInViewport;
  bool isRemoveSwipe = false;

  int hitIndex = 0;
  WaterFlowHitType hitType = WaterFlowHitType.firstGrid;

  double observeOffset = 150;

  // Debug信息相关状态变量
  double _hitLinePosition = 150.0;
  Set<int> _hitGridItems = {};
  int? _hitSwipeIndex;
  int _currentSwipeIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waterfall Flow')),
      body: SliverViewObserver(
        child: _buildBody(),
        leadingOffset: observeOffset,
        scrollNotificationPredicate: defaultScrollNotificationPredicate,
        autoTriggerObserveTypes: const [
          ObserverAutoTriggerObserveType.scrollEnd,
        ],
        triggerOnObserveType: ObserverTriggerOnObserveType.directly,
        extendedHandleObserve: (context) {
          // An extension of the original observation logic.
          final _obj = ObserverUtils.findRenderObject(context);
          if (_obj is RenderSliverWaterfallFlow) {
            return ObserverCore.handleGridObserve(
              context: context,
              fetchLeadingOffset: () => observeOffset,
            );
          }
          return null;
        },
        // customHandleObserve: (context) {
        //   // Here you can customize the observation logic.
        //   final _obj = ObserverUtils.findRenderObject(context);
        //   if (_obj is RenderSliverList) {
        //     ObserverCore.handleListObserve(context: context);
        //   }
        //   if (_obj is RenderSliverGrid || _obj is RenderSliverWaterfallFlow) {
        //     return ObserverCore.handleGridObserve(context: context);
        //   }
        //   return null;
        // },
        sliverContexts: () {
          return [
            if (grid1Context != null) grid1Context!,
            if (swipeContext != null) swipeContext!,
            if (grid2Context != null) grid2Context!,
          ];
        },
        onObserveViewport: (result) {
          firstChildCtxInViewport = result.firstChild.sliverContext;
          if (firstChildCtxInViewport == grid1Context) {
            debugPrint('current first sliver in viewport - gridView1');
            if (WaterFlowHitType.firstGrid == hitType) return;
            hitType = WaterFlowHitType.firstGrid;
            hitIndex = -1;
          } else if (firstChildCtxInViewport == swipeContext) {
            debugPrint('current first sliver in viewport - swipeView');
            if (WaterFlowHitType.swipe == hitType) return;
            setState(() {
              hitType = WaterFlowHitType.swipe;
            });
          } else if (firstChildCtxInViewport == grid2Context) {
            debugPrint('current first sliver in viewport - gridView2');
            if (WaterFlowHitType.secondGrid == hitType) return;
            hitType = WaterFlowHitType.secondGrid;
            hitIndex = -1;
          }
        },
        onObserveAll: (resultMap) {
          final result = resultMap[firstChildCtxInViewport];
          if (firstChildCtxInViewport == grid1Context) {
            if (WaterFlowHitType.firstGrid != hitType) return;
            if (result == null || result is! GridViewObserveModel) return;
            final firstIndexList = result.firstGroupChildList.map((e) {
              return e.index;
            }).toList();
            handleGridHitIndex(firstIndexList);
          } else if (firstChildCtxInViewport == swipeContext) {
          } else if (firstChildCtxInViewport == grid2Context) {
            if (WaterFlowHitType.secondGrid != hitType) return;
            if (result == null || result is! GridViewObserveModel) return;
            final firstIndexList = result.firstGroupChildList.map((e) {
              return e.index;
            }).toList();
            handleGridHitIndex(firstIndexList);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.swipe),
        onPressed: () {
          setState(() {
            isRemoveSwipe = !isRemoveSwipe;
          });
        },
      ),
    );
  }

  handleGridHitIndex(List<int> firstIndexList) {
    if (firstIndexList.isEmpty) return;
    // debugPrint('gridContext displaying -- $firstIndexList');
    int targetIndex = firstIndexList.indexOf(hitIndex);
    if (targetIndex == -1) {
      targetIndex = 0;
    } else {
      targetIndex = targetIndex + 1;
      if (targetIndex >= firstIndexList.length) {
        targetIndex = 0;
      }
    }
    setState(() {
      hitIndex = firstIndexList[targetIndex];
    });
  }

  Widget _buildScrollView() {
    return CustomScrollView(
      slivers: [
        _buildBanner(),
        _buildSeparator(8),
        _buildGridView(isFirst: true, childCount: 5),
        _buildSeparator(8),
        _buildSwipeView(),
        _buildSeparator(15),
        _buildGridView(isFirst: false, childCount: 20),
      ],
    );
  }

  Widget _buildBody() {
    Widget resultWidget = Stack(
      children: [
        _buildScrollView(),
        Positioned(
          left: 0,
          right: 0,
          height: 1,
          top: observeOffset,
          child: Container(color: Colors.red),
        ),
        _buildDebugInfo(),
      ],
    );
    return resultWidget;
  }

  Widget _buildBanner() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.green,
        height: 120,
        child: const Center(
          child: Text(
            'Banner',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView({
    bool isFirst = false,
    required int childCount,
  }) {
    return SliverWaterfallFlow(
      gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          WaterFlowHitType selfType;
          if (isFirst) {
            if (grid1Context != context) grid1Context = context;
            selfType = WaterFlowHitType.firstGrid;
          } else {
            if (grid2Context != context) grid2Context = context;
            selfType = WaterFlowHitType.secondGrid;
          }
          return WaterfallFlowGridItemView(
            selfIndex: index,
            selfType: selfType,
            hitIndex: hitIndex,
            hitType: hitType,
            videoUrls: videoUrls,
          );
        },
        childCount: childCount,
      ),
    );
  }

  Widget _buildSwipeView() {
    if (isRemoveSwipe) {
      swipeContext = null;
      return const SliverToBoxAdapter(child: SizedBox());
    }
    return SliverObserveContextToBoxAdapter(
      child: WaterfallFlowSwipeView(
        hitType: hitType,
        videoUrls: videoUrls,
      ),
      onObserve: (context) {
        if (swipeContext != context) swipeContext = context;
      },
    );
  }

  Widget _buildSeparator(double size) {
    return SliverToBoxAdapter(
      child: Container(height: size),
    );
  }

  Widget _buildDebugInfo() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '红线位置: ${_hitLinePosition.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.yellow, fontSize: 12),
            ),
            Text(
              '命中瀑布流: ${_hitGridItems.join(', ')}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              '命中影音栏目: ${_hitSwipeIndex ?? 'None'}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              '当前影音页: $_currentSwipeIndex',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              '滚动位置: ${_scrollController.hasClients ? _scrollController.offset.toStringAsFixed(1) : '0.0'}',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
