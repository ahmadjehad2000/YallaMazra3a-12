// lib/models/reservation.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String villaName;
  final String contactPhone;
  final String status;
  final String userId;
  final DateTime bookingDateTime;
  final DateTime timestamp;

  Reservation({
    required this.id,
    required this.villaName,
    required this.contactPhone,
    required this.status,
    required this.userId,
    required this.bookingDateTime,
    required this.timestamp,
  });

  factory Reservation.fromMap(Map<String, dynamic> map, String id) {
    return Reservation(
      id: id,
      villaName: map['villaName'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      status: map['status'] ?? 'pending',
      userId: map['userId'] ?? '',
      bookingDateTime: (map['bookingDateTime'] as Timestamp).toDate(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
