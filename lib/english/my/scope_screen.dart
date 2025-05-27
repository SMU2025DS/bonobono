
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScopeScreen extends StatelessWidget {
  const ScopeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('저장된 단어',
          style: TextStyle(
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.w500,
              fontSize: 18
          ),
        ),
        backgroundColor: Colors.white,
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      body:  Text('저장된 단어'),
      backgroundColor: Colors.white,
    );
  }
}