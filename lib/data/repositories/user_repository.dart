import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/data/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Box get _box => Hive.box(AppConstants.hiveUserBox);

  Future<void> cache(UserModel user) async {
    await _box.put('userDetails', user.toJson());
  }

  UserModel? cached() {
    final raw = _box.get('userDetails');
    if (raw is String && raw.isNotEmpty) return UserModel.fromJson(raw);
    return null;
  }

  Future<void> clearCache() async => _box.delete('userDetails');

  Future<UserModel?> getById(String uid) async {
    final doc = await _db.collection(Collections.users).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid: doc.id);
  }

  Future<UserModel> upsertFromAuth(User user, {String? name, String? phone}) async {
    final existing = await getById(user.uid);
    if (existing != null) {
      await cache(existing);
      return existing;
    }
    final model = UserModel(
      uid: user.uid,
      name: name ?? user.displayName ?? '',
      email: user.email ?? '',
      phone: phone ?? '',
      createdAt: DateTime.now(),
    );
    await _db.collection(Collections.users).doc(user.uid).set(model.toFirebaseMap());
    await cache(model);
    return model;
  }

  Future<void> update(UserModel user) async {
    await _db.collection(Collections.users).doc(user.uid).update({
      ...user.toFirebaseMap(),
      'createdAt': user.createdAt != null
          ? Timestamp.fromDate(user.createdAt!)
          : FieldValue.serverTimestamp(),
    });
    await cache(user);
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    return upsertFromAuth(cred.user!, name: name, phone: phone);
  }

  Future<UserModel> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return upsertFromAuth(cred.user!);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await clearCache();
  }

  Stream<User?> authChanges() => _auth.authStateChanges();
}
