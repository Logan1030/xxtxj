import 'package:flutter/material.dart';
import '../app.dart';
import '../models/achievement_model.dart';

/// 成就徽章组件
class AchievementBadgeWidget extends StatefulWidget {
  final AchievementModel achievement;
  final bool showAnimation;
  final VoidCallback? onTap;

  const AchievementBadgeWidget({
    super.key,
    required this.achievement,
    this.showAnimation = false,
    this.onTap,
  });

  @override
  State<AchievementBadgeWidget> createState() => _AchievementBadgeWidgetState();
}

class _AchievementBadgeWidgetState extends State<AchievementBadgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.showAnimation) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = widget.achievement.isUnlocked;
    final badgeColor = _getBadgeColor();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: isUnlocked ? badgeColor.withValues(alpha: 0.1) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUnlocked ? badgeColor : Colors.grey.shade400,
                  width: 3,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: badgeColor.withValues(alpha: 0.3 * _glowAnimation.value),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 徽章图标
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isUnlocked ? badgeColor : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        isUnlocked ? _getBadgeEmoji() : '🔒',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 徽章名称
                  Text(
                    _getBadgeName(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black87 : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getBadgeColor() {
    if (!widget.achievement.isUnlocked) return Colors.grey;

    switch (widget.achievement.type) {
      case AchievementType.firstClear:
        return AppTheme.primaryColor; // 温暖的红色
      case AchievementType.streak3:
        return AppTheme.secondaryColor; // 青绿色
      case AchievementType.perfect:
        return AppTheme.accentColor; // 明亮黄色
      case AchievementType.speedStar:
        return const Color(0xFFFF6B6B); // 红色
      case AchievementType.learningMaster:
        return const Color(0xFF9B59B6); // 紫色
    }
  }

  String _getBadgeEmoji() {
    switch (widget.achievement.type) {
      case AchievementType.firstClear:
        return '🌟';
      case AchievementType.streak3:
        return '🔥';
      case AchievementType.perfect:
        return '💯';
      case AchievementType.speedStar:
        return '⚡';
      case AchievementType.learningMaster:
        return '🏆';
    }
  }

  String _getBadgeName() {
    switch (widget.achievement.type) {
      case AchievementType.firstClear:
        return '初次通关';
      case AchievementType.streak3:
        return '连续正确';
      case AchievementType.perfect:
        return '完美通关';
      case AchievementType.speedStar:
        return '速度之星';
      case AchievementType.learningMaster:
        return '学习达人';
    }
  }
}

/// 成就解锁动画覆盖层
class AchievementUnlockOverlay extends StatefulWidget {
  final AchievementModel achievement;
  final VoidCallback onComplete;

  const AchievementUnlockOverlay({
    super.key,
    required this.achievement,
    required this.onComplete,
  });

  @override
  State<AchievementUnlockOverlay> createState() =>
      _AchievementUnlockOverlayState();
}

class _AchievementUnlockOverlayState extends State<AchievementUnlockOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // 3秒后自动关闭
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: GestureDetector(
        onTap: widget.onComplete,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _getBadgeColor().withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉 成就解锁！',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 大徽章图标
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _getBadgeColor(),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getBadgeColor().withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getBadgeEmoji(),
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _getBadgeName(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getBadgeDescription(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '点击任意处继续',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBadgeColor() {
    switch (widget.achievement.type) {
      case AchievementType.firstClear:
        return AppTheme.primaryColor;
      case AchievementType.streak3:
        return AppTheme.secondaryColor;
      case AchievementType.perfect:
        return AppTheme.accentColor;
      case AchievementType.speedStar:
        return const Color(0xFFFF6B6B);
      case AchievementType.learningMaster:
        return const Color(0xFF9B59B6);
    }
  }

  String _getBadgeEmoji() {
    switch (widget.achievement.type) {
      case AchievementType.firstClear:
        return '🌟';
      case AchievementType.streak3:
        return '🔥';
      case AchievementType.perfect:
        return '💯';
      case AchievementType.speedStar:
        return '⚡';
      case AchievementType.learningMaster:
        return '🏆';
    }
  }

  String _getBadgeName() {
    switch (widget.achievement.type) {
      case AchievementType.firstClear:
        return '初次通关';
      case AchievementType.streak3:
        return '连续正确';
      case AchievementType.perfect:
        return '完美通关';
      case AchievementType.speedStar:
        return '速度之星';
      case AchievementType.learningMaster:
        return '学习达人';
    }
  }

  String _getBadgeDescription() {
    switch (widget.achievement.type) {
      case AchievementType.firstClear:
        return '完成了你的第一个关卡！';
      case AchievementType.streak3:
        return '连续答对3道题！';
      case AchievementType.perfect:
        return '以满星成绩完成关卡！';
      case AchievementType.speedStar:
        return '在极短时间内答对多道题！';
      case AchievementType.learningMaster:
        return '完成了所有学习内容！';
    }
  }
}
