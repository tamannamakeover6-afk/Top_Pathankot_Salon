import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/cards.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/data/models/category_model.dart';
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
                Text('Choose a ritual family, then refine by service.', style: AppTextStyles.body),
                const SizedBox(height: 28),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cats.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Breakpoints.gridCount(context),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (_, i) => CategoryCard(category: cats[i]),
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
  String? subSlug;

  @override
  void initState() {
    super.initState();
    subSlug = Get.parameters['subcategorySlug'];
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final slug = Get.parameters['categorySlug'] ?? '';
    final cat = catalog.categoryBySlug(slug);
    if (cat == null) {
      await catalog.loadHome();
    }
    final resolved = catalog.categoryBySlug(slug);
    if (resolved == null) return;
    String subId = '';
    if (subSlug != null) {
      final match = catalog.subsFor(resolved.id).firstWhereOrNull((s) => s.slug == subSlug);
      subId = match?.id ?? '';
    }
    await catalog.loadListing(categoryId: resolved.id, subcategoryId: subId);
  }

  int _calcColumns(BuildContext context, bool hideFilters) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return hideFilters ? 3 : 2;
    if (width < 1440) return hideFilters ? 4 : 3;
    return hideFilters ? 4 : 3;
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
        final desktop = Breakpoints.isDesktop(context);
        final hideFilters = catalog.hideFilters.value && desktop;
        final items = catalog.listing;

        return ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Breadcrumb navigation
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

                // 2. Title bar with count, "Hide Filters?" and "Sort by"
                desktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat.name, style: AppTextStyles.h1.copyWith(fontSize: 26, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('${items.length} items', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // "Hide Filters?" checkbox toggle
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: catalog.hideFilters.value,
                                    activeColor: const Color(0xFFE8590C),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (v) => catalog.hideFilters.value = v ?? false,
                                  ),
                                  GestureDetector(
                                    onTap: () => catalog.hideFilters.value = !catalog.hideFilters.value,
                                    child: const Text('Hide Filters?', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              _SortDropdown(catalog: catalog),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.name, style: AppTextStyles.h1.copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('${items.length} items', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _openMobileFilters(context, cat),
                                  icon: const Icon(Icons.tune, size: 16),
                                  label: Text(
                                    catalog.hasActiveFilters
                                        ? 'Filters (${catalog.selectedSubcategoryIds.length + catalog.selectedServiceIds.length})'
                                        : 'Filters',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _SortDropdown(catalog: catalog),
                            ],
                          ),
                        ],
                      ),

                const SizedBox(height: 24),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 28),

                // 3. Main content area (Left Tree Filter Sidebar + Right Service Grid)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter sidebar on desktop when not hidden
                    if (desktop && !hideFilters) ...[
                      SizedBox(
                        width: 250,
                        child: _TreeFilterSidebar(category: cat),
                      ),
                      const SizedBox(width: 32),
                    ],

                    // Service Grid
                    Expanded(
                      child: _ListingGrid(
                        catalog: catalog,
                        columns: _calcColumns(context, hideFilters),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _openMobileFilters(BuildContext context, CategoryModel cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  child: _TreeFilterSidebar(category: cat, isMobile: true),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Apply Filters',
                expand: true,
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final CatalogController catalog;
  const _SortDropdown({required this.catalog});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
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
          const Text(
            'Sort by',
            style: TextStyle(fontSize: 10, color: AppColors.textHint, height: 1.1),
          ),
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
                DropdownMenuItem(value: 'popular', child: Text('Default')),
                DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                DropdownMenuItem(value: 'rating', child: Text('Highest Rated')),
                DropdownMenuItem(value: 'discount', child: Text('Biggest Discount')),
                DropdownMenuItem(value: 'newest', child: Text('Newest')),
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

class _TreeFilterSidebar extends StatelessWidget {
  final CategoryModel category;
  final bool isMobile;

  const _TreeFilterSidebar({required this.category, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final catalog = Get.find<CatalogController>();
    final subs = catalog.subsFor(category.id);

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Filters" header with "Clear all"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              if (catalog.hasActiveFilters)
                TextButton(
                  onPressed: catalog.clearFilters,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: Color(0xFFE8590C), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Categories Tree Heading
          const Text(
            'Categories',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),

          // Optional Packages Filter Checkbox
          _FilterCheckboxRow(
            label: 'Packages',
            checked: catalog.filterPackages.value,
            onChanged: (v) {
              catalog.filterPackages.value = v ?? false;
              catalog.applyClientFilters();
            },
          ),

          // Subcategories with Indented Services Tree
          ...subs.map((sub) {
            final subChecked = catalog.selectedSubcategoryIds.contains(sub.id);
            final subServices = catalog.servicesForSub(sub.id);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subcategory Checkbox
                _FilterCheckboxRow(
                  label: sub.name,
                  checked: subChecked,
                  isBold: true,
                  onChanged: (_) => catalog.toggleSubcategory(sub.id),
                ),

                // Indented Child Services (as in the reference screenshot)
                if (subServices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      children: subServices.map((svc) {
                        final svcChecked = catalog.selectedServiceIds.contains(svc.id);
                        return _FilterCheckboxRow(
                          label: svc.name,
                          checked: svcChecked,
                          isIndent: true,
                          onChanged: (_) => catalog.toggleService(svc.id, sub.id),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          }),

          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),

          // Price range filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Range',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Text(
                'Up to ₹${catalog.maxPrice.round()}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFE8590C),
              thumbColor: const Color(0xFFE8590C),
              trackHeight: 3,
            ),
            child: Slider(
              value: catalog.maxPrice,
              min: 200,
              max: 10000,
              onChanged: (v) => catalog.maxPrice = v,
              onChangeEnd: (_) => catalog.applyClientFilters(),
            ),
          ),

          // Discounted Only Switch
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('Discounted only', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            activeThumbColor: const Color(0xFFE8590C),
            value: catalog.discountedOnly,
            onChanged: (v) {
              catalog.discountedOnly = v;
              catalog.applyClientFilters();
            },
          ),
        ],
      );
    });
  }
}

class _FilterCheckboxRow extends StatelessWidget {
  final String label;
  final bool checked;
  final ValueChanged<bool?> onChanged;
  final bool isBold;
  final bool isIndent;

  const _FilterCheckboxRow({
    required this.label,
    required this.checked,
    required this.onChanged,
    this.isBold = false,
    this.isIndent = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: checked,
                activeColor: const Color(0xFFE8590C),
                side: const BorderSide(color: Color(0xFFADB5BD), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isIndent ? 13 : 14,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                  color: checked ? AppColors.textPrimary : const Color(0xFF495057),
                ),
              ),
            ),
          ],
        ),
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
    if (catalog.loadingListing.value) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.78,
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
        message: 'Try clearing some filters or selecting another category.',
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: catalog.listing.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.76,
      ),
      itemBuilder: (_, i) => ServiceCard(service: catalog.listing[i]),
    );
  }
}
