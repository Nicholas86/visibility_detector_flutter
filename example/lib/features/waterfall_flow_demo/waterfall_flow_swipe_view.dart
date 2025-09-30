/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-06-08 22:03:17
 */
import 'package:flutter/material.dart';
import 'video_widget.dart';
import 'waterfall_flow_type.dart';

class WaterfallFlowSwipeView extends StatefulWidget {
  final WaterFlowHitType hitType;
  final List<String> videoUrls;

  const WaterfallFlowSwipeView({
    Key? key,
    required this.hitType,
    required this.videoUrls,
  }) : super(key: key);

  @override
  State<WaterfallFlowSwipeView> createState() => _WaterfallFlowSwipeViewState();
}

class _WaterfallFlowSwipeViewState extends State<WaterfallFlowSwipeView> {
  PageController pageController = PageController(viewportFraction: 0.9);

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = PageView.builder(
      controller: pageController,
      padEnds: false,
      itemBuilder: (context, index) {
        final isHit =
            WaterFlowHitType.swipe == widget.hitType && currentIndex == index;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            color: Colors.blue,
            child: isHit ? _buildVideo() : const SizedBox.shrink(),
          ),
        );
      },
      itemCount: 4,
      onPageChanged: (index) {
        if (currentIndex == index) return;
        setState(() {
          currentIndex = index;
        });
      },
    );
    resultWidget = SizedBox(height: 200, child: resultWidget);
    return resultWidget;
  }

  Widget _buildVideo() {
    // 根据当前页面索引选择对应的视频URL
    final videoUrl = widget.videoUrls.isNotEmpty 
        ? widget.videoUrls[currentIndex % widget.videoUrls.length] 
        : 'https://www.w3schools.com/html/movie.mp4';
        
    Widget resultWidget = VideoWidget(
      url: videoUrl,
    );
    resultWidget = SizedBox(
      width: double.infinity,
      // height: 100,
      child: resultWidget,
    );
    return resultWidget;
  }
}
