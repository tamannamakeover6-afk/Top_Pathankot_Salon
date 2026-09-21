import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/utils/date_parser.dart';
import 'package:tamanna/core/utils/price_utils.dart';

enum DiscountType { percentage, fixed }

class OfferModel {
  final String id;
  final String title;
  final String description;
  final String discountType;
  final double discountValue;
  final String bannerUrl;
  final String bannerPublicId;
  final List<String> categoryIds;
  final List<String> subcategoryIds;
  final List<String> serviceIds;
  final List<String> packageIds;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool active;
  final bool featured;
  final DateTime? createdAt;

  const OfferModel({
    required this.id,
    required this.title,
    this.description = '',
    this.discountType = 'percentage',
    this.discountValue = 0,
    this.bannerUrl = '',
    this.bannerPublicId = '',
    this.categoryIds = const [],
    this.subcategoryIds = const [],
    this.serviceIds = const [],
    this.packageIds = const [],
    this.startAt,
    this.endAt,
    this.active = true,
    this.featured = false,
    this.createdAt,
  });

  bool get isScheduled {
    final now = DateTime.now();
    return startAt != null && startAt!.isAfter(now);
  }

  bool get isExpired {
    final now = DateTime.now();
    return endAt != null && endAt!.isBefore(now);
  }

  bool get isLive => active && !isScheduled && !isExpired;

  String get statusLabel {
    if (isExpired) return 'Expired';
    if (isScheduled) return 'Scheduled';
    if (active) return 'Active';
    return 'Inactive';
  }

  factory OfferModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return OfferModel.fromMap(doc.data() ?? {}, id: doc.id);
  }

  factory OfferModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return OfferModel(
      id: id ?? map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      discountType: map['discountType']?.toString() ?? 'percentage',
      discountValue: PriceUtils.toDouble(map['discountValue']),
      bannerUrl: map['bannerUrl']?.toString() ?? '',
      bannerPublicId: map['bannerPublicId']?.toString() ?? '',
      categoryIds: List<String>.from(map['categoryIds'] ?? const []),
      subcategoryIds: List<String>.from(map['subcategoryIds'] ?? const []),
      serviceIds: List<String>.from(map['serviceIds'] ?? const []),
      packageIds: List<String>.from(map['packageIds'] ?? const []),
      startAt: DateParser.parse(map['startAt']),
      endAt: DateParser.parse(map['endAt']),
      active: map['active'] != false,
      featured: map['featured'] == true,
      createdAt: DateParser.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'discountType': discountType,
        'discountValue': discountValue,
        'bannerUrl': bannerUrl,
        'bannerPublicId': bannerPublicId,
        'categoryIds': categoryIds,
        'subcategoryIds': subcategoryIds,
        'serviceIds': serviceIds,
        'packageIds': packageIds,
        'startAt': startAt != null ? Timestamp.fromDate(startAt!) : null,
        'endAt': endAt != null ? Timestamp.fromDate(endAt!) : null,
        'active': active,
        'featured': featured,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
