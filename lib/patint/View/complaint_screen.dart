import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/constant.dart';
import 'package:ydental_application/main.dart';
import 'package:ydental_application/student/View/student_drawer.dart';
import 'package:http/http.dart' as http;
import '../../Model/patient_model.dart';


class ComplaintPatient extends StatefulWidget {
  final int patient ;
  const ComplaintPatient({super.key, required this.patient});

  @override
  State<ComplaintPatient> createState() => _ComplaintState();
}

class _ComplaintState extends State<ComplaintPatient> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _complaintTitleController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController dateControllers = TextEditingController();
  String dateErrorMessage = '';
  Patient? selectedPatient;
  String? _selectedItem;
  bool isLoading = true;
  bool isSave = false;
  int? _selectedStudentId;
  List<StudentData> students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final url = Uri.parse('$api_local/students/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        students = (data['data'] as List)
            .map((patientJson) => StudentData.fromJson(patientJson))
            .toList();
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل في جلب الطلاب'),
        ),
      );
    }
    setState(() {isLoading = false;});

  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            hintColor: AppColors.primaryColor,
            colorScheme: const ColorScheme.light(primary: AppColors.secondaryColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      dateControllers.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  void validateInputs() {
    bool hasValidPair = false;
    if (dateControllers.text.isNotEmpty) {
      hasValidPair = true;
    }
    setState(() {
      if (hasValidPair) {
        dateErrorMessage = '';
        // Proceed with form submission or further logic
      } else {
        // Clear fields if a date is selected without a corresponding time
        if (dateControllers.text.isNotEmpty) {
          dateControllers.clear();
        }
        dateErrorMessage = 'من فضلك ادخل تاريخ الشكوى ';
      }
    });
  }

  String? _validateComplaintTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'من فضلك ادخل عنوان الشكوى ';
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSave = true);
      try {
        final response = await http.post(
          Uri.parse('$api_local/complaints'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "patient_id": widget.patient,
            "complaint_type": _selectedItem,
            "complaint_title": _complaintTitleController.text,
            "complaint_desciption": _descriptionController.text,
            "complaint_date": dateControllers.text,
            "student_id": _selectedStudentId,
          }),
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال الشكوى!'),
              backgroundColor: Colors.green,
            ),
          );
          _formKey.currentState!.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في الإرسال: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في الاتصال بالخادم'),
            backgroundColor: Colors.red,
          ),
        );
      } finally{
        setState(() => isSave = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
         appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            const Text("رفع بلاغ"),
            Image.asset(
              'assets/logo.png', // Path to your logo image
              fit: BoxFit.contain,
              height: 150, // Set the height of the logo
            ),
          ]),
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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'شاركونا ملاحظاتكم والشكاوي الخاصة بكم',
                    style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 18,

                        letterSpacing: 0.3),
                  ),
                  const Text(
                      'هل لديكم شكوى أو ملاحظات ؟ نحن هنا لمساعدتكم ! يرجى تعبئة النموذج التالي : '),
                  const SizedBox(
                    height: 20,
                  ),
                  // حقل اسم المشتكى عليه
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'اسم الطالب المشتكى عليه',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _selectedStudentId = value),
                    items: students.map((patient) {
                      return DropdownMenuItem<int>(
                        value: patient.id,
                        child: Text(patient.name ?? ''),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // حقل عنوان الشكوى
                  TextFormField(
                    controller: _complaintTitleController,
                    decoration: const InputDecoration(
                      labelText: '* عنوان الشكوى',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),

                  const SizedBox(height: 20),

                  // حقل نوع البلاغ
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'نوع البلاغ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null ? 'مطلوب' : null,
                    value: _selectedItem,
                    items: const [
                      DropdownMenuItem(value: 'شكوى', child: Text('شكوى')),
                      DropdownMenuItem(value: 'ملاحظة', child: Text('ملاحظة')),
                    ],
                    onChanged: (value) => setState(() => _selectedItem = value),
                  ),

                  const SizedBox(height: 20),

                  // حقل التاريخ
                  TextFormField(
                    controller: dateControllers,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '* التاريخ',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    onTap: pickDate,
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelStyle: TextStyle(color: Color(0xffB4B4B8)),
                      labelText: '*  تفاصيل البلاغ ',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(
                    height: 20,
                  ),
                  const Row(
                    children: [
                      Text(
                        '*  تعني أن الحقل إجباري ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 400,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: SizedBox(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width /
                                      2.75,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      _submit();
                                    },
                                    child: isSave
                                        ? const Center(child: CircularProgressIndicator())
                                        : const Text(
                                      'إرسال',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: SizedBox(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width /
                                      2.75,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white70,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'إلغاء',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
