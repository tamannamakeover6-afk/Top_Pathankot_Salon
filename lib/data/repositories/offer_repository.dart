import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/data/models/offer_model.dart';

class OfferRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.offers);

  Future<List<OfferModel>> fetchLive({int limit = 12}) async {
    final snap = await _col.where('active', isEqualTo: true).limit(limit).get();
    return snap.docs.map(OfferModel.fromDoc).where((e) => e.isLive).toList();
  }

  Stream<List<OfferModel>> watchAll() {
    return _col.snapshots().map((s) => s.docs.map(OfferModel.fromDoc).toList());
  }

  Future<String> save(OfferModel model) async {
    if (model.id.isEmpty) {
      final ref = await _col.add(model.toMap());
      return ref.id;
    }
    await _col.doc(model.id).set(model.toMap(), SetOptions(merge: true));
    return model.id;
  }

  Future<void> setActive(String id, bool active) =>
      _col.doc(id).set({'active': active, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

  Future<void> delete(String id) => _col.doc(id).delete();
}
