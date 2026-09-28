import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/category_defaults.dart';
import 'package:tamanna/core/utils/date_parser.dart';
import 'package:tamanna/core/utils/slug_utils.dart';

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String shortDescription;
  final String description;
  final String rawDescription;
  final String rawShortDescription;
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
    this.shortDescription = '',
    this.description = '',
    this.rawDescription = '',
    this.rawShortDescription = '',
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
    final name = map['name']?.toString() ?? '';
    final slug = map['slug']?.toString() ?? SlugUtils.from(name);
    final fallback = CategoryDefaults.get(slug: slug, name: name);
    final rawDesc = map['description']?.toString() ?? '';
    final rawShortDesc = map['shortDescription']?.toString() ?? '';

    return CategoryModel(
      id: id ?? map['id']?.toString() ?? '',
      name: name,
      slug: slug,
      rawDescription: rawDesc,
      rawShortDescription: rawShortDesc,
      shortDescription:
          rawShortDesc.trim().isNotEmpty ? rawShortDesc.trim() : fallback.shortDescription,
      description:
          rawDesc.trim().isNotEmpty ? rawDesc.trim() : fallback.description,
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
        'searchKeywords': SlugUtils.keywords('$name $description $shortDescription'),
        'shortDescription': shortDescription,
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
