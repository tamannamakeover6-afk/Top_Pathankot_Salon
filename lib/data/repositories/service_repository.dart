import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/data/models/service_model.dart';

class ServiceQuery {
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String sort;
  final int limit;

  const ServiceQuery({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.sort = 'price_asc',
    this.limit = 24,
  });
}

class ServiceRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.services);

  Query<Map<String, dynamic>> _base(ServiceQuery q) {
    Query<Map<String, dynamic>> query = _col.where('active', isEqualTo: true);
    if (q.categoryId != null && q.categoryId!.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: q.categoryId);
    }
    if (q.minPrice != null) {
      query = query.where('sellingPrice', isGreaterThanOrEqualTo: q.minPrice);
    }
    if (q.maxPrice != null) {
      query = query.where('sellingPrice', isLessThanOrEqualTo: q.maxPrice);
    }

    switch (q.sort) {
      case 'price_asc':
        query = query.orderBy('sellingPrice');
        break;
      case 'price_desc':
        query = query.orderBy('sellingPrice', descending: true);
        break;
      case 'rating':
        query = query.orderBy('rating', descending: true);
        break;
      case 'newest':
        query = query.orderBy('createdAt', descending: true);
        break;
      default:
        query = query.orderBy('sellingPrice');
        break;
    }
    return query.limit(q.limit);
  }

  Future<List<ServiceModel>> query(ServiceQuery q) async {
    try {
      final snap = await _base(q).get();
      return snap.docs.map(ServiceModel.fromDoc).toList();
    } on FirebaseException {
      final fallback = await _col.where('active', isEqualTo: true).limit(q.limit).get();
      var items = fallback.docs.map(ServiceModel.fromDoc).toList();
      if (q.categoryId != null) {
        items = items.where((e) => e.categoryId == q.categoryId).toList();
      }
      return _sortLocal(items, q.sort);
    }
  }

  List<ServiceModel> _sortLocal(List<ServiceModel> items, String sort) {
    final copy = [...items];
    switch (sort) {
      case 'price_desc':
        copy.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case 'rating':
        copy.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
        copy.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        break;
      case 'price_asc':
      default:
        // Km price pehle (lowest price first)
        copy.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
    }
    return copy;
  }

  Future<ServiceModel?> bySlug(String slug) async {
    final snap = await _col.where('slug', isEqualTo: slug).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return ServiceModel.fromDoc(snap.docs.first);
  }

  Future<ServiceModel?> byId(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return ServiceModel.fromDoc(doc);
  }

  Future<List<ServiceModel>> byIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 10) {
      chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
    }
    final out = <ServiceModel>[];
    for (final chunk in chunks) {
      final snap = await _col.where(FieldPath.documentId, whereIn: chunk).get();
      out.addAll(snap.docs.map(ServiceModel.fromDoc));
    }
    return _sortLocal(out, 'price_asc');
  }

  Future<List<ServiceModel>> related({
    required String categoryId,
    required String excludeId,
    int limit = 4,
  }) async {
    final items = await query(ServiceQuery(categoryId: categoryId, sort: 'price_asc', limit: limit + 5));
    return items.where((e) => e.id != excludeId).take(limit).toList();
  }

  Stream<List<ServiceModel>> watchAll({String sort = 'price_asc'}) {
    return _col.snapshots().map((s) {
      final items = s.docs.map(ServiceModel.fromDoc).toList();
      return _sortLocal(items, sort);
    });
  }

  Stream<List<ServiceModel>> watchActive({
    String? categoryId,
    String sort = 'price_asc',
    int limit = 100,
  }) {
    Query<Map<String, dynamic>> query = _col;
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    return query.snapshots().map((s) {
      var items = s.docs.map(ServiceModel.fromDoc).where((e) => e.active).toList();
      items = _sortLocal(items, sort);
      if (items.length > limit) {
        items = items.sublist(0, limit);
      }
      return items;
    });
  }

  Stream<List<ServiceModel>> watchByCategory(String categoryId, {String sort = 'price_asc'}) {
    return _col.where('categoryId', isEqualTo: categoryId).snapshots().map((s) {
      final items = s.docs.map(ServiceModel.fromDoc).toList();
      return _sortLocal(items, sort);
    });
  }

  Stream<ServiceModel?> watchById(String id) {
    return _col.doc(id).snapshots().map((doc) => doc.exists ? ServiceModel.fromDoc(doc) : null);
  }

  Stream<ServiceModel?> watchBySlug(String slug) {
    return _col.where('slug', isEqualTo: slug).limit(1).snapshots().map((snap) {
      if (snap.docs.isEmpty) return null;
      return ServiceModel.fromDoc(snap.docs.first);
    });
  }

  Stream<List<ServiceModel>> watchRelated({
    required String categoryId,
    required String excludeId,
    int limit = 4,
  }) {
    return watchActive(categoryId: categoryId, sort: 'price_asc', limit: limit + 5).map((items) {
      return items.where((e) => e.id != excludeId).take(limit).toList();
    });
  }

  Future<String> save(ServiceModel model) async {
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

  Future<List<ServiceModel>> search(String term, {int limit = 12}) async {
    final q = term.trim().toLowerCase();
    if (q.isEmpty) return [];
    final snap = await _col
        .where('active', isEqualTo: true)
        .where('nameLower', isGreaterThanOrEqualTo: q)
        .where('nameLower', isLessThan: '$q\uf8ff')
        .limit(limit)
        .get();
    return snap.docs.map(ServiceModel.fromDoc).toList();
  }
}
