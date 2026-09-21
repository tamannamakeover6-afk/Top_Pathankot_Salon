import 'package:get/get.dart';
import 'package:tamanna/features/auth/auth_controller.dart';
import 'package:tamanna/features/catalog/catalog_controller.dart';
import 'package:tamanna/features/favorites/favorites_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(FavoritesController(), permanent: true);
    Get.put(CatalogController(), permanent: true);
  }
}
