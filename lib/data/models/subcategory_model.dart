import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/utils/date_parser.dart';
import 'package:tamanna/core/utils/slug_utils.dart';

class SubcategoryModel {
  final String id;
  final String categoryId;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final String imagePublicId;
  final int sortOrder;
  final bool active;
  final DateTime? createdAt;

  const SubcategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.description = '',
    this.imageUrl = '',
    this.imagePublicId = '',
    this.sortOrder = 0,
    this.active = true,
    this.createdAt,
  });

  factory SubcategoryModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return SubcategoryModel.fromMap(doc.data() ?? {}, id: doc.id);
  }

  factory SubcategoryModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return SubcategoryModel(
      id: id ?? map['id']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? SlugUtils.from(map['name']?.toString() ?? ''),
      description: map['description']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      imagePublicId: map['imagePublicId']?.toString() ?? '',
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      active: map['active'] != false,
      createdAt: DateParser.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'categoryId': categoryId,
        'name': name,
        'slug': slug,
        'nameLower': SlugUtils.searchable(name),
        'description': description,
        'imageUrl': imageUrl,
        'imagePublicId': imagePublicId,
        'sortOrder': sortOrder,
        'active': active,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
