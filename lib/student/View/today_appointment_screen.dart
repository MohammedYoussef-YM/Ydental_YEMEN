import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ydental_application/Model/appointment_model.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/Model/visit_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/student/View/Widget/visit_services.dart';

class TodayAppointment extends StatefulWidget {
  final StudentData student;
  final Function(Visit)? onClick;
  final String? buttonText;
  final Function(Visit)? onCancel;
  final String? cancelButtonText;

  const TodayAppointment({
    super.key,
    this.onClick,
    this.buttonText,
    this.onCancel,
    this.cancelButtonText,
    required this.student,
  });

  @override
  State<TodayAppointment> createState() => _TodayAppointmentState();
}

class _TodayAppointmentState extends State<TodayAppointment> {
  final VisitService _visitService = VisitService();
  List<Visit> visits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    try {
      final result = await _visitService
          .getTodayVisits(widget.student.id!); // استبدل بالـ student_id الفعلي
      setState(() {
        visits = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackbar('فشل في تحميل البيانات');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    String getStatusName(VisitStatus status) { // Use VisitStatus here
      switch (status) {
        case VisitStatus.upcoming:
          return 'بانتظار التأكيد';
        case VisitStatus.uncompleted:
          return 'مؤكدة';
        case VisitStatus.cancelled:
          return 'ملغية';
        case VisitStatus.completed:
          return 'مكتملة';
        default:
          return 'Unknown';
      }
    }

    Color getStatusColor(VisitStatus status) { // Use VisitStatus here
      switch (status) {
        case VisitStatus.upcoming:
          return Colors.blue;
        case VisitStatus.uncompleted:
          return Colors.blue;
        case VisitStatus.cancelled:
          return AppColors.errorColor;
        case VisitStatus.completed:
          return Colors.green;
        default:
          return Colors.grey; // Fallback color
      }
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Center(
          child: Text(
            "قائمة حجوزات اليوم",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -.4,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading // Show loading indicator if _isLoading is true
          ? const Center(child: CircularProgressIndicator()) // Center the indicator
          : SafeArea(
        child: ListView.builder(
          itemCount: visits.length,
          itemBuilder: (context, index) {
            final appointment = visits[index];

            return Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shadowColor: Colors.grey,
                surfaceTintColor: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              " اسم المريض :  ${appointment.patientName}",
                              style: const TextStyle(
                                fontSize: 16,
                                letterSpacing: -.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'الاجراء : ${appointment.procedure}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                letterSpacing: -.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Divider(
                      color: Colors.grey[350],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              size: 16,
                              Icons.calendar_month,
                              color: grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              DateFormat("d/MM/y")
                                  .format(appointment.visitDate),
                              style: const TextStyle(
                                letterSpacing: -.5,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(width: 25),
                        Row(
                          children: [
                            const Icon(
                              size: 16,
                              Icons.access_time_filled,
                              color: grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              DateFormat('jm').format(appointment.visitDate),
                              style: const TextStyle(
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 25),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const SizedBox(width: 25),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: getStatusColor(appointment.status),
                                  radius: 5,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  getStatusName(appointment.status),
                                  style: const TextStyle(
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (widget.buttonText != null &&
                                widget.onClick != null) ...[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => widget.onClick!(appointment),
                                child: Text(widget.buttonText!),
                              ),
                              const SizedBox(width: 10),
                            ],
                            if (widget.cancelButtonText != null &&
                                widget.onCancel != null) ...[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white70,
                                  foregroundColor: Colors.black54,
                                ),
                                onPressed: () => widget.onCancel!(appointment),
                                child: Text(widget.cancelButtonText!),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ]),
                ));
          },
        ),
      ),
    );
  }
}
