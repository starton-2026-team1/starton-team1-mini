import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

class PhoneAuthPage extends StatefulWidget {
  const new({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        isButtonEnabled = _phoneController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
          color: AppColors.black,
          iconSize: 28,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "휴대폰 정보를 입력해주세요.",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // 입력
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 18, color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: '010-1234-5678',
                    hintStyle: TextStyle(
                      color: AppColors.grey400,
                      fontSize: 18,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.black,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.black, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: Text(
                    '휴대폰 번호가 변경되었나요?',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isButtonEnabled
                  ? () {
                      // 다음 페이지 이동
                      print("다음 페이지로 이동합니다.");
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isButtonEnabled
                    ? AppColors.primary
                    : AppColors.grey600,
                disabledBackgroundColor: AppColors.grey600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(5),
                ),
              ),

              child: Text(
                '다음',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
