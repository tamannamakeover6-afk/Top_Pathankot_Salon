import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/data/models/package_model.dart';

class PackageRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.packages);

  List<PackageModel> _sortLocal(List<PackageModel> items, String sort) {
    final copy = [...items];
    switch (sort) {
      case 'price_desc':
        copy.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case 'price_asc':
      default:
        // Km price pehle (lowest price first)
        copy.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
    }
    return copy;
  }

  Stream<List<PackageModel>> watchActive({int limit = 40, String sort = 'price_asc'}) {
    return _col.where('active', isEqualTo: true).snapshots().map((s) {
      var items = s.docs.map(PackageModel.fromDoc).toList();
      items = _sortLocal(items, sort);
      if (items.length > limit) items = items.sublist(0, limit);
      return items;
    });
  }

  Stream<List<PackageModel>> watchAll({String sort = 'price_asc'}) {
    return _col.snapshots().map((s) {
      final items = s.docs.map(PackageModel.fromDoc).toList();
      return _sortLocal(items, sort);
    });
  }

  Stream<PackageModel?> watchById(String id) {
    return _col.doc(id).snapshots().map((doc) => doc.exists ? PackageModel.fromDoc(doc) : null);
  }

  Stream<PackageModel?> watchBySlug(String slug) {
    return _col.where('slug', isEqualTo: slug).limit(1).snapshots().map((snap) {
      if (snap.docs.isEmpty) return null;
      return PackageModel.fromDoc(snap.docs.first);
    });
  }

  Future<List<PackageModel>> fetchActive({int limit = 12, String sort = 'price_asc'}) async {
    Query<Map<String, dynamic>> q = _col.where('active', isEqualTo: true);
    final snap = await q.limit(limit).get();
    final items = snap.docs.map(PackageModel.fromDoc).toList();
    return _sortLocal(items, sort);
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

  Future<String> save(PackageModel model) async {
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
