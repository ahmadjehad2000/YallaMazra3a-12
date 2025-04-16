import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/villa.dart';

class VillaService {
  final _villaCollection = FirebaseFirestore.instance.collection('villas');

  Future<List<Villa>> fetchVillas() async {
    final snapshot = await _villaCollection.get();
    return snapshot.docs.map((doc) => Villa.fromMap(doc.data())).toList();
  }

  Stream<List<Villa>> streamVillas() {
    return _villaCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Villa.fromMap(doc.data())).toList();
    });
  }
}
