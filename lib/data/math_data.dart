import 'dart:ui';
import '../models/math_model.dart';

/// 数学数据 - 数字认知（1-20）
const List<MathModel> mathNumbersData = [
  MathModel(id: 'n1', number: 1, chinese: '一', emoji: '1️⃣', letters: ['1']),
  MathModel(id: 'n2', number: 2, chinese: '二', emoji: '2️⃣', letters: ['2']),
  MathModel(id: 'n3', number: 3, chinese: '三', emoji: '3️⃣', letters: ['3']),
  MathModel(id: 'n4', number: 4, chinese: '四', emoji: '4️⃣', letters: ['4']),
  MathModel(id: 'n5', number: 5, chinese: '五', emoji: '5️⃣', letters: ['5']),
  MathModel(id: 'n6', number: 6, chinese: '六', emoji: '6️⃣', letters: ['6']),
  MathModel(id: 'n7', number: 7, chinese: '七', emoji: '7️⃣', letters: ['7']),
  MathModel(id: 'n8', number: 8, chinese: '八', emoji: '8️⃣', letters: ['8']),
  MathModel(id: 'n9', number: 9, chinese: '九', emoji: '9️⃣', letters: ['9']),
  MathModel(id: 'n10', number: 10, chinese: '十', emoji: '🔟', letters: ['1', '0']),
  MathModel(id: 'n11', number: 11, chinese: '十一', emoji: '1️⃣1️⃣', letters: ['1', '1']),
  MathModel(id: 'n12', number: 12, chinese: '十二', emoji: '1️⃣2️⃣', letters: ['1', '2']),
  MathModel(id: 'n13', number: 13, chinese: '十三', emoji: '1️⃣3️⃣', letters: ['1', '3']),
  MathModel(id: 'n14', number: 14, chinese: '十四', emoji: '1️⃣4️⃣', letters: ['1', '4']),
  MathModel(id: 'n15', number: 15, chinese: '十五', emoji: '1️⃣5️⃣', letters: ['1', '5']),
  MathModel(id: 'n16', number: 16, chinese: '十六', emoji: '1️⃣6️⃣', letters: ['1', '6']),
  MathModel(id: 'n17', number: 17, chinese: '十七', emoji: '1️⃣7️⃣', letters: ['1', '7']),
  MathModel(id: 'n18', number: 18, chinese: '十八', emoji: '1️⃣8️⃣', letters: ['1', '8']),
  MathModel(id: 'n19', number: 19, chinese: '十九', emoji: '1️⃣9️⃣', letters: ['1', '9']),
  MathModel(id: 'n20', number: 20, chinese: '二十', emoji: '2️⃣0️⃣', letters: ['2', '0']),
];

