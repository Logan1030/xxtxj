import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../app.dart';
import '../data/english_numbers_data.dart';
import '../models/english_number_model.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import '../utils/storage_helper.dart';
import '../widgets/letter_tile_widget.dart';
import '../widgets/matching_card.dart';
import '../widgets/star_rating.dart';
import '../widgets/progress_bar.dart';

/// 英语1-10三模式学习游戏页面
class EnglishNumbersGameScreen extends StatefulWidget {
  const EnglishNumbersGameScreen({super.key});

  @override
  State<EnglishNumbersGameScreen> createState() =>
      _EnglishNumbersGameScreenState();
}

class _EnglishNumbersGameScreenState extends State<EnglishNumbersGameScreen> {
  final AudioService _audioService = AudioService();

  // 当前模式：learn(闪卡), match(配对), spell(拼写)
  String _currentMode = 'learn';

  // 闪卡模式状态
  int _currentCardIndex = 0;

  // 配对模式状态
  List<_MatchingItem> _matchingItems = [];
  _MatchingItem? _firstSelected;
  _MatchingItem? _secondSelected;
  int _matchedPairs = 0;
  int _attempts = 0;
  bool _isChecking = false;

  // 拼写模式状态
  int _spellIndex = 0;
  List<String> _availableLetters = [];
  List<String> _selectedLetters = [];
  int _spellAttempts = 0;
  int _spellStars = 0;

  // 极速闯关模式状态
  int _rapidIndex = 0;
  int _rapidCorrect = 0;
  int _rapidTimeLeft = 5;
  bool _rapidAnswered = false;
  List<String> _rapidSelected = [];
  List<int> _rapidTimes = [];
  Timer? _rapidTimer;
  List<EnglishNumberModel> _rapidQuestions = [];

