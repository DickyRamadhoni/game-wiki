import 'package:cloud_firestore/cloud_firestore.dart';

class ItemService {
  final CollectionReference itemsCollection = FirebaseFirestore.instance
      .collection('items');

  // Ambil items sekali
  Future<List<Map<String, dynamic>>> fetchItems() async {
    try {
      final snapshot = await itemsCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // untuk history
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching items: $e");
      return [];
    }
  }

  // Stream realtime semua items
  Stream<List<Map<String, dynamic>>> streamItems() {
    return itemsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // simpan doc ID
        return data;
      }).toList();
    });
  }
}
