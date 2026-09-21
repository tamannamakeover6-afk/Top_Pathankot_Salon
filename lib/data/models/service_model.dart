import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/utils/date_parser.dart';
import 'package:tamanna/core/utils/price_utils.dart';
import 'package:tamanna/core/utils/slug_utils.dart';

class ServiceModel {
  final String id;
  final String name;
  final String slug;
  final String categoryId;
  final String shortDescription;
  final String description;
  final String imageUrl;
  final String imagePublicId;
  final List<String> gallery;
  final double mrp;
  final double sellingPrice;
  final double discountPercent;
  final int durationMinutes;
  final List<String> benefits;
  final List<String> includedItems;
  final List<String> terms;
  final List<String> faqs;
  final double rating;
  final int reviewCount;
  final bool popular;
  final bool active;
  final DateTime? createdAt;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.categoryId,
    this.shortDescription = '',
    this.description = '',
    this.imageUrl = '',
    this.imagePublicId = '',
    this.gallery = const [],
    this.mrp = 0,
    this.sellingPrice = 0,
    this.discountPercent = 0,
    this.durationMinutes = 60,
    this.benefits = const [],
    this.includedItems = const [],
    this.terms = const [],
    this.faqs = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.popular = false,
    this.active = true,
    this.createdAt,
  });

  factory ServiceModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ServiceModel.fromMap(doc.data() ?? {}, id: doc.id);
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final mrp = PriceUtils.toDouble(map['mrp']);
    final selling = PriceUtils.toDouble(map['sellingPrice']);
    return ServiceModel(
      id: id ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? SlugUtils.from(map['name']?.toString() ?? ''),
      categoryId: map['categoryId']?.toString() ?? '',
      shortDescription: map['shortDescription']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      imagePublicId: map['imagePublicId']?.toString() ?? '',
      gallery: List<String>.from(map['gallery'] ?? const []),
      mrp: mrp,
      sellingPrice: selling,
      discountPercent: PriceUtils.toDouble(map['discountPercent']) > 0
          ? PriceUtils.toDouble(map['discountPercent'])
          : PriceUtils.discountPercent(mrp, selling),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 60,
      benefits: List<String>.from(map['benefits'] ?? const []),
      includedItems: List<String>.from(map['includedItems'] ?? const []),
      terms: List<String>.from(map['terms'] ?? const []),
      faqs: List<String>.from(map['faqs'] ?? const []),
      rating: PriceUtils.toDouble(map['rating']),
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      popular: map['popular'] == true,
      active: map['active'] != false,
      createdAt: DateParser.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    final percent = PriceUtils.discountPercent(mrp, sellingPrice);
    return {
      'name': name,
      'slug': slug,
      'nameLower': SlugUtils.searchable(name),
      'searchKeywords': SlugUtils.keywords('$name $shortDescription $description'),
      'categoryId': categoryId,
      'shortDescription': shortDescription,
      'description': description,
      'imageUrl': imageUrl,
      'imagePublicId': imagePublicId,
      'gallery': gallery,
      'mrp': mrp,
      'sellingPrice': sellingPrice,
      'discountPercent': percent,
      'durationMinutes': durationMinutes,
      'benefits': benefits,
      'includedItems': includedItems,
      'terms': terms,
      'faqs': faqs,
      'rating': rating,
      'reviewCount': reviewCount,
      'popular': popular,
      'active': active,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
