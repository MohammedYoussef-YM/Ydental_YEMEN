import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ydental_application/Model/appointment_model.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/constant.dart';
import 'package:ydental_application/student/View/student_appointment_screen.dart';
import 'package:ydental_application/student/View/student_drawer.dart';
import 'main_cases_screen.dart';
import 'patient_screen.dart';
import 'today_appointment_screen.dart';
import 'visit_screen.dart';

class Home extends StatefulWidget {
  final StudentData student;

  const Home({super.key, required this.student});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Appointment appointment;
  var total;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future.microtask(() => getTodaysVisitCount(widget.student.id!));
  }
  Future<Map<String, dynamic>> getTodaysVisitCount(int studentId) async {
    final String apiUrl = '$api_local/visits/today/count?student_id=$studentId';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        total= data['data'];
        setState(() {
          _isLoading = false;
        });
        return data; // Return the parsed data
      } else {
        // Handle error
        _isLoading = false;
        return Future.error('Failed to load visits count'); // Throw an error
      }
    } catch (e) {
      print('Error: $e');
      _isLoading = false;
      return Future.error('An error occurred'); // Throw an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Scaffold(
            drawer:StudentDrawer(),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    height: 150,
                  ),
                ]),
              ),
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "مرحبا, ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "  ${widget.student.name}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TodayAppointment(student: widget.student),
                            ));
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Colors.white,
                              size: 30),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                " مواعيد اليوم "
                                ,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                "${total?['total']} ميعاد "
                                ,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2, // Number of items in each row
                      padding: const EdgeInsets.all(8.0),
                      children: [
                        GridItem(
                          icon: Icons.manage_accounts,
                          text: 'ادارة الحالات',
                          onTap: () => _navigateToPage(context, const MainCases()),
                        ),
                        GridItem(
                          icon: Icons.people,
                          text: 'المرضى',
                          onTap: () => _navigateToPage(context, PatientScreen(student: widget.student.id!)),
                        ),
                        GridItem(
                          icon: Icons.calendar_month_outlined,
                          text: 'الحجوزات',
                          onTap: () =>
                              _navigateToPage(context, const StudentAppointmentScreen(patientId:0)),
                        ),
                        GridItem(
                          icon: Icons.bar_chart,
                          text: 'الزيارات',
                          onTap: () => _navigateToPage(context, VisitScreen(student: widget.student)),
                        ),
                        // You can add more GridItems if needed
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class GridItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const GridItem({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shadowColor: Colors.grey,
        surfaceTintColor: AppColors.secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)
        ),
        margin: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50.0,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 8.0),
            Text(
              text,
              style: const TextStyle(fontSize: 18.0),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
