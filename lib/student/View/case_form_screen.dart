import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ydental_application/Model/cases_model.dart';
import 'package:ydental_application/Model/schedule_model.dart';
import 'package:ydental_application/Model/student_model.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/constant.dart';
import '../../Model/category_model.dart';
import 'package:http/http.dart' as http;


class CaseForm extends StatefulWidget {
  final MyCasesModel? caseModel;
  final StudentData? userData;
  final VoidCallback? onCaseSaved; // Callback for successful save/update

  const CaseForm({super.key, this.caseModel, this.userData, this.onCaseSaved});

  @override
  State<CaseForm> createState() => _CaseFormState();
}

class _CaseFormState extends State<CaseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _procedureController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();
  final List<TextEditingController> dateControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> timeControllers = List.generate(3, (_) => TextEditingController());

   List<Schedule> schedules = [
    Schedule(availableDate: DateTime.now(), availableTime: TimeOfDay.now(), id: 1,isBooking:false),
    // Schedule(availableDate: DateTime.now(), availableTime: TimeOfDay.now(), id: 1),
    // Schedule(availableDate: DateTime.now(), availableTime: TimeOfDay.now(), id: 1)
  ]; // List of 3 schedules

  String dateErrorMessage = '';
  String? _gender;
  String? _genderError;
  int? minAge;
  int? maxAge;
  CategoryModel? selectedCategory;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.caseModel != null) {
      _initializeFormWithExistingData();
    }
  }

  void _initializeFormWithExistingData() {
    final caseData = widget.caseModel!;
    _procedureController.text = caseData.procedure;
    _priceController.text = caseData.cost.toString();
    _descriptionController.text = caseData.description;
    _minAgeController.text = caseData.minAge.toString();
    _maxAgeController.text = caseData.maxAge.toString();
    _gender = caseData.gender;
    minAge = caseData.minAge;
    maxAge = caseData.maxAge;

    // Initialize schedules
    if (caseData.schedule.isNotEmpty) {
      for (int i = 0; i < schedules.length; i++) {
        if (i < caseData.schedule.length) {
          // Populate date and time for each schedule
          schedules[i].availableDate = caseData.schedule[i].availableDate;
          schedules[i].availableTime = caseData.schedule[i].availableTime;

          // Format and set the date and time in the controllers
          dateControllers[i].text = DateFormat('yyyy/MM/dd').format(schedules[i].availableDate);
          final now = DateTime.now();
          final timeToFormat = DateTime(
            now.year,
            now.month,
            now.day,
            schedules[i].availableTime.hour,
            schedules[i].availableTime.minute,
          );
          timeControllers[i].text = DateFormat('hh:mm').format(timeToFormat);
        }
      }
    }

    // Set the selected category
    selectedCategory = myCategories.firstWhere(
          (category) => category.id == caseData.serviceId,
      orElse: () => myCategories.first,
    );
  }

  Future<void> pickDate(int index) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            colorScheme: const ColorScheme.light(primary: AppColors.secondaryColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      dateControllers[index].text = DateFormat('yyyy-MM-dd').format(pickedDate); // Use hyphens
      // dateControllers[index].text = DateFormat('yyyy/MM/dd').format(pickedDate);
    }
  }

  Future<void> pickTime(int index) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            colorScheme: const ColorScheme.light(primary: AppColors.secondaryColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      DateTime now = DateTime.now();
      DateTime dateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      String formattedTime = DateFormat('HH:mm').format(dateTime); // Format to 24-hour format
      timeControllers[index].text = formattedTime;
    }
  }

  void validateInputs() {
    bool hasValidPair = false;
    for (int i = 0; i < 3; i++) {
      if (dateControllers[i].text.isNotEmpty && timeControllers[i].text.isNotEmpty) {
        hasValidPair = true;
        break;
      }
    }

    setState(() {
      if (hasValidPair) {
        dateErrorMessage = '';
      } else {
        dateErrorMessage = 'من فضلك ادخل موعد واحد على الاقل.';
      }
      _genderError = _validateGender(_gender);
    });
  }

  String? _validateprocedure(String? value) {
    if (value == null || value.isEmpty) {
      return 'من فضلك ادخل الإجراء';
    }
    return null;
  }

  String? _validateGender(String? value) {
    if (value == null) {
      return 'يرجى اختيار احد العناصر ';
    }
    return null;
  }

  void _submit() async {
    validateInputs();

    if (_formKey.currentState!.validate() && _validateGender(_gender) == null) {
      try {
        isLoading = true;
        final data = {
          "service_id": selectedCategory!.id.toString() ?? '',
          "procedure": _procedureController.text ?? '',
          "gender": _gender,
          "description": _descriptionController.text,
          "cost": _priceController.text,
          "min_age": _minAgeController.text,
          "max_age": _maxAgeController.text,
          "student_id": widget.caseModel?.studentId != null
              ? widget.caseModel!.studentId.toString()
              : widget.userData!.id.toString(),
          "schedules": List.generate(3, (index) => {
            "available_date": dateControllers[index].text,
            "available_time": timeControllers[index].text,
          }),
        };

        final response = widget.caseModel == null
            ? await http.post(
          Uri.parse('$api_local/create-case-with-schedule/'),
          headers: {'Content-Type': 'application/json'}, // Add headers
          body: jsonEncode(data),
        )
            : await http.put(
          Uri.parse('$api_local/update-case-with-schedule/${widget.caseModel!.id}/'),
          headers: {'Content-Type': 'application/json'}, // Add headers
          body: jsonEncode(data),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pop(context, true);
          _showSuccessMessage();
          if (widget.onCaseSaved != null) {
            widget.onCaseSaved!();
          }
        } else {
          _showErrorMessage('فشل في الحفظ: ${response.statusCode} : ${response.body}');
        }
      } catch (e) {
        _showErrorMessage('حدث خطأ: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم الحفظ بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),

      child: Scaffold(
        appBar: AppBar(
          title: const Center(
              child: Text(
            'إضافة حالة جديدة',style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -.4,
              ),
          )),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.primaryColor,
              )),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButton<CategoryModel>(
                    hint: const Text('اختر الحالة'),
                    value: selectedCategory,
                    onChanged: (CategoryModel? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                    items: myCategories.map<DropdownMenuItem<CategoryModel>>((CategoryModel category) {
                      return DropdownMenuItem<CategoryModel>(
                        value: category,
                        child: Row(
                          children: [
                            Image.asset(category.image, width: 24, height: 24),
                            const SizedBox(width: 12),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    controller: _procedureController,
                    validator: _validateprocedure,
                    decoration: const InputDecoration(
                      // border: OutlineInputBorder(),
                      labelText: 'الإجراء',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'سعر الخدمة',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    children:[
                      Text('العمر المطلوب:'),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("من :"),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 10.0),
                          child: SizedBox(
                            width: 80,
                            height: 40,
                            child: TextFormField(
                              controller: _minAgeController,
                              decoration: const InputDecoration(),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !RegExp(r'^\d{2}$').hasMatch(value)) {
                                  return 'ادخل رقم من خانتين';
                                }
                                return null;
                              },
                              onSaved: (value) => minAge = int.tryParse(value!),
                            ),
                          ),
                        ),
                      ),
                      const Text("إلى :"),
                      Expanded(
                        child: Container(
                        padding: const EdgeInsets.only(left: 20.0, right: 10.0),
                          width: 80,
                          height: 40,
                          child: TextFormField(
                            controller: _maxAgeController,
                            decoration: const InputDecoration(),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !RegExp(r'^\d{2}$').hasMatch(value)) {
                                return 'ادخل رقم من خانتين';
                              }
                              return null;
                            },
                            onSaved: (value) => maxAge = int.tryParse(value!),
                          ),
                        ),
                      ),
                      // Add some spacing between fields
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      const Row(
                        children: [
                          Text("المواعيد المتاحه:"),
                        ],
                      ),
                      const Divider(height: 10),
                      for (int i = 0; i < 3; i++)
                        Column(
                          children: [
                            Row(
                              children: [
                                const Text('الموعد :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(fontSize: 14),
                                    controller: dateControllers[i],
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      hintText: 'التاريخ ',
                                      enabledBorder: InputBorder.none,
                                      prefixIcon: Icon(Icons.calendar_month, color: AppColors.secondaryColor),
                                    ),
                                    onTap: () => pickDate(i),
                                  ),
                                ),
                                const SizedBox(width: 5, height: 70),
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(fontSize: 14),
                                    controller: timeControllers[i],
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      hintText: 'الوقت ',
                                      enabledBorder: InputBorder.none,
                                      prefixIcon: Icon(Icons.access_time, color: AppColors.secondaryColor),
                                    ),
                                    onTap: () => pickTime(i),
                                  ),
                                ),
                              ],
                            ),
                            if (i < 2) const SizedBox(height: 10), // Add spacing between schedules
                          ],
                        ),
                      if (dateErrorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            dateErrorMessage,
                            style: const TextStyle(color: AppColors.errorColor),
                          ),
                        ),
                    ],
                  ),
                  const Divider(
                    height: 10,
                  ),
                  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('النوع:',
                        style: TextStyle(fontWeight: FontWeight.bold),

                      ),
                      Radio<String>(
                        value: 'Male',
                        groupValue: _gender,
                        onChanged: (String? value) {
                          setState(() {
                            _gender = value;
                            _genderError = null; // Clear the error message
                          });
                        },
                      ),
                      const Text('ذكر'),
                      Radio<String>(
                        value: 'Female',
                        groupValue: _gender,
                        onChanged: (String? value) {
                          setState(() {
                            _gender = value;
                            _genderError = null; // Clear the error message
                          });
                        },
                      ),
                      const Text('أنثى'),
                      Radio<String>(
                        value: 'Any',
                        groupValue: _gender,
                        onChanged: (String? value) {
                          setState(() {
                            _gender = value;
                            _genderError = null; // Clear the error message
                          });
                        },
                      ),
                      const Text('ذكر _أنثى'),
                    ],
                  ),
                  if (_genderError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        _genderError!,
                        style: const TextStyle(color: AppColors.errorColor),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white
                        ),
                        onPressed: () {
                          _submit();
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                          }
                        },
                        child: const Text('حفظ',style: TextStyle(color: Colors.white,fontSize: 16)),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          foregroundColor: Colors.black54
                        ),
                        onPressed: () {

                        },
                        child: const Text('الغاء'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

