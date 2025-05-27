import 'package:flutter/material.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('리스트'),
        backgroundColor: Color(0xff323232),
      ),
      body: Center(
        child: Text(
          '여기에 학습 리스트가 표시됩니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
