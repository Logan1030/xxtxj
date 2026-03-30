import 'package:flutter/material.dart';
import '../app.dart';
import '../models/level_model.dart';

/// 旅程地图组件 - 显示关卡路径和节点
class JourneyMapWidget extends StatelessWidget {
  final List<LevelModel> levels;
  final String category;
  final Function(LevelModel) onLevelTap;

  const JourneyMapWidget({
    super.key,
    required this.levels,
    required this.category,
    required this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部装饰
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildCategoryIcon(),
              const SizedBox(width: 12),
              Text(
                _getCategoryName(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getCategoryColor(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 地图路径
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景路径
              CustomPaint(
                size: Size.infinite,
                painter: _PathPainter(
                  levelCount: levels.length,
                  color: _getCategoryColor().withValues(alpha: 0.3),
                ),
              ),
              // 关卡节点
              ...List.generate(levels.length, (index) {
                final level = levels[index];
                return Positioned(
                  left: _getNodeX(index),
                  top: _getNodeY(index),
                  child: _buildLevelNode(level, index),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon() {
    String emoji;
    switch (category) {
      case 'english':
        emoji = '🔤';
        break;
      case 'chinese':
        emoji = '🇨🇳';
        break;
      case 'math':
        emoji = '🔢';
        break;
      default:
        emoji = '🌟';
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _getCategoryColor(),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }

  String _getCategoryName() {
    switch (category) {
      case 'english':
        return '英语学习';
      case 'chinese':
        return '语文学习';
      case 'math':
        return '数学学习';
      default:
        return '学习';
    }
  }

  Color _getCategoryColor() {
    switch (category) {
      case 'english':
        return AppTheme.englishNumbersCategory;
      case 'chinese':
        return AppTheme.chineseCategory;
      case 'math':
        return AppTheme.mathCategory;
      default:
        return AppTheme.primaryColor;
    }
  }

  double _getNodeX(int index) {
    // 左右交替排列
    final screenWidth = 400; // 假设屏幕宽度
    if (index.isEven) {
      return screenWidth * 0.2;
    } else {
      return screenWidth * 0.55;
    }
  }

  double _getNodeY(int index) {
    // 垂直均匀分布
    return 60.0 + index * 120.0;
  }

  Widget _buildLevelNode(LevelModel level, int index) {
    final isLocked = level.status == LevelStatus.locked;
    final isCompleted = level.status == LevelStatus.completed;
    final isCurrent = level.status == LevelStatus.current;

    return GestureDetector(
      onTap: isLocked ? null : () => onLevelTap(level),
      child: Column(
        children: [
          // 关卡节点
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isLocked
                  ? Colors.grey.shade400
                  : (isCompleted
                      ? AppTheme.accentColor
                      : _getCategoryColor()),
              borderRadius: BorderRadius.circular(20),
              border: isCurrent
                  ? Border.all(color: Colors.white, width: 4)
                  : null,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: _getCategoryColor().withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  isLocked ? '🔒' : level.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                // 脉冲动画（当前关卡）
                if (isCurrent)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: 1.2),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 关卡名称
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isLocked
                  ? Colors.grey.shade300
                  : _getCategoryColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              level.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          // 星星显示
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: i < level.stars ? Colors.amber : Colors.grey.shade300,
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

/// 路径绘制器
class _PathPainter extends CustomPainter {
  final int levelCount;
  final Color color;

  _PathPainter({required this.levelCount, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (int i = 0; i < levelCount - 1; i++) {
      final startX = _getX(i, size);
      final startY = _getY(i, size);
      final endX = _getX(i + 1, size);
      final endY = _getY(i + 1, size);

      // 绘制曲线连接
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        (startX + endX) / 2,
        startY + 30,
        endX,
        endY,
      );
    }

    canvas.drawPath(path, paint);
  }

  double _getX(int index, Size size) {
    return index.isEven ? size.width * 0.25 : size.width * 0.65;
  }

  double _getY(int index, Size size) {
    return 90.0 + index * 120.0;
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.levelCount != levelCount || oldDelegate.color != color;
  }
}
