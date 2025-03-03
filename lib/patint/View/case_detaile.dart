import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ydental_application/Model/cases_model.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/constant.dart';
import 'package:ydental_application/patint/View/bottom_navigation_screen.dart';
import 'package:ydental_application/patint/View/patient_home_screen.dart';
import 'package:ydental_application/patint/View/review_screen.dart';
import 'package:ydental_application/patint/View/student_detail.dart';
import '../../colors.dart';
import 'package:http/http.dart' as http;

class CaseDetaile extends StatefulWidget {
  final MyCasesModel student;
  CaseDetaile({super.key, required this.student});
  @override
  State<CaseDetaile> createState() => _CaseDetaileState();
}

class _CaseDetaileState extends State<CaseDetaile> {
  StudentData? studentDetails;
  Patient? patient;
  bool isLoading = true;
  int? _loadingScheduleId;

  // Map to store booking status for each schedule using scheduleId as key
  Map<int, bool> _bookingStatus = {};

  @override
  void initState() {
    super.initState();
    // تهيئة حالة الحجز لكل موعد عند بدء الشاشة
    for (var schedule in widget.student.schedule) {
      _bookingStatus[schedule.id] = schedule.isBooking!;
    }
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchStudentDetails(),
      _loadPatientData(),
    ]);
    setState(() {}); // تحديث الواجهة بعد تحميل البيانات
  }

  Future<void> _loadPatientData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? patientJson = prefs.getString('patient');
    if (patientJson != null) {
      Map<String, dynamic> patientData = jsonDecode(patientJson);
      setState(() {
        patient = Patient.fromJson(patientData);
      });
    }
  }

  Future<void> _fetchStudentDetails() async {
    try {
      final student = await StudentData.fetchStudentById(widget.student.studentId);
      setState(() {
        studentDetails = student;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showConfirmationDialog(String date, String time, int scheduleId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'تأكيد الحجز',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('هل تريد تأكيد الحجز؟', textAlign: TextAlign.right),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'لا',
                style: TextStyle(color: AppColors.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'نعم',
                style: TextStyle(color: AppColors.primaryColor),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _bookAppointment(scheduleId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _bookAppointment(int scheduleId) async {
    setState(() {
      _loadingScheduleId = scheduleId; // عرض مؤشر التحميل على الزر المحدد
    });
    final apiUrl = '$api_local/appointments/';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "patient_id": patient?.id,
        "student_id": widget.student.studentId,
        "thecase_id": widget.student.id, // تأكد من صحة الـ caseId
        "schedule_id": scheduleId,
      }),
    );

    setState(() {
      _loadingScheduleId = null; // إعادة تعيين مؤشر التحميل بعد انتهاء العملية
    });

    if (response.statusCode == 201) {
      // عند نجاح الحجز، نقوم بتحديث حالة الحجز في الـ Map
      setState(() {
        _bookingStatus[scheduleId] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الحجز بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل الحجز: ${response.body}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            // Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  PatientBottomNavigation()),
            );

          },
        ),
        title: Text("تفاصيل الطالب"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Image.asset('assets/patient_image.jpg'),
              ),
              const SizedBox(height: 10),
              Text(
                "الاسم: ${studentDetails?.name}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                "المستوى: ${studentDetails?.level}",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StudentDetail(student: studentDetails!)),
                      );
                    },
                    child: const Center(
                      child: Text(
                        'تفاصيل الطالب',
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.whatsapp),
                    color: Colors.green,
                    onPressed: _launchWhatsApp,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReviewScreen(patientId: patient!.id!, studentId: studentDetails!.id!,)),
                      );
                    },
                    label: const Text("إضافة تعليق"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    icon: const Icon(CupertinoIcons.chat_bubble_text_fill, color: Colors.white),
                  ),
                ],
              ),
              Divider(color: Colors.grey.withOpacity(0.3), thickness: 1, indent: 40, endIndent: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الخدمة',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 10),
                    buildField("نوع الخدمة", widget.student.service.name),
                    buildField("الجنس المطلوب", widget.student.gender),
                    buildField("العمر المطلوب", " ${widget.student.minAge.toString()} - ${widget.student.maxAge.toString()}"),
                    buildField("سعر الخدمة", widget.student.cost.toString()),
                    buildField("الوصف", widget.student.description),
                  ],
                ),
              ),
              Divider(color: Colors.grey.withOpacity(0.3), thickness: 1, indent: 40, endIndent: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                alignment: const Alignment(1, 0),
                child: const Text(
                  'الحجوزات',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              widget.student.schedule.isNotEmpty
                  ? Column(
                children: List.generate(
                  widget.student.schedule.length,
                      (index) {
                    final schedule = widget.student.schedule[index];
                    final scheduleId = schedule.id;
                    // استخدم الحالة المخزنة في الـ Map
                    bool isBooked = _bookingStatus[scheduleId] ?? false;
                    final formattedDate = DateFormat('EEEE, MMMM d, y').format(schedule.availableDate);
                    final formattedTime = '${schedule.availableTime.hour}:${schedule.availableTime.minute.toString().padLeft(2, '0')} ${schedule.availableTime.hour >= 12 ? 'PM' : 'AM'}';

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor.withOpacity(0.8),
                              AppColors.secondaryColor.withOpacity(0.8)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // زر الحجز
                              ElevatedButton(
                                onPressed: isBooked
                                    ? null
                                    : () {
                                  _showConfirmationDialog(formattedDate, formattedTime, scheduleId);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isBooked ? Colors.black12 : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: _loadingScheduleId == scheduleId
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryColor,
                                  ),
                                )
                                    : isBooked
                                    ? const Text(
                                  'تم الحجز',
                                  style: TextStyle(
                                    color: AppColors.backgroundColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                )
                                    : const Text(
                                  'حجز',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
                  : const Center(
                child: Text(
                  'لا توجد مواعيد متاحة',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchWhatsApp() async {
    final phoneNumber = studentDetails?.phoneNumber;
    final message = 'مرحبا! كيف حالك؟';
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'لا يمكن فتح WhatsApp';
    }
  }
}

Widget buildField(String label, String value) {
  return Wrap(
    children: [
      Text(
        label,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          letterSpacing: -.5,
        ),
      ),
      const SizedBox(width: 5),
      Text(
        value,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 15,
          letterSpacing: -.5,
        ),
      ),
    ],
  );
}
