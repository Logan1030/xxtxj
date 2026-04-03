import 'dart:math';
import 'package:flutter/material.dart';
import '../app.dart';
import '../data/words_data.dart';
import '../models/word_model.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/matching_card.dart';
import '../widgets/star_rating.dart';
import '../widgets/progress_bar.dart';

/// 游戏主界面
class GameScreen extends StatefulWidget {
  final String category;

  const GameScreen({super.key, required this.category});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<WordModel> _words;
  final AudioService _audioService = AudioService();

  // 当前模式：learn, match
  String _currentMode = 'learn';

  // 学习模式状态
  int _currentCardIndex = 0;

  // 配对模式状态
  List<_MatchingItem> _matchingItems = [];
  _MatchingItem? _firstSelected;
  _MatchingItem? _secondSelected;
  int _matchedPairs = 0;
  int _attempts = 0;
  int _currentStars = 0;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _words = getAllWords()[widget.category] ?? [];
    _audioService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.getCategoryColor(widget.category),
        title: Text(getCategoryName(widget.category)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _currentMode == 'learn' ? _buildLearnMode() : _buildMatchMode(),
    );
  }

  // 学习模式
  Widget _buildLearnMode() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // 进度指示器
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProgressBar(
            current: _currentCardIndex + 1,
            total: _words.length,
            color: AppTheme.getCategoryColor(widget.category),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentCardIndex + 1} / ${_words.length}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),

        // 闪卡
        Expanded(
          child: Center(
            child: FlashcardWidget(
              word: _words[_currentCardIndex],
            ),
          ),
        ),

        // 导航按钮
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_currentCardIndex > 0)
                _buildNavButton(
                  icon: Icons.arrow_back,
                  label: '上一个',
                  onTap: () {
                    setState(() {
                      _currentCardIndex--;
                    });
                  },
                ),
              _buildNavButton(
                icon: Icons.play_arrow,
                label: '听发音',
                onTap: () {
                  _audioService.speak(_words[_currentCardIndex].word);
                },
                color: AppTheme.secondaryColor,
              ),
              if (_currentCardIndex < _words.length - 1)
                _buildNavButton(
                  icon: Icons.arrow_forward,
                  label: '下一个',
                  onTap: () {
                    setState(() {
                      _currentCardIndex++;
                    });
                  },
                )
              else
                _buildNavButton(
                  icon: Icons.games,
                  label: '开始配对',
                  onTap: _startMatchingGame,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppTheme.primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 开始配对游戏
  void _startMatchingGame() {
    setState(() {
      _currentMode = 'match';
      _initMatchingGame();
    });
  }

  void _initMatchingGame() {
    // 选取4对卡片（8张）
    final selectedWords = _words.take(min(4, _words.length)).toList();
    _matchingItems = [];
    int id = 0;

    for (var word in selectedWords) {
      // 图片卡片
      _matchingItems.add(_MatchingItem(
        id: id++,
        word: word.word,
        emoji: word.emoji,
        isImage: true,
        pairId: word.id,
      ));
      // 文字卡片
      _matchingItems.add(_MatchingItem(
        id: id++,
        word: word.word,
        emoji: word.emoji,
        isImage: false,
        pairId: word.id,
      ));
    }

    // 随机打乱
    _matchingItems.shuffle(Random());

    _firstSelected = null;
    _secondSelected = null;
    _matchedPairs = 0;
    _attempts = 0;
    _currentStars = 0;
  }

  // 配对模式
  Widget _buildMatchMode() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // 进度
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '配对: $_matchedPairs / ${_matchingItems.length ~/ 2}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '尝试: $_attempts',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProgressBar(
            current: _matchedPairs,
            total: _matchingItems.length ~/ 2,
            color: AppTheme.getCategoryColor(widget.category),
          ),
        ),

        // 配对网格
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _matchingItems.length,
              itemBuilder: (context, index) {
                final item = _matchingItems[index];
                return MatchingCard(
                  content: item.word,
                  emoji: item.emoji,
                  isFlipped: item.isFlipped,
                  isMatched: item.isMatched,
                  isImageCard: item.isImage,
                  onTap: () => _onCardTap(item),
                );
              },
            ),
          ),
        ),

        // 返回学习模式按钮
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextButton(
            onPressed: () {
              setState(() {
                _currentMode = 'learn';
                _currentCardIndex = 0;
              });
            },
            child: const Text('返回学习模式'),
          ),
        ),
      ],
    );
  }

  void _onCardTap(_MatchingItem item) {
    if (_isChecking || item.isFlipped || item.isMatched) return;

    setState(() {
      item.isFlipped = true;
      _audioService.speak(item.word);

      if (_firstSelected == null) {
        _firstSelected = item;
      } else {
        _secondSelected = item;
        _attempts++;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    _isChecking = true;

    if (_firstSelected!.pairId == _secondSelected!.pairId) {
      // 配对成功
      setState(() {
        _firstSelected!.isMatched = true;
        _secondSelected!.isMatched = true;
        _matchedPairs++;
        _firstSelected = null;
        _secondSelected = null;
        _isChecking = false;
      });

      // 播放成功音效
      _audioService.playCheerSound();

      // 检查是否完成
      if (_matchedPairs == _matchingItems.length ~/ 2) {
        _onGameComplete();
      }
    } else {
      // 配对失败，延迟翻转回去
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _firstSelected!.isFlipped = false;
            _secondSelected!.isFlipped = false;
            _firstSelected = null;
            _secondSelected = null;
            _isChecking = false;
          });
        }
      });
    }
  }

  void _onGameComplete() {
    // 计算星星
    final totalPairs = _matchingItems.length ~/ 2;
    final accuracy = totalPairs / _attempts;

    int stars;
    if (accuracy >= 0.8) {
      stars = 3;
    } else if (accuracy >= 0.5) {
      stars = 2;
    } else {
      stars = 1;
    }

    _currentStars = stars;
    _audioService.speakStars(stars);

    // 保存进度
    _saveProgress(stars);

    // 显示完成对话框
    _showCompletionDialog(stars);
  }

  Future<void> _saveProgress(int stars) async {
    // 使用 ProgressService 与 HomeScreen 保持一致
    await ProgressService.saveLevelStars(widget.category, stars);
  }

  void _showCompletionDialog(int stars) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '太棒了！',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            StarRating(stars: stars, size: 50),
            const SizedBox(height: 20),
            Text(
              _getEncouragementText(stars),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initMatchingGame();
            },
            child: const Text('再玩一次'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }

  String _getEncouragementText(int stars) {
    switch (stars) {
      case 3:
        return '完美！你真是个小天才！';
      case 2:
        return '很棒！继续加油！';
      default:
        return '不错！再试一次能做得更好！';
    }
  }
}

/// 配对游戏的数据项
class _MatchingItem {
  final int id;
  final String word;
  final String emoji;
  final bool isImage;
  final String pairId;
  bool isFlipped;
  bool isMatched;

  _MatchingItem({
    required this.id,
    required this.word,
    required this.emoji,
    required this.isImage,
    required this.pairId,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
