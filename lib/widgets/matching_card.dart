import 'package:flutter/material.dart';

/// 配对卡片组件
class MatchingCard extends StatefulWidget {
  final String content;
  final String emoji;
  final bool isFlipped;
  final bool isMatched;
  final bool isImageCard;
  final VoidCallback? onTap;

  const MatchingCard({
    super.key,
    required this.content,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
    this.isImageCard = true,
    this.onTap,
  });

  @override
  State<MatchingCard> createState() => _MatchingCardState();
}

class _MatchingCardState extends State<MatchingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isFlipped || widget.isMatched) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MatchingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 配对成功时，确保动画保持在完成位置
    if (widget.isMatched && !oldWidget.isMatched) {
      _controller.value = 1.0;
    }
    // 正常翻转动画（仅在未匹配时）
    if (widget.isFlipped != oldWidget.isFlipped && !widget.isMatched) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isMatched ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159;
          final isFront = _animation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.isMatched
                        ? Colors.green.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isFront
                    ? _buildBack()
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.14159),
                        child: _buildFront(),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    // 卡片背面 - 问号
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade300,
            Colors.purple.shade400,
          ],
        ),
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFront() {
    // 卡片正面
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isMatched
              ? [Colors.green.shade400, Colors.green.shade500]
              : [Colors.white, Colors.white],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isImageCard) ...[
            Text(
              widget.emoji,
              style: const TextStyle(fontSize: 40),
            ),
          ] else ...[
            Text(
              widget.content,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
