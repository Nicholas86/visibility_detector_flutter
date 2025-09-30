/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-06-08 21:59:07
 */
import 'package:flutter/material.dart';
import 'video_widget.dart';
import 'waterfall_flow_type.dart';

class WaterfallFlowGridItemView extends StatelessWidget {
  final int selfIndex;
  final WaterFlowHitType selfType;

  final int hitIndex;
  final WaterFlowHitType hitType;
  
  final List<String> videoUrls;

  bool get isHit => selfType == hitType && selfIndex == hitIndex;

  const WaterfallFlowGridItemView({
    Key? key,
    required this.selfIndex,
    required this.selfType,
    required this.hitIndex,
    required this.hitType,
    required this.videoUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: isHit ? Colors.amber : Colors.amber[100],
      child: _buildBody(), // Text('grid item $selfIndex'),
      // height: 300,
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isHit ? _buildVideo() : _buildCover(),
        const SizedBox(height: 10),
        Text('grid item $selfIndex'),
        SizedBox(
          height: 50.0 + 50.0 * (selfIndex % 2),
        ),
      ],
    );
  }

  Widget _buildCover() {
    return Image.network(
      'https://images.unsplash.com/photo-1660139099083-03e0777ac6a7?auto=format&fit=crop&w=375&q=100',
      fit: BoxFit.fitWidth,
      width: double.infinity,
      height: 100,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          height: 50,
          alignment: Alignment.center,
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideo() {
    // 根据索引选择对应的视频URL
    final videoUrl = videoUrls.isNotEmpty 
        ? videoUrls[selfIndex % videoUrls.length] 
        : 'https://www.w3schools.com/html/movie.mp4';
        
    Widget resultWidget = VideoWidget(
      url: videoUrl,
    );
    resultWidget = SizedBox(
      width: double.infinity,
      height: 100,
      child: resultWidget,
    );
    return resultWidget;
  }
}