  @override
  void initState() {
    super.initState();
    _audioService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4ECDC4),
        title: const Text('英语数字 1-10'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 模式切换按钮
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (mode) {
              setState(() {
                _currentMode = mode;
                if (mode == 'learn') {
                  _currentCardIndex = 0;
                } else if (mode == 'match') {
                  _initMatchingGame();
                } else if (mode == 'spell') {
                  _initSpellGame();
                } else if (mode == 'rapid') {
                  _initRapidGame();
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'learn',
                child: Row(
                  children: [
                    Icon(Icons.style, color: Color(0xFFFF6B6B)),
                    SizedBox(width: 8),
                    Text('认读模式'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'match',
                child: Row(
                  children: [
                    Icon(Icons.grid_view, color: Color(0xFF4ECDC4)),
                    SizedBox(width: 8),
                    Text('配对模式'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'spell',
                child: Row(
                  children: [
                    Icon(Icons.spellcheck, color: Color(0xFFFFE66D)),
                    SizedBox(width: 8),
                    Text('拼写模式'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'rapid',
                child: Row(
                  children: [
                    Icon(Icons.speed, color: Color(0xFFFFE66D)),
                    SizedBox(width: 8),
                    Text('极速闯关 ⭐NEW'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentMode) {
      case 'learn':
        return _buildLearnMode();
      case 'match':
        return _buildMatchMode();
      case 'spell':
        return _buildSpellMode();
      case 'rapid':
        return _buildRapidMode();
      default:
        return _buildLearnMode();
    }
  }

  // ==================== 认读模式 ====================
  Widget _buildLearnMode() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProgressBar(
            current: _currentCardIndex + 1,
            total: englishNumbersData.length,
            color: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentCardIndex + 1} / ${englishNumbersData.length}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Expanded(
          child: Center(
            child: _buildFlashcard(englishNumbersData[_currentCardIndex]),
          ),
        ),
        _buildLearnNavigation(),
      ],
    );
  }

  Widget _buildFlashcard(EnglishNumberModel item) {
    return Container(
      width: 280,
      height: 360,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
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
            item.emoji,
            style: const TextStyle(fontSize: 100),
          ),
          const SizedBox(height: 20),
          Text(
            item.word,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.chinese,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _audioService.speak(item.word),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    '点击听发音',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnNavigation() {
    return Padding(
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
              _audioService.speak(englishNumbersData[_currentCardIndex].word);
            },
            color: AppTheme.secondaryColor,
          ),
          if (_currentCardIndex < englishNumbersData.length - 1)
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
              icon: Icons.spellcheck,
              label: '开始拼写',
              onTap: () {
                setState(() {
                  _currentMode = 'spell';
                  _initSpellGame();
                });
              },
              color: const Color(0xFFFFE66D),
            ),
        ],
      ),
    );
  }

  // ==================== 配对模式 ====================
  void _initMatchingGame() {
    _matchingItems = [];
    int id = 0;
    final selectedNumbers = englishNumbersData.take(4).toList();

    for (var number in selectedNumbers) {
      _matchingItems.add(_MatchingItem(
        id: id++,
        word: number.word,
        emoji: number.emoji,
        isImage: true,
        pairId: number.id,
      ));
      _matchingItems.add(_MatchingItem(
        id: id++,
        word: number.word,
        emoji: number.emoji,
        isImage: false,
        pairId: number.id,
      ));
    }

    _matchingItems.shuffle(Random());
    _firstSelected = null;
    _secondSelected = null;
    _matchedPairs = 0;
    _attempts = 0;
  }

  Widget _buildMatchMode() {
    return Column(
      children: [
        const SizedBox(height: 16),
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
            color: const Color(0xFF4ECDC4),
          ),
        ),
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
                  onTap: () => _onMatchCardTap(item),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextButton(
            onPressed: () {
              setState(() {
                _currentMode = 'learn';
                _currentCardIndex = 0;
              });
            },
            child: const Text('返回认读模式'),
          ),
        ),
      ],
    );
  }

  void _onMatchCardTap(_MatchingItem item) {
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
      setState(() {
        _firstSelected!.isMatched = true;
        _secondSelected!.isMatched = true;
        _matchedPairs++;
        _firstSelected = null;
        _secondSelected = null;
        _isChecking = false;
      });

      _audioService.playCheerSound();

      if (_matchedPairs == _matchingItems.length ~/ 2) {
        _onMatchComplete();
      }
    } else {
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

  void _onMatchComplete() {
    final totalPairs = _matchingItems.length ~/ 2;
    final accuracy = totalPairs / _attempts;
    int stars = accuracy >= 0.8 ? 3 : (accuracy >= 0.5 ? 2 : 1);
    _audioService.speakStars(stars);
    _saveProgress(stars);
    // 解锁下一关（英语数字是英语模块的第1关）
    ProgressService.unlockNextLevelByCategory('english', 1);
    _showCompletionDialog(stars);
  }

  Future<void> _saveProgress(int stars) async {
    await ProgressService.saveLevelStars('english_numbers', stars);
  }

  // ==================== 拼写模式 ====================
  void _initSpellGame() {
    _spellIndex = 0;
    _spellAttempts = 0;
    _spellStars = 0;
    _setupSpellLetters();
  }

  void _setupSpellLetters() {
    final current = englishNumbersData[_spellIndex];
    _selectedLetters = [];

    // 生成字母池：正确字母 + 干扰字母
    _availableLetters = List.from(current.letters);
    final distractorLetters = ['x', 'z', 'q', 'y', 'k', 'j', 'v', 'w'];
    for (var l in distractorLetters) {
      if (_availableLetters.length < 8) {
        _availableLetters.add(l);
      }
    }
    _availableLetters.shuffle(Random());
  }

  Widget _buildSpellMode() {
    final current = englishNumbersData[_spellIndex];
    final targetLength = current.letters.length;

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
                '第 ${_spellIndex + 1} / ${englishNumbersData.length} 题',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              StarRating(stars: _spellStars, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProgressBar(
            current: _spellIndex,
            total: englishNumbersData.length,
            color: const Color(0xFFFFE66D),
          ),
        ),

        const SizedBox(height: 24),
        // Emoji和中文提示
        Text(
          current.emoji,
          style: const TextStyle(fontSize: 80),
        ),
        Text(
          current.chinese,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4ECDC4),
          ),
        ),

        const SizedBox(height: 24),
        // 目标字母槽
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(targetLength, (index) {
              final hasLetter = index < _selectedLetters.length;
              final letter = hasLetter ? _selectedLetters[index] : '';
              final isCorrect = hasLetter &&
                  letter.toLowerCase() == current.letters[index].toLowerCase();

              return Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: hasLetter
                      ? (isCorrect
                          ? const Color(0xFF4ECDC4)
                          : const Color(0xFFFF6B6B))
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasLetter
                        ? Colors.transparent
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    hasLetter ? letter.toUpperCase() : '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),
        Text(
          hasAllCorrect() ? '太棒了！' : '请选择字母组成单词',
          style: TextStyle(
            fontSize: 18,
            color: hasAllCorrect() ? const Color(0xFF4ECDC4) : Colors.grey,
          ),
        ),

        const Spacer(),

        // 字母池
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _availableLetters.asMap().entries.map((entry) {
              final letter = entry.value;
              final isUsed = _selectedLetters.contains(letter);

              return LetterTileWidget(
                letter: letter,
                isSelected: isUsed,
                isInTarget: false,
                isCorrectPosition: false,
                onTap: () => _onLetterTap(letter),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // 操作按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 回退按钮
              if (_selectedLetters.isNotEmpty)
                _buildNavButton(
                  icon: Icons.undo,
                  label: '撤销',
                  onTap: () {
                    setState(() {
                      _selectedLetters.removeLast();
                    });
                  },
                  color: Colors.grey,
                ),
              // 发音按钮
              _buildNavButton(
                icon: Icons.volume_up,
                label: '发音',
                onTap: () => _audioService.speak(current.word),
                color: AppTheme.secondaryColor,
              ),
              // 清除按钮
              if (_selectedLetters.isNotEmpty)
                _buildNavButton(
                  icon: Icons.refresh,
                  label: '清除',
                  onTap: () {
                    setState(() {
                      _selectedLetters.clear();
                    });
                  },
                  color: const Color(0xFFFF6B6B),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  bool hasAllCorrect() {
    if (_selectedLetters.length != englishNumbersData[_spellIndex].letters.length) {
      return false;
    }
    for (int i = 0; i < _selectedLetters.length; i++) {
      if (_selectedLetters[i].toLowerCase() !=
          englishNumbersData[_spellIndex].letters[i].toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  void _onLetterTap(String letter) {
    if (_selectedLetters.contains(letter)) return;

    setState(() {
      _selectedLetters.add(letter);
    });

    // 检查是否完成
    if (_selectedLetters.length == englishNumbersData[_spellIndex].letters.length) {
      if (hasAllCorrect()) {
        // 正确！
        _spellAttempts++;
        _spellStars++;
        _audioService.playCheerSound();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _nextSpellWord();
          }
        });
      } else {
        // 错误，抖动提示
        _spellAttempts++;
        _audioService.speak('try again');
        setState(() {
          _selectedLetters.clear();
        });
      }
    }
  }

  void _nextSpellWord() {
    if (_spellIndex < englishNumbersData.length - 1) {
      setState(() {
        _spellIndex++;
        _setupSpellLetters();
      });
    } else {
      // 完成所有
      _showSpellCompletionDialog();
    }
  }

  void _showSpellCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '拼写完成！',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            StarRating(stars: _spellStars.clamp(0, 3), size: 50),
            const SizedBox(height: 20),
            Text(
              _spellStars >= 8
                  ? '完美！你真是个小天才！'
                  : (_spellStars >= 5
                      ? '很棒！继续加油！'
                      : '不错！再试一次能做得更好！'),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _initSpellGame();
              });
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

  // ==================== 极速闯关模式 ====================
  void _initRapidGame() {
    _rapidIndex = 0;
    _rapidCorrect = 0;
    _rapidTimes = [];
    _rapidQuestions = List.from(englishNumbersData)..shuffle(Random());
    _rapidQuestions = _rapidQuestions.take(10).toList();
    _setupRapidQuestion();
  }

  void _setupRapidQuestion() {
    _rapidSelected = [];
    _rapidAnswered = false;
    _rapidTimeLeft = 5;
    _startRapidTimer();
  }

  void _startRapidTimer() {
    _rapidTimer?.cancel();
    _rapidTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_rapidTimeLeft > 0) {
        setState(() => _rapidTimeLeft--);
      } else {
        _onRapidTimeout();
      }
    });
  }

  void _onRapidTimeout() {
    _rapidTimer?.cancel();
    setState(() => _rapidAnswered = true);
    _audioService.speak('time up');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _nextRapidQuestion();
      }
    });
  }

  void _nextRapidQuestion() {
    if (_rapidIndex < _rapidQuestions.length - 1) {
      setState(() {
        _rapidIndex++;
        _setupRapidQuestion();
      });
    } else {
      _showRapidComplete();
    }
  }

  Widget _buildRapidMode() {
    final current = _rapidQuestions[_rapidIndex];
    final targetLength = current.letters.length;
    final currentStars = _calculateRapidStars();

    return Column(
      children: [
        const SizedBox(height: 16),
        // 顶部信息栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 倒计时
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _rapidTimeLeft <= 2 ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${_rapidTimeLeft}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              // 题号
              Text(
                '第 ${_rapidIndex + 1}/${_rapidQuestions.length} 题',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // 星级
              StarRating(stars: currentStars, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 进度条
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProgressBar(
            current: _rapidIndex,
            total: _rapidQuestions.length,
            color: const Color(0xFFFFE66D),
          ),
        ),
        const Spacer(),
        // Emoji
        Text(
          current.emoji,
          style: const TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 8),
        // 单词提示
        Text(
          current.word,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(height: 24),
        // 目标字母槽
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(targetLength, (index) {
              final hasLetter = index < _rapidSelected.length;
              final letter = hasLetter ? _rapidSelected[index] : '';
              final isCorrect = hasLetter &&
                  letter.toLowerCase() == current.letters[index].toLowerCase();

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _rapidAnswered
                      ? (isCorrect ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B))
                      : (hasLetter
                          ? (isCorrect ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B))
                          : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasLetter ? Colors.transparent : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    hasLetter ? letter.toUpperCase() : '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const Spacer(),
        // 字母池
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _buildRapidLetterPool(current).asMap().entries.map((entry) {
              final letter = entry.value;
              final isUsed = _rapidSelected.contains(letter);

              return LetterTileWidget(
                letter: letter,
                isSelected: isUsed,
                isInTarget: false,
                isCorrectPosition: false,
                onTap: () => _onRapidLetterTap(letter),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        // 发音按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavButton(
                icon: Icons.volume_up,
                label: '发音',
                onTap: () => _audioService.speak(current.word),
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  List<String> _buildRapidLetterPool(EnglishNumberModel current) {
    final pool = List<String>.from(current.letters);
    final distractors = ['x', 'z', 'q', 'y', 'k', 'j', 'v', 'w', 'a', 'b', 'c', 'd', 'e'];
    for (var l in distractors) {
      if (pool.length < 8 && !pool.contains(l)) {
        pool.add(l);
      }
    }
    pool.shuffle(Random());
    return pool;
  }

  void _onRapidLetterTap(String letter) {
    if (_rapidAnswered) return;
    if (_rapidSelected.contains(letter)) return;

    final current = _rapidQuestions[_rapidIndex];

    setState(() => _rapidSelected.add(letter));

    // 检查是否完成
    if (_rapidSelected.length == current.letters.length) {
      if (_checkRapidCorrect()) {
        // 正确！
        _rapidTimer?.cancel();
        _rapidCorrect++;
        _rapidTimes.add(5 - _rapidTimeLeft);
        _audioService.playCheerSound();
        setState(() => _rapidAnswered = true);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _nextRapidQuestion();
          }
        });
      } else {
        // 错误
        _audioService.speak('try again');
        setState(() => _rapidSelected.clear());
      }
    }
  }

  bool _checkRapidCorrect() {
    if (_rapidSelected.length != _rapidQuestions[_rapidIndex].letters.length) {
      return false;
    }
    for (int i = 0; i < _rapidSelected.length; i++) {
      if (_rapidSelected[i].toLowerCase() !=
          _rapidQuestions[_rapidIndex].letters[i].toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  int _calculateRapidStars() {
    if (_rapidCorrect >= 9) return 3;
    if (_rapidCorrect >= 7) return 2;
    if (_rapidCorrect >= 5) return 1;
    return 0;
  }

  void _showRapidComplete() {
    _rapidTimer?.cancel();
    final totalTime = _rapidTimes.fold(0, (a, b) => a + b);
    final stars = _calculateRapidStars();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _rapidCorrect >= 8 ? '太棒了！' : '继续加油！',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StarRating(stars: stars, size: 50),
            const SizedBox(height: 20),
            Text(
              '正确: $_rapidCorrect/${_rapidQuestions.length}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              '用时: ${totalTime}s',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              _rapidCorrect >= 9
                  ? '完美！你真是个小天才！'
                  : (_rapidCorrect >= 7
                      ? '很棒！继续加油！'
                      : '不错！再试一次能做得更好！'),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _initRapidGame();
              });
            },
            child: const Text('再闯一次'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rapidTimer?.cancel();
    super.dispose();
  }

  // ==================== 通用组件 ====================
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
              stars == 3
                  ? '完美！你真是个小天才！'
                  : (stars == 2
                      ? '很棒！继续加油！'
                      : '不错！再试一次能做得更好！'),
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
