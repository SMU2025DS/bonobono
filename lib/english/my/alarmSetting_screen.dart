import 'package:flutter/material.dart';

class AlarmsettingScreen extends StatefulWidget {
  const AlarmsettingScreen({Key? key}) : super(key: key);

  @override
  State<AlarmsettingScreen> createState() => _AlarmsettingScreenState();
}

class _AlarmsettingScreenState extends State<AlarmsettingScreen> {
  bool isNotificationAllowed = true;
  bool isSoundEnabled = true;
  bool isBadgeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '알림 설정',
          style: TextStyle(
            fontFamily: "NotoSansKR",
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 알림 허용 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "알림 허용",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: isNotificationAllowed,
                  onChanged: (value) {
                    setState(() {
                      isNotificationAllowed = value;
                      if (isNotificationAllowed) {
                        // 알림 허용 시 기본값 켜기
                        isSoundEnabled = true;
                        isBadgeEnabled = true;
                      } else {
                        // 알림 비허용 시 모두 끄기
                        isSoundEnabled = false;
                        isBadgeEnabled = false;
                      }
                    });
                  },
                ),
              ],
            ),
            Divider(),
            // 사운드 섹션
            _buildSettingRow(
              label:  "사운드",
              value: isSoundEnabled,
              isEnabled: isNotificationAllowed,
              onChanged: (value) {
                if (isNotificationAllowed) {
                  setState(() {
                    isSoundEnabled = value;
                  });
                }
              },
            ),
            // 배지 섹션
            _buildSettingRow(
              label: "배지",
              value: isBadgeEnabled,
              isEnabled: isNotificationAllowed,
              onChanged: (value) {
                if (isNotificationAllowed) {
                  setState(() {
                    isBadgeEnabled = value;
                  });
                }
              },
            ),
            Divider(),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildNotificationOption(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.blue),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildSettingRow({
    required String label,
    required bool value,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4, // 불투명도 설정
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: isEnabled ? onChanged : null, // 비활성화 처리
          ),
        ],
      ),
    );
  }
}
