import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/utils/price_utils.dart';
import 'package:tamanna/data/models/booking_model.dart';
import 'package:tamanna/data/repositories/package_repository.dart';
import 'package:tamanna/data/repositories/service_repository.dart';

class BookingRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.bookings);
  final _services = ServiceRepository();
  final _packages = PackageRepository();

  Future<String> create({
    required String userId,
    String? serviceId,
    String? packageId,
    required String bookingDate,
    required String bookingTime,
    required String customerName,
    required String phone,
    required String address,
    String notes = '',
  }) async {
    double mrp = 0;
    double selling = 0;
    String itemName = '';
    String itemImage = '';

    if (serviceId != null && serviceId.isNotEmpty) {
      final service = await _services.byId(serviceId);
      if (service == null || !service.active) {
        throw Exception('Service is no longer available.');
      }
      mrp = service.mrp;
      selling = service.sellingPrice;
      itemName = service.name;
      itemImage = service.imageUrl;
    } else if (packageId != null && packageId.isNotEmpty) {
      final pack = await _packages.byId(packageId);
      if (pack == null || !pack.active) {
        throw Exception('Package is no longer available.');
      }
      mrp = pack.mrp;
      selling = pack.sellingPrice;
      itemName = pack.name;
      itemImage = pack.imageUrl;
    } else {
      throw Exception('Select a service or package.');
    }

    final booking = BookingModel(
      id: '',
      userId: userId,
      serviceId: serviceId,
      packageId: packageId,
      itemName: itemName,
      itemImage: itemImage,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      customerName: customerName,
      phone: phone,
      address: address,
      notes: notes,
      mrp: mrp,
      discount: (mrp - selling).clamp(0, mrp),
      finalAmount: selling,
      status: BookingStatus.pending,
    );
    final ref = await _col.add(booking.toMap());
    return ref.id;
  }

  Stream<List<BookingModel>> watchMine(String userId) {
    return _col.where('userId', isEqualTo: userId).snapshots().map((s) {
      final items = s.docs.map(BookingModel.fromDoc).toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return items;
    });
  }

  Future<BookingModel?> byId(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return BookingModel.fromDoc(doc);
  }

  Future<void> cancel(String id, String userId) async {
    final booking = await byId(id);
    if (booking == null || booking.userId != userId) {
      throw Exception('Booking not found.');
    }
    if (booking.status == BookingStatus.completed) {
      throw Exception('Completed bookings cannot be cancelled.');
    }
    await _col.doc(id).update({
      'status': BookingStatus.cancelled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  double preview(double mrp, double selling) => PriceUtils.toDouble(selling);
}
