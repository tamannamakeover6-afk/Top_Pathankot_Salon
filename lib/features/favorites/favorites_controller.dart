import 'package:get/get.dart';
import 'package:tamanna/data/repositories/favorite_repository.dart';
import 'package:tamanna/features/auth/auth_controller.dart';

class FavoritesController extends GetxController {
  final FavoriteRepository repo = FavoriteRepository();
  final ids = <String>{}.obs;

  AuthController get _auth => Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    ever(_auth.currentUser, (_) => _bind());
    _bind();
  }

  void _bind() {
    final uid = _auth.currentUser.value?.uid;
    if (uid == null || uid.isEmpty) {
      ids.clear();
      return;
    }
    repo.watchIds(uid).listen((value) => ids.assignAll(value));
  }

  bool isFavorite(String id) => ids.contains(id);

  Future<void> toggle(String id, {bool isPackage = false}) async {
    final uid = _auth.currentUser.value?.uid;
    if (uid == null || uid.isEmpty) {
      Get.toNamed('/login');
      return;
    }
    await repo.toggle(uid, id, isPackage: isPackage);
  }
}
