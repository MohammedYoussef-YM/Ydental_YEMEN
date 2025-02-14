import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ydental_application/Model/cases_model.dart';
import 'package:ydental_application/Model/city_model.dart';
import 'package:ydental_application/api/data.dart';
import 'package:ydental_application/city_Provider.dart';
import 'package:ydental_application/constant.dart';
import 'package:ydental_application/patint/View/Widget/list_of_student.dart';
import 'package:ydental_application/patint/View/patient_drawer.dart';
import '../../Model/category_model.dart';
import '../../colors.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen ({super.key});

  @override
  State<PatientHomeScreen > createState() => _MainCasesState();
}
class _MainCasesState extends State<PatientHomeScreen > {


  final _formKey = GlobalKey<FormState>();
  String searchQuery = '';
  String category = "";
  List<MyCasesModel> caseStudent = [];
  List<MyCasesModel> _originalCases = []; // Store the original, unfiltered list

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  int? _selectedServiceId;
  String? _selectedCityId;
  String? _selectedUniversityId;
  // String? _selectedCategory;
  String? _noMoreDataMessage; // Store the "no more data" message

  List<MyCasesModel> _cases = [];


  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ProfileProvider>(context, listen: false).fetchCities());
    _loadInitialData();
    _scrollController.addListener(_loadMore);
  }

  Future<void> _loadInitialData() async {
    _currentPage = 1; // Reset to page 1 for initial load
    _hasMore = true;  // Assume there's more data initially
    _noMoreDataMessage = null; // Clear any previous messages
    await _fetchCases();
  }

  Future<void> _fetchCases() async {
    if (_isLoading) return; // Prevent concurrent requests

    setState(() {
      _isLoading = true;
    });
    try {
      // Construct the API URL dynamically based on selected filters
      String apiUrl = '/thecases?';
      if (_selectedServiceId != null) {
        apiUrl += 'service_id=$_selectedServiceId&';
      }
      if (_selectedCityId != null) {
        apiUrl += 'city_id=$_selectedCityId&';
      }
      if (_selectedUniversityId != null) {
        apiUrl += 'university_id=$_selectedUniversityId&';
      }

      // Remove the trailing '&' if no filters are selected
      if (apiUrl.endsWith('&')) {
        apiUrl = apiUrl.substring(0, apiUrl.length - 1);
      }

      // Fetch data from the API
      final apiService = ApiService(api_local);
      final response = await apiService.get(apiUrl);
      if (response == null) throw Exception('Null API response');
      if (response['error'] != null) throw Exception(response['error']);

      final responseData = response['data'];
      if (responseData == null || responseData is! List) {
        _hasMore = false; // No more data if API response is not a list
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Parse the data
      final newCases = responseData
          .map<MyCasesModel?>((dynamic item) {
        try {
          return MyCasesModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          return null;
        }
      })
          .whereType<MyCasesModel>()
          .toList();

      setState(() {
       if (_currentPage == 1) { // Initial load
          _cases = newCases;
          _originalCases = List.from(newCases);
        } else { // Load more
          _cases.addAll(newCases);
        }
        _isLoading = false;
        if (!_hasMore && _cases.isNotEmpty) { // All data loaded
          _noMoreDataMessage = "لا يوجد بيانات أخرى"; // Set the message
        } else {
          _noMoreDataMessage = null; // Clear the message if there's more data
        }
      });
    } catch (e) {
      _hasMore = false; // Assume no more data on error
      _noMoreDataMessage = "حدث خطأ أثناء تحميل البيانات"; // Error message
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCitySelected(String? cityId) {
    setState(() {
      _selectedCityId = cityId;
      _selectedUniversityId = null; // Reset university when city changes
    });
    _loadInitialData(); // Fetch data with the new city filter
  }

  void _onUniversitySelected(String? universityId) {
    setState(() {
      _selectedUniversityId = universityId;
    });
    _loadInitialData(); // Fetch data with the new university filter
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _currentPage++;
      await _fetchCases();
    }
  }

  void filterByCategory(int? serviceId) {
    setState(() {
      _selectedServiceId = serviceId;
    });
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: PatientDrawer(),
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
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController, // Add the controller here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _searchField(),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: _formKey,
                              child: Consumer<ProfileProvider>(
                                builder: (context, provider, child) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'المدينة',
                                          focusedBorder: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          provider.updateCity(value); // Update selectedCity and universities list
                                          _onCitySelected(value); // Trigger data fetch
                                        },
                                        items: provider.cities.isNotEmpty
                                            ? provider.cities.map((city) {
                                          return DropdownMenuItem(
                                            value: city.id,
                                            child: Text(city.name),
                                          );
                                        }).toList()
                                            : [],
                                      ),
                                      const SizedBox(height: 20),
                                      DropdownButtonFormField<University>(
                                        decoration: const InputDecoration(
                                          labelText: 'الجامعة',
                                          focusedBorder: OutlineInputBorder(),
                                        ),
                                        items: provider.universities.map<DropdownMenuItem<University>>((university) {
                                          return DropdownMenuItem<University>(
                                            value: university,
                                            child: Text(university.name),
                                          );
                                        }).toList(),
                                        // value: provider.selectedUniversity,
                                        onChanged: (university) {
                                          provider.updateUniversity(university);
                                          _onUniversitySelected(university?.id.toString());                                        },
                                        validator: (value) => value == null ? 'ادخل جامعتك' : null,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "الخدمات",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: myCategories.length,
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

                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(10),
                                //   border: category == myCategories[index].name
                                //       ? Border.all(width: 2.5, color: AppColors.primaryColor)
                                //       : Border.all(color: Colors.transparent),
                                // ),
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
                                        const SizedBox(height: 40),
                                        Image.asset(
                                          myCategories[index].image,
                                          width: 30,
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      myCategories[index].name,
                                      style: const TextStyle(),
                                    ),
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
                      "الحالات (${_originalCases.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ...List.generate(
                          _originalCases.length,
                              (index) => Padding(
                            padding: index == 0
                                ? const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10)
                                : const EdgeInsets.only(right: 25, left: 25.0, top: 10.0, bottom: 10.0),
                            child: ListOfStudent(
                              caseStudent: _originalCases[index],
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
          ],
        ),
      ),
    );
  }

  Container _searchField() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0)
      ]),
      child: TextField(
        onChanged: searchCases,
        decoration: InputDecoration(
            filled: true,
            hintText: 'بحث عن حالة',
            hintStyle: const TextStyle( fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                'assets/Search.svg',
                alignment: Alignment.center,
              ),
            ),
            suffixIcon: SizedBox(
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
                borderSide: BorderSide.none)),
      ),
    );
  }

  void searchCases(String query) {
    List<MyCasesModel> suggestions; // No need to declare it 'final' here

    if (query.isEmpty) {
      suggestions = List.from(_originalCases); // Restore the original list
    } else {
      suggestions = _originalCases.where((casePatient) {
        final patientName = casePatient.procedure.toLowerCase();
        final input = query.toLowerCase();
        return patientName.startsWith(input);
      }).toList();
    }

    setState(() {
      _originalCases = suggestions; // Update _cases with the filtered or original list
    });
  }
}



