import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bonobono/english/my/alarmSetting_screen.dart';
//import 'package:bonobono/screens/my/developerInformation_screen.dart';
import 'package:bonobono/english/my/notice_screen.dart';
import 'package:bonobono/english/my/scope_screen.dart';
//import 'package:bonobono/screens/my/smu_screen.php.dart';
import 'package:bonobono/english/my/versionInformation_screen.dart';
import 'package:provider/provider.dart';
import '../SharedPreferencesService.dart';
import '../user_provider.dart';
import 'my/editProfile_screen.dart';
import 'package:bonobono/login_screen.dart';
import 'my/wordCount_screen.dart';


class MyScreen extends StatefulWidget {
  final TabController? tabController;
  const MyScreen({Key? key, this.tabController}) : super(key: key);

  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  String? _name;
  String? _phone;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }
//여기
  Future<void> _logout(BuildContext context) async {
    try {

      // UserProvider의 docId를 null로 초기화
      Provider.of<UserProvider>(context, listen: false).clearUser();

      await SharedPreferencesService.logout();

      // 로그인 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false, // 기존 스택을 모두 제거
      );
    } catch (e) {
      print("로그아웃 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그아웃에 실패했습니다.")),
      );
    }
  }


  Future<void> _fetchUserInfo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final docId = userProvider.docId;

    if (docId != null) {
      final firestore = FirebaseFirestore.instance;
      final docSnapshot = await firestore.collection('members').doc(docId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _name = data['name'] ?? '미입력';
          _phone = data['phone'] ?? '미입력';
        });
      }
    }
  }

  String formatPhoneNumber(String? phone) {
    if (phone == null || phone.length < 10) return phone ?? '로딩 중...';

    if (phone.length == 11) {
      return '${phone.substring(0, 3)}-${phone.substring(3, 7)}-${phone.substring(7)}';
    } else if (phone.length == 10) {
      return '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
    }
    return phone; // 예상치 못한 길이일 경우 그대로 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text('내 정보',
                style: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w800,
                ),
              ),
              backgroundColor: Colors.white,
              shape: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              floating: false, // ✅ 스크롤 시 바로 숨기지 않음
              pinned: true, // ✅ 스크롤 위로 올리면 앱바 숨김
              automaticallyImplyLeading: false,
              leading: IconButton( // 👈 이 부분 추가
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(color: Colors.white), // ✅ 배경 색상
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
               Container(
                 height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditprofileScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white, // 버튼 배경색
                          shadowColor: Colors.transparent, // 그림자 색상을 투명하게 설정
                          overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                          padding: EdgeInsets.symmetric(vertical: 0), // 버튼 내부 위아래 여백
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // 둥근 모서리
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 60, // 원 크기 (radius * 2)
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey.shade200, // 🔹 테두리 색상
                                            width: 2, // 🔹 테두리 두께
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.white,
                                          backgroundImage: AssetImage('assets/img/profile.png'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _name ?? '로딩 중...',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontFamily: "NotoSansKR",
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black
                                        ),),
                                      SizedBox(height: 1),
                                      Text(
                                        formatPhoneNumber(_phone),
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: "NotoSansKR",
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600]
                                        ),)
                                    ],
                                  )
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey[600],),
                            ],
                          ),
                        )
                    ),
                  )
              ),
               Container(
                 height: 450,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: SizedBox.expand(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NoticeScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white, // 버튼 배경색
                                foregroundColor: Colors.black, // 텍스트와 아이콘 색
                                padding: EdgeInsets.symmetric(vertical: 10), // 버튼 내부 위아래 여백
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // 둥근 모서리
                                ),
                                textStyle: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.comment_outlined, size: 20, color: Colors.black,),
                                        SizedBox(width: 15),
                                        Text("공지사항"),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[600],),
                                  ],
                                ),
                              )
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: SizedBox.expand(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WordCountScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              textStyle: TextStyle(
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.assignment_outlined, size: 20, color: Colors.black),
                                      SizedBox(width: 15),
                                      Text("단어 갯수 설정"),
                                    ],
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[600]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: SizedBox.expand(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScopeScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white, // 버튼 배경색
                                foregroundColor: Colors.black, // 텍스트와 아이콘 색
                                padding: EdgeInsets.symmetric(vertical: 10), // 버튼 내부 위아래 여백
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // 둥근 모서리
                                ),
                                textStyle: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.star_border, size: 20, color: Colors.black),
                                        SizedBox(width: 15),
                                        Text("저장된 단어"),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[600],),
                                  ],
                                ),
                              )
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: SizedBox.expand(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NoticeScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white, // 버튼 배경색
                                foregroundColor: Colors.black, // 텍스트와 아이콘 색
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // 둥근 모서리
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10), // 버튼 내부 위아래 여백
                                textStyle: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.ring_volume, size: 20, color: Colors.black),
                                        SizedBox(width: 15),
                                        Text("문의사항"),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[600],),
                                  ],
                                ),
                              )
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: SizedBox.expand(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlarmsettingScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white, // 버튼 배경색
                                foregroundColor: Colors.black, // 텍스트와 아이콘 색
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // 둥근 모서리
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10), // 버튼 내부 위아래 여백
                                textStyle: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.notifications_none, size: 20, color: Colors.black),
                                        SizedBox(width: 15),
                                        Text("알림설정"),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[600],),
                                  ],
                                ),
                              )
                          ),
                        ),
                      ),
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          color: Colors.grey[100],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: SizedBox.expand(
                          child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      titlePadding: EdgeInsets.all(40),
                                      actionsAlignment: MainAxisAlignment.center,
                                      title: Center(
                                        child: Text("로그아웃하시겠습니까?",
                                          style: TextStyle(
                                            fontFamily: "NotoSansKR",
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center, // 🔹 버튼들을 가운데 정렬
                                          children: [
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _logout(context); // 로그아웃 함수 호출
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Color(0xff323232)
                                                ),
                                                child: const Text('확인',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontFamily: "NotoSansKR",
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10), // 🔹 버튼 간 간격 추가
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(); // 알림창 닫기
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Color(0xff323232)
                                                ),
                                                child: const Text('닫기',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontFamily: "NotoSansKR",
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white, // 버튼 배경색
                                foregroundColor: Colors.black, // 텍스트와 아이콘 색
                                padding: EdgeInsets.symmetric(vertical: 10), // 버튼 내부 위아래 여백
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // 둥근 모서리
                                ),
                                textStyle: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.logout, size: 20, color: Colors.black),
                                        SizedBox(width: 15),
                                        Text("로그아웃"),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[600],),
                                  ],
                                ),
                              )
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: SizedBox.expand(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VersioninformationScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white, // 버튼 배경색
                                foregroundColor: Colors.black, // 텍스트와 아이콘 색
                                padding: EdgeInsets.symmetric(vertical: 10), // 버튼 내부 위아래 여백
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // 둥근 모서리
                                ),
                                textStyle: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.info_outline, size: 20, color: Colors.black),
                                        SizedBox(width: 15),
                                        Text("버전정보"),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[600],),
                                  ],
                                ),
                              )
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                )
                            ),
                            color: Colors.grey[100],
                          ),

                        ),
                      )
                    ],
                  ),
               ),
            ],
          ),
        )
      )
    );
  }
}



