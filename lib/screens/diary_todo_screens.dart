import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:gatya_hibi/utils/gacha_strage.dart';

class DiaryTodoScreen extends StatefulWidget {
  final DateTime selectedDay;

  DiaryTodoScreen({required this.selectedDay});

  @override
  _DiaryTodoScreenState createState() => _DiaryTodoScreenState();
}

class _DiaryTodoScreenState extends State<DiaryTodoScreen> {
  int gachaCount =0;
  String _diaryText = '';

  bool _diaryRewardGiven = false;

  // ToDoリストと日記を保存
  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> todos = _todoList.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('todo_list_${widget.selectedDay.toIso8601String()}', todos);
    await prefs.setString('diary_${widget.selectedDay.toIso8601String()}', _diaryController.text);
  }

// ToDoリストと日記を読み込む
  void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? todos = prefs.getStringList('todo_list_${widget.selectedDay.toIso8601String()}');
    String? diary = prefs.getString('diary_${widget.selectedDay.toIso8601String()}');


    if (todos != null) {
      setState(() {
        _todoList = todos.map((item) => jsonDecode(item)).cast<Map<String, dynamic>>().toList();
      });
    }

    if (diary != null) {
      _diaryController.text = diary;
      _diaryText = diary;
      _diaryRewardGiven = diary.trim().isNotEmpty;
    }else {
      _diaryRewardGiven = false;
    }
  }


  List<Map<String, dynamic>> _todoList = [];
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _diaryController = TextEditingController();

  @override
  void initState(){
    super.initState();
    loadData();//起動時にデータを読み込む
  }


  @override
  void dispose() {
    _todoController.dispose();
    _diaryController.dispose();
    super.dispose();
  }

  void _addTodo() {
    if (_todoController.text.isNotEmpty) {
      setState(() {
        _todoList.add({
          'task': _todoController.text,
          'isDone': false,
          'rewardGiven': false,
        });
        _todoController.clear();
      });
      saveData(); // 追加したら保存！
    }
  }

  Future<void> _toggleTodoDone(int index) async {
    final wasDone = _todoList[index]['isDone'] == true;
    final wasRewarded = _todoList[index]['rewardGiven'] == true;

    setState(() {
      _todoList[index]['isDone'] = !_todoList[index]['isDone'];
    });

    final isNowDone = _todoList[index]['isDone'] == true;

// 未完了→完了になって、かつまだ報酬をもらってない場合だけガチャ+1
    if (!wasDone && isNowDone && !wasRewarded) {
      await increaseGachaCount();
      _todoList[index]['rewardGiven'] = true;
    }

    saveData();
  }

  bool isToday() {
    final now = DateTime.now();
    return now.year == widget.selectedDay.year &&
        now.month == widget.selectedDay.month &&
        now.day == widget.selectedDay.day;
  }


  void _deleteTodo(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('日記とToDo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// ToDoリストエリア
            Text('ToDoリスト', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _todoList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Checkbox(
                            value: _todoList[index]['isDone'],
                            onChanged: isToday()
                                ? (value) => _toggleTodoDone(index)
                                : null, // 今日だけチェックできる
                          ),
                          title: Text(
                            _todoList[index]['task'],
                            style: TextStyle(
                              decoration: _todoList[index]['isDone']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: isToday()
                              ? IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteTodo(index),
                          )
                              : null, // 今日だけ削除できる
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _todoController,
                          enabled: isToday(), // 今日だけ入力できる
                          decoration: InputDecoration(
                            hintText: '新しいToDoを入力',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: isToday() ? _addTodo : null, // 今日だけ追加できる
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 24),
// 日記エリア
            Text('日記', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Container(
              height: 150,
              child: TextField(
                controller: _diaryController,
                maxLines: null,
                expands: true,
                readOnly: !isToday(), // 今日じゃなかったら編集不可！
                decoration: InputDecoration(
                  hintText: '今日の出来事や思ったことを書こう',
                  border: OutlineInputBorder(),
                ),
                  onChanged: (value) async {
                    if (!_diaryRewardGiven && _diaryText.isEmpty && value.trim().isNotEmpty){
                      await increaseGachaCount();
                      _diaryRewardGiven = true;
                    }

// ここで最新の内容を保存する
//                   _diaryText = value;
                     saveData();
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
