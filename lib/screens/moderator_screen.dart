import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ModeratorScreen extends StatelessWidget {
  const ModeratorScreen({Key? key}) : super(key: key);

  Future<void> _updateStatus(String reservationId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .update({'status': newStatus});
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شغلي'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reservations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('حدث خطأ أثناء تحميل البيانات'),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ModeratorScreen()),
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات حالياً'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>?;

              if (data == null) {
                return const ListTile(
                  title: Text('بيانات غير صالحة'),
                  subtitle: Text('تعذر تحميل الحجز.'),
                );
              }

              final id = doc.id;
              final villaName = data['villaName']?.toString() ?? 'مزرعة غير معروفة';
              final contactPhone = data['contactPhone']?.toString() ?? 'غير متوفر';
              final status = data['status']?.toString() ?? 'pending';
              final userId = data['userId']?.toString() ?? 'غير معروف';

              DateTime? bookingDate;
              DateTime? timestamp;

              try {
                bookingDate = (data['bookingDateTime'] as Timestamp?)?.toDate();
              } catch (_) {}

              try {
                timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              } catch (_) {}

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        villaName.isNotEmpty ? villaName : 'مزرعة تخص $userId',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('الهاتف: $contactPhone'),
                      if (bookingDate != null)
                        Text('موعد الحجز: ${DateFormat('yyyy-MM-dd – HH:mm').format(bookingDate)}'),
                      if (timestamp != null)
                        Text('تاريخ الطلب: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp)}'),
                      Text(
                        'الحالة الحالية: ${_getStatusLabel(status)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton<String>(
                          onSelected: (newStatus) => _updateStatus(id, newStatus),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'approved', child: Text('قبول')),
                            PopupMenuItem(value: 'rejected', child: Text('رفض')),
                            PopupMenuItem(value: 'pending', child: Text('قيد المراجعة')),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getStatusLabel(String? status) {
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

  Color _getStatusColor(String? status) {
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
}
