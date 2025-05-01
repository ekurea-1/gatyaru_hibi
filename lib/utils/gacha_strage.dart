import 'package:shared_preferences/shared_preferences.dart';

// ガチャ回数を保存
Future<void> saveGachaCount(int count) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('gacha_count', count);
}

// ガチャ回数を読み込み
Future<int> loadGachaCount() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('gacha_count') ?? 0;
}

// ガチャ回数を1減らす
Future<void> decreaseGachaCount() async {
  final prefs = await SharedPreferences.getInstance();
  int current = prefs.getInt('gacha_count') ?? 0;
  if (current > 0) {
    current -= 1;
    await prefs.setInt('gacha_count', current);
  }
}
Future<void> increaseGachaCount() async{
  final prefs = await SharedPreferences.getInstance();
  int currentCount = prefs.getInt('gacha_count') ?? 0;
  currentCount += 1;
  await prefs.setInt('gacha_count',currentCount);
}