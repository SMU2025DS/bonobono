import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:bonobono/english/home_screen.dart';
// import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:bonobono/signup_screen.dart';
import 'package:bonobono/user_provider.dart';
import 'package:provider/provider.dart';

import 'SharedPreferencesService.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double? deviseWidth;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime? currentBackPressTime;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      final firestore = FirebaseFirestore.instance;

      // 🔹 Firestore에서 해당 이메일 조회
      QuerySnapshot query = await firestore
          .collection('members')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating, // 🔹 스낵바를 떠있는 형태로 변경
              margin: EdgeInsets.only(
                bottom: deviseWidth! * 0.5, // 🔹 화면 중앙으로 이동
                left: 20,
                right: 20,
              ),
              content: Center(
                child: Text(
                  '회원정보가 없습니다.',
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

      // 🔹 Firestore에서 가져온 사용자 데이터
      var userData = query.docs.first.data() as Map<String, dynamic>;
      String storedPassword = userData['password'] ?? '';

      if (password == storedPassword) {
        // 🔹 기존 문서 ID 가져오기
        String docId = query.docs.first.id;

        // 🔹 UserProvider에 정보 저장
        Provider.of<UserProvider>(context, listen: false).setUser(docId, email);

        // 🔹 SharedPreferences에 사용자 정보 저장
        await SharedPreferencesService.saveUserInfo(docId, email);

        // 🔹 로그인 성공 → 메인 화면 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) =>  HomeScreen()),
              (route) => false, // 🔹 이전 모든 화면 제거
        );
      } else {
        // 🔹 비밀번호 불일치 시 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating, // 🔹 스낵바를 떠있는 형태로 변경
            margin: EdgeInsets.only(
              bottom: deviseWidth! * 0.5, // 🔹 화면 중앙으로 이동
              left: 20,
              right: 20,
            ),
            content: Center(
              child: Text(
                '비밀번호가 일치하지 않습니다.',
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


  Future<bool?> _showSignupDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          icon: Icon(Icons.info, size: 30, color: Color(0xff323232),),
          content: Text(
            "회원정보가 없습니다",
            textAlign: TextAlign.center, // 🔹 본문도 가운데 정렬
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff323232),
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.w800,
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
                      Navigator.of(context).pop(true); // ✅ 확인 → true 반환
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff323232)
                    ),
                    child: const Text('회원가입하기',
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
                      Navigator.of(context).pop(false); // ❌ 취소 → false 반환
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        );
      },
    );
  }

