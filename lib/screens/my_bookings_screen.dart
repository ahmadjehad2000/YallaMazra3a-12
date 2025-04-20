import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  Stream<QuerySnapshot> getUserReservations() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'موافق عليه';
      case 'rejected':
        return 'مرفوض';
      case 'pending':
      default:
        return 'قيد المراجعة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(statusBarHeight + kToolbarHeight),
        child: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
          title: const Text('حجوزاتي'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: statusBarHeight + kToolbarHeight),
        child: StreamBuilder<QuerySnapshot>(
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
                final bookingDateTime = (data['bookingDateTime'] as Timestamp?)?.toDate();
                final status = data['status'] ?? 'pending';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.home, color: Theme.of(context).primaryColor),
                    title: Text(
                      data['villaName'] ?? 'مزرعة غير معروفة',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (bookingDateTime != null)
                          Text('موعد الحجز: ${DateFormat('yyyy-MM-dd – HH:mm').format(bookingDateTime)}'),
                        if (timestamp != null)
                          Text('تم الطلب بتاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp)}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'الحالة: ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              _getStatusLabel(status),
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}