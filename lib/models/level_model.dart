/// 关卡状态枚举
enum LevelStatus {
  locked,   // 未解锁
  current,  // 当前关卡
  completed, // 已完成
}

/// 游戏模式枚举
enum GameMode {
  exploration('探险模式', '🗺️', 0, '慢慢学，不着急'),
  practice('练习模式', '✏️', 15, '轻松练习'),
  challenge('挑战模式', '🏆', 10, '勇于挑战'),
  rapid('极速闯关', '⚡', 5, '极速挑战');

  final String name;
  final String emoji;
  final int timeLimit; // 秒，0表示无限制
  final String description;

  const GameMode(this.name, this.emoji, this.timeLimit, this.description);
}

/// 关卡模型
class LevelModel {
  final String id;
  final String name;
  final String emoji;
  final String category; // english, chinese, math
  final String subCategory; // 如 english_numbers, math_addition 等
  final int levelNumber; // 关卡序号
  final LevelStatus status;
  final int stars; // 0-3星

  const LevelModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.subCategory,
    required this.levelNumber,
    this.status = LevelStatus.locked,
    this.stars = 0,
  });

  LevelModel copyWith({
    String? id,
    String? name,
    String? emoji,
    String? category,
    String? subCategory,
    int? levelNumber,
    LevelStatus? status,
    int? stars,
  }) {
    return LevelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      levelNumber: levelNumber ?? this.levelNumber,
      status: status ?? this.status,
      stars: stars ?? this.stars,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'category': category,
    'subCategory': subCategory,
    'levelNumber': levelNumber,
    'status': status.index,
    'stars': stars,
  };

  /// 从JSON创建
  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String,
    category: json['category'] as String,
    subCategory: json['subCategory'] as String,
    levelNumber: json['levelNumber'] as int,
    status: LevelStatus.values[json['status'] as int],
    stars: json['stars'] as int,
  );
}

/// 关卡数据
class LevelData {
  /// 英语模块关卡
  static List<LevelModel> get englishLevels => [
    const LevelModel(
      id: 'english_numbers',
      name: '英语数字',
      emoji: '1️⃣',
      category: 'english',
      subCategory: 'english_numbers',
      levelNumber: 1,
    ),
    const LevelModel(
      id: 'english_words_body',
      name: '身体部位',
      emoji: '💪',
      category: 'english',
      subCategory: 'english_words_body',
      levelNumber: 2,
    ),
    const LevelModel(
      id: 'english_words_animals_easy',
      name: '动物小词',
      emoji: '🐱',
      category: 'english',
      subCategory: 'english_words_animals_easy',
      levelNumber: 3,
    ),
    const LevelModel(
      id: 'english_words_colors',
      name: '颜色形状',
      emoji: '🎨',
      category: 'english',
      subCategory: 'english_words_colors',
      levelNumber: 4,
    ),
    const LevelModel(
      id: 'english_words_animals_hard',
      name: '动物大词',
      emoji: '🐘',
      category: 'english',
      subCategory: 'english_words_animals_hard',
      levelNumber: 5,
    ),
  ];

  /// 语文模块关卡
  static List<LevelModel> get chineseLevels => [
    const LevelModel(
      id: 'chinese_initials',
      name: '声母',
      emoji: '🔤',
      category: 'chinese',
      subCategory: 'initials',
      levelNumber: 1,
    ),
    const LevelModel(
      id: 'chinese_finals',
      name: '韵母',
      emoji: '📝',
      category: 'chinese',
      subCategory: 'finals',
      levelNumber: 2,
    ),
    const LevelModel(
      id: 'chinese_wholes',
      name: '整体认读',
      emoji: '📖',
      category: 'chinese',
      subCategory: 'wholes',
      levelNumber: 3,
    ),
    const LevelModel(
      id: 'chinese_tones',
      name: '四声',
      emoji: '🎵',
      category: 'chinese',
      subCategory: 'tones',
      levelNumber: 4,
    ),
  ];

  /// 数学模块关卡
  static List<LevelModel> get mathLevels => [
    const LevelModel(
      id: 'math_number_recognition',
      name: '数字认知',
      emoji: '🔢',
      category: 'math',
      subCategory: 'number_recognition',
      levelNumber: 1,
    ),
    const LevelModel(
      id: 'math_addition',
      name: '加法',
      emoji: '➕',
      category: 'math',
      subCategory: 'addition',
      levelNumber: 2,
    ),
    const LevelModel(
      id: 'math_subtraction',
      name: '减法',
      emoji: '➖',
      category: 'math',
      subCategory: 'subtraction',
      levelNumber: 3,
    ),
  ];

  /// 获取所有关卡
  static List<LevelModel> get allLevels => [
    ...englishLevels,
    ...chineseLevels,
    ...mathLevels,
  ];

  /// 根据子类别获取关卡
  static LevelModel? getLevelBySubCategory(String subCategory) {
    try {
      return allLevels.firstWhere((level) => level.subCategory == subCategory);
    } catch (e) {
      return null;
    }
  }

  /// 获取模块的关卡列表
  static List<LevelModel> getLevelsByCategory(String category) {
    return allLevels.where((level) => level.category == category).toList();
  }
}
