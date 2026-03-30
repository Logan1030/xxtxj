import 'package:flutter/material.dart';
import '../app.dart';
import '../models/level_model.dart';

/// 游戏模式选择器 - 底部大按钮
class GameModeSelector extends StatelessWidget {
  final GameMode currentMode;
  final Function(GameMode) onModeSelected;
  final bool isQuizMode; // 是否是答题模式（练习/挑战/极速）

  const GameModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
    this.isQuizMode = true, // 默认显示所有模式
  });

  @override
  Widget build(BuildContext context) {
    // 根据是否为答题模式决定显示哪些按钮
    final modes = isQuizMode
        ? GameMode.values
        : [GameMode.exploration, GameMode.practice];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: modes.map((mode) {
            final isSelected = currentMode == mode;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildModeButton(mode, isSelected),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildModeButton(GameMode mode, bool isSelected) {
    final color = _getModeColor(mode);
    final emoji = mode.emoji;
    final name = mode.name;
    final timeText = mode.timeLimit == 0 ? '无限制' : '${mode.timeLimit}秒';

    return GestureDetector(
      onTap: () => onModeSelected(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.8)],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: isSelected ? 24 : 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            Text(
              timeText,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? Colors.white70 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getModeColor(GameMode mode) {
    switch (mode) {
      case GameMode.exploration:
        return AppTheme.secondaryColor; // 青绿色
      case GameMode.practice:
        return AppTheme.primaryColor; // 温暖的红色
      case GameMode.challenge:
        return AppTheme.accentColor; // 明亮黄色
      case GameMode.rapid:
        return const Color(0xFFFF6B6B); // 红色（极速）
    }
  }
}

/// 游戏模式帮助类
class GameModeHelper {
  /// 根据模式获取计时器时间（秒）
  static int getTimerDuration(GameMode mode) {
    return mode.timeLimit;
  }

  /// 判断是否是计时模式
  static bool isTimedMode(GameMode mode) {
    return mode.timeLimit > 0;
  }

  /// 获取模式对应的颜色
  static Color getModeColor(GameMode mode) {
    switch (mode) {
      case GameMode.exploration:
        return AppTheme.secondaryColor;
      case GameMode.practice:
        return AppTheme.primaryColor;
      case GameMode.challenge:
        return AppTheme.accentColor;
      case GameMode.rapid:
        return const Color(0xFFFF6B6B);
    }
  }

  /// 获取星星评判标准（答对多少题得3星、2星、1星）
  static Map<int, double> getStarThresholds(int totalQuestions) {
    // 3星: 80%以上, 2星: 50%以上, 1星: 完成即可
    return {
      3: totalQuestions * 0.8, // 80%
      2: totalQuestions * 0.5, // 50%
    };
  }
}
