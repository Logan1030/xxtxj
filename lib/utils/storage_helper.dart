import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储进度助手
class StorageHelper {
  static const String _starsKeyPrefix = 'stars_';
  static const String _totalStarsKey = 'total_stars';
  static const String _highestLevelKey = 'highest_level';

  static SharedPreferences? _prefs;

  /// Reset static state - for testing only
  static void reset() {
    _prefs = null;
  }

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 获取某个主题的星星数
  static Future<int> getStars(String category) async {
    await init();
    return _prefs?.getInt('$_starsKeyPrefix$category') ?? 0;
  }

  /// 保存某个主题的星星数
  static Future<void> saveStars(String category, int stars) async {
    await init();
    await _prefs?.setInt('$_starsKeyPrefix$category', stars);
    await _updateTotalStars();
  }

  /// 获取总星星数
  static Future<int> getTotalStars() async {
    await init();
    return _prefs?.getInt(_totalStarsKey) ?? 0;
  }

  /// 更新总星星数
  static Future<void> _updateTotalStars() async {
    await init();
    int total = 0;
    // 获取所有以 stars_ 开头的键来计算总数，支持任意类别
    final keys = _prefs?.getKeys() ?? {};
    for (var key in keys) {
      if (key.startsWith(_starsKeyPrefix)) {
        total += _prefs?.getInt(key) ?? 0;
      }
    }
    await _prefs?.setInt(_totalStarsKey, total);
  }

  /// 获取最高解锁关卡
  static Future<int> getHighestLevel() async {
    await init();
    return _prefs?.getInt(_highestLevelKey) ?? 0;
  }

  /// 保存最高解锁关卡
  static Future<void> saveHighestLevel(int level) async {
    await init();
    await _prefs?.setInt(_highestLevelKey, level);
  }

  /// 重置所有进度
  static Future<void> resetProgress() async {
    await init();
    await _prefs?.remove('${_starsKeyPrefix}colors');
    await _prefs?.remove('${_starsKeyPrefix}numbers');
    await _prefs?.remove('${_starsKeyPrefix}animals');
    await _prefs?.remove('${_starsKeyPrefix}foods');
    await _prefs?.remove('${_starsKeyPrefix}body');
    await _prefs?.setInt(_totalStarsKey, 0);
    await _prefs?.setInt(_highestLevelKey, 0);
  }

  /// 获取所有主题进度
  static Future<Map<String, int>> getAllProgress() async {
    await init();
    return {
      'colors': _prefs?.getInt('${_starsKeyPrefix}colors') ?? 0,
      'numbers': _prefs?.getInt('${_starsKeyPrefix}numbers') ?? 0,
      'animals': _prefs?.getInt('${_starsKeyPrefix}animals') ?? 0,
      'foods': _prefs?.getInt('${_starsKeyPrefix}foods') ?? 0,
      'body': _prefs?.getInt('${_starsKeyPrefix}body') ?? 0,
    };
  }
}
