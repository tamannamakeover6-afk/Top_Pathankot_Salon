import 'dart:async';
import 'package:get/get.dart';
import 'package:tamanna/data/repositories/favorite_repository.dart';
import 'package:tamanna/features/auth/auth_controller.dart';

class FavoritesController extends GetxController {
  final FavoriteRepository _repo = FavoriteRepository();
  final RxSet<String> favoriteIds = <String>{}.obs;
  StreamSubscription<Set<String>>? _sub;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    ever(auth.currentUser, (user) {
      _sub?.cancel();
      if (user != null) {
        _sub = _repo.watchIds(user.uid).listen((ids) {
          favoriteIds.assignAll(ids);
        });
      } else {
        favoriteIds.clear();
      }
    });

    final current = auth.currentUser.value;
    if (current != null) {
      _sub = _repo.watchIds(current.uid).listen((ids) {
        favoriteIds.assignAll(ids);
      });
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  bool isFavorite(String id) => favoriteIds.contains(id);

  Future<void> toggle(String id, {bool isPackage = false}) async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      // Local optimistic toggle if guest
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
      return;
    }

    final uid = auth.currentUser.value!.uid;
    // Optimistic UI update
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }

    try {
      await _repo.toggle(uid, id, isPackage: isPackage);
    } catch (_) {
      // Rollback on error
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
    }
  }
}
