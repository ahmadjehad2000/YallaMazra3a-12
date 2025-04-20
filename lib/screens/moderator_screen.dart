import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeratorScreen extends StatefulWidget {
  const ModeratorScreen({Key? key}) : super(key: key);

  @override
  State<ModeratorScreen> createState() => _ModeratorScreenState();
}

class _ModeratorScreenState extends State<ModeratorScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedStatus = 'all';
  String? _userId;
  bool _isModerator = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');

    if (_userId == null) {
      Navigator.of(context).pushReplacementNamed('/moderator_login');
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      final data = doc.data();
      if (data != null && data['isModerator'] == true) {
        _isModerator = true;
      }
    } catch (_) {
      _isModerator = false;
    }

    setState(() => _isLoading = false);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _reservationsStream {
    Query<Map<String, dynamic>> query = _firestore.collection('reservations');

    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    return query.snapshots();
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    if (!_isModerator || _userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ليس لديك صلاحية التعديل')),
      );
      return;
    }

    try {
      await _firestore.collection('reservations').doc(id).update({
        'status': newStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم التحديث إلى ${_getStatusLabel(newStatus)}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التحديث: $e')),
      );
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'approved':
        return 'موافق عليه';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'قيد المراجعة';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('شغلي'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          Icon(Icons.admin_panel_settings, color: _isModerator ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatus,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('الكل')),
                DropdownMenuItem(value: 'pending', child: Text('قيد المراجعة')),
                DropdownMenuItem(value: 'approved', child: Text('موافق عليه')),
                DropdownMenuItem(value: 'rejected', child: Text('مرفوض')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStatus = value);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _reservationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('خطأ: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('لا توجد حجوزات حالياً'));

          docs.sort((a, b) {
            final aDate = (a.data()['bookingDateTime'] as Timestamp?)?.toDate();
            final bDate = (b.data()['bookingDateTime'] as Timestamp?)?.toDate();
            return bDate?.compareTo(aDate ?? DateTime(2000)) ?? 0;
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final id = doc.id;

              final villa = data['villaName'] ?? 'مزرعة غير معروفة';
              final phone = data['contactPhone'] ?? 'غير متوفر';
              final userId = data['userId'] ?? 'غير معروف';
              final total = data['total']?.toString() ?? '-';
              final duration = data['duration']?.toString() ?? '-';
              final status = data['status'] ?? 'pending';

              DateTime? bookingDate;
              try {
                bookingDate = (data['bookingDateTime'] as Timestamp?)?.toDate();
              } catch (_) {}

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(villa),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'approved'
                              ? Colors.green.shade100
                              : status == 'rejected'
                              ? Colors.red.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'الحالة: ${_getStatusLabel(status)}',
                          style: TextStyle(
                            color: status == 'approved'
                                ? Colors.green.shade800
                                : status == 'rejected'
                                ? Colors.red.shade800
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('الهاتف: $phone'),
                      if (bookingDate != null)
                        Text('موعد الحجز: ${DateFormat('yyyy-MM-dd – HH:mm').format(bookingDate)}'),
                      Text('المدة: $duration'),
                      Text('الإجمالي: $total ريال'),
                      Text('المستخدم: $userId'),
                    ],
                  ),
                  trailing: _isModerator
                      ? PopupMenuButton<String>(
                    onSelected: (newStatus) => _updateStatus(id, newStatus),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'approved', child: Text('قبول')),
                      PopupMenuItem(value: 'rejected', child: Text('رفض')),
                      PopupMenuItem(value: 'pending', child: Text('قيد المراجعة')),
                    ],
                    icon: const Icon(Icons.more_vert),
                  )
                      : const Icon(Icons.lock, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
