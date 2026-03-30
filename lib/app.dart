import 'package:flutter/material.dart';

/// 应用主题配置 - 幼儿园友好配色
class AppTheme {
  // 主题色
  static const Color primaryColor = Color(0xFFFF6B6B); // 温暖的红色
  static const Color secondaryColor = Color(0xFF4ECDC4); // 青绿色
  static const Color accentColor = Color(0xFFFFE66D); // 明亮的黄色
  static const Color backgroundColor = Color(0xFFF7F7F7); // 浅灰背景

  // 分类颜色
  static const Color colorsCategory = Color(0xFFFF6B6B);
  static const Color numbersCategory = Color(0xFF4ECDC4);
  static const Color animalsCategory = Color(0xFFFFE66D);
  static const Color foodsCategory = Color(0xFF95E1D3);
  static const Color bodyCategory = Color(0xFFFFB6C1); // 浅粉色
  static const Color clothesCategory = Color(0xFF9B59B6); // 紫色
  static const Color vehiclesCategory = Color(0xFF3498DB); // 蓝色
  static const Color natureCategory = Color(0xFF2ECC71); // 绿色
  static const Color familyCategory = Color(0xFFE91E63); // 粉红色
  static const Color emotionsCategory = Color(0xFFFF9800); // 橙色
  static const Color actionsCategory = Color(0xFF00BCD4); // 青色
  static const Color shapesCategory = Color(0xFF673AB7); // 深紫色
  static const Color timeCategory = Color(0xFF795548); // 棕色
  static const Color chineseCategory = Color(0xFFFF7043); // 橙色，语文模块
  static const Color englishNumbersCategory = Color(0xFF00BCD4); // 青色，英语数字
  static const Color englishWordsCategory = Color(0xFF9B59B6); // 紫色，英语词汇
  static const Color mathCategory = Color(0xFF5C6BC0); // 靛蓝色，数学模块

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'colors':
        return colorsCategory;
      case 'numbers':
        return numbersCategory;
      case 'animals':
        return animalsCategory;
      case 'foods':
        return foodsCategory;
      case 'body':
        return bodyCategory;
      case 'clothes':
        return clothesCategory;
      case 'vehicles':
        return vehiclesCategory;
      case 'nature':
        return natureCategory;
      case 'family':
        return familyCategory;
      case 'emotions':
        return emotionsCategory;
      case 'actions':
        return actionsCategory;
      case 'shapes':
        return shapesCategory;
      case 'time':
        return timeCategory;
      case 'chinese':
        return chineseCategory;
      case 'english_numbers':
        return englishNumbersCategory;
      case 'english_words':
        return englishWordsCategory;
      default:
        return primaryColor;
    }
  }

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        // 大字体，适合幼儿
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        // 圆角设计
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );
}
