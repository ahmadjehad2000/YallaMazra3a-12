// villa_listings_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/villa.dart';
import 'villa_detail_screen.dart';

class VillaListingsScreen extends StatelessWidget {
  const VillaListingsScreen({Key? key}) : super(key: key);

  Stream<List<Villa>> getVillaStream() {
    return FirebaseFirestore.instance.collection('villas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Villa.fromMap(doc.data())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("استكشف المزارع", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<Villa>>(
        stream: getVillaStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("حدث خطأ في تحميل البيانات"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد مزارع متاحة حالياً"));
          }

          final villas = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: villas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final villa = villas[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VillaDetailScreen(villa: villa),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          villa.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.image_not_supported)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    villa.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey[600])
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${villa.price} ريال / الليلة',
                              style: const TextStyle(fontSize: 16, color: Color(0xFF00C853)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              villa.description.length > 60
                                  ? villa.description.substring(0, 60) + '...'
                                  : villa.description,
                              style: const TextStyle(color: Colors.black54, fontSize: 14),
                            )
                          ],
                        ),
                      )
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
}