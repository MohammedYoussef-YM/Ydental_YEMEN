import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/constant.dart';
import 'package:ydental_application/patint/View/patient_profile.dart';
import '../../colors.dart';
import 'package:http/http.dart' as http;

class PatientEditProfile extends StatefulWidget {
  const PatientEditProfile({super.key});

  @override
  State<PatientEditProfile> createState() => _PatientEditProfileState();
}

class _PatientEditProfileState extends State<PatientEditProfile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _date_of_birthController = TextEditingController();

  String? username;
  String? email;
  String? phoneNumber;
  String _selectedGender = 'Male'; // تأكد من أن القيمة موجودة في القائمة
  final List<String> _genders = ['Male', 'Female']; // تأكد من عدم وجود تكرار
  Patient? patient;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? patientJson = prefs.getString('patient');

    if (patientJson != null) {
      Map<String, dynamic> patientData = jsonDecode(patientJson);
      setState(() {
        patient = Patient.fromJson(patientData);
        _date_of_birthController.text = patient!.dateOfBirth.toString();
        _selectedGender = patient!.gender ?? 'Male'; // تأكد من أن القيمة موجودة في القائمة
      });
    }
  }

  Future<void> _updatePatientData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      // تحضير البيانات المحدثة
      Map<String, dynamic> updatedPatient = {
        "id": patient!.id,
        "name": username ?? patient!.name,
        "email": email ?? patient!.email,
        "otp": null, // يمكنك تعديل هذا الحقل إذا كان مطلوبًا
        "otp_expires_at": null, // يمكنك تعديل هذا الحقل إذا كان مطلوبًا
        "id_card": patient!.idCard ?? "123456789", // يمكنك تعديل هذا الحقل إذا كان مطلوبًا
        "gender": _selectedGender,
        "address": patient!.address ?? "123 Main St, City, Country", // يمكنك تعديل هذا الحقل إذا كان مطلوبًا
        "date_of_birth": _date_of_birthController.text,
        "phone_number": phoneNumber ?? patient!.phoneNumber,
        "userType": patient!.userType ?? "patient",
        "isBlocked": patient!.isBlocked ?? "no",
        "created_at": patient!.createdAt ?? "2025-01-19T09:44:16.000000Z", // يمكنك تعديل هذا الحقل إذا كان مطلوبًا
        "updated_at": DateTime.now().toIso8601String(), // تحديث تاريخ التعديل
      };

      try {
        var url = Uri.parse('$api_local/patients/${patient!.id}');

        var response = await http.put(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(updatedPatient),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          var data = jsonDecode(response.body);

          if (data.isNotEmpty) {
            // تحديث البيانات في SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('patient', jsonEncode(data));
            String? patientJson = prefs.getString('patient');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'تم تحديث البيانات بنجاح',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                backgroundColor: AppColors.primaryColor,
              ),
            );

            // الانتقال إلى شاشة PatientProfile
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PatientProfile(isBack:true),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  data ?? 'حدث خطأ أثناء التحديث',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                backgroundColor: AppColors.primaryColor,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'حدث خطأ أثناء الاتصال بالخادم',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              backgroundColor: AppColors.primaryColor,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ: $e',
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            backgroundColor: AppColors.primaryColor,
          ),
        );
      } finally {
        setState(() {
          isLoading = false; // Hide loading indicator after all data is fetched or an error occurs
        });
      }
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _date_of_birthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (patient == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'تعديل البيانات الشخصية',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new),
              color: AppColors.primaryColor,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: patient!.name,
                    decoration: const InputDecoration(
                      labelText: 'الإسم ',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ادخل الإسم';
                      }
                      return null;
                    },
                    onSaved: (value) => username = value,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: patient!.email,
                    decoration: const InputDecoration(
                      labelText: 'الإيميل *',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'هذا الإيميل غير صالح ';
                      }
                      return null;
                    },
                    onSaved: (value) => email = value,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: patient!.phoneNumber,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف ',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ادخل رقم الهاتف مقيول';
                      }
                      final RegExp regex = RegExp(r'^(0\d{5}|(73|777|77|78|71)\d{7})$');
                      if (!regex.hasMatch(value)) {
                        return 'ادخل رقم مناسب';
                      }
                      return null;
                    },
                    onSaved: (value) => phoneNumber = value,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _date_of_birthController,
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الميلاد',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectBirthDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال تاريخ الميلاد';
                      }

                      // تحويل النص إلى DateTime
                      DateTime? birthDate = DateTime.tryParse(value);
                      if (birthDate == null) {
                        return 'يرجى إدخال تاريخ صحيح';
                      }

                      // حساب العمر
                      DateTime today = DateTime.now();
                      int age = today.year - birthDate.year;

                      // تصحيح العمر إذا لم يكن قد أكمل السنة بعد
                      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
                        age--;
                      }

                      // تحقق من أن العمر بين 2 و130
                      if (age < 2 || age > 130) {
                        return 'يجب أن يكون العمر بين سنتين و130 سنة';
                      }

                      return null; // التحقق ناجح
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'الجنس',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      prefixIcon: Icon(Icons.transgender),
                    ),
                    items: _genders.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                    validator: (value) => value == null ? 'يرجى اختيار الجنس' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 150,
                            height: 40,
                            color: AppColors.primaryColor,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                              ),
                              onPressed: _updatePatientData,
                              child: isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : const Text('حفظ',style: TextStyle(color: Colors.white,fontSize: 16),),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 150,
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white70,
                                foregroundColor: Colors.black54,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('الغاء'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}