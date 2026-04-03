import 'dart:math';
import 'package:flutter/material.dart';
import '../app.dart';
import '../data/pinyin_data.dart';
import '../models/pinyin_model.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import '../widgets/matching_card.dart';
import '../widgets/star_rating.dart';
import '../widgets/progress_bar.dart';

/// 拼音游戏主界面
class PinyinGameScreen extends StatefulWidget {
  final String category;

  const PinyinGameScreen({super.key, required this.category});

  @override
  State<PinyinGameScreen> createState() => _PinyinGameScreenState();
}

class _PinyinGameScreenState extends State<PinyinGameScreen> {
  late List<PinyinModel> _pinyinData;
  final AudioService _audioService = AudioService();

  // 当前模式：learn, match
  String _currentMode = 'learn';

  // 学习模式状态
  int _currentCardIndex = 0;

  // 配对模式状态
  List<_PinyinMatchingItem> _matchingItems = [];
  _PinyinMatchingItem? _firstSelected;
  _PinyinMatchingItem? _secondSelected;
  int _matchedPairs = 0;
  int _attempts = 0;
  int _currentStars = 0;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _pinyinData = getAllPinyin()[widget.category] ?? [];
    _audioService.init();
  }

  Color _getCategoryColor() {
    switch (widget.category) {
      case 'initials':
        return const Color(0xFF5C6BC0);
      case 'finals':
        return const Color(0xFF26A69A);
      case 'wholes':
        return const Color(0xFFAB47BC);
      case 'tones':
        return const Color(0xFFEC407A);
      default:
        return AppTheme.chineseCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: _getCategoryColor(),
        title: Text(getPinyinCategoryName(widget.category)),
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
    // 四声页面特殊布局
    if (widget.category == 'tones') {
      return _buildTonesLearnMode();
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        // 进度指示器
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProgressBar(
            current: _currentCardIndex + 1,
            total: _pinyinData.length,
            color: _getCategoryColor(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentCardIndex + 1} / ${_pinyinData.length}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),

        // 闪卡
        Expanded(
          child: Center(
            child: _buildPinyinCard(_pinyinData[_currentCardIndex]),
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
                  _audioService.speakChinese(_pinyinData[_currentCardIndex].chinese);
                },
                color: AppTheme.secondaryColor,
              ),
              if (_currentCardIndex < _pinyinData.length - 1)
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
                  color: _getCategoryColor(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // 四声特殊布局 - 按行展示
  Widget _buildTonesLearnMode() {
    // 按韵母分组
    final Map<String, List<PinyinModel>> groupedTones = {};
    for (var p in _pinyinData) {
      final base = p.pinyin.replaceAll(RegExp(r'[āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜ]'), _getBaseVowel(p.pinyin));
      groupedTones[base] ??= [];
      groupedTones[base]!.add(p);
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          '单韵母四声练习',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _getCategoryColor(),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '点击卡片听发音',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _pinyinData.length,
              itemBuilder: (context, index) {
                final p = _pinyinData[index];
                return _buildToneCard(p);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildNavButton(
            icon: Icons.games,
            label: '开始配对',
            onTap: _startMatchingGame,
            color: _getCategoryColor(),
          ),
        ),
      ],
    );
  }

  String _getBaseVowel(String pinyin) {
    final vowels = ['a', 'o', 'e', 'i', 'u', 'ü'];
    for (var v in vowels) {
      if (pinyin.contains(v)) return v;
    }
    return pinyin;
  }

  Widget _buildToneCard(PinyinModel p) {
    return GestureDetector(
      onTap: () {
        _audioService.speakChinese(p.chinese);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_getCategoryColor(), _getCategoryColor().withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getCategoryColor().withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              p.pinyin,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              p.tone!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinyinCard(PinyinModel p) {
    return Container(
      width: 280,
      height: 360,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_getCategoryColor(), _getCategoryColor().withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            p.emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 20),
          Text(
            p.pinyin,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            p.chinese,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          if (p.group != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                p.group!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Text(
            '点击听发音',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
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
    final selectedData = _pinyinData.take(min(4, _pinyinData.length)).toList();
    _matchingItems = [];
    int id = 0;

    for (var pinyin in selectedData) {
      // 图片卡片（显示拼音）
      _matchingItems.add(_PinyinMatchingItem(
        id: id++,
        pinyin: pinyin.pinyin,
        chinese: pinyin.chinese,
        emoji: pinyin.emoji,
        isImage: true,
        pairId: pinyin.id,
      ));
      // 文字卡片（显示汉字）
      _matchingItems.add(_PinyinMatchingItem(
        id: id++,
        pinyin: pinyin.pinyin,
        chinese: pinyin.chinese,
        emoji: pinyin.emoji,
        isImage: false,
        pairId: pinyin.id,
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
            color: _getCategoryColor(),
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
                  content: item.isImage ? item.pinyin : item.chinese,
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

  void _onCardTap(_PinyinMatchingItem item) {
    if (_isChecking || item.isFlipped || item.isMatched) return;

    setState(() {
      item.isFlipped = true;
      _audioService.speakChinese(item.chinese);

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
              backgroundColor: _getCategoryColor(),
            ),
            child: const Text('返回'),
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
class _PinyinMatchingItem {
  final int id;
  final String pinyin;
  final String chinese;
  final String emoji;
  final bool isImage;
  final String pairId;
  bool isFlipped;
  bool isMatched;

  _PinyinMatchingItem({
    required this.id,
    required this.pinyin,
    required this.chinese,
    required this.emoji,
    required this.isImage,
    required this.pairId,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
