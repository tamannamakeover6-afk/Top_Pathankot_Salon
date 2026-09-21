import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/app_constants.dart';

class FavoriteRepository {
  CollectionReference<Map<String, dynamic>> _col(String uid) => FirebaseFirestore
      .instance
      .collection(Collections.users)
      .doc(uid)
      .collection(Collections.favorites);

  Stream<Set<String>> watchIds(String uid) {
    return _col(uid).snapshots().map(
          (s) => s.docs.map((d) => d.id).toSet(),
        );
  }

  Future<void> toggle(String uid, String itemId, {required bool isPackage}) async {
    final ref = _col(uid).doc(itemId);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'itemId': itemId,
        'isPackage': isPackage,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
