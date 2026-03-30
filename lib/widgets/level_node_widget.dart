import 'package:flutter/material.dart';
import '../app.dart';
import '../models/level_model.dart';

/// 关卡节点组件
class LevelNodeWidget extends StatefulWidget {
  final LevelModel level;
  final VoidCallback? onTap;
  final bool showPulse;

  const LevelNodeWidget({
    super.key,
    required this.level,
    this.onTap,
    this.showPulse = false,
  });

  @override
  State<LevelNodeWidget> createState() => _LevelNodeWidgetState();
}

class _LevelNodeWidgetState extends State<LevelNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LevelNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.showPulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.level.status == LevelStatus.locked;
    final isCompleted = widget.level.status == LevelStatus.completed;
    final isCurrent = widget.level.status == LevelStatus.current;

    return GestureDetector(
      onTap: isLocked ? null : widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 节点主体
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.showPulse ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getNodeColor(),
                borderRadius: BorderRadius.circular(24),
                border: isCurrent
                    ? Border.all(color: Colors.white, width: 4)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: _getNodeColor().withValues(alpha: 0.4),
                    blurRadius: isCurrent ? 20 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isLocked ? '🔒' : widget.level.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 关卡名称
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isLocked
                  ? Colors.grey.shade200
                  : _getNodeColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.level.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          // 星星
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Icon(
                    Icons.star,
                    size: 18,
                    color: i < widget.level.stars
                        ? Colors.amber
                        : Colors.grey.shade300,
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Color _getNodeColor() {
    final isLocked = widget.level.status == LevelStatus.locked;
    final isCompleted = widget.level.status == LevelStatus.completed;

    if (isLocked) return Colors.grey.shade400;
    if (isCompleted) return AppTheme.accentColor;

    // 根据分类颜色
    switch (widget.level.category) {
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
}
