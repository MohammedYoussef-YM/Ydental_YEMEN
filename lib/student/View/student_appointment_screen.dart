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
import 'Widget/list_of_appointment.dart';
import 'add_visit.dart';

class StudentAppointmentScreen extends StatefulWidget {
  final int patientId;
  const StudentAppointmentScreen({
    super.key, required this.patientId,
  });

  @override
  State<StudentAppointmentScreen> createState() => _StudentAppointmentScreenState();
}

class _StudentAppointmentScreenState extends State<StudentAppointmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Appointment> allAppointments = [];
  bool isLoading = true;
  StudentData? userData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadStudentData(); // تحميل بيانات المريض أولاً

    if (userData != null) {
      await fetchAppointments(); // ثم تحميل المواعيد
    }

    setState(() {});
  }

  Future<void> _loadStudentData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? studentJson = prefs.getString('student');

      if (studentJson != null) {
        final studentData = jsonDecode(studentJson) as Map<String, dynamic>;
        setState(() => userData = StudentData.fromJson(studentData));

      }
    } catch (e) {
      print('Error loading student data: $e');
    }
  }

  Future<void> fetchAppointments() async {
    if (userData == null) {
      return;
    }
    final studentId = userData!.id;
    final String apiUrl;
    if (widget.patientId == 0) {
      apiUrl = "$api_local/appointments/?student_id=$studentId";
    } else {
      apiUrl = "$api_local/appointments/?student_id=$studentId&patient_id=${widget.patientId}";
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse["data"] as List? ?? [];

        final appointmentsList = data.map<Appointment>((appointmentJson) {
          final student = appointmentJson["student"] as Map<String, dynamic>? ?? {};
          final patientData = appointmentJson["patient"] as Map<String, dynamic>? ?? {};
          final caseData = appointmentJson["thecase"] as Map<String, dynamic>? ?? {};

          return Appointment(
            appointment_id: (appointmentJson["id"] as num?)?.toInt() ?? 0,
            patient: Patient(
              id: (patientData["id"] as num?)?.toInt() ?? 0,
              name: patientData["name"] as String? ?? 'Unknown Patient',
            ),
            appointment_date: _parseDateTime(appointmentJson["created_at"]), // Assuming _parseDateTime is defined
            appointment_time: _parseDateTime(appointmentJson["created_at"]), // Assuming _parseDateTime is defined
            status: getStatusFromString(appointmentJson["status"] as String? ?? ''), // Assuming getStatusFromString is defined
            case1: MyCasesModel(
              id: (caseData["id"] as num?)?.toInt() ?? 0, // Use data from thecase
              description: caseData["description"] as String? ?? 'Unknown Case',
              procedure: caseData["procedure"] as String? ?? 'N/A',
              gender: caseData["gender"] as String? ?? 'N/A',
              cost: (caseData["cost"] as num?)?.toDouble() ?? 0.0, // Cast to double
              schedule: (caseData["schedules"] as List?)?.map((scheduleJson) => Schedule.fromJson(scheduleJson)).toList() ?? [Schedule(availableDate: DateTime.now(), availableTime: TimeOfDay.now(), id: 1)],
              minAge: (caseData["min_age"] as num?)?.toInt() ?? 0,
              maxAge: (caseData["max_age"] as num?)?.toInt() ?? 0,
              studentId: (caseData["student_id"] as num?)?.toInt() ?? 0,
              serviceId: (caseData["service_id"] as num?)?.toInt() ?? 0,
              scheduleId: 0, // Or get from the caseData if available
              service: Service(id: 0, name: 'Unknown Service', icon: ''),
              studentName: student["name"] as String? ?? 'Unknown Student', // Use student data
              studentImage: '', // Add if available
            ),
            studentData: StudentData(
              id: (student["id"] as num?)?.toInt() ?? 0,
              name: student["name"] as String? ?? 'Unknown Student',
            ),
            case_id: appointmentJson["thecase_id"],
          );
        }).toList(); // Convert to List<Appointment>

        setState(() {
          allAppointments = appointmentsList; // Assign the List<Appointment>
          isLoading = false;
        }); // Remove the extra setState
      }
    } catch (error) {
      setState(() => isLoading = false);
      print("Error fetching appointments: $error"); // Print the error for debugging
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
      print('Error updating appointment: $e');
      setState(() => isLoading = false);
      return false;
    }
  }

