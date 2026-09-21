import 'dart:async';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/data/repositories/search_repository.dart';

class SearchControllerX extends GetxController {
  final repo = SearchRepository();
  final query = ''.obs;
  final results = <SearchHit>[].obs;
  final recent = <String>[].obs;
  final loading = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final box = Hive.box(AppConstants.hivePrefsBox);
    recent.assignAll(List<String>.from(box.get(AppConstants.recentSearchesKey) ?? []));
  }

  void onChanged(String value) {
    query.value = value;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 320), () => search(value));
  }

  Future<void> search(String value) async {
    loading.value = true;
    results.assignAll(await repo.search(value));
    loading.value = false;
  }

  Future<void> commit(String value) async {
    if (value.trim().length < 2) return;
    recent.remove(value);
    recent.insert(0, value);
    if (recent.length > 6) recent.removeRange(6, recent.length);
    await Hive.box(AppConstants.hivePrefsBox).put(AppConstants.recentSearchesKey, recent.toList());
    await search(value);
  }
}
