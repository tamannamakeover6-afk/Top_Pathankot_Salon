import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/data/models/subcategory_model.dart';

class SubcategoryRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.subcategories);

  Stream<List<SubcategoryModel>> watchByCategory(String categoryId) {
    return watchAllByCategory(categoryId).map((items) => items.where((e) => e.active).toList());
  }

  Stream<List<SubcategoryModel>> watchAllByCategory(String categoryId) {
    return _col.where('categoryId', isEqualTo: categoryId).snapshots().map((s) {
      final items = s.docs.map(SubcategoryModel.fromDoc).toList();
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
    });
  }

  Stream<List<SubcategoryModel>> watchAll() {
    return _col.snapshots().map((s) {
      final items = s.docs.map(SubcategoryModel.fromDoc).toList();
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
    });
  }

  Future<List<SubcategoryModel>> byCategory(String categoryId) async {
    final items = await byCategoryAll(categoryId);
    return items.where((e) => e.active).toList();
  }

  Future<List<SubcategoryModel>> byCategoryAll(String categoryId) async {
    final snap = await _col.where('categoryId', isEqualTo: categoryId).get();
    final items = snap.docs.map(SubcategoryModel.fromDoc).toList();
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items;
  }

  Future<SubcategoryModel?> byId(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return SubcategoryModel.fromDoc(doc);
  }

  Future<SubcategoryModel?> bySlug(String categoryId, String slug) async {
    final snap = await _col
        .where('categoryId', isEqualTo: categoryId)
        .where('slug', isEqualTo: slug)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return SubcategoryModel.fromDoc(snap.docs.first);
  }

  Future<String> save(SubcategoryModel model) async {
    if (model.id.isEmpty) {
      final ref = await _col.add(model.toMap());
      return ref.id;
    }
    await _col.doc(model.id).set(model.toMap(), SetOptions(merge: true));
    return model.id;
  }

  Future<void> setActive(String id, bool active) =>
      _col.doc(id).update({'active': active, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> delete(String id) => _col.doc(id).delete();
}
