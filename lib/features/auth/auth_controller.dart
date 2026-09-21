import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/data/models/user_model.dart';
import 'package:tamanna/data/repositories/user_repository.dart';

class AuthController extends GetxController {
  final UserRepository repo = UserRepository();
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final loading = false.obs;
  final error = ''.obs;

  bool get isLoggedIn => currentUser.value != null && currentUser.value!.uid.isNotEmpty;
  bool get isAdmin => currentUser.value?.isAdmin == true;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = repo.cached();
    repo.authChanges().listen(_onAuth);
  }

  Future<void> _onAuth(User? user) async {
    if (user == null) {
      currentUser.value = null;
      await repo.clearCache();
      return;
    }
    currentUser.value = await repo.upsertFromAuth(user);
  }

  Future<bool> login(String email, String password) async {
    loading.value = true;
    error.value = '';
    try {
      currentUser.value = await repo.signIn(email: email, password: password);
      return true;
    } catch (e) {
      error.value = ErrorHandler.message(e);
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    loading.value = true;
    error.value = '';
    try {
      currentUser.value = await repo.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      return true;
    } catch (e) {
      error.value = ErrorHandler.message(e);
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateProfile(UserModel user) async {
    await repo.update(user);
    currentUser.value = user;
  }

  Future<void> logout() async {
    await repo.signOut();
    currentUser.value = null;
    Get.offAllNamed('/');
  }
}
