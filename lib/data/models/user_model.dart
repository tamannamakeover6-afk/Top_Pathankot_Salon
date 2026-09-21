import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/utils/date_parser.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String profilePicUrl;
  final String role;
  final bool isAdmin;
  final bool isDeleted;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.profilePicUrl = '',
    this.role = Roles.customer,
    this.isAdmin = false,
    this.isDeleted = false,
    this.createdAt,
  });

  factory UserModel.initial() => const UserModel(uid: '');

  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    final admin =
        map['isAdmin'] == true || map['is_admin'] == true || map['role'] == Roles.admin;
    return UserModel(
      uid: uid ?? map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? map['location']?.toString() ?? '',
      profilePicUrl: map['profilePicUrl']?.toString() ?? '',
      role: admin ? Roles.admin : (map['role']?.toString() ?? Roles.customer),
      isAdmin: admin,
      isDeleted: map['isDeleted'] == true,
      createdAt: DateParser.parse(map['createdAt']),
    );
  }

  factory UserModel.fromJson(String? json) {
    if (json == null || json.isEmpty) return UserModel.initial();
    return UserModel.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  Map<String, dynamic> toFirebaseMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'profilePicUrl': profilePicUrl,
        'role': isAdmin ? Roles.admin : Roles.customer,
        'isAdmin': isAdmin,
        'is_admin': isAdmin,
        'isDeleted': isDeleted,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toMap() => {'uid': uid, ...toFirebaseMap()};

  String toJson() => jsonEncode({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'profilePicUrl': profilePicUrl,
        'role': role,
        'isAdmin': isAdmin,
        'isDeleted': isDeleted,
      });

  UserModel copyWith({
    String? name,
    String? phone,
    String? address,
    String? profilePicUrl,
    bool? isAdmin,
    String? role,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      role: role ?? this.role,
      isAdmin: isAdmin ?? this.isAdmin,
      isDeleted: isDeleted,
      createdAt: createdAt,
    );
  }
}
