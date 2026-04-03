import 'package:flutter/material.dart';
import '../app.dart';
import '../data/math_data.dart';
import '../services/progress_service.dart';
import '../widgets/letter_tile_widget.dart';
import '../widgets/matching_card.dart';
import '../widgets/star_rating.dart';
import '../widgets/progress_bar.dart';
import '../widgets/game_mode_selector.dart';
import '../models/math_model.dart';
import '../models/level_model.dart';

/// 数学游戏主界面
class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  @override
  Widget build(BuildContext context) {
    final subCategories = getMathSubCategories();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.mathCategory,
        title: const Text('数学篇'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 顶部标题
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    '🔢 数学学习',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mathCategory,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '学数学，促思维',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 子类别网格
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: subCategories.length,
                  itemBuilder: (context, index) {
                    final subCategory = subCategories[index];
                    return _buildSubCategoryCard(subCategory);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoryCard(String subCategory) {
    final color = getMathCategoryColor(subCategory);
    final emoji = getMathCategoryEmoji(subCategory);
    final name = getMathCategoryName(subCategory);

    return GestureDetector(
      onTap: () => _navigateToGame(subCategory),
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 50),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(String subCategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MathSubCategoryScreen(category: subCategory),
      ),
    );
  }
}

/// 数学子类别游戏界面
class MathSubCategoryScreen extends StatefulWidget {
  final String category;

  const MathSubCategoryScreen({super.key, required this.category});

  @override
  State<MathSubCategoryScreen> createState() => _MathSubCategoryScreenState();
}

class _MathSubCategoryScreenState extends State<MathSubCategoryScreen> {
  GameMode _currentMode = GameMode.exploration;

  // 闪卡模式状态
  int _currentCardIndex = 0;

  // 配对模式状态
  List<_MathMatchingItem> _matchingItems = [];
  _MathMatchingItem? _firstSelected;
  _MathMatchingItem? _secondSelected;
  int _matchedPairs = 0;
  int _attempts = 0;
  bool _isChecking = false;

  // 答题模式状态 (practice/challenge)
  int _spellIndex = 0;
  List<int> _availableNumbers = [];
  int? _selectedAnswer;
  int _spellStars = 0;
  int _spellAttempts = 0;
  int _quizTimeLeft = 0;
  bool _quizAnswered = false;
  int? _quizSelected;

  // 极速闯关模式状态
  List<dynamic> _rapidQuestions = [];
  int _rapidIndex = 0;
  int _rapidCorrect = 0;
  int _rapidTimeLeft = 5;
  bool _rapidAnswered = false;
  int? _rapidSelected;

  @override
  void initState() {
    super.initState();
  }

  void _onModeSelected(GameMode mode) {
    setState(() {
      _currentMode = mode;
      if (mode == GameMode.exploration) {
        _currentCardIndex = 0;
      } else if (mode == GameMode.practice || mode == GameMode.challenge) {
        _initQuizGame(mode.timeLimit);
      } else if (mode == GameMode.rapid) {
        _initRapidGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = getMathCategoryColor(widget.category);
    final name = getMathCategoryName(widget.category);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: color,
        title: Text(name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          GameModeSelector(
            currentMode: _currentMode,
            onModeSelected: _onModeSelected,
            isQuizMode: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentMode) {
      case GameMode.exploration:
        return _buildLearnMode();
      case GameMode.practice:
      case GameMode.challenge:
        return _buildSpellMode();
      case GameMode.rapid:
        return _buildRapidMode();
    }
  }

  // ==================== 认读模式 (探险模式) ====================
  Widget _buildLearnMode() {
    List<dynamic> data;
    if (widget.category == 'number_recognition') {
      data = mathNumbersData;
    } else if (widget.category == 'addition') {
      data = mathAdditionData;
    } else {
      data = mathSubtractionData;
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProgressBar(
            current: _currentCardIndex + 1,
            total: data.length,
            color: getMathCategoryColor(widget.category),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentCardIndex + 1} / ${data.length}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Expanded(
          child: Center(
            child: _buildFlashcard(data[_currentCardIndex]),
          ),
        ),
        _buildLearnNavigation(data),
      ],
    );
  }

  Widget _buildFlashcard(dynamic item) {
    final color = getMathCategoryColor(widget.category);
    String display = '';

    if (widget.category == 'number_recognition') {
      display = '${item.emoji}\n${item.number}\n${item.chinese}';
    } else {
      display = '${item.expression}';
    }

    return Container(
      width: 280,
      height: 360,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
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
          if (widget.category == 'number_recognition') ...[
            Text(
              item.emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),
            Text(
              '${item.number}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.chinese,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white70,
              ),
            ),
          ] else ...[
            Text(
              item.expression,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '= ${item.answer}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLearnNavigation(List<dynamic> data) {
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
          if (_currentCardIndex < data.length - 1)
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
              icon: Icons.psychology,
              label: '开始答题',
              onTap: () {
                setState(() {
                  _currentMode = GameMode.practice;
                  _initQuizGame(GameMode.practice.timeLimit);
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

    List<dynamic> sourceData;
    if (widget.category == 'number_recognition') {
      sourceData = mathNumbersData.take(4).toList();
    } else if (widget.category == 'addition') {
      sourceData = mathAdditionData.take(4).toList();
    } else {
      sourceData = mathSubtractionData.take(4).toList();
    }

    for (var item in sourceData) {
      String left, right;
      if (widget.category == 'number_recognition') {
        left = '${item.number}';
        right = item.chinese;
      } else {
        left = item.expression;
        right = '${item.answer}';
      }

      _matchingItems.add(_MathMatchingItem(
        id: id++,
        content: left,
        pairContent: right,
        isImage: true,
        pairId: item.id,
      ));
      _matchingItems.add(_MathMatchingItem(
        id: id++,
        content: right,
        pairContent: left,
        isImage: false,
        pairId: item.id,
      ));
    }

    _matchingItems.shuffle();
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
            color: getMathCategoryColor(widget.category),
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
                  content: item.content,
                  emoji: '',
                  isFlipped: item.isFlipped,
                  isMatched: item.isMatched,
                  isImageCard: item.isImage,
                  onTap: () => _onMatchCardTap(item),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onMatchCardTap(_MathMatchingItem item) {
    if (_isChecking || item.isFlipped || item.isMatched) return;

    setState(() {
      item.isFlipped = true;

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
    _saveProgress(stars);
    _showCompletionDialog(stars);
  }

  // ==================== 答题模式 (练习/挑战) ====================
  void _initQuizGame(int timerDuration) {
    _spellIndex = 0;
    _spellAttempts = 0;
    _spellStars = 0;
    _quizTimeLeft = timerDuration;
    _quizAnswered = false;
    _quizSelected = null;
    _generateAnswerOptions();
  }

  void _startQuizTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _quizAnswered) return;
      setState(() {
        if (_quizTimeLeft > 0) {
          _quizTimeLeft--;
        }
      });
      if (_quizTimeLeft > 0) {
        _startQuizTimer();
      } else {
        _onQuizTimeout();
      }
    });
  }

  void _onQuizTimeout() {
    setState(() => _quizAnswered = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _generateAnswerOptions() {
    List<dynamic> data;
    if (widget.category == 'number_recognition') {
      data = mathNumbersData;
    } else if (widget.category == 'addition') {
      data = mathAdditionData;
    } else {
      data = mathSubtractionData;
    }

    final currentItem = data[_spellIndex];
    final correctAnswer = widget.category == 'number_recognition'
        ? currentItem.number
        : currentItem.answer;

    _availableNumbers = [correctAnswer];
    final allNumbers = widget.category == 'number_recognition'
        ? List.generate(20, (i) => i + 1)
        : List.generate(10, (i) => i);

    allNumbers.shuffle();
    for (var num in allNumbers) {
      if (_availableNumbers.length < 4 && num != correctAnswer) {
        _availableNumbers.add(num);
      }
    }
    _availableNumbers.shuffle();
    _selectedAnswer = null;
  }

  Widget _buildSpellMode() {
    List<dynamic> data;
    if (widget.category == 'number_recognition') {
      data = mathNumbersData;
    } else if (widget.category == 'addition') {
      data = mathAdditionData;
    } else {
      data = mathSubtractionData;
    }

    final currentItem = data[_spellIndex];
    final total = data.length;
    final hasTimer = _currentMode != GameMode.exploration;
    final timerColor = hasTimer && _currentMode.timeLimit > 0
        ? (_quizTimeLeft <= 2 ? const Color(0xFFFF6B6B) : GameModeHelper.getModeColor(_currentMode))
        : null;

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (hasTimer)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: timerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${_quizTimeLeft}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  '第 ${_spellIndex + 1} / $total 题',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              StarRating(stars: _spellStars.clamp(0, 3), size: 24),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProgressBar(
            current: _spellIndex,
            total: total,
            color: getMathCategoryColor(widget.category),
          ),
        ),
        const Spacer(),
        // 题目展示
        if (widget.category == 'number_recognition') ...[
          Text(
            currentItem.emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 16),
          Text(
            currentItem.chinese,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C6BC0),
            ),
          ),
        ] else ...[
          Text(
            currentItem.expression,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C6BC0),
            ),
          ),
        ],
        const SizedBox(height: 32),
        // 答案选项
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _availableNumbers.map((num) {
              final isSelected = _quizSelected == num;
              final isCorrect = widget.category == 'number_recognition'
                  ? num == currentItem.number
                  : num == currentItem.answer;
              final showResult = _quizAnswered;

              Color bgColor;
              if (showResult) {
                if (isCorrect) {
                  bgColor = const Color(0xFF4ECDC4);
                } else if (isSelected) {
                  bgColor = const Color(0xFFFF6B6B);
                } else {
                  bgColor = Colors.grey.shade300;
                }
              } else {
                bgColor = isSelected
                    ? getMathCategoryColor(widget.category)
                    : Colors.grey.shade200;
              }

              return GestureDetector(
                onTap: _quizAnswered
                    ? null
                    : () => _onQuizAnswerSelected(num, isCorrect),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: bgColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$num',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: showResult && !isCorrect
                            ? Colors.white54
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextButton(
            onPressed: () {
              setState(() {
                _currentMode = GameMode.exploration;
                _currentCardIndex = 0;
              });
            },
            child: const Text('返回认读模式'),
          ),
        ),
      ],
    );
  }

  void _onQuizAnswerSelected(int answer, bool isCorrect) {
    setState(() {
      _quizSelected = answer;
      _quizAnswered = true;
    });

    if (isCorrect) {
      _spellAttempts++;
      _spellStars++;
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    List<dynamic> data;
    if (widget.category == 'number_recognition') {
      data = mathNumbersData;
    } else if (widget.category == 'addition') {
      data = mathAdditionData;
    } else {
      data = mathSubtractionData;
    }

    if (_spellIndex < data.length - 1) {
      setState(() {
        _spellIndex++;
        _quizSelected = null;
        _quizAnswered = false;
        _quizTimeLeft = _currentMode.timeLimit;
        _generateAnswerOptions();
      });
      if (_currentMode.timeLimit > 0) {
        _startQuizTimer();
      }
    } else {
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
              '答题完成！',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            StarRating(stars: _spellStars.clamp(0, 3), size: 50),
            const SizedBox(height: 20),
            Text(
              _spellStars >= (_spellIndex + 1) * 0.8
                  ? '太棒了！你真是个小天才！'
                  : (_spellStars >= (_spellIndex + 1) * 0.5
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
                _initQuizGame(_currentMode.timeLimit);
              });
            },
            child: const Text('再试一次'),
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

  // ==================== 极速闯关模式 ====================
  void _initRapidGame() {
    _rapidIndex = 0;
    _rapidCorrect = 0;

    List<dynamic> sourceData;
    if (widget.category == 'number_recognition') {
      sourceData = List.from(mathNumbersData)..shuffle();
      _rapidQuestions = sourceData.take(10).toList();
    } else if (widget.category == 'addition') {
      sourceData = List.from(mathAdditionData)..shuffle();
      _rapidQuestions = sourceData.take(10).toList();
    } else {
      sourceData = List.from(mathSubtractionData)..shuffle();
      _rapidQuestions = sourceData.take(10).toList();
    }

    _setupRapidQuestion();
  }

  void _setupRapidQuestion() {
    _rapidSelected = null;
    _rapidAnswered = false;
    _rapidTimeLeft = 5;
    _generateRapidOptions();
    _startRapidTimer();
  }

  void _generateRapidOptions() {
    final currentItem = _rapidQuestions[_rapidIndex];
    final correctAnswer = widget.category == 'number_recognition'
        ? currentItem.number
        : currentItem.answer;

    _availableNumbers = [correctAnswer];
    final allNumbers = widget.category == 'number_recognition'
        ? List.generate(20, (i) => i + 1)
        : List.generate(10, (i) => i);

    allNumbers.shuffle();
    for (var num in allNumbers) {
      if (_availableNumbers.length < 4 && num != correctAnswer) {
        _availableNumbers.add(num);
      }
    }
    _availableNumbers.shuffle();
  }

  void _startRapidTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _rapidAnswered) return;
      setState(() {
        if (_rapidTimeLeft > 0) {
          _rapidTimeLeft--;
        }
      });
      if (_rapidTimeLeft > 0) {
        _startRapidTimer();
      } else {
        _onRapidTimeout();
      }
    });
  }

  void _onRapidTimeout() {
    setState(() => _rapidAnswered = true);
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
    if (_rapidIndex >= _rapidQuestions.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentItem = _rapidQuestions[_rapidIndex];
    final currentStars = _calculateRapidStars();

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _rapidTimeLeft <= 2
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF4ECDC4),
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
              Text(
                '第 ${_rapidIndex + 1}/${_rapidQuestions.length} 题',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              StarRating(stars: currentStars, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProgressBar(
            current: _rapidIndex,
            total: _rapidQuestions.length,
            color: const Color(0xFFFFE66D),
          ),
        ),
        const Spacer(),
        // 题目展示
        if (widget.category == 'number_recognition') ...[
          Text(
            currentItem.emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 8),
          Text(
            currentItem.chinese,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C6BC0),
            ),
          ),
        ] else ...[
          Text(
            currentItem.expression,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C6BC0),
            ),
          ),
        ],
        const SizedBox(height: 24),
        // 答案选项
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _availableNumbers.map((num) {
              final isSelected = _rapidSelected == num;
              final isCorrect = widget.category == 'number_recognition'
                  ? num == currentItem.number
                  : num == currentItem.answer;
              final showResult = _rapidAnswered;

              Color bgColor;
              if (showResult) {
                if (isCorrect) {
                  bgColor = const Color(0xFF4ECDC4);
                } else if (isSelected) {
                  bgColor = const Color(0xFFFF6B6B);
                } else {
                  bgColor = Colors.grey.shade300;
                }
              } else {
                bgColor = isSelected
                    ? getMathCategoryColor(widget.category)
                    : Colors.grey.shade200;
              }

              return GestureDetector(
                onTap: _rapidAnswered ? null : () => _onRapidAnswerSelected(num),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: bgColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$num',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: showResult && !isCorrect && !isSelected
                            ? Colors.white54
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Spacer(),
        const SizedBox(height: 32),
      ],
    );
  }

  void _onRapidAnswerSelected(int answer) {
    final currentItem = _rapidQuestions[_rapidIndex];
    final isCorrect = widget.category == 'number_recognition'
        ? answer == currentItem.number
        : answer == currentItem.answer;

    setState(() {
      _rapidSelected = answer;
      _rapidAnswered = true;
    });

    if (isCorrect) {
      _rapidCorrect++;
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _nextRapidQuestion();
      }
    });
  }

  int _calculateRapidStars() {
    if (_rapidCorrect >= 9) return 3;
    if (_rapidCorrect >= 7) return 2;
    if (_rapidCorrect >= 5) return 1;
    return 0;
  }

  void _showRapidComplete() {
    final stars = _calculateRapidStars();
    _saveProgress(stars);

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

  Future<void> _saveProgress(int stars) async {
    await ProgressService.saveLevelStars('math_${widget.category}', stars);
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
              setState(() {
                _initMatchingGame();
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
}

/// 配对游戏的数据项
class _MathMatchingItem {
  final int id;
  final String content;
  final String pairContent;
  final bool isImage;
  final String pairId;
  bool isFlipped;
  bool isMatched;

  _MathMatchingItem({
    required this.id,
    required this.content,
    required this.pairContent,
    required this.isImage,
    required this.pairId,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
