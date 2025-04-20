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
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');

    if (_userId == null) {
      if (mounted) Navigator.of(context).pushReplacementNamed('/moderator_login');
      return;
    }

    if (_userId == 'localModerator') {
      _isModerator = true;
      setState(() => _isLoading = false);
      _refreshReservations();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      final data = doc.data();
      _isModerator = data?['isModerator'] == true;
    } catch (_) {
      _isModerator = false;
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _refreshReservations();
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchReservations() async {
    try {
      final snapshot = await _firestore.collection('reservations').get();
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.docs;

      if (_selectedStatus != 'all') {
        docs = docs.where((doc) => doc.data()['status'] == _selectedStatus).toList();
      }

      docs.sort((a, b) {
        final aTime = (a.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final bTime = (b.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime); // Newest first
      });

      return docs;
    } catch (e) {
      print('❌ Firestore read error: $e');
      return [];
    }
  }

  Future<void> _refreshReservations() async {
    final docs = await _fetchReservations();
    if (mounted) {
      setState(() => _reservations = docs);
    }
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
      _refreshReservations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التحديث: $e')),
      );
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'approved':
        return 'مقبول';
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
                DropdownMenuItem(value: 'approved', child: Text('مقبول')),
                DropdownMenuItem(value: 'rejected', child: Text('مرفوض')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStatus = value);
                  _refreshReservations();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReservations,
        child: _reservations.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 200),
            Center(child: Text('لا توجد حجوزات حالياً')),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _reservations.length,
          itemBuilder: (context, index) {
            final doc = _reservations[index];
            final data = doc.data();
            final id = doc.id;
            final status = data['status'] ?? 'pending';

            final bookingDate = (data['bookingDateTime'] as Timestamp?)?.toDate();
            final createdAt = (data['timestamp'] as Timestamp?)?.toDate();

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // حالة الحجز
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'approved'
                            ? Colors.green.shade100
                            : status == 'rejected'
                            ? Colors.red.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'الحالة: ${_getStatusLabel(status)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == 'approved'
                              ? Colors.green.shade800
                              : status == 'rejected'
                              ? Colors.red.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'اسم المزرعة: ${data['villaName'] ?? 'غير متوفر'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'رقم الهاتف: ${data['contactPhone'] ?? 'غير متوفر'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (bookingDate != null)
                      Text(
                        'تاريخ الحجز: ${DateFormat('EEEE، d MMMM yyyy – hh:mm a', 'ar').format(bookingDate)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (createdAt != null)
                      Text(
                        'تم الطلب بتاريخ: ${DateFormat('yyyy-MM-dd – HH:mm', 'ar').format(createdAt)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (data['duration'] != null)
                      Text(
                        'المدة: ${data['duration']} ساعة',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (data['total'] != null)
                      Text(
                        'الإجمالي: ${data['total']} ريال',
                        style: const TextStyle(fontSize: 16),
                      ),
                    const SizedBox(height: 10),
                    if (_isModerator)
                      Align(
                        alignment: Alignment.centerLeft,
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
        ),
      ),
    );
  }
}