// دالة تأكيد الحجز المحدثة
  Future<void> confirmAppointment(BuildContext context, Appointment appointment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.done_all_outlined,
            color: AppColors.secondaryColor,
            size: 40,
          ),
          title: const Text('تأكيد الحجز'),
          content: Text(
            ' هل أنت متأكد من تأكيد هذا الحجز مع :${appointment.patient.name} ؟ ',
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
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text(
                'نعم',
                style: TextStyle(
                  color: AppColors.secondaryColor,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await _updateAppointmentStatus(appointment, 'مؤكد');
      if (success) {
        setState(() => appointment.status = AppointmentStatus.confirmed);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تحديث الحالة')),
        );
      }
    }
  }

// دالة اكتمال الحجز مع رسالة التأكيد
  Future<void> completeAppointment(BuildContext context, Appointment appointment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.secondaryColor,
            size: 40,
          ),

          title: const Text('اكتمال الموعد'),
          content: Text(
            '  هل أنت متأكد من اكتمال هذا الموعد مع : ${appointment.patient.name}  أم ترغب بإضافة زيارة ؟  ',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'إضافة زيارة',
                style: TextStyle(
                  color: AppColors.secondaryColor,

                ),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                     builder: (context) =>
                         AddVisit(appointmentId: appointment.appointment_id, patientId: appointment.patient.id!, student: userData!.id!, patientName: appointment.patient.name!),
                   )
                );
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
      final success = await _updateAppointmentStatus(appointment, 'مكتمل');
      if (success) {
        setState(() => appointment.status = AppointmentStatus.completed);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تحديث الحالة')),
        );
      }
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
          const SnackBar(content: Text('فشل في تحديث الحالة')),
        );
      }
    }
  }

  // دالة إعادة الحجز الحجز مع رسالة التأكيد
  Future<void> rescheduleAppointment(BuildContext context, Appointment appointment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.refresh_outlined,
            color: AppColors.secondaryColor,
            size: 40,
          ),

          title: const Text('إعادة تأكيد الحجز'),
          content: const Text(
            ' هل ترغب بإعادة تأكيد هذا الحجز ؟ ',
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
      final success = await _updateAppointmentStatus(appointment, 'مؤكد');

      if (success) {
        setState(() => appointment.status = AppointmentStatus.confirmed);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تحديث الحالة')),
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
      ),
      body: SafeArea(
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
                      isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
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
                      "اسم المريض : ${appointment.patient.name}",
                      style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: -.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Row(
                      children: [
                        const Text("الاجراء : ",
                          style: TextStyle(letterSpacing: 0),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          appointment.case1.procedure,
                          style: const TextStyle(letterSpacing: 0),
                        ),
                      ],
                    ),
                    const SizedBox(width: 25),
                    Row(
                      children: [
                        const Text("الجنس : ",
                          style: TextStyle(letterSpacing: 0),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          appointment.case1.gender,
                          style: const TextStyle(letterSpacing: 0),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Divider(color: Colors.grey[350]),
                const SizedBox(height: 6),
                Column( // Use a Column to hold all the rows and dividers
                children: appointment.case1.schedule.map((schedule) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              const Icon(size: 16, Icons.calendar_month, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(
                                DateFormat("d/MM/y").format(schedule.availableDate),
                                style: const TextStyle(letterSpacing: 0),
                              ),
                            ],
                          ),
                          const SizedBox(width: 25),
                          Row(
                            children: [
                              const Icon(size: 16, Icons.access_time_filled, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(
                                DateFormat('jm').format(
                                  DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    schedule.availableTime.hour,
                                    schedule.availableTime.minute,
                                  ),
                                ),
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
                      if (appointment.case1.schedule.indexOf(schedule) < appointment.case1.schedule.length - 1) // Divider after each item EXCEPT the last
                        Divider(color: Colors.grey[350]),
                    ],
                  );
                }).toList(),
              ),
                const SizedBox(height: 6),
                Divider(color: Colors.grey[350]),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (appointment.status == AppointmentStatus.upcoming)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => confirmAppointment(context, appointment),
                        child: const Text('تأكيد الحجز'),
                      ),
                    const SizedBox(width: 10),
                    if (appointment.status == AppointmentStatus.upcoming)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          foregroundColor: Colors.black54,
                        ),
                        onPressed: () => cancelAppointment(context, appointment),
                        child: const Text('إلغاء الحجز'),
                      ),
                    if (appointment.status == AppointmentStatus.confirmed)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => completeAppointment(context, appointment),
                        child: const Text('تم اكتمال الموعد'),
                      ),
                    if (appointment.status == AppointmentStatus.cancelled)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => rescheduleAppointment(context, appointment),
                        child: const Text('إعادة تأكيد الحجز'),
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
