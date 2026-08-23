import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import 'phone_auth_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // 나라 선택 창
  String selectedCountry = '대한민국';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 빈 화면 병합
            Spacer(flex: 3),
            // 당근 이미지 로고
            Image(
              image: AssetImage('assets/image/logo.png'),
              width: 120,
              height: 120,
            ),
            SizedBox(height: 16),
            Text(
              "당신 근처의 당근",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text("동네라서 가능한 모든 것"),
            Text("지금 내 동네를 선택하고 시작해보세요!"),

            // 동네 설정 버튼
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCountry,
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.black54),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
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
            const Spacer(flex: 4),

            // 시작하기 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PhoneAuthPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),

                child: Text(
                  '시작하기',
                  style: TextStyle(color: AppColors.white, fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            // 로그인 버튼
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "이미 계정이 있나요? ",
                  style: TextStyle(color: AppColors.grey700),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PhoneAuthPage(),
                      ),
                    );
                  },
                  child: Text(
                    "로그인",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
