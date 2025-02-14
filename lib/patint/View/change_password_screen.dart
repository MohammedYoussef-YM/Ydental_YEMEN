
import 'package:flutter/material.dart';
import 'package:ydental_application/colors.dart';

class PasswordForm extends StatefulWidget {
  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>();
  String? _newPassword;
  String? _confirmPassword;
  bool _isObscured = true;


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم التعديل'),backgroundColor:  AppColors.primaryColor),
      );
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور الجديدة';
    }
    if (value.length < 8) {
      return 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'يجب أن تحتوي كلمة المرور على حرف واحد على الأقل';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
    }
    _newPassword = value;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primaryColor,
          ), // Custom leading icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Center(child: Text('تغيير كلمة المرور',style: TextStyle
          (    color: AppColors.primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -.4,
            ))),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: AppColors.primaryColor)),
                      errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.errorColor)),
                      focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.secondaryColor)),
                      labelText: 'كلمة المرور الجديدة',
                  labelStyle: TextStyle(color: Colors.grey,),

                  prefixIcon: IconButton(
                    icon: Icon(
                      color:  AppColors.primaryColor,
                      _isObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),
                obscureText: _isObscured,
                validator: _validatePassword,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 20,),
              TextFormField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: AppColors.primaryColor)),
                      errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.errorColor)),
                      focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.secondaryColor)),
                  labelText: 'تأكيد كلمة المرور',
                  labelStyle: TextStyle(color:Colors.grey,),

                ),
                obscureText: true,
                textAlign: TextAlign.right,

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى تأكيد كلمة المرور الخاصة بك';
                  }
                  if (value != _newPassword) {
                    return 'كلمات المرور غير متطابقة';
                  }
                  _confirmPassword = value;
                  return null;
                },
              ),
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  height: 50,
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: AppColors.primaryColor, // Text color
                    ),
                    onPressed: _submitForm,
                    child: Text('تعديل'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}