import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../user_provider.dart'; // 🔹 docId를 가져오기 위해 필요
import 'package:shared_preferences/shared_preferences.dart'; // 🔹 상단에 추가


class WordCountScreen extends StatefulWidget {
  const WordCountScreen({Key? key}) : super(key: key);

  @override
  _WordCountScreenState createState() => _WordCountScreenState();
}

class _WordCountScreenState extends State<WordCountScreen> {
  int _selectedCount = 20;


  Future<void> _updateWordCount(int count) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final docId = userProvider.docId;

    try {
      // 🔹 Firestore에 저장
      if (docId != null) {
        await FirebaseFirestore.instance
            .collection('members')
            .doc(docId)
            .update({'wordCount': count});
      }

      // 🔹 로컬 SharedPreferences에도 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('wordCount', count);

      // 🔹 성공 시 이전 화면으로 돌아가기
      Navigator.pop(context, count);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("업데이트에 실패했습니다.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('하루 학습 단어 수'),
        backgroundColor: Color(0xff323232),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('하루에 외울 단어 수를 선택하세요',
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController:
              FixedExtentScrollController(initialItem: _selectedCount - 1),
              onSelectedItemChanged: (int index) {
                setState(() {
                  _selectedCount = index + 1;
                });
              },
              children: List.generate(100, (index) {
                return Center(child: Text('${index + 1}개'));
              }),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _updateWordCount(_selectedCount),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff323232),
              minimumSize: Size(200, 45),
            ),
            child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
