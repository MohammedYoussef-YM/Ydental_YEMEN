import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydental_application/Model/appointment_model.dart';
import 'package:ydental_application/Model/cases_model.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/Model/schedule_model.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/constant.dart';
import 'package:http/http.dart' as http;

class PatientAppointmentScreen extends StatefulWidget {
  const PatientAppointmentScreen({
    super.key,
  });

  @override
  State<PatientAppointmentScreen> createState() => _PatientAppointmentScreenState();
}

class _PatientAppointmentScreenState extends State<PatientAppointmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Appointment> allAppointments = [];
  bool isLoading = true;
  Patient? patient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadPatientData(); // تحميل بيانات المريض أولاً

    if (patient != null) {
      await fetchAppointments(); // ثم تحميل المواعيد
    }
    setState(() {});
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

  Future<void> fetchAppointments() async {
    if (patient == null) {
      return;
    }

    final patientId = patient!.id;

    final String apiUrl = "$api_local/appointments/?patient_id=$patientId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse["data"] as List? ?? [];

        final casesList = await MyCasesModel.fetchAllCases(patientId);

        setState(() {
          allAppointments = data.map<Appointment>((appointmentJson) {
            final student = appointmentJson["student"] as Map<String, dynamic>? ?? {};
            final patientData = appointmentJson["patient"] as Map<String, dynamic>? ?? {};

            return Appointment(
              appointment_id: (appointmentJson["id"] as num?)?.toInt() ?? 0,
              patient: Patient(
                id: (patientData["id"] as num?)?.toInt() ?? 0,
                name: patientData["name"] as String? ?? 'Unknown Patient',
              ),
              appointment_date: _parseDateTime(appointmentJson["created_at"]),
              appointment_time: _parseDateTime(appointmentJson["created_at"]),
              status: getStatusFromString(appointmentJson["status"] as String? ?? ''),
              case1: casesList.firstWhere(
                    (c) => c.id == (appointmentJson["thecase_id"] as num?)?.toInt(),
                orElse: () => MyCasesModel(
                  id: -1,
                  description: 'Unknown Case',
                  procedure: 'N/A',
                  gender: 'N/A',
                  cost: 0,
                  schedule: [ // Wrap in a list
                    Schedule(
                      availableDate: DateTime.now(),
                      availableTime: TimeOfDay.now(),
                      id: 1,isBooking:false
                    ),
                  ],
                  minAge: 0,
                  maxAge: 0,
                  studentId: 0,
                  serviceId: 0,
                  scheduleId: 0,
                  service: Service(id: 0, name: 'Unknown Service', icon: ''),
                  studentName: 'Unknown Student',
                  studentImage: '',
                ),
              ),
              studentData: StudentData(
                id: (student["id"] as num?)?.toInt() ?? 0,
                name: student["name"] as String? ?? 'Unknown Student',
              ), case_id: appointmentJson["thecase_id"],
              schedule: appointmentJson["schedule"]??Schedule(id: 1, isBooking: false, availableDate: DateTime.now(), availableTime: TimeOfDay.now()),
            );
          }).toList();

          isLoading = false;
        });
      }
    } catch (error) {
      setState(() => isLoading = false);
    }
  }

  DateTime _parseDateTime(dynamic dateString) {
    try {
      return DateTime.parse(dateString as String);
    } catch (e) {
      return DateTime.now();
    }
  }

  AppointmentStatus getStatusFromString(String status) {
    switch (status) {
      case "مؤكد":
        return AppointmentStatus.confirmed;
      case "مكتمل":
        return AppointmentStatus.completed;
      case "ملغي":
        return AppointmentStatus.cancelled;
      case "بانتظار التأكيد": // إضافة الحالة الجديدة
        return AppointmentStatus.upcoming;
      default:
        return AppointmentStatus.upcoming;
    }
  }

