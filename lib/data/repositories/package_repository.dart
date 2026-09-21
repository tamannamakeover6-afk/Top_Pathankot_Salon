import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/data/models/package_model.dart';

class PackageRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.packages);

  Future<List<PackageModel>> fetchActive({bool featuredOnly = false, int limit = 12}) async {
    Query<Map<String, dynamic>> q = _col.where('active', isEqualTo: true);
    if (featuredOnly) q = q.where('featured', isEqualTo: true);
    final snap = await q.limit(limit).get();
    return snap.docs.map(PackageModel.fromDoc).toList();
  }

  Future<PackageModel?> bySlug(String slug) async {
    final snap = await _col.where('slug', isEqualTo: slug).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return PackageModel.fromDoc(snap.docs.first);
  }

  Future<PackageModel?> byId(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return PackageModel.fromDoc(doc);
  }

  Stream<List<PackageModel>> watchAll() {
    return _col.snapshots().map((s) => s.docs.map(PackageModel.fromDoc).toList());
  }

  Future<String> save(PackageModel model) async {
    if (model.id.isEmpty) {
      final ref = await _col.add(model.toMap());
      return ref.id;
    }
    await _col.doc(model.id).set(model.toMap(), SetOptions(merge: true));
    return model.id;
  }

  Future<void> setActive(String id, bool active) =>
      _col.doc(id).update({'active': active, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> updatePricing(String id, {required double mrp, required double sellingPrice}) {
    final percent = mrp <= 0 ? 0 : ((mrp - sellingPrice) / mrp) * 100;
    return _col.doc(id).update({
      'mrp': mrp,
      'sellingPrice': sellingPrice,
      'discountPercent': percent < 0 ? 0 : percent,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<PackageModel>> search(String term, {int limit = 8}) async {
    final q = term.trim().toLowerCase();
    if (q.isEmpty) return [];
    final snap = await _col
        .where('active', isEqualTo: true)
        .where('nameLower', isGreaterThanOrEqualTo: q)
        .where('nameLower', isLessThan: '$q\uf8ff')
        .limit(limit)
        .get();
    return snap.docs.map(PackageModel.fromDoc).toList();
  }
}
