import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ydental_application/Model/cases_model.dart';
import 'package:ydental_application/Model/category_model.dart';
import 'package:ydental_application/api/data.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/constant.dart';
import '../../Model/student_model.dart';
import 'Widget/cases_Items.dart';
import 'case_form_screen.dart';
import 'package:http/http.dart' as http;


class MainCases extends StatefulWidget {
  const MainCases({super.key});

  @override
  State<MainCases> createState() => _MainCasesState();
}
class _MainCasesState extends State<MainCases> {
  String category = "";
  List<CategoryModel> casesCategoryModel = [];
  List<MyCasesModel> _cases = [];
  List<MyCasesModel> _originalCases = []; // Store the original, unfiltered list
  List<CategoryModel> services = [];

  final ScrollController _scrollController = ScrollController();
  int? _selectedServiceId;
  int? categoryId;
  StudentData? userData;
  int _currentPage = 1;
  bool _isLoading = true;
  bool _isLoadingStudentData  = true;
  bool _hasMore = true;
  String? _noMoreDataMessage; // Store the "no more data" message

  @override
  void initState() {
    super.initState();
    _loadData(); // Call the combined data loading function
    _scrollController.addListener(_loadMore);
  }
  Future<void> _loadData() async {
    try {
      await _loadStudentData(); // Then load student data (which loads cases)
      await _fetchCategories(); // Fetch categories first
      _currentPage = 1; // Reset to page 1 for initial load
      _hasMore = true;  // Assume there's more data initially
      _noMoreDataMessage = null; // Clear any previous messages
    } catch (e) {
      // Handle the error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' خطا في تحميل البيانات: $e')),
      );
    }
  }

  /// **جلب الخدمات من الـ API**
  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse("$api_local/services")); // Corrected URL
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse["data"];

        casesCategoryModel = data.map((categoryJson) => CategoryModel.fromJson(categoryJson)).toList();
         _loadInitialData();
      } else {
        // Handle error, e.g., show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا في تحميل البيانات : ${response.statusCode}')),
        );
      }
    } catch (error) {
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('  :خطا في الاتصال مع السيرفر : $error')),
      );
    }
  }

  // Add this method to reload data
  Future<void> _reloadData() async {
    await _loadInitialData(); // Call your existing data loading function
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _currentPage++;
      await _loadInitialData();
    }
  }

  Future<void> _loadStudentData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? studentJson = prefs.getString('student');

      if (studentJson != null) {
        final studentData = jsonDecode(studentJson) as Map<String, dynamic>;
        setState(() => userData = StudentData.fromJson(studentData));
        // await _loadInitialData();
      }
    } catch (e) {
      print('خطا في تحميل البيانات : $e');
    }
  }

  Future<void> _loadInitialData() async {
    // if (_isLoading) return; // Prevent concurrent requests
    setState(() {
      _isLoading = true;
    });
    try {
      // Construct the API URL dynamically based on selected filters
      String apiUrl = '/thecases?';
      if (_selectedServiceId != null) {
        apiUrl += 'service_id=$_selectedServiceId&';
      }
      if (userData!.id != null) {
        apiUrl += 'student_id=${userData!.id} ';
      }

      // Fetch data from the API
      final apiService = ApiService(api_local);
      final response = await apiService.get(apiUrl);

      if (response == null) throw Exception('Null API response');
      if (response['error'] != null) throw Exception(response['error']);

      final responseData = response['data'];
      if (responseData == null || responseData is! List) {
        return;
      }

      // Parse the data
      _cases = responseData.map<MyCasesModel?>((dynamic item) {
        try {
          return MyCasesModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          return null;
        }
      })
          .whereType<MyCasesModel>()
          .toList();
      // setState(() {
        if (_currentPage == 1) { // Initial load
          // _cases = newCases;
          _originalCases = List.from(_cases);
        } else { // Load more
          _cases.addAll(_cases);
        }
        _isLoading = false;
        if (!_hasMore && _cases.isNotEmpty) { // All data loaded
          _noMoreDataMessage = "لا يوجد بيانات أخرى"; // Set the message
        } else {
          _noMoreDataMessage = null; // Clear the message if there's more data
        }
      // });
    } catch (e) {
      _hasMore = false; // Assume no more data on error
      _noMoreDataMessage = "حدث خطأ أثناء تحميل البيانات"; // Error message
      setState(() {
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoadingStudentData = false; // Hide loading indicator after all data is fetched or an error occurs
      });
    }
  }

  void filterByCategory(int? serviceId) async{
    setState(() {
      _isLoadingStudentData = true;
      _selectedServiceId = serviceId;
    });
   await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('إدراة الحالات',style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -.4,
            )),
          ), // Set the title of the AppBar
          backgroundColor: Colors.transparent,
          elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
          color: AppColors.primaryColor,
        ),
        onPressed: (){
          Navigator.pop(context);
        },
      ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add,
                color: AppColors.primaryColor,
              ),
              onPressed: () {
                // Navigate to the second page when the search button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CaseForm(userData: userData)),
                );
              },
            ),

          ],
        ),
        body: SafeArea(
          child: Stack(
            children:[
              _isLoadingStudentData
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    controller: _scrollController, // Add the controller here
                child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                   const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "الحالات",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height:10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: casesCategoryModel.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                filterByCategory(myCategories[index].id);
                              },
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: _selectedServiceId == myCategories[index].id
                                      ? Border.all(width: 2.5, color: AppColors.primaryColor)
                                      : Border.all(color: Colors.transparent),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        Container(
                                          height: 5,
                                          width: 47,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryColor.withOpacity(0.9),
                                                offset: const Offset(0, 10),
                                                blurRadius: 25,
                                                spreadRadius: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height:40 ,),
                                        Image.asset(
                                          myCategories[index].image,
                                          width: 30,
                                          fit: BoxFit.cover,
                                        )
                                      ],
                                    ),
                                    // const SizedBox(height: 10),
                                    Text(
                                      myCategories[index].name,
                                      style: const TextStyle(
                                        // fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "النتائج (${_originalCases.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ...List.generate(
                          _originalCases.length,
                          (index) => Padding(
                            padding: index == 0
                                ? const EdgeInsets.only(left: 25, right: 25,top: 10,bottom: 10)
                                : const EdgeInsets.only(right: 25,left: 25.0,top: 10.0,bottom: 10.0),
                            child: CasesItems(
                              caseModel: _originalCases[index],
                              onCaseUpdated: _reloadData, // Pass the reload function
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  _isLoading && _hasMore // Show loading only if loading AND there's more data
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

            ]),
        ),
      ),
    );
  }
}
