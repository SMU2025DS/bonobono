import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('단어 외우기'),
        backgroundColor: Color(0xff323232),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '환영합니다!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansKR',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/study');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff323232),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('오늘의 단어 학습',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'NotoSansKR',
                ),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/wordlist');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('단어 목록 보기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'NotoSansKR',
                ),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/stats');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('나의 통계',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'NotoSansKR',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
