import 'dart:async';
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
  String sort = 'price_asc'; // Default: lowest price first (km price pehle)

  final _cats = CategoryRepository();
  final _services = ServiceRepository();
  final _packages = PackageRepository();
  final _offers = OfferRepository();

  StreamSubscription<List<CategoryModel>>? _catSub;
  StreamSubscription<List<ServiceModel>>? _homeServicesSub;
  StreamSubscription<List<PackageModel>>? _packagesSub;
  StreamSubscription<List<OfferModel>>? _offersSub;
  StreamSubscription<List<ServiceModel>>? _listingSub;

  @override
  void onInit() {
    super.onInit();
    // Real-time active categories stream
    _catSub = _cats.watchActive().listen((v) => categories.assignAll(v));

    // Initialize real-time streams for home data (services, packages, offers)
    _initHomeStreams();
  }

  void _initHomeStreams() {
    loadingHome.value = true;
    homeError.value = '';

    // Real-time services stream, sorted by lowest price first
    _homeServicesSub?.cancel();
    _homeServicesSub = _services.watchActive(sort: 'price_asc', limit: 8).listen(
      (items) {
        homeServices.assignAll(items);
        loadingHome.value = false;
      },
      onError: (e) {
        homeError.value = ErrorHandler.message(e);
        loadingHome.value = false;
      },
    );

    // Real-time packages stream, sorted by lowest price first
    _packagesSub?.cancel();
    _packagesSub = _packages.watchActive(sort: 'price_asc', limit: 12).listen(
      (items) => packages.assignAll(items),
      onError: (e) => homeError.value = ErrorHandler.message(e),
    );

    // Real-time live offers stream
    _offersSub?.cancel();
    _offersSub = _offers.watchLive().listen(
      (items) => offers.assignAll(items),
      onError: (e) => homeError.value = ErrorHandler.message(e),
    );
  }

  Future<void> loadHome() async {
    // Re-bind / restart streams if necessary
    _initHomeStreams();
  }

  Future<void> loadListing({String? categoryId}) async {
    selectedCategoryId = categoryId ?? selectedCategoryId;
    loadingListing.value = true;
    listingError.value = '';

    _listingSub?.cancel();
    // Real-time stream for category services, sorted by price ascending
    _listingSub = _services
        .watchActive(
          categoryId: selectedCategoryId.isEmpty ? null : selectedCategoryId,
          sort: sort,
          limit: 100,
        )
        .listen(
          (allForCat) {
            categoryServices.assignAll(allForCat);
            applyClientFilters();
            loadingListing.value = false;
          },
          onError: (e) {
            listingError.value = ErrorHandler.message(e);
            loadingListing.value = false;
          },
        );
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
      case 'price_desc':
        items.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case 'newest':
        items.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        break;
      case 'price_asc':
      default:
        // Km price pehle (lowest price first)
        items.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
    }

    listing.assignAll(items);
  }

  CategoryModel? categoryBySlug(String slug) =>
      categories.firstWhereOrNull((c) => c.slug == slug);

  Stream<List<PackageModel>> watchPackages({int limit = 40}) =>
      _packages.watchActive(limit: limit, sort: 'price_asc');

  Stream<List<OfferModel>> watchOffers({int limit = 40}) =>
      _offers.watchLive(limit: limit);

  Future<List<PackageModel>> allPackages() => _packages.fetchActive(limit: 40, sort: 'price_asc');
  Future<List<OfferModel>> allOffers() => _offers.fetchLive(limit: 40);

  @override
  void onClose() {
    _catSub?.cancel();
    _homeServicesSub?.cancel();
    _packagesSub?.cancel();
    _offersSub?.cancel();
    _listingSub?.cancel();
    super.onClose();
  }
}
