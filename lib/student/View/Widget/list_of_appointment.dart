//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:ydental_application/colors.dart';
//
// import '../../../Model/appointment_model.dart';
//
//
//
// class AppointmentList extends StatelessWidget {
//   final List<Appointment> appointments;
//   final Function(Appointment)? onClick;
//   final String? buttonText;
//   final Function(Appointment)? onCancel;
//   final String? cancelButtonText;
//   final Function(Appointment)? onComplete;
//
//   const AppointmentList({
//     super.key,
//     required this.appointments,
//     this.onClick,
//     this.buttonText,
//     this.onCancel,
//     this.cancelButtonText, this.onComplete,
//   });
//
//   Color getStatusColor(AppointmentStatus status) {
//     switch (status) {
//       case AppointmentStatus.upcoming:
//         return Colors.blue;
//       case AppointmentStatus.confirmed:
//         return Colors.green;
//       case AppointmentStatus.cancelled:
//         return AppColors.errorColor;
//       default:
//         return Colors.grey; // Fallback color
//     }
//   }
//
//   String getStatusName(AppointmentStatus status) {
//     switch (status) {
//       case AppointmentStatus.upcoming:
//         return 'بانتظار التأكيد';
//       case AppointmentStatus.confirmed:
//         return 'مؤكدة';
//       case AppointmentStatus.cancelled:
//         return 'ملغية';
//       case AppointmentStatus.completed:
//         return 'مكتملة';
//       default:
//         return 'Unknown';
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: appointments.length,
//       itemBuilder: (context, index) {
//         final appointment = appointments[index];
//
//         return Card(
//           margin: EdgeInsets.symmetric(horizontal: 20 , vertical: 8),
//           shadowColor: Colors.grey,
//           surfaceTintColor:Colors.grey ,
//
//
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       " اسم المريض :  ${appointment.patient.name}",
//                       style: const TextStyle(
//
//                         fontSize: 16,
//                         letterSpacing: -.5,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       'الاجراء : ${appointment.case1!.procedure} ',
//                       style: const TextStyle(
//                         color: Colors.grey,
//                         fontSize: 15,
//                         letterSpacing: -.5,
//                       ),
//                     ),
//                     SizedBox(
//                       width: 20,
//                     ),
//                     Text(
//                       ' النوع :  ${appointment.case1!.gender}  ',
//                       style: const TextStyle(
//                         color: Colors.grey,
//                         fontSize: 15,
//                         letterSpacing: -.5,
//                       ),
//                     ),
//                     SizedBox(
//                       width: 20,
//                     ),
//                     Text(
//                       'العمر :${appointment.case1!.minAge}  ',
//                       style: const TextStyle(
//                         color: Colors.grey,
//                         fontSize: 15,
//                         letterSpacing: -.5,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 Divider(
//                   color: Colors.grey[350],
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(
//                           size: 16,
//                           Icons.calendar_month,
//                           color: grey,
//                         ),
//                         const SizedBox(width: 5),
//                         Text(
//                           DateFormat("d/MM/y")
//                               .format(appointment.appointment_date),
//                           style: const TextStyle(
//
//                             letterSpacing: -.5,
//                           ),
//                         )
//                       ],
//                     ),
//                     const SizedBox(width: 25),
//                     Row(
//                       children: [
//                         const Icon(
//                           size: 16,
//                           Icons.access_time_filled,
//                           color: grey,
//                         ),
//                         const SizedBox(width: 5),
//                         Text(
//                           DateFormat('jm').format(appointment.appointment_time),
//                           style: const TextStyle(
//
//                             letterSpacing: 0,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: 25),
//                     Row(
//                       children: [
//                         // if (isUpcomingAppointment(statusFilter))
//                         CircleAvatar(
//                           backgroundColor: getStatusColor(appointment.status),
//                           radius: 5,
//                         ),
//
//                         const SizedBox(width: 5),
//                         Text(
//                           getStatusName(appointment.status),
//                           style: const TextStyle(
//
//                             letterSpacing: 0,
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 15),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                       child: buttonText != null && onClick != null
//                           ? ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: primary,
//                           foregroundColor: Colors.white,
//                         ),
//                         onPressed: () => onClick!(appointment),
//                         child: Text(buttonText!),
//                       )
//                           : null,
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Container(
//                       child: cancelButtonText != null && onCancel != null
//                           ? ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white70,
//                           foregroundColor: Colors.black54,
//                         ),
//                         onPressed: () => onCancel!(appointment),
//                         child: Text(cancelButtonText!),
//                       )
//                           : null,
//                     ),
//
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }