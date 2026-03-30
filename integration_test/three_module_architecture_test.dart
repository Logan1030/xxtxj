import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:english_game_v3_0329/app.dart';
import 'package:english_game_v3_0329/screens/home_screen.dart';
import 'package:english_game_v3_0329/screens/math_game_screen.dart';
import 'package:english_game_v3_0329/screens/chinese_game_screen.dart';
import 'package:english_game_v3_0329/utils/storage_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StorageHelper.reset();
    StorageHelper.init();
  });

  group('Three-Module Architecture E2E Tests', () {
    // Journey 1: Home Screen Module Navigation
    testWidgets('H1: Verify 3 module cards displayed on home screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify app title
      expect(find.text('小小探索家'), findsOneWidget);

      // Verify 3 module cards are displayed
      expect(find.text('英语学习'), findsOneWidget);
      expect(find.text('语文学习'), findsOneWidget);
      expect(find.text('数学学习'), findsOneWidget);

      // Verify emojis are shown
      expect(find.text('🔤'), findsOneWidget); // English
      expect(find.text('🇨🇳'), findsOneWidget); // Chinese
      expect(find.text('🔢'), findsOneWidget); // Math

      // Verify subtitles
      expect(find.text('数字 · 词汇'), findsOneWidget);
      expect(find.text('拼音 · 声调'), findsOneWidget);
      expect(find.text('数字 · 加减法'), findsOneWidget);

      // Verify arrow icons for navigation
      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(3));

      // Verify reset button
      expect(find.text('家长模式：重置进度'), findsOneWidget);
    });

    // Journey 2: Progress Reset Flow
    testWidgets('H2: Verify reset progress dialog appears', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap reset button
      await tester.tap(find.text('家长模式：重置进度'));
      await tester.pumpAndSettle();

      // Verify dialog appears with correct content
      expect(find.text('重置进度'), findsWidgets);
      expect(find.text('确定要重置所有学习进度吗？'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('确定重置'), findsOneWidget);

      // Verify dialog can be cancelled
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(find.text('确定要重置所有学习进度吗？'), findsNothing);
    });

    // Journey 3: English Module Flow
    testWidgets('E1: Navigate to English Module and verify sub-categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap English module card
      await tester.tap(find.text('英语学习'));
      await tester.pumpAndSettle();

      // Verify EnglishModuleScreen appears
      expect(find.text('英语学习'), findsWidgets); // AppBar title + card
      expect(find.text('学英语，拓视野'), findsOneWidget);

      // Verify 2 sub-categories are displayed
      expect(find.text('英语数字'), findsOneWidget);
      expect(find.text('英语词汇'), findsOneWidget);

      // Verify emojis for sub-categories
      expect(find.text('1️⃣'), findsOneWidget); // Numbers
      expect(find.text('💪'), findsOneWidget); // Words

      // Navigate to English Numbers game
      await tester.tap(find.text('英语数字'));
      await tester.pumpAndSettle();

      // Verify EnglishNumbersGameScreen loads
      expect(find.text('英语数字 1-10'), findsOneWidget);

      // Verify mode selector (popup menu button)
      expect(find.byIcon(Icons.menu), findsOneWidget);

      // Go back to English module
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Navigate to English Words game
      await tester.tap(find.text('英语词汇'));
      await tester.pumpAndSettle();

      // Verify EnglishWordsGameScreen loads
      expect(find.text('英语词汇学习'), findsOneWidget);
    });

    // Journey 4: Chinese Module Flow
    testWidgets('C1: Navigate to Chinese Module and verify', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Chinese module card
      await tester.tap(find.text('语文学习'));
      await tester.pumpAndSettle();

      // Verify ChineseGameScreen appears
      expect(find.text('语文篇'), findsOneWidget);

      // Verify 4 sub-categories are displayed (声母篇/韵母篇/整体认读音节/单韵母四声)
      expect(find.text('声母篇'), findsOneWidget);
      expect(find.text('韵母篇'), findsOneWidget);
      expect(find.text('整体认读音节'), findsOneWidget);
      expect(find.text('单韵母四声'), findsOneWidget);
    });

    // Journey 5: Math Module Flow
    testWidgets('M1: Navigate to Math Module and verify sub-categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Math module card
      await tester.tap(find.text('数学学习'));
      await tester.pumpAndSettle();

      // Verify MathGameScreen appears
      expect(find.text('数学篇'), findsOneWidget);
      expect(find.text('学数学，促思维'), findsOneWidget);

      // Verify 3 sub-categories: 数字认知, 加法, 减法
      expect(find.text('数字认知'), findsOneWidget);
      expect(find.text('加法'), findsOneWidget);
      expect(find.text('减法'), findsOneWidget);

      // Navigate to Number Recognition
      await tester.tap(find.text('数字认知'));
      await tester.pumpAndSettle();

      // Verify MathSubCategoryScreen loads
      expect(find.text('数字认知'), findsWidgets); // Title + subtitle

      // Verify game modes are available
      // Should have认读/配对/拼写/极速闯关 in menu
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    // Journey 6: Math Addition Flow
    testWidgets('M2: Navigate to Math Addition and verify', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Math Module
      await tester.tap(find.text('数学学习'));
      await tester.pumpAndSettle();

      // Navigate to Addition
      await tester.tap(find.text('加法'));
      await tester.pumpAndSettle();

      // Verify MathSubCategoryScreen with addition mode
      expect(find.text('加法'), findsWidgets);

      // Verify mode selector exists
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    // Journey 7: Math Subtraction Flow
    testWidgets('M3: Navigate to Math Subtraction and verify', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Math Module
      await tester.tap(find.text('数学学习'));
      await tester.pumpAndSettle();

      // Navigate to Subtraction
      await tester.tap(find.text('减法'));
      await tester.pumpAndSettle();

      // Verify MathSubCategoryScreen with subtraction mode
      expect(find.text('减法'), findsWidgets);

      // Verify mode selector exists
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    // Journey 8: Complete navigation flow (Home -> English -> Math -> Chinese)
    testWidgets('F1: Complete navigation flow through all modules', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Start at Home Screen
      expect(find.text('小小探索家'), findsOneWidget);

      // Navigate to English
      await tester.tap(find.text('英语学习'));
      await tester.pumpAndSettle();
      expect(find.text('英语学习'), findsWidgets);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Navigate to Math
      await tester.tap(find.text('数学学习'));
      await tester.pumpAndSettle();
      expect(find.text('数学篇'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Navigate to Chinese
      await tester.tap(find.text('语文学习'));
      await tester.pumpAndSettle();
      expect(find.text('语文篇'), findsOneWidget);

      // Go back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back at home
      expect(find.text('小小探索家'), findsOneWidget);
      expect(find.text('英语学习'), findsOneWidget);
      expect(find.text('数学学习'), findsOneWidget);
      expect(find.text('语文学习'), findsOneWidget);
    });
  });
}
