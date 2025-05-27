import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';

import 'package:bonobono/login_screen.dart';
import 'package:bonobono/english/home_screen.dart';
import 'package:bonobono/user_provider.dart';
import 'SharedPreferencesService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized");
  } catch (e, stack) {
    print("❌ Firebase 초기화 실패: $e\n$stack");
  }

  try {
    KakaoSdk.init(nativeAppKey: '키값');
    await printKeyHash();
  } catch (e, stack) {
    print("❌ Kakao SDK 초기화 실패: $e\n$stack");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

Future<void> printKeyHash() async {
  try {
    final keyHash = await KakaoSdk.origin;
    print("🔑 현재 사용 중인 키 해시: $keyHash");
  } catch (e) {
    print("❌ 키 해시를 가져오는 중 오류 발생: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 개발 중에 상단 디버그 배너 제거
      home: FutureBuilder<Map<String, dynamic>?>(
        future: SharedPreferencesService.getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.black54),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            print("❌ SharedPreferences 로딩 중 오류: ${snapshot.error}");
            return ErrorScreen(); // 아래에서 정의
          } else if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            final docId = data['username'];
            final email = data['email'];

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Provider.of<UserProvider>(context, listen: false).setUser(docId, email);
              }
            });

            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          "앱 실행 중 오류가 발생했습니다.\n다시 시작해주세요.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
