import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/utils/date_parser.dart';
import 'package:tamanna/core/utils/slug_utils.dart';

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final String imagePublicId;
  final int sortOrder;
  final bool active;
  final int serviceCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.imageUrl = '',
    this.imagePublicId = '',
    this.sortOrder = 0,
    this.active = true,
    this.serviceCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CategoryModel.fromMap(data, id: doc.id);
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CategoryModel(
      id: id ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? SlugUtils.from(map['name']?.toString() ?? ''),
      description: map['description']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      imagePublicId: map['imagePublicId']?.toString() ?? '',
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      active: map['active'] != false,
      serviceCount: (map['serviceCount'] as num?)?.toInt() ?? 0,
      createdAt: DateParser.parse(map['createdAt']),
      updatedAt: DateParser.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'slug': slug,
        'nameLower': SlugUtils.searchable(name),
        'searchKeywords': SlugUtils.keywords('$name $description'),
        'description': description,
        'imageUrl': imageUrl,
        'imagePublicId': imagePublicId,
        'sortOrder': sortOrder,
        'active': active,
        'serviceCount': serviceCount,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
