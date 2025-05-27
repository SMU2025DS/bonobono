import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'study_screen.dart';
import 'wordList_screen.dart';
import 'my/scope_screen.dart';
import 'my_screen.dart';
import '../../user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final docId = userProvider.docId;

    if (docId != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('members')
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _userName = docSnapshot.data()?['name'] ?? '';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScopeScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 환영 카드
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _userName != null
                      ? Column(
                    children: [
                      Text(
                        '$_userName 님',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'NotoSansKR',
                          color: Color(0xff323232),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '환영합니다!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'NotoSansKR',
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  )
                      : Center(child: CircularProgressIndicator()),
                ),
              ),
              SizedBox(height: 30),

              // 오늘의 단어 학습 버튼
              _buildMenuButton(
                icon: Icons.school,
                label: '오늘의 단어 학습',
                color: Color(0xff323232),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudyScreen()),
                  );
                },
              ),

              SizedBox(height: 15),

              // 단어 목록 보기 버튼
              _buildMenuButton(
                icon: Icons.list,
                label: '단어 목록 보기',
                color: Colors.grey[800]!,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WordListScreen()),
                  );
                },
              ),

              SizedBox(height: 15),

              // 나의 통계 버튼
              _buildMenuButton(
                icon: Icons.bar_chart,
                label: '나의 통계',
                color: Colors.grey[600]!,
                onPressed: () {
                  Navigator.pushNamed(context, '/stats');
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xff323232),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '저장한 단어'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이'),
        ],
      ),
    );
  }

// 🔹 버튼 위젯 분리
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          fontFamily: 'NotoSansKR',
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
