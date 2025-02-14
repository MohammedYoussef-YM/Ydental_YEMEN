import 'package:flutter/material.dart';

import '../colors.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  void _sendResetLink(BuildContext context) {
    final email = _emailController.text;

    // هنا يمكنك إضافة المنطق لإرسال رابط إعادة تعيين كلمة المرور
    // مثل الاتصال بخدمة Firebase أو أي خدمة أخرى

    // على سبيل المثال:
    if (email.isNotEmpty) {
      // إرسال رابط إعادة تعيين كلمة المرور
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رابط إعادة تعيين كلمة المرور تم إرساله إلى $email')),
      );
      // أضف هنا الكود الخاص بإرسال الرابط
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال البريد الإلكتروني')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: Text(
          'نسيت كلمة المرور',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -.4, // لون النص
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new,
            color: AppColors.primaryColor,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'أدخل بريدك الإلكتروني لاستعادة كلمة المرور',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _sendResetLink(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,),
              child: Text('إرسال رابط إعادة تعيين كلمة المرور',
                style: TextStyle(color: Colors.white))
                ,
            ),
          ],
        ),
      ),
    );
  }
}