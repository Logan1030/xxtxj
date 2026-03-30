import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../app.dart';

/// 庆祝动画覆盖层 - 关卡完成时显示
class CelebrationOverlay extends StatefulWidget {
  final int stars; // 获得的星星数 (0-3)
  final VoidCallback onComplete;
  final bool showConfetti;

  const CelebrationOverlay({
    super.key,
    required this.stars,
    required this.onComplete,
    this.showConfetti = true,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _controller.forward();

    if (widget.showConfetti) {
      _confettiController.play();
    }

    // 3秒后自动关闭
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 庆祝消息
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildContent(),
          ),
          // Confetti
          if (widget.showConfetti)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                  AppTheme.accentColor,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                numberOfParticles: 30,
                maxBlastForce: 50,
                minBlastForce: 20,
                emissionFrequency: 0.05,
                gravity: 0.2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return GestureDetector(
      onTap: widget.onComplete,
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _getResultColor().withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 结果表情
            Text(
              _getResultEmoji(),
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),
            // 结果文字
            Text(
              _getResultText(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _getResultColor(),
              ),
            ),
            const SizedBox(height: 24),
            // 星星显示
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final isEarned = index < widget.stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isEarned ? Icons.star : Icons.star_border,
                    size: 50,
                    color: isEarned ? Colors.amber : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // 鼓励文字
            Text(
              _getEncourageText(),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              '点击任意处继续',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getResultEmoji() {
    if (widget.stars >= 3) return '🏆';
    if (widget.stars >= 2) return '🌟';
    if (widget.stars >= 1) return '👍';
    return '💪';
  }

  String _getResultText() {
    if (widget.stars >= 3) return '完美通关！';
    if (widget.stars >= 2) return '很棒！';
    if (widget.stars >= 1) return '不错！';
    return '继续加油！';
  }

  Color _getResultColor() {
    if (widget.stars >= 3) return AppTheme.accentColor;
    if (widget.stars >= 2) return AppTheme.secondaryColor;
    if (widget.stars >= 1) return AppTheme.primaryColor;
    return Colors.grey;
  }

  String _getEncourageText() {
    if (widget.stars >= 3) return '太厉害了！你是学习小天才！🏆';
    if (widget.stars >= 2) return '做得很棒！再接再厉！';
    if (widget.stars >= 1) return '有进步！多练习能做得更好！';
    return '别灰心，多练习几次就能成功！';
  }
}

/// 简易庆祝动画 - 不带confetti
class SimpleCelebrationOverlay extends StatefulWidget {
  final String message;
  final String emoji;
  final Color color;
  final VoidCallback onComplete;

  const SimpleCelebrationOverlay({
    super.key,
    required this.message,
    required this.emoji,
    required this.color,
    required this.onComplete,
  });

  @override
  State<SimpleCelebrationOverlay> createState() =>
      _SimpleCelebrationOverlayState();
}

class _SimpleCelebrationOverlayState extends State<SimpleCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // 2秒后自动关闭
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: GestureDetector(
        onTap: widget.onComplete,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
