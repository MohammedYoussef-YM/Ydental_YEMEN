import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/city_Provider.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/constant.dart';
import 'package:ydental_application/student/View/bottom_navigation_screen.dart';
import 'package:ydental_application/student/View/student_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentEditProfile extends StatefulWidget {
  const StudentEditProfile({super.key});

  @override
  State<StudentEditProfile> createState() => _StudentEditProfileState();
}

class _StudentEditProfileState extends State<StudentEditProfile> {
  final _formKey = GlobalKey<FormState>();
  late StudentData userData;
  bool isLoading = true;

  // Form fields
  String? username;
  String? email;
  String? phoneNumber;
  String? selectedLevel;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ProfileProvider>(context, listen: false).fetchCities());
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentJson = prefs.getString('student');

    if (studentJson != null) {
      Map<String, dynamic> studentData = jsonDecode(studentJson);
      setState(() {
        userData = StudentData.fromJson(studentData);
        username = userData.name;
        email = userData.email;
        phoneNumber = userData.phoneNumber.toString();
        selectedLevel = userData.level;
        isLoading = false;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _saveStudentData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
      isLoading = true;
      });
      _formKey.currentState!.save();

      final updatedData = {
        'name': username,
        'email': email,
        'phone_number': phoneNumber,
        'city_id': userData.cityId,
        'university_id': userData.universityId,
        'level': selectedLevel,
      };

      final url = Uri.parse('$api_local/students/${userData.id}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var data = jsonDecode(response.body);
        // استخراج جزء student فقط
        Map<String, dynamic> studentData = data['student'];
        // حفظ جزء student فقط
        prefs.setString('student', jsonEncode(studentData));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح'),backgroundColor:AppColors.primaryColor),
        );
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentProfile(student: userData,isBack:true),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تحديث البيانات')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
              onPressed: () => Navigator.pop(context),
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
                    initialValue: username,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم *',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'ادخل الإسم' : null,
                    onSaved: (value) => username = value,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(
                      labelText: 'الإيميل *',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    validator: (value) => value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)
                        ? 'هذا الإيميل غير صالح'
                        : null,
                    onSaved: (value) => email = value,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: phoneNumber,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف *',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    validator: (value) =>
                    value == null || !RegExp(r'^(0\d{5}|(73|777|77|78|71)\d{7})$').hasMatch(value)
                        ? 'ادخل رقم مناسب'
                        : null,
                    onSaved: (value) => phoneNumber = value,
                  ),
                  const SizedBox(height: 20),
                  Consumer<ProfileProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: userData.cityId!= null? userData.cityId.toString(): null, // Fix here

                            // value: userData.cityId.toString(),
                            decoration: const InputDecoration(
                              labelText: 'المدينة *',
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                            items: provider.cities.map((city) {
                              return DropdownMenuItem<String>(
                                value: city.id,
                                child: Text(city.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              final selectedCity = provider.cities.firstWhere(
                                    (city) => city.id == value,
                              );
                              setState(() => userData.cityId = selectedCity.id);
                              provider.updateCity(value); // <-- إضافة هذا السطر
                              userData.universityId = null;
                            },
                            validator: (value) => value == null ? 'اختر المدينة' : null,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: userData.universityId!= null? userData.universityId.toString(): null, // Fix here
                            decoration: const InputDecoration(
                              labelText: 'الجامعة *',
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                            items: provider.universities.map((university) {
                              return DropdownMenuItem(
                                value: university.id.toString(),
                                child: Text(university.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              final selectedUniversity = provider.universities.firstWhere(
                                    (university) => university.id.toString() == value,
                              );
                              setState(() => userData.universityId = selectedUniversity.id);
                            },
                            // validator: (value) => value == null ? 'ادخل جامعتك' : null,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedLevel,
                    items: [
                      'الثاني',
                      'الثالث',
                      'الرابع',
                      'الخامس',
                      'امتياز',
                      'ماجستير',
                      'دكتوراه',
                    ].map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text('المستوى $level'), // Add "المستوى" prefix only for display
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'المستوى',
                      // border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedLevel = value;
                      });
                    },
                    validator: (value) => value == null ? 'يرجى اختيار المستوى' : null,                        ),

                  // DropdownButtonFormField<String>(
                  //   value: selectedLevel,
                  //   decoration: const InputDecoration(
                  //     labelText: 'المستوى *',
                  //     labelStyle: TextStyle(color: Colors.black),
                  //   ),
                  //   items: [
                  //     'المستوى الثاني',
                  //     'ثالث',
                  //     'المستوى الرابع',
                  //     'المستوى الخامس',
                  //     'امتياز',
                  //     'ماجستير',
                  //     'دكتوراة',
                  //   ].map<DropdownMenuItem<String>>((String value) {
                  //     return DropdownMenuItem(
                  //       value: value,
                  //       child: Text(value),
                  //     );
                  //   }).toList(),
                  //   onChanged: (value) => setState(() => selectedLevel = value),
                  //   validator: (value) => value == null ? 'ادخل المستوى' : null,
                  // ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        onPressed: _saveStudentData,
                        child: const Text('حفظ',style: TextStyle(color: Colors.white,fontSize: 16),),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          foregroundColor: Colors.black54,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('الغاء'),
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