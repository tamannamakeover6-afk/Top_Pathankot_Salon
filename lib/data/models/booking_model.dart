import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/utils/date_parser.dart';
import 'package:tamanna/core/utils/price_utils.dart';

class BookingStatus {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const inProgress = 'in_progress';
  static const completed = 'completed';
  static const cancelled = 'cancelled';

  static const labels = {
    pending: 'Pending',
    confirmed: 'Confirmed',
    inProgress: 'In Progress',
    completed: 'Completed',
    cancelled: 'Cancelled',
  };
}

class BookingModel {
  final String id;
  final String userId;
  final String? serviceId;
  final String? packageId;
  final String itemName;
  final String itemImage;
  final String bookingDate;
  final String bookingTime;
  final String customerName;
  final String phone;
  final String address;
  final String notes;
  final double mrp;
  final double discount;
  final double finalAmount;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingModel({
    required this.id,
    required this.userId,
    this.serviceId,
    this.packageId,
    this.itemName = '',
    this.itemImage = '',
    this.bookingDate = '',
    this.bookingTime = '',
    this.customerName = '',
    this.phone = '',
    this.address = '',
    this.notes = '',
    this.mrp = 0,
    this.discount = 0,
    this.finalAmount = 0,
    this.status = BookingStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return BookingModel.fromMap(doc.data() ?? {}, id: doc.id);
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return BookingModel(
      id: id ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      serviceId: map['serviceId']?.toString(),
      packageId: map['packageId']?.toString(),
      itemName: map['itemName']?.toString() ?? '',
      itemImage: map['itemImage']?.toString() ?? '',
      bookingDate: map['bookingDate']?.toString() ?? '',
      bookingTime: map['bookingTime']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      mrp: PriceUtils.toDouble(map['mrp']),
      discount: PriceUtils.toDouble(map['discount']),
      finalAmount: PriceUtils.toDouble(map['finalAmount']),
      status: map['status']?.toString() ?? BookingStatus.pending,
      createdAt: DateParser.parse(map['createdAt']),
      updatedAt: DateParser.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'serviceId': serviceId,
        'packageId': packageId,
        'itemName': itemName,
        'itemImage': itemImage,
        'bookingDate': bookingDate,
        'bookingTime': bookingTime,
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'notes': notes,
        'mrp': mrp,
        'discount': discount,
        'finalAmount': finalAmount,
        'status': status,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