/// 加法题目数据（10以内）
const List<MathAdditionModel> mathAdditionData = [
  MathAdditionModel(id: 'a1', left: 1, right: 1, answer: 2, expression: '1 + 1 = ?'),
  MathAdditionModel(id: 'a2', left: 1, right: 2, answer: 3, expression: '1 + 2 = ?'),
  MathAdditionModel(id: 'a3', left: 1, right: 3, answer: 4, expression: '1 + 3 = ?'),
  MathAdditionModel(id: 'a4', left: 1, right: 4, answer: 5, expression: '1 + 4 = ?'),
  MathAdditionModel(id: 'a5', left: 1, right: 5, answer: 6, expression: '1 + 5 = ?'),
  MathAdditionModel(id: 'a6', left: 1, right: 6, answer: 7, expression: '1 + 6 = ?'),
  MathAdditionModel(id: 'a7', left: 1, right: 7, answer: 8, expression: '1 + 7 = ?'),
  MathAdditionModel(id: 'a8', left: 1, right: 8, answer: 9, expression: '1 + 8 = ?'),
  MathAdditionModel(id: 'a9', left: 1, right: 9, answer: 10, expression: '1 + 9 = ?'),
  MathAdditionModel(id: 'a10', left: 2, right: 1, answer: 3, expression: '2 + 1 = ?'),
  MathAdditionModel(id: 'a11', left: 2, right: 2, answer: 4, expression: '2 + 2 = ?'),
  MathAdditionModel(id: 'a12', left: 2, right: 3, answer: 5, expression: '2 + 3 = ?'),
  MathAdditionModel(id: 'a13', left: 2, right: 4, answer: 6, expression: '2 + 4 = ?'),
  MathAdditionModel(id: 'a14', left: 2, right: 5, answer: 7, expression: '2 + 5 = ?'),
  MathAdditionModel(id: 'a15', left: 2, right: 6, answer: 8, expression: '2 + 6 = ?'),
  MathAdditionModel(id: 'a16', left: 2, right: 7, answer: 9, expression: '2 + 7 = ?'),
  MathAdditionModel(id: 'a17', left: 2, right: 8, answer: 10, expression: '2 + 8 = ?'),
  MathAdditionModel(id: 'a18', left: 3, right: 1, answer: 4, expression: '3 + 1 = ?'),
  MathAdditionModel(id: 'a19', left: 3, right: 2, answer: 5, expression: '3 + 2 = ?'),
  MathAdditionModel(id: 'a20', left: 3, right: 3, answer: 6, expression: '3 + 3 = ?'),
  MathAdditionModel(id: 'a21', left: 3, right: 4, answer: 7, expression: '3 + 4 = ?'),
  MathAdditionModel(id: 'a22', left: 3, right: 5, answer: 8, expression: '3 + 5 = ?'),
  MathAdditionModel(id: 'a23', left: 3, right: 6, answer: 9, expression: '3 + 6 = ?'),
  MathAdditionModel(id: 'a24', left: 3, right: 7, answer: 10, expression: '3 + 7 = ?'),
  MathAdditionModel(id: 'a25', left: 4, right: 1, answer: 5, expression: '4 + 1 = ?'),
  MathAdditionModel(id: 'a26', left: 4, right: 2, answer: 6, expression: '4 + 2 = ?'),
  MathAdditionModel(id: 'a27', left: 4, right: 3, answer: 7, expression: '4 + 3 = ?'),
  MathAdditionModel(id: 'a28', left: 4, right: 4, answer: 8, expression: '4 + 4 = ?'),
  MathAdditionModel(id: 'a29', left: 4, right: 5, answer: 9, expression: '4 + 5 = ?'),
  MathAdditionModel(id: 'a30', left: 4, right: 6, answer: 10, expression: '4 + 6 = ?'),
  MathAdditionModel(id: 'a31', left: 5, right: 1, answer: 6, expression: '5 + 1 = ?'),
  MathAdditionModel(id: 'a32', left: 5, right: 2, answer: 7, expression: '5 + 2 = ?'),
  MathAdditionModel(id: 'a33', left: 5, right: 3, answer: 8, expression: '5 + 3 = ?'),
  MathAdditionModel(id: 'a34', left: 5, right: 4, answer: 9, expression: '5 + 4 = ?'),
  MathAdditionModel(id: 'a35', left: 5, right: 5, answer: 10, expression: '5 + 5 = ?'),
];