// دالة مساعدة لتحديث الحالة للحجز على الخادم
  Future<bool> _updateAppointmentStatus(Appointment appointment, String newStatus) async {
    try {
      setState(() => isLoading = true);
      final response = await http.put(
        Uri.parse('$api_local/appointments/${appointment.appointment_id}/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': newStatus,
          // يمكن إضافة باقي الحقول إذا يحتاج الخادم لها
          'patient_id': appointment.patient.id,
          'student_id': appointment.studentData?.id,
          'thecase_id': appointment.case_id,
        }),
      );
      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);
        appointment.status = getStatusFromString(updatedData['status']);
        setState(() => isLoading = false);
        return true;
      }
      isLoading = false;
      return false;
    } catch (e) {
      setState(() => isLoading = false);
      return false;
    }
  }

// دالة إلغاء الحجز مع رسالة التأكيد
  Future<void> cancelAppointment(BuildContext context, Appointment appointment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.cancel,
            size: 40,
            color: AppColors.errorColor,
          ),

          title: const Text('إلغاء الحجز'),
          content: const Text(
            ' هل أنت متأكد من  رغبتك بإلغاء هذا الحجز ؟ ',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'لا',
                style: TextStyle(
                  color: AppColors.secondaryColor,

                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                'نعم',
                style: TextStyle(
                  color: AppColors.secondaryColor,

                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await _updateAppointmentStatus(appointment, 'ملغي');
      if (success) {
        setState(() => appointment.status = AppointmentStatus.cancelled);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحديث الحالة')),
        );
      }
    }
  }

  List<Appointment> getAppointmentsByStatus(AppointmentStatus status) {
    return allAppointments.where((a) => a.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Center(
            child: Text('قائمة الحجوزات',style:
            TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -.4,
            )
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: TabBar(
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelPadding: EdgeInsets.zero,
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            labelColor: Colors.white,
                            indicator: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            controller: _tabController,
                            tabs: [
                              ...List.generate(
                                tabs.length,
                                    (index) => Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                                  child: Tab(
                                    text: tabs[index],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: TabBarView(

                          controller: _tabController,
                          children: [
                            //حجوزات بانتظار التأكيد
                            _buildAppointmentList(AppointmentStatus.upcoming),
                            _buildAppointmentList(AppointmentStatus.confirmed),
                            _buildAppointmentList(AppointmentStatus.completed),
                            _buildAppointmentList(AppointmentStatus.cancelled),
                          ],
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
    );
  }

  Widget _buildAppointmentList(AppointmentStatus status) {
    final appointments = getAppointmentsByStatus(status);

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          shadowColor: Colors.grey,
          surfaceTintColor: Colors.grey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "اسم الطالب : ${appointment.studentData?.name}",
                      style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: -.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Divider(color: Colors.grey[350]),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(size: 16, Icons.calendar_month, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat("d/MM/y").format(appointment.appointment_date),
                          style: const TextStyle(letterSpacing: -.5),
                        )
                      ],
                    ),
                    const SizedBox(width: 25),
                    Row(
                      children: [
                        const Icon(size: 16, Icons.access_time_filled, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('jm').format(appointment.appointment_time),
                          style: const TextStyle(letterSpacing: 0),
                        ),
                      ],
                    ),
                    const SizedBox(width: 25),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getStatusColor(appointment.status),
                          radius: 5,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _getStatusName(appointment.status),
                          style: const TextStyle(letterSpacing: 0),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (appointment.status == AppointmentStatus.confirmed)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          foregroundColor: Colors.black54,
                        ),
                        onPressed: () => cancelAppointment(context, appointment),
                        child: const Text('إلغاء الحجز'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دالة مساعدة للحصول على لون الحالة
  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return AppColors.errorColor;
      default:
        return Colors.grey;
    }
  }

// دالة مساعدة للحصول على اسم الحالة
  String _getStatusName(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return 'بانتظار التأكيد';
      case AppointmentStatus.confirmed:
        return 'مؤكدة';
      case AppointmentStatus.cancelled:
        return 'ملغية';
      case AppointmentStatus.completed:
        return 'مكتملة';
      default:
        return 'غير معروف';
    }
  }
}
