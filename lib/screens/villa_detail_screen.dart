import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/villa.dart';

class VillaDetailScreen extends StatelessWidget {
  final Villa villa;

  const VillaDetailScreen({Key? key, required this.villa}) : super(key: key);

  Future<void> _makeReservation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب تسجيل الدخول أولاً لإتمام الحجز")),
      );
      return;
    }

    final reservation = {
      'villaId': villa.id,
      'villaName': villa.name,
      'userId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .add(reservation);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("تم الحجز"),
          content: const Text("تم إرسال طلب الحجز بنجاح!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("حسناً"),
            )
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء إرسال الحجز")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    villa.imageUrl,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  villa.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '${villa.price} ريال / الليلة',
                  style: const TextStyle(fontSize: 20, color: Colors.green),
                ),
                const SizedBox(height: 16),
                const Text(
                  'تفاصيل المزرعة:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  villa.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _makeReservation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "احجز الآن",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
