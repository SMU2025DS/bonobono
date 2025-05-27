import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VersioninformationScreen extends StatelessWidget {
  const VersioninformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '버전정보',
          style: TextStyle(
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.w500,
              fontSize: 18),
        ),
        backgroundColor: Colors.white,
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0), // 둥근 모서리 값
                child: Image.asset(
                  'assets/img/toeic.jpg',
                  width: 80, // 원하는 너비
                  height: 80, // 원하는 높이
                  fit: BoxFit.cover, // 이미지 비율 유지
                ),
              ),
              SizedBox(height: 20), // 이미지와 텍스트 사이 여백
              Text(
                '1.0.0',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
