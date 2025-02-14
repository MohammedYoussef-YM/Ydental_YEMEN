import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ydental_application/colors.dart';

import '../../../Model/visit_model.dart';


class ListOfVisit extends StatelessWidget {
  final List<Visit> visits;
  final Function(Visit)? onClick;
  final String? buttonText;
  final Function(Visit)? onCancel;
  final String? cancelButtonText;
  final Function(Visit)? onComplete;

  const ListOfVisit({
    super.key,
    required this.visits, this.onClick, this.buttonText, this.onCancel, this.cancelButtonText, this.onComplete,
  });


  Color getStatusColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.uncompleted:
        return Colors.blue;
      case VisitStatus.completed:
        return Colors.grey;
      case VisitStatus.cancelled:
        return AppColors.errorColor;
      case VisitStatus.upcoming:
        return Colors.blue;
    }
  }

  String getStatusName(VisitStatus status) {
    switch (status) {
      case VisitStatus.uncompleted:
        return 'غير مكتملة';
      case VisitStatus.completed:
        return 'مكتملة';
      case VisitStatus.cancelled:
        return 'ملغية';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visit = visits[index];

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 20 , vertical: 8),
                  shadowColor: Colors.grey,
                  surfaceTintColor:Colors.grey ,

                  child:
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        " اسم المريض : ${visit.patientName} ",
                        style: const TextStyle(

                          fontSize: 16,
                          letterSpacing: -.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        ' الاجراء :  ${visit.procedure} ',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          letterSpacing: -.5,
                        ),
                      ),
                      Container(
                        width: 400,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  ' ملاحظة :  ${visit.note} ',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    letterSpacing: -.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                       Divider(
                        color: Colors.grey[350],
                      ),
                      Row(
                        children: [
                          Icon(
                            size: 16,
                            Icons.calendar_month,
                            color: grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat("d/MM/y").format(visit.visitDate),
                            style: const TextStyle(

                              letterSpacing: -.5,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            size: 16,
                            Icons.access_time_filled,
                            color: grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('jm').format(visit.visitDate),
                            style: const TextStyle(

                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(width: 10,),
                          // Container(
                          //   height: 7,
                          //   width: 7,
                          //   decoration: const BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     color: Colors.blue,
                          //   ),
                          // ),
                          CircleAvatar(
                            backgroundColor: getStatusColor(visit.status),
                            radius: 5,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            getStatusName(visit.status),
                            style: const TextStyle(

                              letterSpacing: 0,
                            ),
                          )

                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: buttonText != null && onClick != null
                                ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => onClick!(visit),
                              child: Text(buttonText!),
                            )
                                : null,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: cancelButtonText != null && onCancel != null
                                ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white70,
                                foregroundColor: Colors.black54,
                              ),
                              onPressed: () => onCancel!(visit),
                              child: Text(cancelButtonText!),
                            )
                                : null,
                          ),

                        ],
                      ),
                    ]),
                  ),
                ),
              ),
            ],

          );
        }
    );
  }
}
