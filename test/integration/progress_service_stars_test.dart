import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/services/progress_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ProgressService.init();
  });

  test('完整流程测试: 保存并读取星星', () async {
    // 1. 先验证初始状态是0
    final initialEnglish = await ProgressService.getCategoryStars('english');
    print('初始英语模块星星: $initialEnglish');

    // 2. 保存星星 (模拟闯关成功后)
    await ProgressService.saveLevelStars('english_numbers', 3);
    print('已保存 english_numbers = 3');

    // 3. 再次读取验证
    final afterEnglish = await ProgressService.getCategoryStars('english');
    print('保存后英语模块星星: $afterEnglish');

    // 验证
    expect(afterEnglish, 3, reason: '英语模块应该有3颗星星');
  });

  test('多关卡星星累加', () async {
    // 保存多个关卡的星星
    await ProgressService.saveLevelStars('english_numbers', 3);
    await ProgressService.saveLevelStars('english_words_body', 2);

    final total = await ProgressService.getCategoryStars('english');
    print('英语模块总星星: $total');

    expect(total, 5, reason: '英语模块应该有5颗星星(3+2)');
  });
}
