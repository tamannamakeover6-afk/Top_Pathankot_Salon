import 'package:get/get.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/data/models/category_model.dart';
import 'package:tamanna/data/models/offer_model.dart';
import 'package:tamanna/data/models/package_model.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/repositories/category_repository.dart';
import 'package:tamanna/data/repositories/offer_repository.dart';
import 'package:tamanna/data/repositories/package_repository.dart';
import 'package:tamanna/data/repositories/service_repository.dart';

class CatalogController extends GetxController {
  final categories = <CategoryModel>[].obs;
  final homeServices = <ServiceModel>[].obs;
  final packages = <PackageModel>[].obs;
  final offers = <OfferModel>[].obs;
  final listing = <ServiceModel>[].obs;
  final categoryServices = <ServiceModel>[].obs;

  final loadingHome = false.obs;
  final loadingListing = false.obs;
  final homeError = ''.obs;
  final listingError = ''.obs;
  final searchQuery = ''.obs;

  String selectedCategoryId = '';
  String sort = 'newest';

  final _cats = CategoryRepository();
  final _services = ServiceRepository();
  final _packages = PackageRepository();
  final _offers = OfferRepository();

  @override
  void onInit() {
    super.onInit();
    _cats.watchActive().listen((v) => categories.assignAll(v));
  }

  Future<void> loadHome() async {
    loadingHome.value = true;
    homeError.value = '';
    try {
      final results = await Future.wait([
        _services.query(const ServiceQuery(sort: 'newest', limit: 8)),
        _packages.fetchActive(limit: 12),
        _offers.fetchLive(),
      ]);
      homeServices.assignAll(results[0] as List<ServiceModel>);
      packages.assignAll(results[1] as List<PackageModel>);
      offers.assignAll(results[2] as List<OfferModel>);
    } catch (e) {
      homeError.value = ErrorHandler.message(e);
    } finally {
      loadingHome.value = false;
    }
  }

  Future<void> loadListing({String? categoryId}) async {
    selectedCategoryId = categoryId ?? selectedCategoryId;
    loadingListing.value = true;
    listingError.value = '';
    try {
      final allForCat = await _services.query(
        ServiceQuery(
          categoryId: selectedCategoryId.isEmpty ? null : selectedCategoryId,
          limit: 100,
        ),
      );
      categoryServices.assignAll(allForCat);
      applyClientFilters();
    } catch (e) {
      listingError.value = ErrorHandler.message(e);
    } finally {
      loadingListing.value = false;
    }
  }

  void applyClientFilters() {
    var items = List<ServiceModel>.from(categoryServices);
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.shortDescription.toLowerCase().contains(q) ||
            s.description.toLowerCase().contains(q);
      }).toList();
    }

    switch (sort) {
      case 'price_asc':
        items.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
      case 'price_desc':
        items.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case 'newest':
      default:
        items.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        break;
    }

    listing.assignAll(items);
  }

  CategoryModel? categoryBySlug(String slug) =>
      categories.firstWhereOrNull((c) => c.slug == slug);

  Future<List<PackageModel>> allPackages() => _packages.fetchActive(limit: 40);
  Future<List<OfferModel>> allOffers() => _offers.fetchLive(limit: 40);
}
