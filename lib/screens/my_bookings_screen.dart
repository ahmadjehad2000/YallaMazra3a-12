import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  Stream<QuerySnapshot> getUserReservations() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUserReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات حالياً'));
          }

          final reservations = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final data = reservations[index].data() as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final bookingDate = (data['bookingDate'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(data['villaName'] ?? 'مزرعة غير معروفة'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('معرّف: ${data['villaId'] ?? '-'}'),
                      if (bookingDate != null)
                        Text('تاريخ الحجز: ${DateFormat('yyyy-MM-dd').format(bookingDate)}'),
                      if (timestamp != null)
                        Text('أُنشئ في: ${timestamp.toLocal().toString().substring(0, 16)}'),
                    ],
                  ),
                  leading: const Icon(Icons.home, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
