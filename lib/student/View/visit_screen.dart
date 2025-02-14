import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/Model/visit_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/student/View/Widget/visit_services.dart';
import 'Widget/list_of_visit.dart';
import 'add_visit.dart';

class VisitScreen extends StatefulWidget {
  final StudentData student;

  const VisitScreen({
    super.key, required this.student,
  });

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}
// visit_screen.dart
class _VisitScreenState extends State<VisitScreen>
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
      final result = await _visitService.getVisits(widget.student.id!); // استبدل بالـ student_id الفعلي
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

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> completeVisit(BuildContext context, Visit visit) async {
    final bool? confirmed = await _showConfirmationDialog(context, visit);

    if (confirmed == true) {
      try {
        final updatedVisit = await _visitService.updateVisitStatus(
          visit,
          VisitStatus.completed,
        );

        setState(() {
          visits = visits.map((v) => v.id == updatedVisit.id ? updatedVisit : v).toList();
          _showSuccessSnackbar('تم اكتمال الحجز');
        });
      } catch (e) {
        _showErrorSnackbar('فشل في تحديث الحالة');
      }
    }
  }

  Future<void> cancelAppointment(BuildContext context, Visit visit) async {
    final bool? confirmed = await _showCancelDialog(context);
    if (confirmed == true) {
      setState(() => isCanceled = true);
      try {
        final updatedVisit = await _visitService.updateVisitStatus(
          visit,
          VisitStatus.cancelled,
        );
        setState(() {
          visits = visits.map((v) => v.id == updatedVisit.id ? updatedVisit : v).toList();
          _showSuccessSnackbar('تم الإلغاء بنجاح');
        });
      } catch (e) {
        _showErrorSnackbar('فشل في الإلغاء: $e');
      } finally {
        setState(() => isCanceled = false);
      }
    }
  }

  Future<void> rescheduleVisit(BuildContext context, Visit visit) async {
    final bool? confirmed = await _showRescheduleDialog(context);
    if (confirmed == true) {
      try {
        final updatedVisit = await _visitService.updateVisitStatus(
          visit,
          VisitStatus.uncompleted,
        );

        setState(() {
          visits = visits.map((v) => v.id == updatedVisit.id ? updatedVisit : v).toList();
          _showSuccessSnackbar('تم اعادة تاكيد الحجز');
        });
      } catch (e) {
        _showErrorSnackbar('فشل في تحديث الحالة');
      }
    }
  }

// داخل كلاس _VisitScreenState
  Future<bool?> _showConfirmationDialog(BuildContext context, Visit visit) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            color: AppColors.secondaryColor,
            Icons.check_circle_rounded,
            size: 40,
          ),
          title: const Text('اكتمال الزيارة'),
          content: Text(
            'هل أنت متأكد من اكتمال هذه الزيارة مع : ${visit.patientName} أم ترغب بإضافة زيارة أخرى ؟',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'إضافة زيارة',
                style: TextStyle(color: AppColors.secondaryColor),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVisit(
                      patientId: visit.patientId,student:widget.student.id!,
                      appointmentId: visit.appointmentId, patientName: visit.patientName),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text(
                'نعم',
                style: TextStyle(color: AppColors.secondaryColor),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showCancelDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.cancel,
            size: 40,
            color: AppColors.errorColor,
          ),
          title: const Text('إلغاء الزيارة'),
          content: const Text(
            'هل أنت متأكد من رغبتك بإلغاء هذه الزيارة ؟',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'لا',
                style: TextStyle(color: AppColors.secondaryColor),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                'نعم',
                style: TextStyle(color: AppColors.secondaryColor),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showRescheduleDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            color: AppColors.secondaryColor,
            Icons.refresh_outlined,
            size: 40,
          ),
          title: const Text('إعادة تأكيد الزيارة'),
          content: const Text(
            'هل ترغب بإعادة تأكيد هذه الزيارة ؟',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'لا',
                style: TextStyle(color: AppColors.secondaryColor),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                'نعم',
                style: TextStyle(color: AppColors.secondaryColor),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
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
                                  onClick: (visit) =>
                                      completeVisit(context, visit),
                                  buttonText: 'تم إكتمال الزيارة',
                                  onCancel: (visit) => cancelAppointment(context, visit),
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
                                  onClick: (visit) =>
                                      rescheduleVisit(context, visit),
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