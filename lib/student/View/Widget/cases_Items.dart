import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ydental_application/Model/schedule_model.dart';
import 'package:ydental_application/constant.dart';
import '../../../Model/cases_model.dart';
import '../../../colors.dart';
import '../case_form_screen.dart';
import 'package:http/http.dart' as http;

class CasesItems extends StatefulWidget {
  final MyCasesModel caseModel;
  final VoidCallback onCaseUpdated; // Add a callback function

  const CasesItems({super.key, required this.caseModel, required this.onCaseUpdated});
  @override
  _CasesItemsState createState() => _CasesItemsState();
}

class _CasesItemsState extends State<CasesItems> {
  bool _showDescription = false;

  Future<bool> deleteCase(int caseId) async {
    final String apiUrl = '$api_local/thecases/$caseId/';

    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['success'] == true) { // Or whatever your success key is
            return true; // Return true to indicate success
          } else {
            print('API returned an error: ${responseData['message']}');
            return false; // Return false if API reports failure
          }
        } catch (e) {
          print('Error decoding JSON response: $e');
          // If JSON decoding fails, assume deletion was successful for now.
          // Better error handling would be to check the HTTP status code more carefully.
          return true;
        }
      }
      else if (response.statusCode == 204) {
        // No Content - often used for successful DELETE requests
        return true;
      }
      else {
        // Handle error
        print('Error deleting case: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false; // Return false to indicate failure
      }
    } catch (e) {
      print('Error deleting case: $e');
      return false; // Return false for network or other errors
    }
  }

  // Example usage:
  Future<void> _deleteCase(int caseId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(
            Icons.cancel,
            size: 40,
            color: AppColors.errorColor,
          ),

          title: const Text('حذف الحالة'),
          content: const Text(
            ' هل أنت متأكد من  رغبتك بحذف هذه الحالة ؟ ',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'لا',
                style: TextStyle(
                  color: AppColors.secondaryColor,

                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                'نعم',
                style: TextStyle(
                  color: AppColors.secondaryColor,

                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    if (confirmed == true) {

      bool success = await deleteCase(caseId);
    if (success) {
      // Case deleted successfully
      print('Case deleted successfully');
      setState(() {
        widget.onCaseUpdated(); // Call the callback to reload data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحذف بنجاح')),
        );
      });      // You might want to refresh the list of cases or navigate away

      // Example:
      // Navigator.pop(context); // If you're on a details screen
    } else {
      // Case deletion failed
      print('Case deletion failed');
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete case')),
      );
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0 , vertical: 0),
      shadowColor: Colors.grey,
      surfaceTintColor:Colors.grey ,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.caseModel.procedure,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                 " الخدمة :${widget.caseModel.service.name}" ,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                // Always show the appointments
                Column(
                  children: List.generate(
                    widget.caseModel.schedule.length,
                        (index) => _buildTimeDateRow(
                      'المواعد ${index + 1} : ',
                      widget.caseModel.schedule[index], // Pass the Schedule object
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      _showDescription = !_showDescription; // Toggle visibility of the description
                    });
                  },
                  child: Text(
                    _showDescription ? 'أقل' : 'المزيد',
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
                ),

                if (_showDescription) ...[
                  const SizedBox(height: 5),
                  Text(
                        "الوصف:\n${widget.caseModel.description}",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // _buildInfoRow(widget.caseModel.ageRanges.map((range) => range.toString()).join(', '), ''),
                  Row(
                    children: [
                      const Icon(Icons.man, color: Colors.grey, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        "النوع: ${widget.caseModel.gender}",),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 5,
            left: 10,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        CaseForm(caseModel: widget.caseModel, onCaseSaved: widget.onCaseUpdated, // Pass callback here
                    )));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.errorColor),
                  onPressed: () async {
                    // Add delete functionality here
                    _deleteCase(widget.caseModel.id);

                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}


// Widget _buildTimeDateRow(String label, dynamic time, dynamic date) {
//   // Convert 'time' to DateTime if needed.
//   DateTime timeToFormat;
//   if (time is TimeOfDay) {
//     final now = DateTime.now();
//     timeToFormat = DateTime(now.year, now.month, now.day, time.hour, time.minute);
//   } else if (time is DateTime) {
//     timeToFormat = time;
//   } else {
//     // Fallback to current time if the type is not supported.
//     timeToFormat = DateTime.now();
//   }
//
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4.0),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: AppColors.primaryColor,
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 28.0, top: 4.0),
//           child: Row(
//             children: [
//               const Icon(Icons.access_time, size: 20, color: Colors.grey),
//               const SizedBox(width: 8),
//               Text(
//                 DateFormat('hh:mm').format(timeToFormat),
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(width: 16),
//               const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
//               const SizedBox(width: 8),
//               Text(
//                 DateFormat('yyyy/MM/dd').format(date),
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

Widget _buildTimeDateRow(String label, Schedule schedule) {
  // Convert TimeOfDay to DateTime for formatting
  final now = DateTime.now();
  final timeToFormat = DateTime(
    now.year,
    now.month,
    now.day,
    schedule.availableTime.hour,
    schedule.availableTime.minute,
  );

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28.0, top: 4.0),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                DateFormat('hh:mm a').format(timeToFormat), // Show AM/PM
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                DateFormat('yyyy/MM/dd').format(schedule.availableDate),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
