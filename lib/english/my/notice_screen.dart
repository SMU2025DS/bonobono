import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // 배경색을 흰색으로 명시
      appBar: AppBar(
        title: const Text(
          '공지사항',
          style: TextStyle(
            color: Colors.black,
            fontFamily: "NotoSansKR",
            fontWeight: FontWeight.w500,
            fontSize: 18
          ), // 텍스트 색상 검정
        ),
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        backgroundColor: Colors.white, // AppBar 배경 흰색
        iconTheme: const IconThemeData(color: Colors.black), // 아이콘 색상 검정
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('information').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                '오류가 발생했습니다. 다시 시도하세요.',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w500,
                ), // 텍스트 색 검정
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black, // 로딩 인디케이터 색상 검정
              ),
            );
          }

          final documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return const Center(
              child: Text(
                '공지사항이 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(5),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index];
              return Card(
                color: Colors.white, // 카드 배경 흰색
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent, // Divider 색상을 투명으로 설정
                    splashColor: Colors.transparent
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0), // 타일 패딩 조정
                    collapsedIconColor: Colors.grey,
                    iconColor: Colors.grey,
                    title: Text(
                      data['timestamp'] != null
                          ? (data['timestamp'] as Timestamp)
                          .toDate()
                          .toString()
                          .substring(0, 16)
                          : '날짜 없음',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w400,
                        color: Colors.grey, // 날짜 색상 회색
                      ),
                    ),
                    subtitle: Text(
                      data['title'].trim() ?? '제목 없음',
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w600,
                        color: Colors.black, // 제목 색상 검정
                      ),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            data['content'] ?? '내용 없음',
                            textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w400,
                              color: Colors.black, // 내용 색상 검정
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
