import 'package:flutter/material.dart';
import '../app.dart';
import '../models/achievement_model.dart';
import '../services/achievement_service.dart';
import '../widgets/achievement_badge_widget.dart';

/// 明星墙界面 - 成就徽章展示
class StarWallScreen extends StatefulWidget {
  const StarWallScreen({super.key});

  @override
  State<StarWallScreen> createState() => _StarWallScreenState();
}

class _StarWallScreenState extends State<StarWallScreen> {
  List<AchievementModel> _achievements = [];
  bool _isLoading = true;
  AchievementModel? _unlockedAchievement;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final achievements = await AchievementService.getAllAchievements();
    if (mounted) {
      setState(() {
        _achievements = achievements;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // 顶部导航
                _buildHeader(),
                // 成就统计
                _buildStats(),
                // 成就网格
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildAchievementGrid(),
                ),
              ],
            ),
          ),
          // 成就解锁动画
          if (_unlockedAchievement != null)
            AchievementUnlockOverlay(
              achievement: _unlockedAchievement!,
              onComplete: () {
                setState(() {
                  _unlockedAchievement = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '⭐ 明星墙',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final unlockedCount =
        _achievements.where((a) => a.isUnlocked).length;
    final totalCount = _achievements.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentColor,
            AppTheme.accentColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // 进度圆环
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Text(
                  '$unlockedCount/$totalCount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '成就进度',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unlockedCount == totalCount
                      ? '太棒了！全部成就已解锁！🏆'
                      : '再解锁${totalCount - unlockedCount}个成就即可全部完成！',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return AchievementBadgeWidget(
          achievement: achievement,
          onTap: () => _showAchievementDetail(achievement),
        );
      },
    );
  }

  void _showAchievementDetail(AchievementModel achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 把手
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // 徽章图标
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? _getBadgeColor(achievement.type)
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  achievement.isUnlocked
                      ? _getBadgeEmoji(achievement.type)
                      : '🔒',
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 徽章名称
            Text(
              _getBadgeName(achievement.type),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // 徽章描述
            Text(
              _getBadgeDescription(achievement.type),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // 解锁状态
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    achievement.isUnlocked
                        ? Icons.check_circle
                        : Icons.lock_outline,
                    color:
                        achievement.isUnlocked ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    achievement.isUnlocked ? '已解锁' : '未解锁',
                    style: TextStyle(
                      color:
                          achievement.isUnlocked ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                '解锁时间: ${_formatDate(achievement.unlockedAt!)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor(AchievementType type) {
    switch (type) {
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

  String _getBadgeEmoji(AchievementType type) {
    switch (type) {
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

  String _getBadgeName(AchievementType type) {
    switch (type) {
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

  String _getBadgeDescription(AchievementType type) {
    switch (type) {
      case AchievementType.firstClear:
        return '完成了你的第一个关卡！这是你学习旅程的重要起点，继续加油！';
      case AchievementType.streak3:
        return '连续答对3道题！保持专注，你是最棒的！';
      case AchievementType.perfect:
        return '以满星成绩完成关卡！太厉害了，知识掌握得非常牢固！';
      case AchievementType.speedStar:
        return '在极短时间内答对多道题！你的反应真快！';
      case AchievementType.learningMaster:
        return '完成了所有学习内容！你是真正的学习小达人！';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
