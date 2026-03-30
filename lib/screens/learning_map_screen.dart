import 'package:flutter/material.dart';
import '../app.dart';
import '../models/level_model.dart';
import '../services/progress_service.dart';
import '../widgets/journey_map_widget.dart';
import '../widgets/level_node_widget.dart';
import 'chinese_game_screen.dart';
import 'english_numbers_game_screen.dart';
import 'english_words_game_screen.dart';
import 'math_game_screen.dart';

/// 学习地图界面 - 显示单个模块的关卡进度
class LearningMapScreen extends StatefulWidget {
  final String category; // english, chinese, math

  const LearningMapScreen({
    super.key,
    required this.category,
  });

  @override
  State<LearningMapScreen> createState() => _LearningMapScreenState();
}

class _LearningMapScreenState extends State<LearningMapScreen> {
  List<LevelModel> _levels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    final levels = await ProgressService.getLevelsByCategory(widget.category);
    if (mounted) {
      setState(() {
        _levels = levels;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 顶部导航栏
                  _buildHeader(),
                  // 地图内容
                  Expanded(
                    child: JourneyMapWidget(
                      levels: _levels,
                      category: widget.category,
                      onLevelTap: _onLevelTap,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // 标题
          Expanded(
            child: Text(
              _getCategoryTitle(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _getCategoryColor(),
              ),
            ),
          ),
          // 星星数量
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 4),
                Text(
                  '$_totalStars',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int get _totalStars {
    return _levels.where((l) => l.status == LevelStatus.completed)
        .fold(0, (sum, l) => sum + l.stars);
  }

  String _getCategoryTitle() {
    switch (widget.category) {
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
    switch (widget.category) {
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

  void _onLevelTap(LevelModel level) {
    if (level.status == LevelStatus.locked) return;

    // 根据子类别导航到对应游戏
    switch (level.subCategory) {
      case 'english_numbers':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EnglishNumbersGameScreen(),
          ),
        ).then((_) => _loadLevels());
        break;
      case 'english_words':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EnglishWordsGameScreen(),
          ),
        ).then((_) => _loadLevels());
        break;
      case 'initials':
      case 'finals':
      case 'wholes':
      case 'tones':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChineseGameScreen(),
          ),
        ).then((_) => _loadLevels());
        break;
      case 'number_recognition':
      case 'addition':
      case 'subtraction':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MathGameScreen(),
          ),
        ).then((_) => _loadLevels());
        break;
    }
  }
}
