/// 成就类型枚举
enum AchievementType {
  firstClear('初次通关', '🌟', '第一次完成任意关卡'),
  streak3('连续正确', '🔥', '连续答对3题'),
  perfect('完美通关', '💯', '三星完美通过一个关卡'),
  speedStar('速度之星', '⚡', '在挑战模式下10秒内答对5题'),
  learningMaster('学习达人', '🎓', '完成所有关卡');

  final String name;
  final String emoji;
  final String description;

  const AchievementType(this.name, this.emoji, this.description);
}

/// 成就模型
class AchievementModel {
  final AchievementType type;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  const AchievementModel({
    required this.type,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  AchievementModel copyWith({
    AchievementType? type,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return AchievementModel(
      type: type ?? this.type,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'type': type.index,
    'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    'isUnlocked': isUnlocked,
  };

  /// 从JSON创建
  factory AchievementModel.fromJson(Map<String, dynamic> json) => AchievementModel(
    type: AchievementType.values[json['type'] as int],
    unlockedAt: json['unlockedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'] as int)
        : null,
    isUnlocked: json['isUnlocked'] as bool,
  );

  /// 获取图标
  String get emoji => type.emoji;

  /// 获取名称
  String get name => type.name;

  /// 获取描述
  String get description => type.description;
}

/// 成就数据
class AchievementData {
  /// 获取所有成就的初始状态
  static List<AchievementModel> get allAchievements => [
    const AchievementModel(type: AchievementType.firstClear),
    const AchievementModel(type: AchievementType.streak3),
    const AchievementModel(type: AchievementType.perfect),
    const AchievementModel(type: AchievementType.speedStar),
    const AchievementModel(type: AchievementType.learningMaster),
  ];
}
