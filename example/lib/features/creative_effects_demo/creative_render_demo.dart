import 'package:flutter/material.dart';
import 'creative_render_effects.dart';
import 'dart:math' as math;

/// 创意RenderObject效果演示页面
class CreativeRenderDemoPage extends StatefulWidget {
  const CreativeRenderDemoPage({Key? key}) : super(key: key);

  @override
  State<CreativeRenderDemoPage> createState() => _CreativeRenderDemoPageState();
}

class _CreativeRenderDemoPageState extends State<CreativeRenderDemoPage>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _particleController;
  late AnimationController _flipController;
  late AnimationController _gridController;

  List<Particle> _particles = [];
  Offset? _explosionCenter;
  Offset? _gridInteractionPoint;
  List<Offset> _magneticPoints = [];

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _flipController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _gridController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // 初始化磁性点
    _initializeMagneticPoints();
  }

  void _initializeMagneticPoints() {
    _magneticPoints = [
      const Offset(100, 100),
      const Offset(200, 150),
      const Offset(150, 200),
    ];
  }

  void _createParticleExplosion(Offset center) {
    setState(() {
      _explosionCenter = center;
      _particles.clear();
      
      // 创建粒子
      final random = math.Random();
      for (int i = 0; i < 30; i++) {
        final angle = random.nextDouble() * 2 * math.pi;
        final speed = 50 + random.nextDouble() * 100;
        final velocity = Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        );
        
        _particles.add(Particle(
          initialPosition: center,
          velocity: velocity,
          life: 1.0,
          color: Colors.primaries[random.nextInt(Colors.primaries.length)],
        ));
      }
    });
    
    _particleController.reset();
    _particleController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _particleController.dispose();
    _flipController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创意 RenderObject 效果'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. 液体波浪效果'),
            _buildLiquidWaveDemo(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('2. 粒子爆炸效果'),
            _buildParticleExplosionDemo(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('3. 磁性吸附布局'),
            _buildMagneticLayoutDemo(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('4. 3D翻转卡片'),
            _buildFlipCard3DDemo(),
            
            const SizedBox(height: 32),
            _buildSectionTitle('5. 动态网格背景'),
            _buildDynamicGridDemo(),
            
            const SizedBox(height: 32),
            _buildImplementationNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildLiquidWaveDemo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '液体波浪效果展示了如何创建流动的动画效果：',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return LiquidWave(
                      waveHeight: 20,
                      waveSpeed: 2.0,
                      waveColor: Colors.blue.shade400,
                      backgroundColor: Colors.blue.shade50,
                      waveCount: 3,
                      animationValue: _waveController.value,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '• 多层波浪叠加\n• 可调节波浪高度和速度\n• 支持自定义颜色',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticleExplosionDemo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '点击区域触发粒子爆炸效果：',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.grey.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  onTapDown: (details) {
                    _createParticleExplosion(details.localPosition);
                  },
                  child: AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      return ParticleExplosion(
                        particles: _particles,
                        explosionCenter: _explosionCenter ?? Offset.zero,
                        animationValue: _particleController.value,
                        particleColor: Colors.orange,
                        particleSize: 4.0,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '• 点击任意位置触发爆炸\n• 随机颜色粒子\n• 物理运动模拟',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMagneticLayoutDemo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '磁性吸附布局，子组件会被吸引到磁性点：',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade50,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MagneticLayout(
                  magneticPoints: _magneticPoints,
                  magneticStrength: 80.0,
                  children: [
                    _buildMagneticChild('A', Colors.red),
                    _buildMagneticChild('B', Colors.green),
                    _buildMagneticChild('C', Colors.blue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '• 磁性吸附效果\n• 可视化磁性区域\n• 智能布局算法',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMagneticChild(String text, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildFlipCard3DDemo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '3D翻转卡片效果：',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () {
                  if (_flipController.isCompleted) {
                    _flipController.reverse();
                  } else {
                    _flipController.forward();
                  }
                },
                child: Container(
                  width: 200,
                  height: 120,
                  child: AnimatedBuilder(
                    animation: _flipController,
                    builder: (context, child) {
                      return FlipCard3D(
                        flipProgress: _flipController.value,
                        frontChild: _buildCardFace('正面', Colors.blue),
                        backChild: _buildCardFace('背面', Colors.red),
                        child: _flipController.value < 0.5
                            ? _buildCardFace('正面', Colors.blue)
                            : _buildCardFace('背面', Colors.red),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_flipController.isCompleted) {
                    _flipController.reverse();
                  } else {
                    _flipController.forward();
                  }
                },
                child: const Text('翻转卡片'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '• 3D翻转动画\n• 双面显示\n• 平滑过渡效果',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFace(String text, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicGridDemo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '动态网格背景，支持交互效果：',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.black87,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _gridInteractionPoint = details.localPosition;
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      _gridInteractionPoint = null;
                    });
                  },
                  child: AnimatedBuilder(
                    animation: _gridController,
                    builder: (context, child) {
                      return DynamicGridBackground(
                        gridSize: 30,
                        lineColor: Colors.cyan.withOpacity(0.3),
                        highlightColor: Colors.cyan,
                        animationValue: _gridController.value,
                        interactionPoint: _gridInteractionPoint,
                        interactionRadius: 60.0,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '• 拖拽产生交互效果\n• 动态高亮显示\n• 科技感网格背景',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImplementationNotes() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '实现要点',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '这些创意效果展示了自定义RenderObject的强大功能：\n\n'
              '• 液体波浪：使用数学函数创建流动效果\n'
              '• 粒子系统：模拟物理运动和生命周期\n'
              '• 磁性布局：实现智能的空间布局算法\n'
              '• 3D翻转：利用变换矩阵创建3D效果\n'
              '• 动态网格：结合交互和动画的背景效果\n\n'
              '每个效果都充分利用了RenderObject的核心功能：\n'
              '- performLayout(): 计算布局和大小\n'
              '- paint(): 自定义绘制逻辑\n'
              '- hitTestSelf(): 处理用户交互\n'
              '- markNeedsPaint(): 触发重绘\n\n'
              '这些示例可以作为创建更复杂自定义组件的基础。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}