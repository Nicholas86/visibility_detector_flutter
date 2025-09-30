import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'manual_layout.dart';
import 'linear_gradient_progress_indicator.dart';
import 'line_chart.dart';
import 'popup_arrow.dart';
import 'slider.dart';
import 'fixed_size_tab_indicator.dart';
import 'address.dart';
import 'dart:convert';

class ComponentDemosPage extends StatefulWidget {
  const ComponentDemosPage({Key? key}) : super(key: key);

  @override
  State<ComponentDemosPage> createState() => _ComponentDemosPageState();
}

class _ComponentDemosPageState extends State<ComponentDemosPage> with TickerProviderStateMixin {
  late TabController _tabController;
  double _progressValue = 0.3;
  double _sliderValue = 0.5;
  List<RegionData> _selectedRegions = [];
  List<RegionData> _realAddressData = [];
  bool _isLoadingAddressData = true;
  List<RegionData> _currentList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadAddressData();
  }

  // 加载地址数据
  void _loadAddressData() async {
    final data = await _loadRealAddressData();
    setState(() {
      _realAddressData = data;
      _isLoadingAddressData = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('组件演示'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.black54,
              indicator: const FixedSizeTabIndicator(
                width: 22,
                height: 4,
              ),
              tabs: const [
                Tab(text: '手动布局'),
                Tab(text: '进度条'),
                Tab(text: '折线图'),
                Tab(text: '弹出箭头'),
                Tab(text: '滑块'),
                Tab(text: 'Tab指示器'),
                Tab(text: '地址选择'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildManualLayoutDemo(),
                _buildProgressIndicatorDemo(),
                _buildLineChartDemo(),
                _buildPopupArrowDemo(),
                _buildSliderDemo(),
                _buildTabIndicatorDemo(),
                _buildAddressWidgetDemo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualLayoutDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ManualLayoutWidget 演示',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('自定义布局 - 瀑布流效果:'),
          const SizedBox(height: 12),
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ManualLayoutWidget(
              layoutChild: (childSize, previousChildRect, index, constraints) {
                const double spacing = 8.0;
                const int columns = 3;
                final double itemWidth = (constraints.maxWidth - spacing * (columns + 1)) / columns;

                final int column = index % columns;
                final int row = index ~/ columns;

                final double x = spacing + column * (itemWidth + spacing);
                final double y = spacing + row * (childSize.height + spacing);

                return Offset(x, y);
              },
              children: List.generate(12, (index) {
                final colors = [
                  Colors.red.shade100,
                  Colors.blue.shade100,
                  Colors.green.shade100,
                  Colors.orange.shade100,
                  Colors.purple.shade100,
                  Colors.teal.shade100,
                ];
                return Container(
                  width: 80,
                  height: 60 + (index % 3) * 20,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '项目 ${index + 1}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          const Text('圆形布局效果:'),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ManualLayoutWidget(
              layoutChild: (childSize, previousChildRect, index, constraints) {
                final center = Offset(constraints.maxWidth / 2, 100);
                final radius = 60.0;
                final angle = (index * 2 * math.pi) / 8;

                final x = center.dx + radius * math.cos(angle) - childSize.width / 2;
                final y = center.dy + radius * math.sin(angle) - childSize.height / 2;

                return Offset(x, y);
              },
              children: List.generate(8, (index) {
                return Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicatorDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LinearGradientProgressIndicator 演示',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('当前进度: ${(_progressValue * 100).toInt()}%'),
          const SizedBox(height: 12),
          LinearGradientProgressIndicator(
            width: 300,
            height: 8,
            progress: _progressValue,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF0400), Color(0xFFFF4336)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _progressValue = math.min(1.0, _progressValue + 0.1);
              });
            },
            child: const Text('增加进度'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _progressValue = math.max(0.0, _progressValue - 0.1);
              });
            },
            child: const Text('减少进度'),
          ),
          const SizedBox(height: 24),
          const Text('不同样式的进度条:'),
          const SizedBox(height: 12),
          LinearGradientProgressIndicator.colors(
            width: 300,
            height: 12,
            progress: 0.7,
            colors: const [Colors.green, Colors.lightGreen],
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 12),
          LinearGradientProgressIndicator.colors(
            width: 300,
            height: 6,
            progress: 0.4,
            colors: const [Colors.blue, Colors.cyan],
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 12),
          LinearGradientProgressIndicator.colors(
            width: 300,
            height: 16,
            progress: 0.9,
            colors: const [Colors.purple, Colors.pink],
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DJLineChart 演示',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('销售数据折线图:'),
          const SizedBox(height: 12),
          Center(
            child: DJLineChart(
              points: [
                DJChartPointData(yValue: 10, backgroundColor: Colors.blue),
                DJChartPointData(yValue: 25, backgroundColor: Colors.green),
                DJChartPointData(yValue: 15, backgroundColor: Colors.orange),
                DJChartPointData(yValue: 35, backgroundColor: Colors.red),
                DJChartPointData(yValue: 30, backgroundColor: Colors.purple),
                DJChartPointData(yValue: 45, backgroundColor: Colors.teal),
              ],
              xAxisMarks: [
                AxisTickMark(text: '1月'),
                AxisTickMark(text: '2月'),
                AxisTickMark(text: '3月'),
                AxisTickMark(text: '4月'),
                AxisTickMark(text: '5月'),
                AxisTickMark(text: '6月'),
              ],
              yAxisMarks: [
                AxisTickMark(text: '0'),
                AxisTickMark(text: '20'),
                AxisTickMark(text: '40'),
              ],
              xDesc: '月份',
              yDesc: '销量',
              yGap: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupArrowDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PopupArrowWidget 演示',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('不同位置的弹出箭头:'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildPopupArrowItem('顶部左侧', PopupArrowPosition.topLeft),
              _buildPopupArrowItem('顶部中央', PopupArrowPosition.topCenter),
              _buildPopupArrowItem('顶部右侧', PopupArrowPosition.topRight),
              _buildPopupArrowItem('底部左侧', PopupArrowPosition.bottomLeft),
              _buildPopupArrowItem('底部中央', PopupArrowPosition.bottomCenter),
              _buildPopupArrowItem('底部右侧', PopupArrowPosition.bottomRight),
            ],
          ),
          const SizedBox(height: 24),
          const Text('直角箭头样式:'),
          const SizedBox(height: 12),
          PopupArrowWidget.rightAngle(
            fillColor: Colors.orange,
            arrowPosition: PopupArrowPosition.bottomCenter,
            size: const Size(120, 60),
            child: const Center(
              child: Text(
                '直角箭头',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupArrowItem(String title, PopupArrowPosition position) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        PopupArrowWidget(
          fillColor: Colors.blue,
          arrowPosition: position,
          size: const Size(80, 40),
          child: const Center(
            child: Text(
              '提示',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DJSlider 演示',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('当前值: ${(_sliderValue * 100).toInt()}%'),
          const SizedBox(height: 12),
          DJSlider(
            imageProvider: const AssetImage('assets/images/slider_thumb.png'),
            defaultValue: _sliderValue,
            onChanged: (value) {
              setState(() {
                _sliderValue = value;
              });
            },
          ),
          const SizedBox(height: 24),
          const Text('不同颜色的滑块:'),
          const SizedBox(height: 12),
          DJSlider(
            imageProvider: const AssetImage('assets/images/slider_thumb.png'),
            defaultValue: 0.3,
            activeColor: Colors.green,
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {},
          ),
          const SizedBox(height: 12),
          DJSlider(
            imageProvider: const AssetImage('assets/images/slider_thumb.png'),
            defaultValue: 0.7,
            activeColor: Colors.purple,
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabIndicatorDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FixedSizeTabIndicator 演示',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('固定大小的Tab指示器已在顶部Tab中使用'),
          const SizedBox(height: 24),
          const Text('不同样式的指示器:'),
          const SizedBox(height: 12),
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicator: const FixedSizeTabIndicator(
                    width: 30,
                    height: 3,
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.lightBlue],
                    ),
                  ),
                  tabs: const [
                    Tab(text: '选项1'),
                    Tab(text: '选项2'),
                    Tab(text: '选项3'),
                  ],
                ),
                const SizedBox(height: 20),
                TabBar(
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey,
                  indicator: const FixedSizeTabIndicator(
                    width: 40,
                    height: 4,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.lightGreen],
                    ),
                  ),
                  tabs: const [
                    Tab(text: '标签A'),
                    Tab(text: '标签B'),
                    Tab(text: '标签C'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressWidgetDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AddressWidget 演示',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '使用真实的中国省市区数据',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_selectedRegions.isNotEmpty) ...[
            Text('已选择: ${_selectedRegions.map((e) => e.name).join(' - ')}'),
            const SizedBox(height: 12),
          ],
          Container(
            height: 500,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoadingAddressData
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('正在加载地址数据...'),
                      ],
                    ),
                  )
                : AddressWidget(
                    province: _realAddressData.isNotEmpty ? _realAddressData : _getMockProvinceData(),
                    provinceHasAllData: true,
                    // regionLevel: AddressRegionLevel.city,
                    fetchNextLevelData: _handleNextLevelData,
                    onFinished: (result) {
                      setState(() {
                        _selectedRegions = result;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('选择完成: ${result.map((e) => e.name).join(' - ')}'),
                        ),
                      );
                    },
                    onChange: (result) {
                      setState(() {
                        _selectedRegions = result;
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }

  FutureOr<List<RegionData>?> _handleNextLevelData(RegionData data, int level, int index) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentList = data.children ?? [];

    return [..._currentList];
  }

  List<RegionData> _getMockProvinceData() {
    return [
      RegionData(
        name: '北京市',
        children: [
          RegionData(
            name: '北京市',
            children: [
              RegionData(name: '东城区'),
              RegionData(name: '西城区'),
              RegionData(name: '朝阳区'),
              RegionData(name: '丰台区'),
            ],
          ),
        ],
      ),
      RegionData(
        name: '上海市',
        children: [
          RegionData(
            name: '上海市',
            children: [
              RegionData(name: '黄浦区'),
              RegionData(name: '徐汇区'),
              RegionData(name: '长宁区'),
              RegionData(name: '静安区'),
            ],
          ),
        ],
      ),
      RegionData(
        name: '广东省',
        children: [
          RegionData(
            name: '广州市',
            children: [
              RegionData(name: '天河区'),
              RegionData(name: '越秀区'),
              RegionData(name: '荔湾区'),
            ],
          ),
          RegionData(
            name: '深圳市',
            children: [
              RegionData(name: '南山区'),
              RegionData(name: '福田区'),
              RegionData(name: '罗湖区'),
            ],
          ),
        ],
      ),
    ];
  }

  // 加载真实地址数据
  Future<List<RegionData>> _loadRealAddressData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/json/pcas-code.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((province) => _convertToRegionData(province)).toList();
    } catch (e) {
      print('加载地址数据失败: $e');
      // 如果加载失败，返回模拟数据
      return _getMockProvinceData();
    }
  }

  // 将JSON数据转换为RegionData格式
  RegionData _convertToRegionData(Map<String, dynamic> data) {
    List<RegionData>? children;
    if (data['children'] != null) {
      children = (data['children'] as List).map((child) => _convertToRegionData(child)).toList();
    }

    return RegionData(
      name: data['name'],
      children: children,
    );
  }
}
