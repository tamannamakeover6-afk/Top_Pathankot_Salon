import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/routes/app_routes.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/core/utils/price_utils.dart';
import 'package:tamanna/core/utils/slug_utils.dart';
import 'package:tamanna/core/widgets/image_uploader.dart';
import 'package:tamanna/core/widgets/media_kit.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/data/models/category_model.dart';
import 'package:tamanna/data/models/offer_model.dart';
import 'package:tamanna/data/models/package_model.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/repositories/category_repository.dart';
import 'package:tamanna/data/repositories/offer_repository.dart';
import 'package:tamanna/data/repositories/package_repository.dart';
import 'package:tamanna/data/repositories/service_repository.dart';
import 'package:tamanna/features/admin/admin_shell.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Dashboard',
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection(Collections.services).snapshots(),
        builder: (context, _) {
          return FutureBuilder(
            future: _stats(),
            builder: (context, snap) {
              final data = snap.data ?? {};
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _card('Categories', '${data['categories'] ?? 0}'),
                      _card('Services', '${data['services'] ?? 0}'),
                      _card('Packages', '${data['packages'] ?? 0}'),
                      if ((data['offers'] ?? 0) > 0)
                        _card('Active offers', '${data['offers'] ?? 0}'),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _card(String label, String value) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.small),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: int.tryParse(value.split('.').first) ?? 0),
            duration: const Duration(milliseconds: 700),
            builder: (context, v, child) => Text(value.contains('.') ? value : '$v', style: AppTextStyles.h2),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _stats() async {
    final db = FirebaseFirestore.instance;
    final cats = await db.collection(Collections.categories).get();
    final services = await db.collection(Collections.services).get();
    final packs = await db.collection(Collections.packages).get();
    final offers = await db.collection(Collections.offers).where('active', isEqualTo: true).get();
    return {
      'categories': cats.size,
      'services': services.size,
      'packages': packs.size,
      'offers': offers.size,
    };
  }
}

