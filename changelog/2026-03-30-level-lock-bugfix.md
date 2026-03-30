# 修改记录 - 2026-03-30

## Bug修复

### 问题：所有模块关卡无法点击

**文件：** `lib/services/progress_service.dart`

**根本原因：**
- `getHighestUnlockedLevel()` 默认返回 `0`
- 关卡 `levelNumber` 从 `1` 开始
- 判断条件 `levelNumber == highestUnlocked` 永远为 `false`
- 导致所有关卡状态都变成 `locked`，无法点击

**修复方案：**
- 将 `getHighestUnlockedLevel()` 默认值从 `0` 改为 `1`
- 新用户第一关默认为 `current` 状态，可正常点击进入

**影响范围：**
- 英语学习模块（英语数字、英语词汇）
- 语文学习模块（声母、韵母、整体认读、四声）
- 数学学习模块（数字认知、加法、减法）

**修改前：**
```dart
return _prefs?.getInt(_highestLevelKey) ?? 0;
```

**修改后：**
```dart
return _prefs?.getInt(_highestLevelKey) ?? 1;
```
