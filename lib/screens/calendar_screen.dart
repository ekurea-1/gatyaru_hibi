import 'package:flutter/material.dart';
import 'package:gatya_hibi/screens/diary_todo_screens.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // 曜日表示に使うなら
import 'gacha_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // ガチャ回数を保存
  Future<void> saveGachaCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gacha_count', gachaCount);
  }

// ガチャ回数を読み込み
  Future<void> loadGachaCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      gachaCount = prefs.getInt('gacha_count') ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    loadGachaCount();
  }

  int gachaCount = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,//背景を黒
      appBar: AppBar(
        title: Text('カレンダー'),
        actions: [
          IconButton(
            icon:Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GachaScreen(initialGachaCount: gachaCount)),
              );
            },
          ),
        ],
      ),
      body: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2040, 12, 31),
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryTodoScreen(selectedDay: selectedDay),
            ),
          );
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Colors.green, // 緑
            shape: BoxShape.circle, // 丸
          ),
          defaultTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            Color? textColor;
            if (day.weekday == DateTime.saturday) {
              textColor = Colors.red; // 土曜を赤色に
            } else if (day.weekday == DateTime.sunday) {
              textColor = Colors.blue; // 日曜を青色に
            } else {
              textColor = Colors.white; // 平日は白
            }

            final text = DateFormat.E().format(day); // 曜日 (Sun, Mon, Tue...) を取得

            return Center(
              child: Text(
                text,
                style: TextStyle(color: textColor),
              ),
            );
          },
        ),
      ),
    );
  }
}
