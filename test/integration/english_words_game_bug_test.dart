import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/screens/english_words_game_screen.dart';
import '../../lib/data/english_words_data.dart';
import '../../lib/widgets/letter_tile_widget.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LetterTileWidget Bug Test', () {
    testWidgets('Tapping one O tile should NOT select both O tiles - UI test',
        (WidgetTester tester) async {
      // This test creates LetterTileWidgets directly and verifies
      // that tapping one does not affect the other

      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Two O letter tiles - simulating duplicate letters in "foot"
                LetterTileWidget(
                  letter: 'o',
                  isSelected: false,
                  isInTarget: false,
                  isCorrectPosition: false,
                  onTap: () => tappedIndex = 0,
                ),
                LetterTileWidget(
                  letter: 'o',
                  isSelected: false,
                  isInTarget: false,
                  isCorrectPosition: false,
                  onTap: () => tappedIndex = 1,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find both O tiles
      final oTiles = find.byWidgetPredicate((widget) {
        return widget is LetterTileWidget && widget.letter.toUpperCase() == 'O';
      });

      expect(oTiles, findsNWidgets(2), reason: 'Should find 2 O tiles');

      // Tap the first O tile
      print('Tapping first O tile...');
      await tester.tap(oTiles.first);
      await tester.pumpAndSettle();

      // Verify only the first tile's onTap was called
      expect(tappedIndex, 0, reason: 'Tapping first O should set tappedIndex to 0');
      print('tappedIndex after first tap: $tappedIndex');

      // Reset and tap the second O tile
      tappedIndex = -1;
      await tester.tap(oTiles.last);
      await tester.pumpAndSettle();

      expect(tappedIndex, 1, reason: 'Tapping second O should set tappedIndex to 1');
      print('tappedIndex after second tap: $tappedIndex');

      // This test verifies that each LetterTileWidget
      // responds to taps independently based on index
    });

    testWidgets('LetterTileWidget displays correct state visually',
        (WidgetTester tester) async {
      // Test unselected state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTileWidget(
              letter: 'o',
              isSelected: false,
              isInTarget: false,
              isCorrectPosition: false,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Text widget with 'O'
      expect(find.text('O'), findsOneWidget);

      // The widget should not be in selected state
      // We can verify by checking the container's decoration
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      print('Unselected color: ${decoration.color}');

      // Gray color is used for selected: Colors.grey.shade300 which is approximately #D4D4D4
      // Unselected color should be yellow: const Color(0xFFFFE66D)
      expect(decoration.color, isNot(equals(Colors.grey.shade300)),
          reason: 'Unselected tile should not be gray');
    });

    testWidgets('LetterTileWidget shows gray when selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTileWidget(
              letter: 'o',
              isSelected: true, // Selected state
              isInTarget: false,
              isCorrectPosition: false,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      print('Selected color: ${decoration.color}');

      // When selected, color should be grey.shade300
      expect(decoration.color, equals(Colors.grey.shade300),
          reason: 'Selected tile should be gray');
    });
  });

  group('English Words Game - Data Verification', () {
    test('Word "foot" should have exactly 2 o letters', () {
      final footWord = englishWordsData.firstWhere(
        (word) => word.word == 'foot',
        orElse: () => throw Exception('Word "foot" not found in data'),
      );

      expect(footWord.word, 'foot');
      expect(footWord.letters, ['f', 'o', 'o', 't']);
      expect(footWord.letters.where((l) => l == 'o').length, 2,
          reason: 'Word "foot" should have exactly 2 o letters');
    });

    test('Foot word is at index 2 in englishWordsData', () {
      final footIndex = englishWordsData.indexWhere((word) => word.word == 'foot');
      expect(footIndex, 2,
          reason: 'Word "foot" should be at index 2 (3rd word)');
    });
  });

  group('English Words Game - State Logic Test', () {
    testWidgets('Spell mode should handle duplicate letters correctly',
        (WidgetTester tester) async {
      // Build the English Words Game Screen
      await tester.pumpWidget(
        const MaterialApp(
          home: EnglishWordsGameScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter spell mode via menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('拼写模式'));
      await tester.pumpAndSettle();

      // Verify spell mode is active
      // Should see letter tiles
      expect(find.byType(LetterTileWidget), findsWidgets);

      // The first word is "arm" - let's spell it correctly to progress to "foot"
      // We need to tap: a, r, m (but shuffled)

      // Get all letter tiles
      final letterTileFinder = find.byType(LetterTileWidget);

      // Find and tap 'A', 'R', 'M' in order
      for (final letter in ['a', 'r', 'm']) {
        final letterFinder = find.byWidgetPredicate((widget) {
          if (widget is LetterTileWidget) {
            return widget.letter.toLowerCase() == letter && !widget.isSelected;
          }
          return false;
        });

        if (letterFinder.evaluate().isNotEmpty) {
          await tester.tap(letterFinder.first);
          await tester.pumpAndSettle();
        }
      }

      // Wait for the word to be accepted and move to next
      await tester.pump(const Duration(seconds: 2));

      // Now we should be on "leg" word
      // Let's spell it: l, e, g
      for (final letter in ['l', 'e', 'g']) {
        final letterFinder = find.byWidgetPredicate((widget) {
          if (widget is LetterTileWidget) {
            return widget.letter.toLowerCase() == letter && !widget.isSelected;
          }
          return false;
        });

        if (letterFinder.evaluate().isNotEmpty) {
          await tester.tap(letterFinder.first);
          await tester.pumpAndSettle();
        }
      }

      // Wait for the word to be accepted
      await tester.pump(const Duration(seconds: 2));

      // Now we should be on "foot" word
      expect(find.text('脚'), findsOneWidget,
          reason: 'Should be on foot word (脚)');

      // Now let's test the bug: tap one 'o' and verify both don't get selected
      // Get all letter tiles
      final allTiles = find.byType(LetterTileWidget);

      // Count O tiles before
      int oCountBefore = 0;
      for (final element in allTiles.evaluate()) {
        final widget = element.widget as LetterTileWidget;
        if (widget.letter.toUpperCase() == 'O' && widget.isSelected) {
          oCountBefore++;
        }
      }
      print('O tiles selected before tap: $oCountBefore');

      // Find an unselected O tile and tap it
      final oFinder = find.byWidgetPredicate((widget) {
        if (widget is LetterTileWidget) {
          return widget.letter.toUpperCase() == 'O' && !widget.isSelected;
        }
        return false;
      });

      expect(oFinder, findsWidgets, reason: 'Should find unselected O tiles');

      print('Tapping an O tile...');
      await tester.tap(oFinder.first);
      await tester.pumpAndSettle();

      // Count O tiles after
      int oCountAfter = 0;
      for (final element in allTiles.evaluate()) {
        final widget = element.widget as LetterTileWidget;
        if (widget.letter.toUpperCase() == 'O' && widget.isSelected) {
          oCountAfter++;
        }
      }
      print('O tiles selected after tap: $oCountAfter');

      // BUG CHECK: If both O tiles are selected, oCountAfter would be 2
      // CORRECT: Only 1 O should be selected
      expect(oCountAfter, 1,
          reason: 'BUG: Clicking one O should NOT select both O tiles. '
              'Found $oCountAfter selected O tiles. '
              'This indicates the bug exists.');
    });
  });
}
