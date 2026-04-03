import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/utils/storage_helper.dart';

void main() {
  setUp(() {
    // Reset SharedPreferences and StorageHelper static state before each test
    SharedPreferences.setMockInitialValues({});
    StorageHelper.reset();
    StorageHelper.init();
  });

  group('StorageHelper', () {
    group('getStars / saveStars', () {
      test('should return 0 for category with no saved stars', () async {
        final stars = await StorageHelper.getStars('colors');
        expect(stars, 0);
      });

      test('should save and retrieve stars for a category', () async {
        await StorageHelper.saveStars('colors', 3);
        final stars = await StorageHelper.getStars('colors');
        expect(stars, 3);
      });

      test('should update stars for existing category', () async {
        await StorageHelper.saveStars('colors', 3);
        await StorageHelper.saveStars('colors', 5);
        final stars = await StorageHelper.getStars('colors');
        expect(stars, 5);
      });

      test('should save stars for different categories independently', () async {
        await StorageHelper.saveStars('colors', 3);
        await StorageHelper.saveStars('numbers', 2);
        await StorageHelper.saveStars('animals', 1);

        expect(await StorageHelper.getStars('colors'), 3);
        expect(await StorageHelper.getStars('numbers'), 2);
        expect(await StorageHelper.getStars('animals'), 1);
      });
    });

    group('getTotalStars', () {
      test('should return 0 when no stars saved', () async {
        final total = await StorageHelper.getTotalStars();
        expect(total, 0);
      });

      test('should calculate total stars from all categories', () async {
        await StorageHelper.saveStars('colors', 3);
        await StorageHelper.saveStars('numbers', 2);
        await StorageHelper.saveStars('animals', 1);
        await StorageHelper.saveStars('foods', 2);

        final total = await StorageHelper.getTotalStars();
        expect(total, 8);
      });
    });

    group('getHighestLevel / saveHighestLevel', () {
      test('should return 0 when no level saved', () async {
        final level = await StorageHelper.getHighestLevel();
        expect(level, 0);
      });

      test('should save and retrieve highest level', () async {
        await StorageHelper.saveHighestLevel(5);
        final level = await StorageHelper.getHighestLevel();
        expect(level, 5);
      });

      test('should update highest level', () async {
        await StorageHelper.saveHighestLevel(3);
        await StorageHelper.saveHighestLevel(7);
        final level = await StorageHelper.getHighestLevel();
        expect(level, 7);
      });
    });

    group('resetProgress', () {
      test('should reset all category stars to 0', () async {
        await StorageHelper.saveStars('colors', 3);
        await StorageHelper.saveStars('numbers', 2);
        await StorageHelper.saveStars('animals', 1);
        await StorageHelper.saveStars('foods', 2);

        await StorageHelper.resetProgress();

        expect(await StorageHelper.getStars('colors'), 0);
        expect(await StorageHelper.getStars('numbers'), 0);
        expect(await StorageHelper.getStars('animals'), 0);
        expect(await StorageHelper.getStars('foods'), 0);
      });

      test('should reset total stars to 0', () async {
        await StorageHelper.saveStars('colors', 3);
        await StorageHelper.resetProgress();

        expect(await StorageHelper.getTotalStars(), 0);
      });

      test('should reset highest level to 0', () async {
        await StorageHelper.saveHighestLevel(5);
        await StorageHelper.resetProgress();

        expect(await StorageHelper.getHighestLevel(), 0);
      });
    });

    group('getAllProgress', () {
      test('should return zeros when no progress saved', () async {
        final progress = await StorageHelper.getAllProgress();

        expect(progress['colors'], 0);
        expect(progress['numbers'], 0);
        expect(progress['animals'], 0);
        expect(progress['foods'], 0);
        expect(progress['body'], 0);
      });

      test('should return saved progress for all categories', () async {
        await StorageHelper.saveStars('colors', 3);
        await StorageHelper.saveStars('numbers', 2);
        await StorageHelper.saveStars('animals', 1);
        await StorageHelper.saveStars('foods', 2);
        await StorageHelper.saveStars('body', 3);

        final progress = await StorageHelper.getAllProgress();

        expect(progress['colors'], 3);
        expect(progress['numbers'], 2);
        expect(progress['animals'], 1);
        expect(progress['foods'], 2);
        expect(progress['body'], 3);
      });

      test('should return all 5 categories', () async {
        final progress = await StorageHelper.getAllProgress();
        expect(progress.keys.length, 5);
        expect(progress.containsKey('colors'), true);
        expect(progress.containsKey('numbers'), true);
        expect(progress.containsKey('animals'), true);
        expect(progress.containsKey('foods'), true);
        expect(progress.containsKey('body'), true);
      });
    });

    group('edge cases', () {
      test('should handle saving 0 stars', () async {
        await StorageHelper.saveStars('colors', 0);
        expect(await StorageHelper.getStars('colors'), 0);
      });

      test('should handle saving max stars (3)', () async {
        await StorageHelper.saveStars('colors', 3);
        expect(await StorageHelper.getStars('colors'), 3);
      });

      test('should handle empty category name', () async {
        await StorageHelper.saveStars('', 1);
        expect(await StorageHelper.getStars(''), 1);
      });
    });

    group('新类别支持 (Bug修复验证)', () {
      test('should calculate total stars for new categories (english/chinese/math/pinyin)', () async {
        // 修复前: _updateTotalStars() 硬编码了5个旧类别
        // 修复后: 动态获取所有 stars_ 开头的键
        await StorageHelper.saveStars('english', 3);
        await StorageHelper.saveStars('chinese', 2);
        await StorageHelper.saveStars('math', 3);
        await StorageHelper.saveStars('pinyin', 2);
        // 旧类别也兼容
        await StorageHelper.saveStars('colors', 1);

        final total = await StorageHelper.getTotalStars();
        expect(total, 11); // 3+2+3+2+1 = 11
      });

      test('should calculate total stars for mixed old and new categories', () async {
        await StorageHelper.saveStars('english', 3);
        await StorageHelper.saveStars('chinese', 2);
        await StorageHelper.saveStars('colors', 1);
        await StorageHelper.saveStars('numbers', 2);

        final total = await StorageHelper.getTotalStars();
        expect(total, 8); // 3+2+1+2 = 8
      });
    });
  });
}
