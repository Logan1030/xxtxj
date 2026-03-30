import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_model.dart';

/// 进度管理服务
class ProgressService {
  static SharedPreferences? _prefs;

  // 存储键
  static const String _levelPrefix = 'level_';
  static const String _levelStarsPrefix = 'level_stars_';
  static const String _totalStarsKey = 'total_stars';
  static const String _highestLevelKey = 'highest_level';
  static const String _currentStreakKey = 'current_streak';
  static const String _gameModeKey = 'game_mode_';

  /// 初始化
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 获取某个关卡的星星数
  static Future<int> getLevelStars(String levelId) async {
    await init();
    return _prefs?.getInt('$_levelStarsPrefix$levelId') ?? 0;
  }

  /// 保存某个关卡的星星数
  static Future<void> saveLevelStars(String levelId, int stars) async {
    await init();
    final currentStars = await getLevelStars(levelId);
    if (stars > currentStars) {
      await _prefs?.setInt('$_levelStarsPrefix$levelId', stars);
      await _updateTotalStars();
    }
  }

  /// 获取总星星数
  static Future<int> getTotalStars() async {
    await init();
    return _prefs?.getInt(_totalStarsKey) ?? 0;
  }

  /// 更新总星星数
  static Future<void> _updateTotalStars() async {
    int total = 0;
    for (var level in LevelData.allLevels) {
      total += _prefs?.getInt('$_levelStarsPrefix${level.subCategory}') ?? 0;
    }
    await _prefs?.setInt(_totalStarsKey, total);
  }

  /// 获取最高解锁关卡序号（默认1，第一关默认解锁）
  static Future<int> getHighestUnlockedLevel() async {
    await init();
    return _prefs?.getInt(_highestLevelKey) ?? 1;
  }

  /// 解锁下一关
  static Future<void> unlockNextLevel(int currentLevel) async {
    await init();
    final highest = await getHighestUnlockedLevel();
    if (currentLevel >= highest) {
      await _prefs?.setInt(_highestLevelKey, currentLevel + 1);
    }
  }

  /// 获取当前连续正确数
  static Future<int> getCurrentStreak() async {
    await init();
    return _prefs?.getInt(_currentStreakKey) ?? 0;
  }

  /// 更新连续正确数
  static Future<void> updateStreak(bool isCorrect) async {
    await init();
    if (isCorrect) {
      final current = await getCurrentStreak();
      await _prefs?.setInt(_currentStreakKey, current + 1);
    } else {
      await _prefs?.setInt(_currentStreakKey, 0);
    }
  }

  /// 获取游戏模式设置
  static Future<GameMode> getGameMode(String levelId) async {
    await init();
    final modeIndex = _prefs?.getInt('$_gameModeKey$levelId') ?? 0;
    return GameMode.values[modeIndex];
  }

  /// 保存游戏模式设置
  static Future<void> saveGameMode(String levelId, GameMode mode) async {
    await init();
    await _prefs?.setInt('$_gameModeKey$levelId', mode.index);
  }

  /// 获取所有关卡进度
  static Future<List<LevelModel>> getAllLevelsProgress() async {
    await init();
    final highestUnlocked = await getHighestUnlockedLevel();
    final List<LevelModel> levels = [];

    for (var level in LevelData.allLevels) {
      final stars = await getLevelStars(level.subCategory);
      LevelStatus status;

      if (level.levelNumber < highestUnlocked || stars > 0) {
        status = LevelStatus.completed;
      } else if (level.levelNumber == highestUnlocked) {
        status = LevelStatus.current;
      } else {
        status = LevelStatus.locked;
      }

      levels.add(level.copyWith(status: status, stars: stars));
    }

    return levels;
  }

  /// 重置所有进度
  static Future<void> resetAllProgress() async {
    await init();
    for (var level in LevelData.allLevels) {
      await _prefs?.remove('$_levelStarsPrefix${level.subCategory}');
    }
    await _prefs?.setInt(_totalStarsKey, 0);
    await _prefs?.setInt(_highestLevelKey, 0);
    await _prefs?.setInt(_currentStreakKey, 0);
  }

  /// 获取模块的总星星数
  static Future<int> getCategoryStars(String category) async {
    await init();
    int total = 0;
    for (var level in LevelData.getLevelsByCategory(category)) {
      total += _prefs?.getInt('$_levelStarsPrefix${level.subCategory}') ?? 0;
    }
    return total;
  }

  /// 获取某个模块的关卡进度列表
  static Future<List<LevelModel>> getLevelsByCategory(String category) async {
    await init();
    final highestUnlocked = await getHighestUnlockedLevel();
    final List<LevelModel> levels = [];

    for (var level in LevelData.getLevelsByCategory(category)) {
      final stars = await getLevelStars(level.subCategory);
      LevelStatus status;

      if (level.levelNumber < highestUnlocked || stars > 0) {
        status = LevelStatus.completed;
      } else if (level.levelNumber == highestUnlocked) {
        status = LevelStatus.current;
      } else {
        status = LevelStatus.locked;
      }

      levels.add(level.copyWith(status: status, stars: stars));
    }

    return levels;
  }
}
