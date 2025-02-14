import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ydental_application/colors.dart';
import 'package:ydental_application/constant.dart';
import '../../Model/patient_model.dart';
import 'package:http/http.dart' as http;

class AddVisit extends StatefulWidget {
final int patientId;
final String patientName;
final int student;
final int appointmentId;

  const AddVisit({
    super.key, required this.patientId, required this.student, required this.patientName, required this.appointmentId,

  });

  @override
  State<AddVisit> createState() => _AddVisitPageState();
}

class _AddVisitPageState extends State<AddVisit> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _procedureController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController dateControllers = TextEditingController();
  final TextEditingController timeControllers = TextEditingController();
  String dateErrorMessage = '';
  bool _isLoading = false; // Add loading state

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            hintColor: AppColors.primaryColor,
            colorScheme: const ColorScheme.light(primary: AppColors.secondaryColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      dateControllers.text = pickedDate.toLocal().toString().split(' ')[0];
    }
  }

  Future<void> pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            hintColor: AppColors.primaryColor,
            colorScheme: const ColorScheme.light(primary: AppColors.secondaryColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    // if (pickedTime != null) {
    //   timeControllers.text = pickedTime.format(context);
    // }
    if (pickedTime != null) {
      // Format to 24-hour format (HH:mm:ss)
      DateTime now = DateTime.now();
      DateTime dateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      String formattedTime = DateFormat('HH:mm:ss').format(dateTime); // 24-hour format
      timeControllers.text = formattedTime;
    }
  }

  void validateInputs() {
    bool hasValidPair = false;
    if (dateControllers.text.isNotEmpty && timeControllers.text.isNotEmpty) {
      hasValidPair = true;
    }

    setState(() {
      if (hasValidPair) {
        dateErrorMessage = '';
        // Proceed with form submission or further logic
      } else {
        // Clear fields if a date is selected without a corresponding time
        if (dateControllers.text.isNotEmpty && timeControllers.text.isEmpty) {
          dateControllers.clear();
          timeControllers.clear();
        }
        if (timeControllers.text.isNotEmpty && dateControllers.text.isEmpty) {
          timeControllers.clear();
        }

        dateErrorMessage = 'من فضلك ادخل وقت وتاريخ الزيارة ';
      }
      // _genderError = _validateGender(_selectedGender);
    });
  }

  String? _validateprocedure(String? value) {
    if (value == null || value.isEmpty) {
      return 'من فضلك ادخل إجراء الزيارة ';
    }
    return null;
  }

  Future<void> _submit() async {
    validateInputs();
    if (_formKey.currentState!.validate() && dateErrorMessage.isEmpty) { // Check both form and date errors
        setState(() {
          _isLoading = true; // Show loading indicator
        });
      try {
        final data = {
          "visit_date": dateControllers.text,
          "procedure": _procedureController.text,
          "note": _descriptionController.text,
          "status": "غير مكتملة", // Or let the user choose the status
          "visit_time": timeControllers.text,
          "appointment_id": widget.appointmentId.toString(), // Use widget.patient.id
          // "appointment_id": widget.patient.id, // Use widget.patient.id
        };
        final response = await http.post(
          Uri.parse('$api_local/visits?student_id=${widget.student}&patient_id=${widget.patientId}'), // Include student_id
          body: data,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body); // Decode the response

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تمت الإضافة بنجاح!',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              backgroundColor: AppColors.primaryColor,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success

        } else {// Print for debugging
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في الإضافة: ${response.body}'), // Show error message from server
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator, even if there's an error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        // drawer: YDentalDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Center(
            child: Text('إضافة زيارة',style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -.4,
            )),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    " اسم المريض : ${widget.patientName} ",
                    style: const TextStyle(
                      fontSize: 18,
                      letterSpacing: -.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _procedureController,
                    validator: _validateprocedure,
                    decoration: const InputDecoration(
                      labelText: '* الإجراء ',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(
                    height: 20,
                  ),
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              " موعد الزيارة :",
                              style: TextStyle(

                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: dateControllers,
                              readOnly: true,
                              decoration: const InputDecoration(


                                hintText: '* التاريخ '
                                // ,border: OutlineInputBorder()
                                ,
                                prefixIcon: Icon(Icons.calendar_month,
                                color: AppColors.primaryColor,
                                ),

                              ),
                              onTap: () => pickDate(),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                            height: 70,
                          ),
                          Expanded(
                            child: TextField(
                              controller: timeControllers,
                              readOnly: true,
                              decoration: const InputDecoration(
                                hintText: '* الوقت ',
                                prefixIcon: Icon(Icons.access_time,
                                  color: AppColors.primaryColor,
                                ),
                                iconColor: Colors.cyan,
                              ),
                              onTap: () => pickTime(),
                            ),
                          ),
                        ],
                      ),
                      if (dateErrorMessage.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [

                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                dateErrorMessage,
                                style:
                                    const TextStyle(color: AppColors.errorColor),

                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const Divider(
                    height: 20,
                  ),
                  const Row(
                    children: [
                      Text(
                        '*  تعني أن الحقل إجباري ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xffB20600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _submit();
                          },
                          child: _isLoading // Show loading indicator if _isLoading is true
                              ? const Center(child: CircularProgressIndicator()) // Center the indicator
                              : const Text(
                            'حفظ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,

                            ),
                          ),
                        ),
                      ),
                  const SizedBox(width: 10,),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(

                            backgroundColor: Colors.white70,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,

                            ),
                          ),
                        ),
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
