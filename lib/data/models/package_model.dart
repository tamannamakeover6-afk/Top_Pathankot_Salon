import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/utils/date_parser.dart';
import 'package:tamanna/core/utils/price_utils.dart';
import 'package:tamanna/core/utils/slug_utils.dart';

class PackageModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final String imagePublicId;
  final List<String> serviceIds;
  final int durationMinutes;
  final double mrp;
  final double sellingPrice;
  final double discountPercent;
  final bool active;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? createdAt;

  const PackageModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.imageUrl = '',
    this.imagePublicId = '',
    this.serviceIds = const [],
    this.durationMinutes = 120,
    this.mrp = 0,
    this.sellingPrice = 0,
    this.discountPercent = 0,
    this.active = true,
    this.startAt,
    this.endAt,
    this.createdAt,
  });

  factory PackageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return PackageModel.fromMap(doc.data() ?? {}, id: doc.id);
  }

  factory PackageModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final mrp = PriceUtils.toDouble(map['mrp']);
    final selling = PriceUtils.toDouble(map['sellingPrice']);
    return PackageModel(
      id: id ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? SlugUtils.from(map['name']?.toString() ?? ''),
      description: map['description']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      imagePublicId: map['imagePublicId']?.toString() ?? '',
      serviceIds: List<String>.from(map['serviceIds'] ?? const []),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 120,
      mrp: mrp,
      sellingPrice: selling,
      discountPercent: PriceUtils.toDouble(map['discountPercent']) > 0
          ? PriceUtils.toDouble(map['discountPercent'])
          : PriceUtils.discountPercent(mrp, selling),
      active: map['active'] != false,
      startAt: DateParser.parse(map['startAt']),
      endAt: DateParser.parse(map['endAt']),
      createdAt: DateParser.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    final percent = PriceUtils.discountPercent(mrp, sellingPrice);
    return {
      'name': name,
      'slug': slug,
      'nameLower': SlugUtils.searchable(name),
      'searchKeywords': SlugUtils.keywords('$name $description'),
      'description': description,
      'imageUrl': imageUrl,
      'imagePublicId': imagePublicId,
      'serviceIds': serviceIds,
      'durationMinutes': durationMinutes,
      'mrp': mrp,
      'sellingPrice': sellingPrice,
      'discountPercent': percent,
      'active': active,
      'startAt': startAt != null ? Timestamp.fromDate(startAt!) : null,
      'endAt': endAt != null ? Timestamp.fromDate(endAt!) : null,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
