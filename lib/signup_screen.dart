import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bonobono/user_provider.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final String? initialEmail; // 🔹 네이버 로그인 시 이메일 자동 입력

  SignupScreen({this.initialEmail});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  double? deviseWidth;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedGender;

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
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!; // 🔹 네이버 로그인 이메일 자동 입력
    }
    _selectedYear = _years.first; // 현재 연도 선택
    _selectedMonth = 1; // 기본 1월 선택
    _updateDays(); // 기본 날짜 업데이트
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String phone = _phoneController.text.trim();
      String name = _nameController.text.trim();
      String gender = _selectedGender ?? "선택 안함";

      int yyyy = _selectedYear ?? 0;
      int mm = _selectedMonth ?? 0;
      int dd = _selectedDay ?? 0;

      // 🔹 하나라도 0이면 null 저장
      String? birthdate = (yyyy == 0 || mm == 0 || dd == 0) ? null : "${yyyy}-${mm.toString().padLeft(2, '0')}-${dd.toString().padLeft(2, '0')}";

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      try {
        // 🔹 같은 이메일 또는 전화번호가 있는지 확인
        QuerySnapshot query = await firestore
            .collection('members')
            .where('email', isEqualTo: email)
            .get();

        QuerySnapshot phoneQuery = await firestore
            .collection('members')
            .where('phone', isEqualTo: phone)
            .get();

        if (query.docs.isNotEmpty) {
          // 이미 존재하는 이메일
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              width: deviseWidth! / 2,
              content: Center(
                child: Text(
                  '이미 가입된 이메일입니다.',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0.5), // ✅ 반투명 적용 (70% 불투명)
              elevation: 0,
              duration: Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.red.withOpacity(0.7),
                  width: 2,
                ),
              ),
            ),
          );
          return;
        }

        if (phoneQuery.docs.isNotEmpty) {
          // 이미 존재하는 전화번호
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              width: deviseWidth! / 2,
              content: Center(
                child: Text(
                  '이미 가입된 전화번호입니다.',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0.5), // ✅ 반투명 적용 (70% 불투명)
              elevation: 0,
              duration: Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.red.withOpacity(0.7),
                  width: 2,
                ),
              ),
            ),
          );

          return;
        }

        // 🔹 Firestore에 저장
        await firestore.collection('members').add({
          'email': email,
          'password': password, // 보안상 해싱 필요
          'phone': phone,
          'name': name,
          'gender': gender,
          'birthdate': birthdate, // 🔹 null 가능
          'createdAt': FieldValue.serverTimestamp(), // 가입 시간
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            width: deviseWidth! / 2,
            content: Center(
              child: Text(
                '회원가입 성공',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            backgroundColor: Colors.white.withOpacity(0.5), // ✅ 반투명 적용 (70% 불투명)
            elevation: 0,
            duration: Duration(milliseconds: 1000),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.green.withOpacity(0.7),
                width: 2,
              ),
            ),
          ),
        );

        // ✅ 로그인 화면으로 이동 (기록 삭제)
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false, // 🔹 이전 모든 화면 제거
          );
        });

      } catch (e) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            width: deviseWidth! / 2,
            content: Center(
              child: Text(
                '회원가입 실패',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            backgroundColor: Colors.white.withOpacity(0.5), // ✅ 반투명 적용 (70% 불투명)
            elevation: 0,
            duration: Duration(milliseconds: 1000),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.red.withOpacity(0.7),
                width: 2,
              ),
            ),
          ),
        );
      }
    }
  }

  Widget _buildGenderCheckbox(String gender) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = (_selectedGender == gender) ? null : gender;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            hoverColor: Colors.black,
            activeColor: Color(0xff323232),
            value: _selectedGender == gender,
            onChanged: (bool? value) {
              setState(() {
                _selectedGender = value! ? gender : null;
              });
            },
          ),
          Text(
            gender,
            style: const TextStyle(
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    deviseWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
        onTap: () {
      FocusScope.of(context).unfocus();
    },
    child: Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body:NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              floating: false, // ✅ 스크롤 시 바로 숨기지 않음
              pinned: false, // ✅ 스크롤 위로 올리면 앱바 숨김
              flexibleSpace: FlexibleSpaceBar(
                background: Container(color: Colors.white), // ✅ 배경 색상
              ),
            ),
          ];
        },
          body: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        child: Text("Sign Up",
                          style: TextStyle(
                            fontSize: 50,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w900,
                            color: Color(0xff323232),
                            shadows: [
                              Shadow(
                                offset: Offset(0, 3.0), // 그림자의 위치 (x, y)
                                blurRadius: 7.0, // 그림자의 흐림 정도
                                color: Colors.grey.withOpacity(0.5), // 그림자 색상 및 투명도
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Text('이메일',
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Color(0xff323232),
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          hintText: '이메일을 입력해주세요',
                          hintStyle: TextStyle(
                              color: Colors.grey
                          ),
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
                          errorStyle: TextStyle(
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w600,
                          ),
                          errorBorder: OutlineInputBorder( // ⬅ 기본 에러 테두리 스타일
                            borderSide: BorderSide(color: Colors.grey, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder( // ⬅ 포커스된 상태에서의 에러 테두리 스타일
                            borderSide: BorderSide(color: Color(0xff323232), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일을 입력하세요';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return '올바른 이메일 형식이 아닙니다';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Text('비밀번호',
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        cursorColor: Color(0xff323232),
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          hintText: '비밀번호을 입력해주세요',
                          hintStyle: TextStyle(
                            color: Colors.grey
                          ),
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
                          errorStyle: TextStyle(
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w600,
                          ),
                          errorBorder: OutlineInputBorder( // ⬅ 기본 에러 테두리 스타일
                            borderSide: BorderSide(color: Colors.grey, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder( // ⬅ 포커스된 상태에서의 에러 테두리 스타일
                            borderSide: BorderSide(color: Color(0xff323232), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요';
                          }
                          if (value.length < 8) {
                            return '비밀번호는 최소 8자리 이상이어야 합니다';
                          }
                          if (!RegExp(r'(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                            return '비밀번호는 영어와 숫자를 포함해야 합니다';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Text('비밀번호 확인',
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        cursorColor: Color(0xff323232),
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          hintText: '비밀번호를 한번 더 입력해주세요',
                          hintStyle: TextStyle(
                              color: Colors.grey
                          ),
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
                          errorStyle: TextStyle(
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w600,
                          ),
                          errorBorder: OutlineInputBorder( // ⬅ 기본 에러 테두리 스타일
                            borderSide: BorderSide(color: Colors.grey, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder( // ⬅ 포커스된 상태에서의 에러 테두리 스타일
                            borderSide: BorderSide(color: Color(0xff323232), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 다시 입력하세요';
                          }
                          if (value != _passwordController.text) {
                            return '비밀번호가 일치하지 않습니다';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Text('이름',
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _nameController,
                        cursorColor: Color(0xff323232),
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          hintText: '이름을 입력해주세요',
                          hintStyle: TextStyle(
                              color: Colors.grey
                          ),
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
                          errorStyle: TextStyle(
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w600,
                          ),
                          errorBorder: OutlineInputBorder( // ⬅ 기본 에러 테두리 스타일
                            borderSide: BorderSide(color: Colors.grey, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder( // ⬅ 포커스된 상태에서의 에러 테두리 스타일
                            borderSide: BorderSide(color: Color(0xff323232), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름를 입력하세요';
                          }
                          if (value.length < 2) {
                            return '이름은 최소 2글자 이상이어야 합니다';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Text('전화번호',
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.number,
                                cursorColor: Color(0xff323232),
                                style: TextStyle(
                                  fontFamily: "NotoSansKR",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                decoration: const InputDecoration(
                                  hintText: '숫자만 입력해주세요',
                                  hintStyle: TextStyle(
                                      color: Colors.grey
                                  ),
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
                                  errorStyle: TextStyle(
                                    fontFamily: "NotoSansKR",
                                    fontWeight: FontWeight.w600,
                                  ),
                                  errorBorder: OutlineInputBorder( // ⬅ 기본 에러 테두리 스타일
                                    borderSide: BorderSide(color: Colors.grey, width: 2),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder( // ⬅ 포커스된 상태에서의 에러 테두리 스타일
                                    borderSide: BorderSide(color: Color(0xff323232), width: 2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '전화번호를 입력하세요';
                                  }
                                  if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
                                    return '올바른 전화번호 (10~11자리)를 입력하세요';
                                  }
                                  return null;
                                },
                              ),
                          ),
                          SizedBox(width: 5,),
                          ElevatedButton(
                            onPressed: (){},
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(80, 45),
                                backgroundColor: Color(0xff323232),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15), // 둥근 모서리
                                ),
                            ),
                            child: const Text('인증하기',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('성별',
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child:
                          _buildGenderCheckbox('남자'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child:
                          _buildGenderCheckbox('여자'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child:
                          _buildGenderCheckbox('미입력'),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('생년월일',
                        style: TextStyle(
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          // 연도 선택 Dropdown
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              style: TextStyle(
                                color: Color(0xff323232),
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: '연도',
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
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
                              value: _selectedYear,
                              dropdownColor: Colors.white,
                              menuMaxHeight: 200,
                              items: _years.map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()+'년'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedYear = value;
                                  _updateDays();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),

                          // 월 선택 Dropdown
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              style: TextStyle(
                                color: Color(0xff323232),
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: '월',
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
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
                              value: _selectedMonth,
                              dropdownColor: Colors.white,
                              menuMaxHeight: 200,
                              items: _months.map((month) {
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(month.toString()+'월'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMonth = value;
                                  _updateDays();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),

                          // 일 선택 Dropdown
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              style: TextStyle(
                                color: Color(0xff323232),
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: '일',
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
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
                              value: _selectedDay,
                              dropdownColor: Colors.white,
                              menuMaxHeight: 200,
                              items: _days.map((day) {
                                return DropdownMenuItem(
                                  value: day,
                                  child: Text(day.toString()+'일'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDay = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                            backgroundColor: Color(0xff323232)
                        ),
                        child: const Text('회원가입',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            )
          ),
        )
      )
    );
  }
}
