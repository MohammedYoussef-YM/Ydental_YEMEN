// visit_model.dart
import 'package:intl/intl.dart';

enum VisitStatus { upcoming,uncompleted, completed, cancelled }

extension VisitStatusExtension on VisitStatus {
  String toApiString() {
    switch (this) {
      case VisitStatus.uncompleted:
        return 'غير مكتملة';
        case VisitStatus.upcoming:
        return 'بانتظار التأكيد';
      case VisitStatus.completed:
        return 'مكتملة';
      case VisitStatus.cancelled:
        return 'ملغية';
    }
  }

  static VisitStatus fromApiString(String status) {
    switch (status) {
      case 'غير مكتملة':
        return VisitStatus.uncompleted;
      case 'مكتملة':
        return VisitStatus.completed;
      case 'ملغية':
        return VisitStatus.cancelled;
      default:
        throw ArgumentError('حالة غير معروفة: $status');
    }
  }
}

class Visit {
  final int id;
  final DateTime visitDate;
  final String procedure;
  final String note;
  VisitStatus status;
  final String visitTime;
  final String patientName;
  final int patientId;
  final int appointmentId;

  Visit({
    required this.id,
    required this.visitDate,
    required this.procedure,
    required this.note,
    required this.status,
    required this.visitTime,
    required this.appointmentId,
    required this.patientName,
    required this.patientId,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      visitDate: DateTime.parse(json['visit_date']),
      procedure: json['procedure'],
      note: json['note'],
      status: VisitStatusExtension.fromApiString(json['status']),
      visitTime: json['visit_time'],
      appointmentId: json['appointment_id'],
      patientId: json['appointment']['patient']['id']??0,
      patientName: json['appointment']['patient']['name']??'غير معروف',
    );
  }

  DateTime get fullDateTime {
    final time = DateFormat('HH:mm:ss').parse(visitTime);
    return DateTime(
      visitDate.year,
      visitDate.month,
      visitDate.day,
      time.hour,
      time.minute,
    );
  }
}

List<String> visit_tabs = ['غير مكتملة','المكتملة', 'الملغية'];
