import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오늘의 단어 학습'),
        backgroundColor: Color(0xff323232),
      ),
      body: Center(
        child: Text(
          '여기에 오늘의 단어 학습 기능이 들어갑니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
