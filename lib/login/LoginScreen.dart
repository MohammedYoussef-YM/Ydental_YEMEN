
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/api/data.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/constant.dart';
import 'package:ydental_application/local/local_data.dart';
import 'package:ydental_application/login/SignupScreen.dart';
import 'package:ydental_application/student/View/Widget/custom_dialog.dart';
import 'package:ydental_application/student/View/bottom_navigation_screen.dart';
import 'package:ydental_application/student/View/student_home_screen.dart';
import '../patint/View/bottom_navigation_screen.dart';
import 'ForgotPasswordPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  final String userType;

  const LoginScreen({required this.userType});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService(api_local);

  bool _obscureText = true; // حالة إظهار كلمة المرور
  bool _isLoading = false; // Add loading state

  void _login() async {
    final prefs = SharedPrefsService();
    await prefs.init();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final endpoint = widget.userType == 'patient'
            ? '/patients/login'
            : widget.userType == 'student'
            ? '/students/login'
            : null;

        if (endpoint == null) {
          showMessage('نوع المستخدم غير معروف',context);
          return;
        }

        final response = await _apiService.post(endpoint, {
          'email': email,
          'password': password,
        });

        if (response['success'] == true) {
          if (widget.userType == 'patient') {
            await prefs.setString('patient', jsonEncode(response['patient']));
            Provider.of<Patient>(context, listen: false)
                .updatePatient(response['patient']);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PatientBottomNavigation()),
            );
          } else if (widget.userType == 'student') {

            await prefs.setString('student', jsonEncode(response['student']));
            Provider.of<StudentData>(context, listen: false).updateStudent(response['student']);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StudentBottomNavigation()),
            );
          }
          showMessage('تم تسجيل الدخول بنجاح',context);
        } else {
          showMessage('البريد الإلكتروني أو كلمة المرور غير صحيحة',context);
        }
      } catch (e) {
        showMessage('حدث خطأ أثناء تسجيل الدخول: $e',context);
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator, even if there's an error
        });
      }

    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // تغيير حالة إظهار كلمة المرور
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0), // ارتفاع AppBar
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Center(
              child: Text(
                'تسجيل الدخول كـ ${widget.userType == 'student' ? 'طبيب' : 'مريض'}',
                style: const TextStyle(
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
        ),
        body:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 0, bottom: 50),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 250,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_'{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          ).hasMatch(value!);
                          if (value.isEmpty) {
                            return "يرجى إدخال البريد الإلكتروني";
                          } else if (!emailValid) {
                            return "يرجى إدخال بريد إلكتروني صحيح";
                          }
                          return null; // إذا كانت التحقق ناجحة
                        },
                      ),
                      const SizedBox(height: 16), // مساحة بين الحقول
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                validator: (value) {
                          if (value!.isEmpty) {
                            return "يرجى إدخال كلمة المرور";
                          } else if (value.length < 8) {
                            return "يجب أن تكون كلمة المرور أكثر من 8 أحرف";
                          } else if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(
                              value)) {
                            return "يجب أن تحتوي كلمة المرور على أحرف وأرقام";
                          }
                          return null; // إذا كانت التحقق ناجحة
                        },
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: 150,
                        height: 40,
                        decoration: const BoxDecoration(),
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                          ),
                          child: _isLoading // Show loading indicator if _isLoading is true
                              ? const Center(child: CircularProgressIndicator()) // Center the indicator
                              : const Text(
                            'تسجيل الدخول',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Center(child: Text('ليس لديك حساب؟')),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) =>
                                      SignUpScreen(userType: widget.userType)),
                                );
                              },
                              child: const Center(
                                  child: Text(' إنشاء حساب', style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                  ),)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // TextButton(
                      //   onPressed: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
                      //     );
                      //   },
                      //   child: const Text(
                      //     'نسيت كلمة المرور؟',
                      //     style: TextStyle(
                      //       color: AppColors.primaryColor,
                      //       fontSize: 16,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}