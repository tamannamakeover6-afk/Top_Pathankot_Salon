import 'package:get/get.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/data/models/category_model.dart';
import 'package:tamanna/data/models/offer_model.dart';
import 'package:tamanna/data/models/package_model.dart';
import 'package:tamanna/data/models/review_model.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/models/subcategory_model.dart';
import 'package:tamanna/data/repositories/category_repository.dart';
import 'package:tamanna/data/repositories/offer_repository.dart';
import 'package:tamanna/data/repositories/package_repository.dart';
import 'package:tamanna/data/repositories/review_repository.dart';
import 'package:tamanna/data/repositories/service_repository.dart';
import 'package:tamanna/data/repositories/subcategory_repository.dart';

class CatalogController extends GetxController {
  final categories = <CategoryModel>[].obs;
  final subcategories = <SubcategoryModel>[].obs;
  final featuredServices = <ServiceModel>[].obs;
  final packages = <PackageModel>[].obs;
  final offers = <OfferModel>[].obs;
  final reviews = <ReviewModel>[].obs;
  final listing = <ServiceModel>[].obs;

  final loadingHome = false.obs;
  final loadingListing = false.obs;
  final homeError = ''.obs;
  final listingError = ''.obs;

  final hideFilters = false.obs;
  final selectedSubcategoryIds = <String>{}.obs;
  final selectedServiceIds = <String>{}.obs;
  final filterPackages = false.obs;
  final categoryServices = <ServiceModel>[].obs;

  String selectedCategoryId = '';
  String selectedSubcategoryId = '';
  String sort = 'popular';
  double minPrice = 0;
  double maxPrice = 10000;
  double minRating = 0;
  bool discountedOnly = false;

  final _cats = CategoryRepository();
  final _subs = SubcategoryRepository();
  final _services = ServiceRepository();
  final _packages = PackageRepository();
  final _offers = OfferRepository();
  final _reviews = ReviewRepository();

  @override
  void onInit() {
    super.onInit();
    _cats.watchActive().listen((v) => categories.assignAll(v));
    _subs.watchAll().listen((v) => subcategories.assignAll(v.where((e) => e.active).toList()));
  }

  Future<void> loadHome() async {
    loadingHome.value = true;
    homeError.value = '';
    try {
      final results = await Future.wait([
        _services.featured(),
        _packages.fetchActive(featuredOnly: true),
        _offers.fetchLive(),
        _reviews.fetchApproved(limit: 8),
      ]);
      featuredServices.assignAll(results[0] as List<ServiceModel>);
      packages.assignAll(results[1] as List<PackageModel>);
      offers.assignAll(results[2] as List<OfferModel>);
      reviews.assignAll(results[3] as List<ReviewModel>);
    } catch (e) {
      homeError.value = ErrorHandler.message(e);
    } finally {
      loadingHome.value = false;
    }
  }

  Future<void> loadListing({String? categoryId, String? subcategoryId}) async {
    selectedCategoryId = categoryId ?? selectedCategoryId;
    if (subcategoryId != null) {
      selectedSubcategoryId = subcategoryId;
      if (subcategoryId.isNotEmpty) {
        selectedSubcategoryIds.assignAll([subcategoryId]);
      } else {
        selectedSubcategoryIds.clear();
      }
    }
    loadingListing.value = true;
    listingError.value = '';
    try {
      // Fetch all services for the category if category changed or not yet loaded
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

    // Filter by selected subcategories if any
    if (selectedSubcategoryIds.isNotEmpty) {
      items = items.where((s) => selectedSubcategoryIds.contains(s.subcategoryId)).toList();
    }

    // Filter by specific selected service IDs if any
    if (selectedServiceIds.isNotEmpty) {
      items = items.where((s) => selectedServiceIds.contains(s.id)).toList();
    }

    // Price range
    if (minPrice > 0) {
      items = items.where((s) => s.sellingPrice >= minPrice).toList();
    }
    if (maxPrice < 10000) {
      items = items.where((s) => s.sellingPrice <= maxPrice).toList();
    }

    // Rating
    if (minRating > 0) {
      items = items.where((s) => s.rating >= minRating).toList();
    }

    // Discounted only
    if (discountedOnly) {
      items = items.where((s) => s.discountPercent > 0).toList();
    }

    // Sort
    switch (sort) {
      case 'price_asc':
        items.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
      case 'price_desc':
        items.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case 'rating':
        items.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'discount':
        items.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        break;
      case 'newest':
        items.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        break;
      case 'popular':
      default:
        items.sort((a, b) => (b.popular ? 1 : 0).compareTo(a.popular ? 1 : 0));
        break;
    }

    listing.assignAll(items);
  }

  void toggleSubcategory(String subId) {
    if (selectedSubcategoryIds.contains(subId)) {
      selectedSubcategoryIds.remove(subId);
      // Remove any selected services belonging to this subcategory
      final subServices = categoryServices.where((s) => s.subcategoryId == subId).map((s) => s.id).toSet();
      selectedServiceIds.removeWhere(subServices.contains);
    } else {
      selectedSubcategoryIds.add(subId);
    }
    applyClientFilters();
  }

  void toggleService(String serviceId, String subcategoryId) {
    if (selectedServiceIds.contains(serviceId)) {
      selectedServiceIds.remove(serviceId);
    } else {
      selectedServiceIds.add(serviceId);
      // Ensure parent subcategory is also checked
      selectedSubcategoryIds.add(subcategoryId);
    }
    applyClientFilters();
  }

  void clearFilters() {
    selectedSubcategoryIds.clear();
    selectedServiceIds.clear();
    filterPackages.value = false;
    minPrice = 0;
    maxPrice = 10000;
    minRating = 0;
    discountedOnly = false;
    applyClientFilters();
  }

  bool get hasActiveFilters =>
      selectedSubcategoryIds.isNotEmpty ||
      selectedServiceIds.isNotEmpty ||
      filterPackages.value ||
      minPrice > 0 ||
      maxPrice < 10000 ||
      minRating > 0 ||
      discountedOnly;

  List<ServiceModel> servicesForSub(String subId) =>
      categoryServices.where((s) => s.subcategoryId == subId).toList();

  List<SubcategoryModel> subsFor(String categoryId) =>
      subcategories.where((s) => s.categoryId == categoryId).toList();

  CategoryModel? categoryBySlug(String slug) =>
      categories.firstWhereOrNull((c) => c.slug == slug);

  Future<List<PackageModel>> allPackages() => _packages.fetchActive(limit: 40);
  Future<List<ReviewModel>> allReviews() => _reviews.fetchApproved(limit: 40);
  Future<List<OfferModel>> allOffers() => _offers.fetchLive(limit: 40);
}
