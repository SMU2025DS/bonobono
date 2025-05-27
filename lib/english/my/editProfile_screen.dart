import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bonobono/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:bonobono/login_screen.dart';

import '../../SharedPreferencesService.dart';

class EditprofileScreen extends StatefulWidget {
  const EditprofileScreen({Key? key}) : super(key: key);

  @override
  State<EditprofileScreen> createState() => _EditprofileScreenState();
}

class _EditprofileScreenState extends State<EditprofileScreen> {
  double? deviseHeight;
  double? deviseWidth;
  String? _MemberNumber; //추후 키 값으로 바꾸기
  String? _phone;
  String? _email;
  String? _birthdate;
  String? _gender = "미입력";
  String? _name; // Firebase에서 가져온 이름을 저장할 변수

  List<int> _years = List.generate(DateTime.now().year - 1900 + 1,
          (index) => DateTime.now().year - index);
  List<int> _months = List.generate(12, (index) => index + 1);
  List<int> _days = [];

  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _selectedYear = _years.first; // 현재 연도 선택
    _selectedMonth = 1; // 기본 1월 선택
    _updateDays(); // 기본 날짜 업데이트
  }

// 화면으로 돌아왔을 때 데이터를 다시 불러오도록 설정
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserInfo(); // Firebase에서 데이터를 다시 불러오기
  }

  void _updateDays() {
    if (_selectedYear == null || _selectedMonth == null) return;

    int daysInMonth;
    if (_selectedMonth == 2) {
      // 윤년 체크 (4년마다 윤년, 100년 단위 평년, 400년 단위 윤년)
      bool isLeapYear = (_selectedYear! % 4 == 0 && _selectedYear! % 100 != 0) || (_selectedYear! % 400 == 0);
      daysInMonth = isLeapYear ? 29 : 28;
    } else {
      // 30일인 달과 31일인 달 구분
      daysInMonth = [4, 6, 9, 11].contains(_selectedMonth) ? 30 : 31;
    }

    setState(() {
      _days = List.generate(daysInMonth, (index) => index + 1);
      if (_selectedDay != null && _selectedDay! > daysInMonth) {
        _selectedDay = daysInMonth; // 선택된 날짜가 넘어가면 최대 일로 조정
      }
    });
  }

  // 데이터를 다시 가져오는 메서드
  Future<void> _fetchUserInfo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final docId = userProvider.docId;

    if (docId != null) {
      final firestore = FirebaseFirestore.instance;
      final docSnapshot = await firestore.collection('members').doc(docId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _MemberNumber = docId ?? '404'; // 회원번호 가져오기
          _phone = data['phone'] ?? '미입력';
          _email = data['email'] ?? '미입력';
          _birthdate = data['birthdate'] ?? '미입력'; // 생년월일 가져오기
          _gender = data['gender'] ?? "미입력"; // 성별 가져오기
          _name = data['name'] ?? '미입력'; // 이름 가져오기
        });
      }
    }
  }

  Future<void> _updateUserInfo(String field, String value) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final docId = userProvider.docId;

    if (docId != null) {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('members').doc(docId).update({field: value});
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

  // 생년월일 선택 모달에서 선택한 후 Firebase에 저장하고 UI 업데이트
  Future<void> _selectBirthdate(BuildContext context) async {
    int? selectedYear = _selectedYear;
    int? selectedMonth = _selectedMonth;
    int? selectedDay = _selectedDay;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          contentPadding: EdgeInsets.fromLTRB(20,30,20,20),
          content: Container(
            width: deviseWidth! * 0.7,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    icon: const SizedBox.shrink(),
                    value: selectedYear,
                    style: TextStyle(
                      color: Color(0xff323232),
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: "연도",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff323232), width: 2),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    menuMaxHeight: 200,
                    items: _years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text("$year 년"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedYear = value;
                      _updateDays();
                    },
                  ),
                ),
                SizedBox(width: 10),
                // 월 선택 Dropdown
                Expanded(
                  child: DropdownButtonFormField<int>(
                    icon: const SizedBox.shrink(),
                    value: selectedMonth,
                    style: TextStyle(
                      color: Color(0xff323232),
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: "월",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff323232), width: 2),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    menuMaxHeight: 200,
                    items: _months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text("$month 월"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedMonth = value;
                      _updateDays();
                    },
                  ),
                ),
                SizedBox(width: 10),
                // 일 선택 Dropdown
                Expanded(
                  child: DropdownButtonFormField<int>(
                    icon: const SizedBox.shrink(),
                    value: selectedDay,
                    style: TextStyle(
                      color: Color(0xff323232),
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: "일",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff323232), width: 2),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    menuMaxHeight: 200,
                    items: _days.map((day) {
                      return DropdownMenuItem(
                        value: day,
                        child: Text("$day 일"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedDay = value;
                    },
                  ),
                ),
              ],
            ),
          ),

          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 🔹 버튼들을 가운데 정렬
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedYear != null && selectedMonth != null && selectedDay != null) {
                        String formattedDate =
                            "$selectedYear-${selectedMonth.toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')}";

                        setState(() {
                          _birthdate = formattedDate;
                        });

                        await _updateUserInfo('birthdate', formattedDate);
                        _fetchUserInfo();
                      }
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff323232)
                    ),
                    child: const Text('수정하기',
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
                      Navigator.of(context).pop();
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
  }


  void _selectGender(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25)
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _gender = "남자";
                    });
                    await _updateUserInfo('gender', "남자"); // Firebase에 저장
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff323232)
                  ),
                  child: const Text('남자',
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
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _gender = "여자";
                    });
                    await _updateUserInfo('gender', "여자"); // Firebase에 저장
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff323232)
                  ),
                  child: const Text('여자',
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
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _gender = "미입력";
                    });
                    await _updateUserInfo('gender', "미입력"); // Firebase에 저장
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff323232)
                  ),
                  child: const Text('미입력',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: "NotoSansKR",
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    deviseHeight = MediaQuery.of(context).size.height;
    deviseWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            '내 정보 관리',
            style: TextStyle(
                fontFamily: "NotoSansKR",
                fontWeight: FontWeight.w500,
                fontSize: 18),
          ),
          backgroundColor: Colors.grey[100],
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 100, // 원 크기 (radius * 2)
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade200, // 🔹 테두리 색상
                                  width: 2, // 🔹 테두리 두께
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage('assets/img/profile.png'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        _name ?? '로딩 중...', // Firebase의 name 속성 사용
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      )
                    ]
                )
            ),
            Align(
              child: Container(
                height: deviseHeight! * 0.5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 40),
                        Row(
                          children: [
                            Text("기본정보",
                              style: TextStyle(
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("회원번호",
                              style: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.grey[600]
                              ),
                            ),
                            Text(
                              _MemberNumber ?? '로딩 중...',
                              style: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.black
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("휴대폰",
                              style: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.grey[600]
                              ),
                            ),
                            Text(
                              formatPhoneNumber(_phone),
                              style: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.black
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("이메일",
                              style: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.grey[600]
                              ),
                            ),
                            Text(
                              _email ?? '로딩 중...',
                              style: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.black
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                        Row(
                          children: [
                            Text("부가정보",
                              style: TextStyle(
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("생년월일",
                              style: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.grey[600]
                              ),
                            ),
                            GestureDetector(
                                onTap: () => _selectBirthdate(context), // 생년월일 선택 모달 호출
                                child: Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          _birthdate ?? '미입력',
                                          style: TextStyle(
                                              fontFamily: "NotoSansKR",
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.black
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(Icons.mode_edit, size: 14, color: Color(0xff1148d3))
                                      ],
                                    )
                                )
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("성별",
                              style: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.grey[600]
                              ),
                            ),
                            GestureDetector(
                                onTap: () => _selectGender(context), //성별 선택 모달 호출
                                child: Container(
                                  child: Row(
                                    children: [
                                      Text(
                                        _gender!,
                                        style: TextStyle(
                                            fontFamily: "NotoSansKR",
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Colors.black
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(Icons.mode_edit, size: 14, color: Color(0xff1148d3))
                                    ],
                                  ),
                                )
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _showDeleteConfirmationDialog(context),
                      child: Text('TAYO 탈퇴하기'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size( deviseWidth!* 0.4, 45),
                        backgroundColor: Colors.red[400], // 버튼 배경색
                        foregroundColor: Colors.white, // 텍스트와 아이콘 색
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), // 둥근 모서리
                        ),
                        padding: EdgeInsets.symmetric(vertical: 2), // 버튼 내부 위아래 여백
                        textStyle: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w800,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 1),
                  ],
                ),
              )
            ),
          )
        ],
      )
    );
  }
}

void _showDeleteConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        titlePadding: EdgeInsets.fromLTRB(0,20,0,10),
        title: Text(
          "정말 탈퇴하시겠어요?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "NotoSansKR",
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          "영구히 삭제되며 복구되지 않습니다.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "NotoSansKR",
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // 🔹 버튼들을 가운데 정렬
            children: [
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Firebase에서 회원번호로 문서 삭제
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final docId = userProvider.docId; // 회원번호(docId)

                      if (docId != null) {
                        final firestore = FirebaseFirestore.instance;
                        await firestore.collection('members').doc(docId).delete();

                        await SharedPreferencesService.logout();

                        // 삭제 성공 시 Login Screen으로 이동
                        Navigator.of(context).pop(); // 팝업 닫기
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(), // Login Screen으로 이동
                          ),
                        );
                      } else {
                        // 회원번호가 없는 경우 에러 처리
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("회원번호를 찾을 수 없습니다."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      // Firebase 삭제 실패 시 에러 처리
                      print("문서 삭제 중 오류 발생: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("탈퇴 처리 중 문제가 발생했습니다. 다시 시도해주세요."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red
                  ),
                  child: const Text('탈퇴하기',
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
                    Navigator.of(context).pop(); // 팝업 닫기
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
}
