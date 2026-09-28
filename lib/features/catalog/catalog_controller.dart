import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/constants/category_defaults.dart';
import 'package:tamanna/core/constants/service_defaults.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/core/utils/slug_utils.dart';
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
  final allActiveServices = <ServiceModel>[].obs;
  final servicesLoaded = false.obs;
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
  StreamSubscription<List<ServiceModel>>? _allServicesSub;
  StreamSubscription<List<PackageModel>>? _packagesSub;
  StreamSubscription<List<OfferModel>>? _offersSub;
  StreamSubscription<List<ServiceModel>>? _listingSub;

  @override
  void onInit() {
    super.onInit();
    // Real-time active categories stream
    _catSub = _cats.watchActive().listen((v) {
      categories.assignAll(v);
      _syncAllDataToFirestore(allActiveServices);
    });

    // Real-time stream of all active services for accurate dynamic counts per category
    _allServicesSub = _services.watchActive(limit: 1000).listen(
      (items) {
        allActiveServices.assignAll(items);
        servicesLoaded.value = true;
        _syncAllDataToFirestore(items);
      },
      onError: (_) {
        servicesLoaded.value = true;
      },
    );

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
    _initHomeStreams();
    if (categories.isEmpty) {
      try {
        final cats = await _cats.fetchActive();
        if (categories.isEmpty) categories.assignAll(cats);
      } catch (_) {}
    }
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

  bool matchesCategory(ServiceModel service, CategoryModel cat) {
    final sCat = service.categoryId.trim().toLowerCase();
    final cId = cat.id.trim().toLowerCase();
    final cSlug = cat.slug.trim().toLowerCase();
    final cName = cat.name.trim().toLowerCase();

    if (sCat.isEmpty) return false;
    if (cId.isNotEmpty && sCat == cId) return true;
    if (cSlug.isNotEmpty && (sCat == cSlug || sCat == 'cat_$cSlug')) return true;
    if (cName.isNotEmpty && (sCat == cName || sCat == SlugUtils.from(cName))) return true;
    return false;
  }

  int serviceCountFor(CategoryModel cat) {
    if (!servicesLoaded.value && allActiveServices.isEmpty) {
      return cat.serviceCount;
    }
    return allActiveServices.where((s) => matchesCategory(s, cat)).length;
  }

  void _syncAllDataToFirestore(List<ServiceModel> services) {
    if (categories.isEmpty) return;
    for (final cat in categories) {
      if (cat.id.isEmpty) continue;
      final fallback = CategoryDefaults.get(slug: cat.slug, name: cat.name);
      final updates = <String, dynamic>{};

      // If category has no description saved in Firestore, auto-populate the static description!
      if (cat.rawDescription.trim().isEmpty && fallback.description.isNotEmpty) {
        updates['description'] = fallback.description;
      }
      if (cat.rawShortDescription.trim().isEmpty && fallback.shortDescription.isNotEmpty) {
        updates['shortDescription'] = fallback.shortDescription;
      }

      if (services.isNotEmpty) {
        final realCount = services.where((s) => matchesCategory(s, cat)).length;
        if (cat.serviceCount != realCount) {
          updates['serviceCount'] = realCount;
        }
      }

      if (updates.isNotEmpty) {
        FirebaseFirestore.instance
            .collection(Collections.categories)
            .doc(cat.id)
            .update(updates)
            .catchError((_) {});
      }
    }

    // Also auto-populate services in Firestore where rawDescription is empty
    for (final s in services) {
      if (s.id.isEmpty) continue;
      if (s.rawDescription.trim().isEmpty || s.rawShortDescription.trim().isEmpty) {
        final fallbackDesc =
            ServiceDefaults.getDescription(name: s.name, categoryId: s.categoryId);
        final fallbackShort =
            ServiceDefaults.getShortDescription(name: s.name, categoryId: s.categoryId);
        final sUpdates = <String, dynamic>{};
        if (s.rawDescription.trim().isEmpty) {
          sUpdates['description'] = fallbackDesc;
        }
        if (s.rawShortDescription.trim().isEmpty) {
          sUpdates['shortDescription'] = fallbackShort;
        }
        FirebaseFirestore.instance
            .collection(Collections.services)
            .doc(s.id)
            .update(sUpdates)
            .catchError((_) {});
      }
    }
  }

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
    _allServicesSub?.cancel();
    _packagesSub?.cancel();
    _offersSub?.cancel();
    _listingSub?.cancel();
    super.onClose();
  }
}
