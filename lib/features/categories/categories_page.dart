import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/cards.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/features/catalog/catalog_controller.dart';
import 'package:tamanna/features/shell/site_shell.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = Get.find<CatalogController>();
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Obx(() {
            final cats = catalog.categories;
            if (cats.isEmpty) {
              return const EmptyState(
                title: 'No categories yet',
                message: 'The catalog will appear once published.',
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All categories', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text('Open a category to see its services.', style: AppTextStyles.body),
                const SizedBox(height: 28),
                LayoutBuilder(
                  builder: (context, _) {
                    final isMobile = Breakpoints.isMobile(context);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cats.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Breakpoints.gridCount(context),
                        mainAxisSpacing: isMobile ? 14 : 20,
                        crossAxisSpacing: isMobile ? 12 : 20,
                        mainAxisExtent: isMobile ? 175 : 225,
                      ),
                      itemBuilder: (_, i) => CategoryCard(category: cats[i]),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({super.key});
  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final catalog = Get.find<CatalogController>();
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    catalog.searchQuery.value = '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final slug = Get.parameters['categorySlug'] ?? '';
    var resolved = catalog.categoryBySlug(slug);
    if (resolved == null) {
      await catalog.loadHome();
      resolved = catalog.categoryBySlug(slug);
    }
    if (resolved == null) return;
    await catalog.loadListing(categoryId: resolved.id);
  }

  int _columns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return 2;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final slug = Get.parameters['categorySlug'] ?? '';
    return SiteShell(
      child: Obx(() {
        final cat = catalog.categoryBySlug(slug);
        if (cat == null) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: EmptyState(title: 'Category not found', message: 'It may have been unpublished.'),
          );
        }
        final items = catalog.listing;
        return ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Get.toNamed('/'),
                      child: Text('Home', style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                    ),
                    Text('  /  ', style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                    InkWell(
                      onTap: () => Get.toNamed('/categories'),
                      child: Text('Categories', style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                    ),
                    Text('  /  ', style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                    Text(
                      cat.name,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(cat.name, style: AppTextStyles.h1.copyWith(fontSize: 26, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${items.length} services', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 720;
                    final searchField = TextField(
                      controller: search,
                      onChanged: (v) {
                        catalog.searchQuery.value = v;
                        catalog.applyClientFilters();
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search services in this category',
                        prefixIcon: Icon(Icons.search),
                      ),
                    );
                    final sort = _SortDropdown(catalog: catalog);
                    if (stacked) {
                      return Column(
                        children: [
                          searchField,
                          const SizedBox(height: 12),
                          Align(alignment: Alignment.centerRight, child: sort),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: searchField),
                        const SizedBox(width: 16),
                        sort,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                _ListingGrid(catalog: catalog, columns: _columns(context)),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final CatalogController catalog;
  const _SortDropdown({required this.catalog});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sort by', style: TextStyle(fontSize: 10, color: AppColors.textHint, height: 1.1)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: catalog.sort,
              isDense: true,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              items: const [
                DropdownMenuItem(value: 'newest', child: Text('Newest')),
                DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
              ],
              onChanged: (v) {
                if (v != null) {
                  catalog.sort = v;
                  catalog.applyClientFilters();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingGrid extends StatelessWidget {
  final CatalogController catalog;
  final int columns;

  const _ListingGrid({required this.catalog, required this.columns});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final mainSpacing = isMobile ? 14.0 : 28.0;
    final crossSpacing = isMobile ? 10.0 : 24.0;
    final extent = isMobile ? 218.0 : 285.0;

    if (catalog.loadingListing.value) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: mainSpacing,
          crossAxisSpacing: crossSpacing,
          mainAxisExtent: extent,
        ),
        itemBuilder: (context, index) => const SkeletonServiceCard(),
      );
    }
    if (catalog.listingError.isNotEmpty) {
      return ErrorState(message: catalog.listingError.value, onRetry: catalog.loadListing);
    }
    if (catalog.listing.isEmpty) {
      return const EmptyState(
        title: 'No services found',
        message: 'Try another search, or check back after services are added to this category.',
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: catalog.listing.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: mainSpacing,
        crossAxisSpacing: crossSpacing,
        mainAxisExtent: extent,
      ),
      itemBuilder: (_, i) => ServiceCard(service: catalog.listing[i]),
    );
  }
}