/// 减法题目数据（10以内）
const List<MathSubtractionModel> mathSubtractionData = [
  MathSubtractionModel(id: 's1', left: 2, right: 1, answer: 1, expression: '2 - 1 = ?'),
  MathSubtractionModel(id: 's2', left: 3, right: 1, answer: 2, expression: '3 - 1 = ?'),
  MathSubtractionModel(id: 's3', left: 3, right: 2, answer: 1, expression: '3 - 2 = ?'),
  MathSubtractionModel(id: 's4', left: 4, right: 1, answer: 3, expression: '4 - 1 = ?'),
  MathSubtractionModel(id: 's5', left: 4, right: 2, answer: 2, expression: '4 - 2 = ?'),
  MathSubtractionModel(id: 's6', left: 4, right: 3, answer: 1, expression: '4 - 3 = ?'),
  MathSubtractionModel(id: 's7', left: 5, right: 1, answer: 4, expression: '5 - 1 = ?'),
  MathSubtractionModel(id: 's8', left: 5, right: 2, answer: 3, expression: '5 - 2 = ?'),
  MathSubtractionModel(id: 's9', left: 5, right: 3, answer: 2, expression: '5 - 3 = ?'),
  MathSubtractionModel(id: 's10', left: 5, right: 4, answer: 1, expression: '5 - 4 = ?'),
  MathSubtractionModel(id: 's11', left: 6, right: 1, answer: 5, expression: '6 - 1 = ?'),
  MathSubtractionModel(id: 's12', left: 6, right: 2, answer: 4, expression: '6 - 2 = ?'),
  MathSubtractionModel(id: 's13', left: 6, right: 3, answer: 3, expression: '6 - 3 = ?'),
  MathSubtractionModel(id: 's14', left: 6, right: 4, answer: 2, expression: '6 - 4 = ?'),
  MathSubtractionModel(id: 's15', left: 6, right: 5, answer: 1, expression: '6 - 5 = ?'),
  MathSubtractionModel(id: 's16', left: 7, right: 1, answer: 6, expression: '7 - 1 = ?'),
  MathSubtractionModel(id: 's17', left: 7, right: 2, answer: 5, expression: '7 - 2 = ?'),
  MathSubtractionModel(id: 's18', left: 7, right: 3, answer: 4, expression: '7 - 3 = ?'),
  MathSubtractionModel(id: 's19', left: 7, right: 4, answer: 3, expression: '7 - 4 = ?'),
  MathSubtractionModel(id: 's20', left: 7, right: 5, answer: 2, expression: '7 - 5 = ?'),
  MathSubtractionModel(id: 's21', left: 7, right: 6, answer: 1, expression: '7 - 6 = ?'),
  MathSubtractionModel(id: 's22', left: 8, right: 1, answer: 7, expression: '8 - 1 = ?'),
  MathSubtractionModel(id: 's23', left: 8, right: 2, answer: 6, expression: '8 - 2 = ?'),
  MathSubtractionModel(id: 's24', left: 8, right: 3, answer: 5, expression: '8 - 3 = ?'),
  MathSubtractionModel(id: 's25', left: 8, right: 4, answer: 4, expression: '8 - 4 = ?'),
  MathSubtractionModel(id: 's26', left: 8, right: 5, answer: 3, expression: '8 - 5 = ?'),
  MathSubtractionModel(id: 's27', left: 8, right: 6, answer: 2, expression: '8 - 6 = ?'),
  MathSubtractionModel(id: 's28', left: 8, right: 7, answer: 1, expression: '8 - 7 = ?'),
  MathSubtractionModel(id: 's29', left: 9, right: 1, answer: 8, expression: '9 - 1 = ?'),
  MathSubtractionModel(id: 's30', left: 9, right: 2, answer: 7, expression: '9 - 2 = ?'),
  MathSubtractionModel(id: 's31', left: 9, right: 3, answer: 6, expression: '9 - 3 = ?'),
  MathSubtractionModel(id: 's32', left: 9, right: 4, answer: 5, expression: '9 - 4 = ?'),
  MathSubtractionModel(id: 's33', left: 9, right: 5, answer: 4, expression: '9 - 5 = ?'),
  MathSubtractionModel(id: 's34', left: 9, right: 6, answer: 3, expression: '9 - 6 = ?'),
  MathSubtractionModel(id: 's35', left: 9, right: 7, answer: 2, expression: '9 - 7 = ?'),
  MathSubtractionModel(id: 's36', left: 9, right: 8, answer: 1, expression: '9 - 8 = ?'),
  MathSubtractionModel(id: 's37', left: 10, right: 1, answer: 9, expression: '10 - 1 = ?'),
  MathSubtractionModel(id: 's38', left: 10, right: 2, answer: 8, expression: '10 - 2 = ?'),
  MathSubtractionModel(id: 's39', left: 10, right: 3, answer: 7, expression: '10 - 3 = ?'),
  MathSubtractionModel(id: 's40', left: 10, right: 4, answer: 6, expression: '10 - 4 = ?'),
  MathSubtractionModel(id: 's41', left: 10, right: 5, answer: 5, expression: '10 - 5 = ?'),
  MathSubtractionModel(id: 's42', left: 10, right: 6, answer: 4, expression: '10 - 6 = ?'),
  MathSubtractionModel(id: 's43', left: 10, right: 7, answer: 3, expression: '10 - 7 = ?'),
  MathSubtractionModel(id: 's44', left: 10, right: 8, answer: 2, expression: '10 - 8 = ?'),
  MathSubtractionModel(id: 's45', left: 10, right: 9, answer: 1, expression: '10 - 9 = ?'),
];

/// 获取数学子类别列表
List<String> getMathSubCategories() {
  return MathCategory.values.map((e) => e.key).toList();
}

/// 获取数学子类别颜色
Color getMathCategoryColor(String category) {
  switch (category) {
    case 'number_recognition':
      return const Color(0xFF5C6BC0); // 靛蓝色
    case 'addition':
      return const Color(0xFF26A69A); // 青色
    case 'subtraction':
      return const Color(0xFFEC407A); // 粉红色
    default:
      return const Color(0xFFFF7043); // 橙色
  }
}

/// 获取数学子类别名称
String getMathCategoryName(String category) {
  switch (category) {
    case 'number_recognition':
      return '数字认知';
    case 'addition':
      return '加法';
    case 'subtraction':
      return '减法';
    default:
      return category;
  }
}

/// 获取数学子类别Emoji
String getMathCategoryEmoji(String category) {
  switch (category) {
    case 'number_recognition':
      return '🔢';
    case 'addition':
      return '➕';
    case 'subtraction':
      return '➖';
    default:
      return '🔢';
  }
}