class AdminCategoriesPage extends StatelessWidget {
  const AdminCategoriesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = CategoryRepository();
    return AdminShell(
      title: 'Categories',
      child: StreamBuilder(
        stream: repo.watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? [];
          return _AdminList(
            createLabel: 'New category',
            onCreate: () => _categoryForm(context, repo),
            emptyTitle: 'No categories',
            emptyMessage: 'Create a category, then open it to add services.',
            children: items
                .map(
                  (c) => ListTile(
                    onTap: () => Get.toNamed(AppRoutes.adminCategory(c.id)),
                    leading: CloudinaryImage(url: c.imageUrl, width: 48, height: 48),
                    title: Text(c.name),
                    subtitle: Text('${c.active ? 'Active' : 'Inactive'} · tap to open services'),
                    trailing: _AdminActions(
                      active: c.active,
                      onActiveChanged: (v) => _setActive(() => repo.setActive(c.id, v)),
                      onEdit: () => _categoryForm(context, repo, existing: c),
                      onDelete: () => _confirmDelete(context, () => repo.delete(c.id)),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class AdminCategoryServicesPage extends StatelessWidget {
  const AdminCategoryServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryId = Get.parameters['categoryId'] ?? '';
    final serviceRepo = ServiceRepository();
    return FutureBuilder(
      future: CategoryRepository().byId(categoryId),
      builder: (context, catSnap) {
        final cat = catSnap.data;
        return AdminShell(
          title: cat?.name ?? 'Services',
          onBack: () => Get.offNamed(AppRoutes.adminCategories),
          child: StreamBuilder(
            stream: serviceRepo.watchByCategory(categoryId),
            builder: (context, snap) {
              final items = snap.data ?? [];
              return _AdminList(
                createLabel: 'New service',
                onCreate: () => _serviceForm(context, lockedCategoryId: categoryId),
                emptyTitle: 'No services in this category',
                emptyMessage: 'Add services here. They belong directly to this category.',
                children: items
                    .map(
                      (s) => ListTile(
                        leading: CloudinaryImage(url: s.imageUrl, width: 48, height: 48),
                        title: Text(s.name),
                        subtitle: Text('${PriceUtils.format(s.sellingPrice)} · ${s.active ? 'Active' : 'Inactive'}'),
                        trailing: _AdminActions(
                          active: s.active,
                          onActiveChanged: (v) => _setActive(() => serviceRepo.setActive(s.id, v)),
                          onEdit: () => _serviceForm(
                            context,
                            existing: s,
                            lockedCategoryId: categoryId,
                          ),
                          onDelete: () => _confirmDelete(context, () => serviceRepo.delete(s.id)),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        );
      },
    );
  }
}

class AdminServicesPage extends StatelessWidget {
  const AdminServicesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = ServiceRepository();
    return AdminShell(
      title: 'Services',
      child: StreamBuilder(
        stream: CategoryRepository().watchAll(),
        builder: (context, catSnap) {
          return StreamBuilder(
            stream: repo.watchAll(),
            builder: (context, snap) {
              final items = snap.data ?? [];
              final cats = {for (final c in catSnap.data ?? <CategoryModel>[]) c.id: c.name};
              return _AdminList(
                createLabel: 'New service',
                onCreate: () => _serviceForm(context),
                emptyTitle: 'No services',
                emptyMessage: 'Open a category and add services inside it.',
                children: items
                    .map(
                      (s) => ListTile(
                        onTap: s.categoryId.isEmpty ? null : () => Get.toNamed(AppRoutes.adminCategory(s.categoryId)),
                        leading: CloudinaryImage(url: s.imageUrl, width: 48, height: 48),
                        title: Text(s.name),
                        subtitle: Text(
                          '${cats[s.categoryId] ?? 'No category'} · ${PriceUtils.format(s.sellingPrice)} · ${s.active ? 'Active' : 'Inactive'}',
                        ),
                        trailing: _AdminActions(
                          active: s.active,
                          onActiveChanged: (v) => _setActive(() => repo.setActive(s.id, v)),
                          onEdit: () => _serviceForm(context, existing: s),
                          onDelete: () => _confirmDelete(context, () => repo.delete(s.id)),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminPackagesPage extends StatelessWidget {
  const AdminPackagesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = PackageRepository();
    return AdminShell(
      title: 'Packages',
      child: StreamBuilder(
        stream: repo.watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? [];
          return _AdminList(
            onCreate: () => _packageForm(context),
            children: items
                .map(
                  (p) => ListTile(
                    leading: CloudinaryImage(url: p.imageUrl, width: 48, height: 48),
                    title: Text(p.name),
                    subtitle: Text('${PriceUtils.format(p.sellingPrice)} · ${p.active ? 'Active' : 'Inactive'}'),
                    trailing: _AdminActions(
                      active: p.active,
                      onActiveChanged: (v) => _setActive(() => repo.setActive(p.id, v)),
                      onEdit: () => _packageForm(context, existing: p),
                      onDelete: () => _confirmDelete(context, () => repo.delete(p.id)),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class AdminPricingPage extends StatelessWidget {
  const AdminPricingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Pricing',
      child: StreamBuilder(
        stream: ServiceRepository().watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: items
                .map(
                  (s) => ListTile(
                    title: Text(s.name),
                    subtitle: Text('MRP ${PriceUtils.format(s.mrp)} · Selling ${PriceUtils.format(s.sellingPrice)}'),
                    trailing: TextButton(
                      onPressed: () => _priceForm(context, s),
                      child: const Text('Edit'),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class AdminOffersPage extends StatelessWidget {
  const AdminOffersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = OfferRepository();
    return AdminShell(
      title: 'Offers',
      child: StreamBuilder(
        stream: repo.watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? [];
          return _AdminList(
            onCreate: () => _offerForm(context),
            children: items
                .map(
                  (o) => ListTile(
                    title: Text(o.title),
                    subtitle: Text('${o.statusLabel} · ${o.active ? 'Active' : 'Inactive'}'),
                    trailing: _AdminActions(
                      active: o.active,
                      onActiveChanged: (v) => _setActive(() => repo.setActive(o.id, v)),
                      onEdit: () => _offerForm(context, existing: o),
                      onDelete: () => _confirmDelete(context, () => repo.delete(o.id)),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _AdminList extends StatelessWidget {
  final List<Widget> children;
  final VoidCallback onCreate;
  final String createLabel;
  final String emptyTitle;
  final String emptyMessage;
  const _AdminList({
    required this.children,
    required this.onCreate,
    this.createLabel = 'Create',
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage = 'Use Create to add the first item.',
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(label: createLabel, onTap: onCreate),
          ),
        ),
        Expanded(
          child: children.isEmpty
              ? EmptyState(title: emptyTitle, message: emptyMessage)
              : ListView(children: children),
        ),
      ],
    );
  }
}

Future<void> _setActive(Future<void> Function() action) async {
  try {
    await action();
  } catch (e) {
    Get.snackbar('Status not updated', ErrorHandler.message(e));
  }
}

class _AdminActions extends StatelessWidget {
  final bool active;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminActions({
    required this.active,
    required this.onActiveChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: FittedBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              active ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.success : AppColors.danger,
              ),
            ),
            Switch.adaptive(
              value: active,
              activeThumbColor: AppColors.success,
              onChanged: onActiveChanged,
            ),
            IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
            IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete_outline), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDelete(BuildContext context, Future<void> Function() action) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete this item?'),
      content: const Text(
        'It will be removed from the catalog. Past bookings keep the name and price that were saved at booking time.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    await action();
    Get.snackbar('Deleted', 'Item removed from the catalog.');
  } catch (e) {
    Get.snackbar('Delete failed', ErrorHandler.message(e));
  }
}

Future<void> _categoryForm(BuildContext context, CategoryRepository repo, {CategoryModel? existing}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final desc = TextEditingController(text: existing?.description ?? '');
  var imageUrl = existing?.imageUrl ?? '';
  var publicId = existing?.imagePublicId ?? '';
  var active = existing?.active ?? true;
  await Get.dialog(
    AlertDialog(
      title: Text(existing == null ? 'New category' : 'Edit category'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setLocal) => Column(
                  children: [
                    ImageUploader(
                      url: imageUrl,
                      onUploaded: (a) => setLocal(() {
                        imageUrl = a.url;
                        publicId = a.publicId;
                      }),
                      onCleared: () => setLocal(() {
                        imageUrl = '';
                        publicId = '';
                      }),
                    ),
                    SwitchListTile(title: const Text('Active'), value: active, onChanged: (v) => setLocal(() => active = v)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            if (name.text.trim().isEmpty) return;
            await repo.save(
              CategoryModel(
                id: existing?.id ?? '',
                name: name.text.trim(),
                slug: SlugUtils.from(name.text),
                description: desc.text.trim(),
                imageUrl: imageUrl,
                imagePublicId: publicId,
                active: active,
                sortOrder: existing?.sortOrder ?? 99,
                serviceCount: existing?.serviceCount ?? 0,
                createdAt: existing?.createdAt,
              ),
            );
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<void> _serviceForm(
  BuildContext context, {
  ServiceModel? existing,
  String? lockedCategoryId,
}) async {
  final cats = await CategoryRepository().fetchAll();
  final name = TextEditingController(text: existing?.name ?? '');
  final short = TextEditingController(text: existing?.shortDescription ?? '');
  final desc = TextEditingController(text: existing?.description ?? '');
  final mrp = TextEditingController(text: existing?.mrp.toString() ?? '');
  final price = TextEditingController(text: existing?.sellingPrice.toString() ?? '');
  final duration = TextEditingController(text: existing?.durationMinutes.toString() ?? '60');
  var categoryId = lockedCategoryId ?? existing?.categoryId ?? (cats.isNotEmpty ? cats.first.id : '');
  var imageUrl = existing?.imageUrl ?? '';
  var publicId = existing?.imagePublicId ?? '';
  var popular = existing?.popular ?? false;
  var active = existing?.active ?? true;
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? 'New service' : 'Edit service'),
      content: SizedBox(
        width: 520,
        child: StatefulBuilder(
          builder: (context, setLocal) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  if (lockedCategoryId == null)
                    DropdownButtonFormField<String>(
                      initialValue: categoryId.isEmpty ? null : categoryId,
                      items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (v) => setLocal(() => categoryId = v ?? ''),
                      decoration: const InputDecoration(labelText: 'Category'),
                    )
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        cats.where((c) => c.id == categoryId).map((c) => c.name).firstWhere((_) => true, orElse: () => 'Category'),
                        style: AppTextStyles.small,
                      ),
                    ),
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'Service name')),
                  TextField(controller: short, decoration: const InputDecoration(labelText: 'Short description')),
                  TextField(controller: desc, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
                  TextField(controller: mrp, decoration: const InputDecoration(labelText: 'MRP')),
                  TextField(controller: price, decoration: const InputDecoration(labelText: 'Selling price')),
                  TextField(controller: duration, decoration: const InputDecoration(labelText: 'Duration (minutes)')),
                  ImageUploader(
                    url: imageUrl,
                    onUploaded: (a) {
                      imageUrl = a.url;
                      publicId = a.publicId;
                    },
                  ),
                  SwitchListTile(title: const Text('Show on website (Active)'), value: active, onChanged: (v) => setLocal(() => active = v)),
                  SwitchListTile(title: const Text('Popular'), value: popular, onChanged: (v) => setLocal(() => popular = v)),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            final mrpVal = PriceUtils.toDouble(mrp.text);
            final sellVal = PriceUtils.toDouble(price.text);
            if (name.text.isEmpty || categoryId.isEmpty || mrpVal < 0 || sellVal < 0) {
              Get.snackbar('Incomplete', 'Choose a category, then add a name and price.');
              return;
            }
            if (PriceUtils.sellingExceedsMrp(mrpVal, sellVal)) {
              Get.snackbar('Pricing', 'Selling price cannot exceed MRP.');
              return;
            }
            await ServiceRepository().save(
              ServiceModel(
                id: existing?.id ?? '',
                name: name.text.trim(),
                slug: SlugUtils.from(name.text),
                categoryId: categoryId,
                shortDescription: short.text.trim(),
                description: desc.text.trim(),
                imageUrl: imageUrl,
                imagePublicId: publicId,
                mrp: mrpVal,
                sellingPrice: sellVal,
                durationMinutes: int.tryParse(duration.text) ?? 60,
                popular: popular,
                active: active,
                createdAt: existing?.createdAt,
              ),
            );
            if (existing == null) {
              await CategoryRepository().bumpServiceCount(categoryId, 1);
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<void> _packageForm(BuildContext context, {PackageModel? existing}) async {
  final services = await ServiceRepository().query(const ServiceQuery(limit: 80));
  final name = TextEditingController(text: existing?.name ?? '');
  final desc = TextEditingController(text: existing?.description ?? '');
  final price = TextEditingController(text: existing?.sellingPrice.toString() ?? '');
  var selected = [...?existing?.serviceIds];
  var imageUrl = existing?.imageUrl ?? '';
  var active = existing?.active ?? true;
  await Get.dialog(
    AlertDialog(
      title: Text(existing == null ? 'New package' : 'Edit package'),
      content: SizedBox(
        width: 520,
        child: StatefulBuilder(
          builder: (context, setLocal) {
            final mrp = services.where((s) => selected.contains(s.id)).fold<double>(0, (a, b) => a + b.mrp);
            return SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'Package name')),
                  TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
                  ImageUploader(url: imageUrl, onUploaded: (a) => setLocal(() => imageUrl = a.url)),
                  Text('Auto MRP: ${PriceUtils.format(mrp)}'),
                  TextField(controller: price, decoration: const InputDecoration(labelText: 'Package price')),
                  SwitchListTile(title: const Text('Show on website (Active)'), value: active, onChanged: (v) => setLocal(() => active = v)),
                  ...services.map(
                    (s) => CheckboxListTile(
                      value: selected.contains(s.id),
                      title: Text(s.name),
                      onChanged: (v) => setLocal(() {
                        if (v == true) {
                          selected.add(s.id);
                        } else {
                          selected.remove(s.id);
                        }
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            final mrp = services.where((s) => selected.contains(s.id)).fold<double>(0, (a, b) => a + b.mrp);
            final selling = PriceUtils.toDouble(price.text);
            if (name.text.isEmpty || selected.isEmpty) return;
            if (PriceUtils.sellingExceedsMrp(mrp, selling)) {
              Get.snackbar('Pricing', 'Package price cannot exceed combined MRP.');
              return;
            }
            await PackageRepository().save(
              PackageModel(
                id: existing?.id ?? '',
                name: name.text.trim(),
                slug: SlugUtils.from(name.text),
                description: desc.text.trim(),
                imageUrl: imageUrl,
                serviceIds: selected,
                mrp: mrp,
                sellingPrice: selling,
                active: active,
                createdAt: existing?.createdAt,
              ),
            );
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<void> _priceForm(BuildContext context, ServiceModel service) async {
  final mrp = TextEditingController(text: service.mrp.toString());
  final price = TextEditingController(text: service.sellingPrice.toString());
  await Get.dialog(
    AlertDialog(
      title: Text('Price · ${service.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: mrp, decoration: const InputDecoration(labelText: 'MRP')),
          TextField(controller: price, decoration: const InputDecoration(labelText: 'Selling price')),
        ],
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            final m = PriceUtils.toDouble(mrp.text);
            final s = PriceUtils.toDouble(price.text);
            if (PriceUtils.sellingExceedsMrp(m, s)) return;
            await ServiceRepository().updatePricing(service.id, mrp: m, sellingPrice: s);
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<void> _offerForm(BuildContext context, {OfferModel? existing}) async {
  final title = TextEditingController(text: existing?.title ?? '');
  final desc = TextEditingController(text: existing?.description ?? '');
  final value = TextEditingController(text: existing?.discountValue.toString() ?? '10');
  var type = existing?.discountType ?? 'percentage';
  var imageUrl = existing?.bannerUrl ?? '';
  var active = existing?.active ?? true;
  await Get.dialog(
    AlertDialog(
      title: Text(existing == null ? 'New offer' : 'Edit offer'),
      content: SizedBox(
        width: 460,
        child: StatefulBuilder(
          builder: (context, setLocal) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                    DropdownMenuItem(value: 'fixed', child: Text('Fixed amount')),
                  ],
                  onChanged: (v) => setLocal(() => type = v ?? 'percentage'),
                ),
                TextField(controller: value, decoration: const InputDecoration(labelText: 'Value')),
                ImageUploader(url: imageUrl, onUploaded: (a) => setLocal(() => imageUrl = a.url)),
                SwitchListTile(
                  title: const Text('Show on website (Active)'),
                  value: active,
                  onChanged: (v) => setLocal(() => active = v),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            await OfferRepository().save(
              OfferModel(
                id: existing?.id ?? '',
                title: title.text.trim(),
                description: desc.text.trim(),
                discountType: type,
                discountValue: PriceUtils.toDouble(value.text),
                bannerUrl: imageUrl,
                startAt: existing?.startAt ?? DateTime.now(),
                endAt: existing?.endAt ?? DateTime.now().add(const Duration(days: 14)),
                active: active,
                createdAt: existing?.createdAt,
              ),
            );
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
