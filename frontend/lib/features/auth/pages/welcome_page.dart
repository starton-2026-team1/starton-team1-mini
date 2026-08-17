import 'package:flutter/material.dart';

import '../../main_navigation/pages/main_navigation_page.dart';
import 'phone_auth_page.dart';

class WelcomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // 나라 선택 창
  String selectedCountry = '대한민국';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 빈 화면 병합
            Spacer(),
            // 당근 이미지 로고
            Image(
              image: AssetImage('assets/image/logo.png'),
              width: 100,
              height: 100,
            ),
            SizedBox(height: 16),
            Text(
              "당신 근처의 당근",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text("동네라서 가능한 모든 것"),
            Text("지금 내 동네를 선택하고 시작해보세요!"),

            // 동네 설정 버튼
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCountry,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue!;
                  });
                },
                items:
                    <Map<String, String>>[
                      // 더미 데이터
                      {'flag': '🇰🇷', 'name': '대한민국'},
                    ].map((country) {
                      return DropdownMenuItem<String>(
                        value: country['name'],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              country['flag']!,
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 8),
                            Text(
                              country['name']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            const Spacer(),

            // 시작하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PhoneAuthPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffFF6F0F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(5),
                  ),
                ),

                child: Text('시작하기', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MainNavigationPage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('메인 화면 테스트', style: TextStyle(fontSize: 12)),
            ),

            SizedBox(height: 16),
            // 로그인 버튼
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "이미 계정이 있나요? ",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                Text(
                  "로그인",
                  style: TextStyle(
                    color: Color(0xffFF6F0F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
