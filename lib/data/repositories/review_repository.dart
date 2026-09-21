import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/data/models/review_model.dart';

class ReviewRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.reviews);

  Future<List<ReviewModel>> fetchApproved({String? serviceId, String? packageId, int limit = 20}) async {
    try {
      Query<Map<String, dynamic>> q = _col.where('status', isEqualTo: 'approved');
      if (serviceId != null) q = q.where('serviceId', isEqualTo: serviceId);
      if (packageId != null) q = q.where('packageId', isEqualTo: packageId);
      final snap = await q.limit(limit).get();
      final items = snap.docs.map(ReviewModel.fromDoc).toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return items;
    } catch (_) {
      final snap = await _col.limit(limit).get();
      return snap.docs
          .map(ReviewModel.fromDoc)
          .where((e) => e.isApproved)
          .where((e) => serviceId == null || e.serviceId == serviceId)
          .toList();
    }
  }

  Stream<List<ReviewModel>> watchAll() {
    return _col.snapshots().map((s) {
      final items = s.docs.map(ReviewModel.fromDoc).toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return items;
    });
  }

  Future<void> create(ReviewModel review) async {
    await _col.add(review.toMap());
  }

  Future<void> setStatus(String id, String status) => _col.doc(id).update({'status': status});

  Future<void> delete(String id) => _col.doc(id).delete();
}
