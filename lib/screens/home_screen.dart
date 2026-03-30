import 'package:flutter/material.dart';
import '../app.dart';
import '../services/progress_service.dart';
import 'learning_map_screen.dart';

/// 首页 - 三大模块入口 + 进度地图风格
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalStars = 0;
  Map<String, int> _categoryStars = {
    'english': 0,
    'chinese': 0,
    'math': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final total = await ProgressService.getTotalStars();
    final english = await ProgressService.getCategoryStars('english');
    final chinese = await ProgressService.getCategoryStars('chinese');
    final math = await ProgressService.getCategoryStars('math');

    if (mounted) {
      setState(() {
        _totalStars = total;
        _categoryStars = {
          'english': english,
          'chinese': chinese,
          'math': math,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题和星星
            _buildHeader(),
            // 三模块入口卡片
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 英语模块
                    _buildModuleCard(
                      emoji: '🔤',
                      name: '英语学习',
                      color: AppTheme.englishNumbersCategory,
                      stars: _categoryStars['english'] ?? 0,
                      onTap: () => _navigateToLearningMap('english'),
                    ),
                    const SizedBox(height: 16),

                    // 语文模块
                    _buildModuleCard(
                      emoji: '🇨🇳',
                      name: '语文学习',
                      color: AppTheme.chineseCategory,
                      stars: _categoryStars['chinese'] ?? 0,
                      onTap: () => _navigateToLearningMap('chinese'),
                    ),
                    const SizedBox(height: 16),

                    // 数学模块
                    _buildModuleCard(
                      emoji: '🔢',
                      name: '数学学习',
                      color: AppTheme.mathCategory,
                      stars: _categoryStars['math'] ?? 0,
                      onTap: () => _navigateToLearningMap('math'),
                    ),
                  ],
                ),
              ),
            ),

            // 底部重置按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: _showResetDialog,
                child: const Text(
                  '家长模式：重置进度',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '小小探索家',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                '快乐学习！',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentColor, AppTheme.accentColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_totalStars',
                  style: const TextStyle(
                    fontSize: 24,
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

  Widget _buildModuleCard({
    required String emoji,
    required String name,
    required Color color,
    required int stars,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getModuleSubtitle(name),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '$stars',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getModuleSubtitle(String name) {
    switch (name) {
      case '英语学习':
        return '数字 · 词汇';
      case '语文学习':
        return '拼音 · 声调';
      case '数学学习':
        return '数字 · 加减法';
      default:
        return '';
    }
  }

  void _navigateToLearningMap(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LearningMapScreen(category: category),
      ),
    ).then((_) => _loadProgress());
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置进度'),
        content: const Text('确定要重置所有学习进度吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ProgressService.resetAllProgress();
              await _loadProgress();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('进度已重置')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('确定重置'),
          ),
        ],
      ),
    );
  }
}
