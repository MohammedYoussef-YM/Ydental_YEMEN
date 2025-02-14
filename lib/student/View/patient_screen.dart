import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ydental_application/Model/patient_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/constant.dart';
import 'Widget/list_of_patient.dart';
import 'package:http/http.dart' as http;

class PatientScreen extends StatefulWidget {
  final int student;

  const PatientScreen({super.key, required this.student});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  List<Patient> patients = [];
  List<Patient> _originalPatient = []; // Store the original, unfiltered list
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingStudentData  = true;
  bool isLoading = true;
  bool _hasMore = true;
  String? _noMoreDataMessage;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchPatients(widget.student);
    _scrollController.addListener(_loadMore);

  }
  Future<void> _loadMore() async {
    if (isLoading || !_hasMore) return;

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _currentPage++;
      await _fetchPatients(widget.student);
    }
  }

  Future<void> _fetchPatients(int? studentId) async {
    setState(() {
      _currentPage = 1; // Reset to page 1 for initial load
      _hasMore = true;  // Assume there's more data initially
      _noMoreDataMessage = null; // Clear any previous messages
       isLoading = true;
    });
    try {

      final url = Uri.parse('$api_local/students/$studentId/patients');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        patients = (data['patients'] as List)
            .map((patientJson) => Patient.fromJson(patientJson))
            .toList();
        // _originalPatient = List.from(patients); // Copy the fetched data to _originalPatient

          if (_currentPage == 1) { // Initial load
            // _cases = newCases;
            _originalPatient = List.from(patients);
          } else { // Load more
            patients.addAll(patients);
          }
          isLoading = false;
          if (!_hasMore && patients.isNotEmpty) { // All data loaded
            _noMoreDataMessage = "لا يوجد بيانات أخرى"; // Set the message
          } else {
            _noMoreDataMessage = null; // Clear the message if there's more data
          }
      });
    } else {
      _hasMore = false; // Assume no more data on error
      _noMoreDataMessage = "حدث خطأ أثناء تحميل البيانات"; // Error message
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load patients'),
        ),
      );
    }
    } catch (e) {
      _hasMore = false; // Assume no more data on error
      _noMoreDataMessage = "حدث خطأ أثناء تحميل البيانات"; // Error message
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        _isLoadingStudentData = false; // Hide loading indicator after all data is fetched or an error occurs
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: const Center(
                  child: Text(
                    "قائمة المرضى",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -.4,
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              _isLoadingStudentData
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _searchField(),
                      const SizedBox(height: 20),
                      ...List.generate(
                        patients.length,
                            (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: ListOfPatient(
                            patient: patients[index],
                            student:widget.student
                          ),
                        ),
                      ),
                      isLoading && _hasMore // Show loading only if loading AND there's more data
                          ? const Center(child: CircularProgressIndicator())
                          : Container(), // Empty container if not loading

                      if (_noMoreDataMessage != null) // Show message if available
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _noMoreDataMessage!,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _searchField() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: TextField(
        onChanged: searchPatient,
        decoration: InputDecoration(
          filled: true,
          hintText: 'بحث عن مريض',
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/Search.svg',
              alignment: Alignment.center,
            ),
          ),
          suffixIcon: Container(
            width: 100,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const VerticalDivider(
                    color: Colors.black,
                    indent: 10,
                    endIndent: 10,
                    thickness: 0.1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset('assets/Filter.svg'),
                  ),
                ],
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void searchPatient(String query) {
    List<Patient> suggestions; // No need to declare it 'final' here

    if (query.isEmpty) {
      suggestions = List.from(_originalPatient); // Restore the original list
    } else {
      suggestions = _originalPatient.where((patient) {
        final patientName = patient.name!.toLowerCase();
        final input = query.toLowerCase();
        return patientName.startsWith(input);
      }).toList();
    }

    setState(() {
      patients = suggestions; // Update _cases with the filtered or original list
    });
  }

}