/*
  Future<void> _loginWithNaver(BuildContext context) async {
    try {
      // 🔹 네이버 로그인 수행
      NaverLoginResult loginResult = await FlutterNaverLogin.logIn();
      String email = loginResult.account.email ?? '';

      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("이메일을 가져오지 못했습니다.")),
        );
        return;
      }

      final firestore = FirebaseFirestore.instance;

      // 🔹 Firestore에서 해당 이메일 조회
      QuerySnapshot query = await firestore
          .collection('members')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isEmpty) {
        // 🔹 회원가입 여부 확인
        bool? confirmSignup = await _showSignupDialog(context);

        if (confirmSignup == true) {
          // 🔹 동의하면 회원가입 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupScreen(initialEmail: email),
            ),
          );
        } else {
          // 🔹 동의하지 않으면 아무 동작도 하지 않음
          return;
        }
      } else {
        // 🔹 기존 문서 ID 가져오기
        String docId = query.docs.first.id;

        // 🔹 UserProvider에 정보 저장
        Provider.of<UserProvider>(context, listen: false).setUser(docId, email);

        // 🔹 SharedPreferences에 사용자 정보 저장
        await SharedPreferencesService.saveUserInfo(docId, email);

        // 🔹 로그인 성공 → 메인 화면 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => RootScreen()),
              (route) => false, // 🔹 이전 모든 화면 제거
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네이버 로그인 실패: $e")),
      );
    }
  }*/


  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      // 카카오 로그인 수행
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      User user = await UserApi.instance.me();

      String email = user.kakaoAccount?.email ?? '';

      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("이메일을 가져오지 못했습니다.")),
        );
        return;
      }

      final firestore = FirebaseFirestore.instance;

      // 🔹 Firestore에서 해당 이메일 조회
      QuerySnapshot query = await firestore
          .collection('members')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isEmpty) {
        // 🔹 회원가입 여부 확인
        bool? confirmSignup = await _showSignupDialog(context);

        if (confirmSignup == true) {
          // 🔹 동의하면 회원가입 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupScreen(initialEmail: email),
            ),
          );
        } else {
          // 🔹 동의하지 않으면 아무 동작도 하지 않음
          return;
        }
      } else {
        // 🔹 기존 문서 ID 가져오기
        String docId = query.docs.first.id;

        // 🔹 UserProvider에 정보 저장
        Provider.of<UserProvider>(context, listen: false).setUser(docId, email);

        // 🔹 SharedPreferences에 사용자 정보 저장
        await SharedPreferencesService.saveUserInfo(docId, email);

        // 🔹 로그인 성공 → 메인 화면 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false, // 🔹 이전 모든 화면 제거
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("카카오 로그인 실패: $e")),
      );
    }
  }

  Future<bool> onWillPop(){
    DateTime now = DateTime.now();
    if(currentBackPressTime == null || now.difference(currentBackPressTime!)
        > Duration(seconds: 2))
    {
      currentBackPressTime = now;
      final msg = "종료하려면 한번 더 누르세요.";

      Fluttertoast.showToast(msg: msg);
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {

    deviseWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
        onWillPop: onWillPop,
        child: GestureDetector(
        onTap: () {
      FocusScope.of(context).unfocus();
    },
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body:Form(
      key: _formKey,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 60),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              child: Text("Login",
                style: TextStyle(
                  fontSize: 40,
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
            SizedBox(height: 10),
            Container(
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                cursorColor: Color(0xff323232),
                style: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: '이메일을 입력해주세요',
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
            ),
            const SizedBox(height: 10),
            Container(
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                cursorColor: Color(0xff323232),
                style: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력해주세요',
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
                    return '비밀번호를 입력하세요';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 15),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){},
                        child: const Text(
                          '이메일 찾기',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text("  |  ",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontFamily: "NotoSansKR",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){},
                        child: const Text(
                          '비밀번호 찾기',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus(); // 🔹 키보드 내리기
                _login(); // 🔹 로그인 실행
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                backgroundColor: Color(0xff323232)
              ),
              child: const Text('로그인',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Color(0xffA2A2A2),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '간편로그인',
                  style: TextStyle(
                    fontSize: deviseWidth! * .035,
                    color: Colors.grey,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Color(0xffA2A2A2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: GestureDetector(
                        onTap: (){
                          FocusScope.of(context).unfocus();
                          _loginWithKakao(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3), // 그림자 색상 (투명도 조정)
                                blurRadius: 7, // 그림자 흐림 정도
                                offset: Offset(0, 3), // 그림자 위치 (x: 오른쪽, y: 아래쪽)
                              ),
                            ],
                            borderRadius: BorderRadius.circular(100),
                            color: Color(0xffFEE500),
                          ),
                          child: Center(
                            child: Image.asset("assets/img/login_button_kakao.png", height: 50),
                          ),
                        ),
                      )
                  ),
                ),
                Container(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: GestureDetector(
                        onTap: (){
                          FocusScope.of(context).unfocus();
                          // _loginWithNaver(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3), // 그림자 색상 (투명도 조정)
                                blurRadius: 7, // 그림자 흐림 정도
                                offset: Offset(0, 3), // 그림자 위치 (x: 오른쪽, y: 아래쪽)
                              ),
                            ],
                            borderRadius: BorderRadius.circular(100),
                            color: Color(0xff03C75A),
                          ),
                          child: Center(
                            child: Image.asset("assets/img/login_button_naver.png", height: 50),
                          ),
                        ),
                      )
                  ),
                ),
                Container(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: GestureDetector(
                        onTap: (){
                          FocusScope.of(context).unfocus();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3), // 그림자 색상 (투명도 조정)
                                blurRadius: 7, // 그림자 흐림 정도
                                offset: Offset(0, 3), // 그림자 위치 (x: 오른쪽, y: 아래쪽)
                              ),
                            ],
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Image.asset("assets/img/login_button_google.png", height: 50),
                          ),
                        ),
                      )
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      )
    )
        )
    );
  }
}
