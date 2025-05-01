import 'package:flutter/material.dart';
import 'package:gatya_hibi/utils/draw_character.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ガチャ引く関数をインポート
import 'package:gatya_hibi/utils/gacha_strage.dart';
import 'zukan_screen.dart';
import 'package:gatya_hibi/character_list.dart';

class GachaScreen extends StatefulWidget {
  final int initialGachaCount; // ←ここでしっかり final 宣言して

  const GachaScreen({Key? key, required this.initialGachaCount}) : super(key: key); // ←コンストラクタもちゃんと書く

  @override
  _GachaScreenState createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> {
  late int gachaCount; // ←lateにして、あとで初期化する
  Map<String, dynamic>? drawnCharacter;

  Future<void> decreaseGachaCount() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt('gacha_count') ?? 0;
    if (currentCount > 0) {
      currentCount -= 1;
      await prefs.setInt('gacha_count', currentCount);
      setState(() {
        gachaCount = currentCount;
      });
    }
  }




  @override
  void initState() {
    super.initState();
    loadGachaCount().then((value){
      setState(() {
        gachaCount = value;
      });
    });
    gachaCount = widget.initialGachaCount; // ←ここで初期化
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ガチャ'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ZukanScreen(allCharacters: characterList),
                ),
              );
            },
            child: Text('図鑑を見る'),
          ),
          ),
    ]
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (drawnCharacter != null) ...[
              Image.asset(
                drawnCharacter!['image'],
                width: 300,
                height: 400,
              ),
              SizedBox(height: 10),
              Text(
                drawnCharacter!['name'],
                style: TextStyle(fontSize: 24),
              ),
              Text(
                'レアリティ: ${drawnCharacter!['rarity']}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 30),
            ],
            ElevatedButton(
              onPressed: gachaCount > 0
                  ? ()async{
                final result = drawCharacter();
                setState(() {
                  drawnCharacter = result;
                });
                await decreaseGachaCount();
                await saveObtainedCharacter(result['name']);
              }
                  : null,
              child: Text('ガチャを回す！ (${gachaCount}回分)'),
            ),
          ],
        ),
      ),
    );
  }
}
// キャラをゲットしたら保存する関数
Future<void> saveObtainedCharacter(String characterName) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> obtainedCharacters = prefs.getStringList('obtained_characters') ?? [];

  if (!obtainedCharacters.contains(characterName)) {
    obtainedCharacters.add(characterName);
    await prefs.setStringList('obtained_characters', obtainedCharacters);
  }
}