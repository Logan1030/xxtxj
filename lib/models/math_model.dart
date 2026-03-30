/// 数学数据模型
class MathModel {
  final String id;
  final int number;
  final String chinese;
  final String emoji;
  final List<String> letters; // 用于拼写模式

  const MathModel({
    required this.id,
    required this.number,
    required this.chinese,
    required this.emoji,
    required this.letters,
  });
}

/// 数学加法题目模型
class MathAdditionModel {
  final String id;
  final int left;
  final int right;
  final int answer;
  final String expression; // "3 + 5 = ?"

  const MathAdditionModel({
    required this.id,
    required this.left,
    required this.right,
    required this.answer,
    required this.expression,
  });
}

/// 数学减法题目模型
class MathSubtractionModel {
  final String id;
  final int left;
  final int right;
  final int answer;
  final String expression; // "8 - 3 = ?"

  const MathSubtractionModel({
    required this.id,
    required this.left,
    required this.right,
    required this.answer,
    required this.expression,
  });
}

/// 数学子类别枚举
enum MathCategory {
  numberRecognition('number_recognition', '数字认知', '🔢'),
  addition('addition', '加法', '➕'),
  subtraction('subtraction', '减法', '➖');

  final String key;
  final String name;
  final String emoji;

  const MathCategory(this.key, this.name, this.emoji);
}
