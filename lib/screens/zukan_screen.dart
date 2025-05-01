import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatya_hibi/character_list.dart'; // キャラリスト

class ZukanScreen extends StatelessWidget {
  final List<Map<String, dynamic>> allCharacters;

  const ZukanScreen({Key? key, required this.allCharacters}) : super(key: key);

// 保存されているゲット済みキャラを読み込む関数
  Future<List<String>> loadObtainedCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('obtained_characters') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: loadObtainedCharacters(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final obtainedCharacters = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('キャラ図鑑'),
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: allCharacters.length,
            itemBuilder: (context, index) {
              final character = allCharacters[index];
              final isObtained = obtainedCharacters.contains(character['name']);

              return Column(
                children: [
                  ColorFiltered(
                    colorFilter: isObtained
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    child: Image.asset(
                      character['image'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    character['name'],
                    style: TextStyle(
                      color: isObtained ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}