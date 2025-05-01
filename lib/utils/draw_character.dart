import 'dart:math';
import 'package:gatya_hibi/character_list.dart';

Map<String, dynamic> drawCharacter() {
  final random = Random();
  double value = random.nextDouble() * 100; // 0〜100の間の数を出す

  String selectedRarity;
  if (value < 0.03) {
    selectedRarity = 'SS';
  } else if (value < 13.03) {
    selectedRarity = 'S';
  } else if (value < 53.03) {
    selectedRarity = 'A';
  } else {
    selectedRarity = 'B';
  }

// 選ばれたレアリティのキャラだけ抽出
  List<Map<String, dynamic>> filtered = characterList.where((c) => c['rarity'] == selectedRarity).toList();

// その中からランダムで1体選ぶ
  return filtered[random.nextInt(filtered.length)];
}