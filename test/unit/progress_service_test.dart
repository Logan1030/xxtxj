import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/services/progress_service.dart';
import '../../lib/models/level_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ProgressService.init();
  });

  group('ProgressService all levels unlocked', () {
    test('all levels should be unlocked by default (current status)', () async {
      final levels = await ProgressService.getLevelsByCategory('english');
      // All levels should be current (unlocked)
      for (var level in levels) {
        expect(level.status, LevelStatus.current, reason: 'Level ${level.levelNumber} should be current');
      }
    });

    test('completed level should have completed status when stars earned', () async {
      await ProgressService.saveLevelStars('english_numbers', 3);

      final levels = await ProgressService.getLevelsByCategory('english');
      final level1 = levels.firstWhere((l) => l.subCategory == 'english_numbers');
      expect(level1.status, LevelStatus.completed);
      expect(level1.stars, 3);
    });

    test('getAllLevelsProgress should show completed for levels with stars', () async {
      // Set stars for one level
      await ProgressService.saveLevelStars('english_numbers', 3);

      final levels = await ProgressService.getAllLevelsProgress();
      // english_numbers should be completed
      final englishNumbers = levels.firstWhere((l) => l.subCategory == 'english_numbers');
      expect(englishNumbers.status, LevelStatus.completed);
    });
  });
}
