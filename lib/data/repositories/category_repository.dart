import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/data/models/category_model.dart';

class CategoryRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.categories);

  Stream<List<CategoryModel>> watchActive() {
    return _col.snapshots().map((s) {
      final items = s.docs.map(CategoryModel.fromDoc).where((e) => e.active).toList();
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
    });
  }

  Stream<List<CategoryModel>> watchAll() {
    return _col.snapshots().map((s) {
      final items = s.docs.map(CategoryModel.fromDoc).toList();
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
    });
  }

  Future<List<CategoryModel>> fetchAll() async {
    final snap = await _col.get();
    final items = snap.docs.map(CategoryModel.fromDoc).toList();
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items;
  }

  Future<List<CategoryModel>> fetchActive() async {
    try {
      final snap = await _col.where('active', isEqualTo: true).orderBy('sortOrder').get();
      return snap.docs.map(CategoryModel.fromDoc).toList();
    } catch (_) {
      final snap = await _col.get();
      final items = snap.docs.map(CategoryModel.fromDoc).where((e) => e.active).toList();
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
    }
  }

  Future<CategoryModel?> bySlug(String slug) async {
    final snap = await _col.where('slug', isEqualTo: slug).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return CategoryModel.fromDoc(snap.docs.first);
  }

  Future<CategoryModel?> byId(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return CategoryModel.fromDoc(doc);
  }

  Future<String> save(CategoryModel model) async {
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

  Future<void> bumpServiceCount(String id, int delta) async {
    await _col.doc(id).update({'serviceCount': FieldValue.increment(delta)});
  }
}
