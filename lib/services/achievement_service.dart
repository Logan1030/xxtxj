import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement_model.dart';

/// 成就服务
class AchievementService {
  static SharedPreferences? _prefs;
  static const String _achievementsKey = 'achievements';

  /// 初始化
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 获取所有成就
  static Future<List<AchievementModel>> getAllAchievements() async {
    await init();
    final achievementsJson = _prefs?.getString(_achievementsKey);

    if (achievementsJson == null) {
      return AchievementData.allAchievements;
    }

    try {
      final List<dynamic> decoded = jsonDecode(achievementsJson);
      final savedAchievements = decoded
          .map((json) => AchievementModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // 合并保存的成就和初始成就（确保新成就也被添加）
      final List<AchievementModel> result = [];
      for (var defaultAchievement in AchievementData.allAchievements) {
        final saved = savedAchievements.firstWhere(
          (a) => a.type == defaultAchievement.type,
          orElse: () => defaultAchievement,
        );
        result.add(saved);
      }
      return result;
    } catch (e) {
      return AchievementData.allAchievements;
    }
  }

  /// 解锁成就
  static Future<AchievementModel?> unlockAchievement(AchievementType type) async {
    await init();
    final achievements = await getAllAchievements();

    // 查找对应成就
    final index = achievements.indexWhere((a) => a.type == type);
    if (index == -1) return null;

    final achievement = achievements[index];
    if (achievement.isUnlocked) return achievement;

    // 更新成就状态
    final unlocked = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );
    achievements[index] = unlocked;

    // 保存
    await _saveAchievements(achievements);

    return unlocked;
  }

  /// 检查并解锁初次通关成就
  static Future<AchievementModel?> checkFirstClearAchievement() async {
    return unlockAchievement(AchievementType.firstClear);
  }

  /// 检查并解锁连续正确成就
  static Future<AchievementModel?> checkStreakAchievement(int streak) async {
    if (streak >= 3) {
      return unlockAchievement(AchievementType.streak3);
    }
    return null;
  }

  /// 检查并解锁完美通关成就
  static Future<AchievementModel?> checkPerfectAchievement(int stars) async {
    if (stars >= 3) {
      return unlockAchievement(AchievementType.perfect);
    }
    return null;
  }

  /// 检查并解锁速度之星成就
  static Future<AchievementModel?> checkSpeedStarAchievement(
    int correctCount,
    int timeLimit,
  ) async {
    if (correctCount >= 5 && timeLimit <= 10) {
      return unlockAchievement(AchievementType.speedStar);
    }
    return null;
  }

  /// 检查并解锁学习达人成就
  static Future<AchievementModel?> checkLearningMasterAchievement(
    int completedLevels,
    int totalLevels,
  ) async {
    if (completedLevels >= totalLevels) {
      return unlockAchievement(AchievementType.learningMaster);
    }
    return null;
  }

  /// 获取已解锁成就数量
  static Future<int> getUnlockedCount() async {
    final achievements = await getAllAchievements();
    return achievements.where((a) => a.isUnlocked).length;
  }

  /// 获取已解锁成就
  static Future<List<AchievementModel>> getUnlockedAchievements() async {
    final achievements = await getAllAchievements();
    return achievements.where((a) => a.isUnlocked).toList();
  }

  /// 保存成就列表
  static Future<void> _saveAchievements(List<AchievementModel> achievements) async {
    final json = jsonEncode(achievements.map((a) => a.toJson()).toList());
    await _prefs?.setString(_achievementsKey, json);
  }

  /// 重置所有成就
  static Future<void> resetAllAchievements() async {
    await init();
    await _prefs?.remove(_achievementsKey);
  }
}
