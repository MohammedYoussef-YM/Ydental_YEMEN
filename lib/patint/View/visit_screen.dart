import 'package:flutter/material.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/Model/visit_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/student/View/Widget/list_of_visit.dart';
import 'package:ydental_application/student/View/Widget/visit_services.dart';


class VisitPatientScreen extends StatefulWidget {
  final int patient ;
  const VisitPatientScreen({
    super.key, required this.patient,
  });

  @override
  State<VisitPatientScreen> createState() => _VisitPatientScreenState();
}
// visit_screen.dart
class _VisitPatientScreenState extends State<VisitPatientScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VisitService _visitService = VisitService();
  List<Visit> visits = [];
  bool isLoading = true;
  bool isCanceled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    try {
      final result = await _visitService.getPatientsVisits(widget.patient); // استبدل بالـ student_id الفعلي
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

  // ... بقية الدوال مثل completeVisit, cancelAppointment, etc.

  @override
  Widget build(BuildContext context) {
  List<Visit> getVisitsByStatus(VisitStatus status) {
      return visits
          .where((appointment) => appointment.status == status)
          .toList();
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('قائمة الزيارات',style:
            TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -.4,
            )
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
          child: Stack(
            children: [
              isCanceled
                  ? const Center(child: CircularProgressIndicator())
                  :  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                  ),
                  Expanded(
                    child: DefaultTabController(
                      length: 3,
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
                                controller: _tabController,
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelPadding: EdgeInsets.zero,
                                indicatorColor: primary,
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                labelColor: Colors.white,
                                indicator: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                tabs: [
                                  ...List.generate(
                                    visit_tabs.length,
                                    (index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      child: Tab(
                                        text: visit_tabs[index],
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
                                //زيارات غير مكتملة

                                //
                                ListOfVisit(
                                  visits: getVisitsByStatus(
                                      VisitStatus.uncompleted),
                                  buttonText: 'تم إكتمال الزيارة',
                                  cancelButtonText: 'إلغاء الزيارة',
                                ),
                                //زيارات مكتملة

                                ListOfVisit(
                                  visits:
                                      getVisitsByStatus(VisitStatus.completed),
                                ),
                                //زيارات تم الغاؤها

                                ListOfVisit(
                                  visits:
                                      getVisitsByStatus(VisitStatus.cancelled),
                                  buttonText: 'إعادة تأكيد الزيارة',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

      ),
    );
  }
}