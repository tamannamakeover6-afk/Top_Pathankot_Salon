import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/utils/date_parser.dart';
import 'package:tamanna/core/utils/price_utils.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String? serviceId;
  final String? packageId;
  final String itemName;
  final int rating;
  final String review;
  final String photoUrl;
  final String status;
  final DateTime? createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    this.userName = '',
    this.userAvatar = '',
    this.serviceId,
    this.packageId,
    this.itemName = '',
    this.rating = 5,
    this.review = '',
    this.photoUrl = '',
    this.status = 'pending',
    this.createdAt,
  });

  bool get isApproved => status == 'approved';

  factory ReviewModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ReviewModel.fromMap(doc.data() ?? {}, id: doc.id);
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ReviewModel(
      id: id ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      userAvatar: map['userAvatar']?.toString() ?? '',
      serviceId: map['serviceId']?.toString(),
      packageId: map['packageId']?.toString(),
      itemName: map['itemName']?.toString() ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 5,
      review: map['review']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: DateParser.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'serviceId': serviceId,
        'packageId': packageId,
        'itemName': itemName,
        'rating': rating,
        'review': review,
        'photoUrl': photoUrl,
        'status': status,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };

  double get ratingValue => PriceUtils.toDouble(rating);
}
