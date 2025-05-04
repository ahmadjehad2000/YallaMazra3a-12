import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'my_bookings_screen.dart';
import '../models/villa.dart';

class VillaDetailScreen extends StatefulWidget {
  final Villa villa;
  const VillaDetailScreen({Key? key, required this.villa}) : super(key: key);

  @override
  _VillaDetailScreenState createState() => _VillaDetailScreenState();
}

class _VillaDetailScreenState extends State<VillaDetailScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  // Gallery state
  List<String> _imagesToShow = [];
  bool _isLoadingImages = true;
  final CacheManager _cacheManager = DefaultCacheManager();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadAndCacheImages();
  }

  Future<void> _loadAndCacheImages() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('villas')
          .doc(widget.villa.id)
          .get();
      final data = snap.data();
      if (data != null && data['images'] is List) {
        _imagesToShow = List<String>.from(data['images']);
      }
    } catch (_) {
      // ignore errors and fall back
    }
    if (_imagesToShow.isEmpty) {
      _imagesToShow = [widget.villa.imageUrl];
    }
    await Future.wait(_imagesToShow.map((url) => _cacheManager.getSingleFile(url)));
    setState(() {
      _isLoadingImages = false;
    });
  }

  Future<void> _pickDateTime() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  Future<void> _enterContactAndSubmit() async {
    final controller = TextEditingController();
    final phone = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('أدخل رقمك المفضل ليتواصل معك المندوب عليه'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: 'رقم الهاتف'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(controller.text.trim()), child: const Text('إرسال')),
        ],
      ),
    );
    if (phone == null || phone.isEmpty) return;
    await _submitReservation(phone);
  }

  Future<void> _submitReservation(String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب تسجيل الدخول أولاً لإتمام الحجز')));
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار تاريخ ووقت الحجز')));
      return;
    }
    if (phone.length < 6 || !RegExp(r'^\d+$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال رقم هاتف صحيح للتواصل')));
      return;
    }

    setState(() => _isSubmitting = true);

    final bookingDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      final conflict = await FirebaseFirestore.instance
          .collection('reservations')
          .where('villaId', isEqualTo: widget.villa.id)
          .where('bookingDateTime', isEqualTo: Timestamp.fromDate(bookingDateTime))
          .get();
      if (conflict.docs.isNotEmpty) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('المزرعة محجوزة في هذا التوقيت، يرجى اختيار وقت آخر')));
        return;
      }

      await FirebaseFirestore.instance.collection('reservations').add({
        'villaId': widget.villa.id,
        'villaName': widget.villa.name,
        'userId': user.uid,
        'bookingDateTime': Timestamp.fromDate(bookingDateTime),
        'contactPhone': phone,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الحجز بنجاح، بانتظار المراجعة')));
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final villa = widget.villa;
    final dateStr = _selectedDate == null
        ? 'اختر التاريخ والوقت'
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final timeStr = _selectedTime?.format(context) ?? '';

    // Build button label with proper interpolation
    final pickLabel = _selectedDate == null
        ? 'اختر التاريخ والوقت'
        : '$dateStr${timeStr.isNotEmpty ? '  $timeStr' : ''}';

    return Scaffold(
      appBar: AppBar(
        title: Text(villa.name, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Image gallery
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: _isLoadingImages
                        ? const Center(child: CircularProgressIndicator())
                        : (_imagesToShow.isNotEmpty
                        ? PageView.builder(
                      controller: _pageController,
                      itemCount: _imagesToShow.length,
                      itemBuilder: (_, i) => CachedNetworkImage(
                        imageUrl: _imagesToShow[i],
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    )
                        : const Center(child: Text('لا توجد صور'))),
                  ),
                ),
                const SizedBox(height: 16),
                // Thumbnails
                if (!_isLoadingImages && _imagesToShow.length > 1)
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _imagesToShow.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) => GestureDetector(
                        onTap: () => _pageController.jumpToPage(i),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: _imagesToShow[i],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(villa.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('${villa.price.toStringAsFixed(0)} JD / الليلة', style: const TextStyle(fontSize: 20, color: Colors.green)),
                const SizedBox(height: 16),
                const Text('تفاصيل المزرعة:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(villa.description, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _pickDateTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    pickLabel,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: (_selectedDate != null && _selectedTime != null && !_isSubmitting)
                      ? _enterContactAndSubmit
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('احجز الآن', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
