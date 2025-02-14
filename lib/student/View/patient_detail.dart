import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/student/View/student_appointment_screen.dart';
import 'add_visit.dart';

class PatientDetail extends StatefulWidget {
  final Patient patient;
  final int student;

  const PatientDetail({
    super.key,
    required this.patient, required this.student,
  });

  @override
  State<PatientDetail> createState() => _PatientDetailState();
}

class _PatientDetailState extends State<PatientDetail> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Center(
            child: Text(
              'تفاصيل المريض',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -.4,
              ),
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildPatientCard(),
                const SizedBox(height: 20),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage('assets/patient_image.jpg'),
            ),
            const SizedBox(height: 16),
            Text(
              widget.patient.name ?? 'اسم المريض',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.whatsapp),
              color: Colors.green,
              onPressed: _launchWhatsApp,
            ),
            const Divider(),
            _buildPatientInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'بيانات المريض الشخصية:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('النوع:', widget.patient.gender ?? 'غير محدد'),
          _buildInfoRow('تاريخ الميلاد:', "${widget.patient.dateOfBirth}" ?? 'غير محدد'),
          _buildInfoRow('البريد الإلكتروني:', widget.patient.email ?? 'غير محدد'),
          _buildInfoRow('رقم الهاتف:', widget.patient.phoneNumber ?? 'غير محدد'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // _buildButton(
            //   icon: CupertinoIcons.calendar_badge_plus,
            //   label: 'إضافة زيارة',
            //   color: AppColors.primaryColor,
            //   onPressed: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => AddVisit(patient: widget.patient,student:widget.student),
            //     ),
            //   ),
            // ),
            const SizedBox(width: 16),
            _buildButton(
              icon: Icons.calendar_today,
              label: 'الحجوزات',
              color: Colors.white70,
              textColor: Colors.black54,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentAppointmentScreen(patientId: widget.patient.id!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      onPressed: onPressed,
    );
  }

  void _launchWhatsApp() async {
    final phoneNumber = widget.patient.phoneNumber;
    const message = 'مرحبا! كيف حالك؟';
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'لا يمكن فتح WhatsApp';
    }
  }
}