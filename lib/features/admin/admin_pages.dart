import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/utils/price_utils.dart';
import 'package:tamanna/core/utils/slug_utils.dart';
import 'package:tamanna/core/widgets/image_uploader.dart';
import 'package:tamanna/core/widgets/media_kit.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/data/models/category_model.dart';
import 'package:tamanna/data/models/offer_model.dart';
import 'package:tamanna/data/models/package_model.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/models/subcategory_model.dart';
import 'package:tamanna/data/repositories/category_repository.dart';
import 'package:tamanna/data/repositories/offer_repository.dart';
import 'package:tamanna/data/repositories/package_repository.dart';
import 'package:tamanna/data/repositories/review_repository.dart';
import 'package:tamanna/data/repositories/service_repository.dart';
import 'package:tamanna/data/repositories/subcategory_repository.dart';
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
                      _card('Active offers', '${data['offers'] ?? 0}'),
                      _card('Reviews', '${data['reviews'] ?? 0}'),
                      _card('Avg rating', '${data['rating'] ?? 0}'),
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
    final reviews = await db.collection(Collections.reviews).get();
    double avg = 0;
    if (reviews.docs.isNotEmpty) {
      avg = reviews.docs
              .map((d) => PriceUtils.toDouble(d.data()['rating']))
              .fold<double>(0, (a, b) => a + b) /
          reviews.docs.length;
    }
    return {
      'categories': cats.size,
      'services': services.size,
      'packages': packs.size,
      'offers': offers.size,
      'reviews': reviews.size,
      'rating': avg.toStringAsFixed(1),
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
            onCreate: () => _categoryForm(context, repo),
            children: items
                .map(
                  (c) => ListTile(
                    leading: CloudinaryImage(url: c.imageUrl, width: 48, height: 48),
                    title: Text(c.name),
                    subtitle: Text('${c.active ? 'Active' : 'Hidden'} · ${c.serviceCount} services'),
                    trailing: Wrap(
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _categoryForm(context, repo, existing: c)),
                        IconButton(
                          icon: Icon(c.active ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => repo.setActive(c.id, !c.active),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirm(() => repo.delete(c.id)),
                        ),
                      ],
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

class AdminSubcategoriesPage extends StatelessWidget {
  const AdminSubcategoriesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = SubcategoryRepository();
    final cats = CategoryRepository();
    return AdminShell(
      title: 'Subcategories',
      child: StreamBuilder(
        stream: repo.watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? [];
          return _AdminList(
            onCreate: () => _subForm(context, repo, cats),
            children: items
                .map(
                  (s) => ListTile(
                    title: Text(s.name),
                    subtitle: Text(s.active ? 'Active' : 'Hidden'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _subForm(context, repo, cats, existing: s),
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

class AdminServicesPage extends StatelessWidget {
  const AdminServicesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = ServiceRepository();
    return AdminShell(
      title: 'Services',
      child: StreamBuilder(
        stream: repo.watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? [];
          return _AdminList(
            onCreate: () => _serviceForm(context),
            children: items
                .map(
                  (s) => ListTile(
                    leading: CloudinaryImage(url: s.imageUrl, width: 48, height: 48),
                    title: Text(s.name),
                    subtitle: Text('${PriceUtils.format(s.sellingPrice)} · ${s.active ? 'Active' : 'Hidden'}'),
                    trailing: Wrap(
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _serviceForm(context, existing: s)),
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () => repo.setActive(s.id, !s.active),
                        ),
                      ],
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
                    subtitle: Text(PriceUtils.format(p.sellingPrice)),
                    trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _packageForm(context, existing: p)),
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
                    subtitle: Text(o.statusLabel),
                    trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _offerForm(context, existing: o)),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class AdminReviewsPage extends StatelessWidget {
  const AdminReviewsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = ReviewRepository();
    return AdminShell(
      title: 'Reviews',
      child: StreamBuilder(
        stream: repo.watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: items
                .map(
                  (r) => ListTile(
                    title: Text('${r.userName} · ${r.rating}★'),
                    subtitle: Text('${r.itemName}\n${r.review}'),
                    isThreeLine: true,
                    trailing: Wrap(
                      children: [
                        IconButton(icon: const Icon(Icons.check), onPressed: () => repo.setStatus(r.id, 'approved')),
                        IconButton(icon: const Icon(Icons.visibility_off), onPressed: () => repo.setStatus(r.id, 'hidden')),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => repo.delete(r.id)),
                      ],
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
  const _AdminList({required this.children, required this.onCreate});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(label: 'Create', onTap: onCreate),
          ),
        ),
        Expanded(child: ListView(children: children)),
      ],
    );
  }
}

Future<void> _confirm(Future<void> Function() action) async {
  final ok = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Confirm'),
      content: const Text('This will deactivate the record so historical bookings stay intact.'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        TextButton(onPressed: () => Get.back(result: true), child: const Text('Continue')),
      ],
    ),
  );
  if (ok == true) await action();
}

Future<void> _categoryForm(BuildContext context, CategoryRepository repo, {CategoryModel? existing}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final desc = TextEditingController(text: existing?.description ?? '');
  var imageUrl = existing?.imageUrl ?? '';
  var publicId = existing?.imagePublicId ?? '';
  var featured = existing?.featured ?? false;
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
                    SwitchListTile(title: const Text('Featured'), value: featured, onChanged: (v) => setLocal(() => featured = v)),
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
                featured: featured,
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

Future<void> _subForm(
  BuildContext context,
  SubcategoryRepository repo,
  CategoryRepository cats, {
  SubcategoryModel? existing,
}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final desc = TextEditingController(text: existing?.description ?? '');
  var categoryId = existing?.categoryId ?? '';
  var imageUrl = existing?.imageUrl ?? '';
  final allCats = await cats.fetchActive();
  if (categoryId.isEmpty && allCats.isNotEmpty) categoryId = allCats.first.id;
  await Get.dialog(
    AlertDialog(
      title: Text(existing == null ? 'New subcategory' : 'Edit subcategory'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: categoryId.isEmpty ? null : categoryId,
              items: allCats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => categoryId = v ?? '',
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
            ImageUploader(url: imageUrl, onUploaded: (a) => imageUrl = a.url),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            if (name.text.isEmpty || categoryId.isEmpty) return;
            await repo.save(
              SubcategoryModel(
                id: existing?.id ?? '',
                categoryId: categoryId,
                name: name.text.trim(),
                slug: SlugUtils.from(name.text),
                description: desc.text.trim(),
                imageUrl: imageUrl,
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

Future<void> _serviceForm(BuildContext context, {ServiceModel? existing}) async {
  final cats = await CategoryRepository().fetchActive();
  final name = TextEditingController(text: existing?.name ?? '');
  final short = TextEditingController(text: existing?.shortDescription ?? '');
  final desc = TextEditingController(text: existing?.description ?? '');
  final mrp = TextEditingController(text: existing?.mrp.toString() ?? '');
  final price = TextEditingController(text: existing?.sellingPrice.toString() ?? '');
  final duration = TextEditingController(text: existing?.durationMinutes.toString() ?? '60');
  var categoryId = existing?.categoryId ?? (cats.isNotEmpty ? cats.first.id : '');
  var subcategoryId = existing?.subcategoryId ?? '';
  var imageUrl = existing?.imageUrl ?? '';
  var publicId = existing?.imagePublicId ?? '';
  var featured = existing?.featured ?? false;
  var popular = existing?.popular ?? false;
  await Get.dialog(
    AlertDialog(
      title: Text(existing == null ? 'New service' : 'Edit service'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: categoryId.isEmpty ? null : categoryId,
                items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => categoryId = v ?? '',
                decoration: const InputDecoration(labelText: 'Category'),
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
              StatefulBuilder(
                builder: (context, setLocal) => Column(
                  children: [
                    SwitchListTile(title: const Text('Featured'), value: featured, onChanged: (v) => setLocal(() => featured = v)),
                    SwitchListTile(title: const Text('Popular'), value: popular, onChanged: (v) => setLocal(() => popular = v)),
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
            final mrpVal = PriceUtils.toDouble(mrp.text);
            final sellVal = PriceUtils.toDouble(price.text);
            if (name.text.isEmpty || categoryId.isEmpty || mrpVal < 0 || sellVal < 0) return;
            if (PriceUtils.sellingExceedsMrp(mrpVal, sellVal)) {
              Get.snackbar('Pricing', 'Selling price cannot exceed MRP.');
              return;
            }
            final id = await ServiceRepository().save(
              ServiceModel(
                id: existing?.id ?? '',
                name: name.text.trim(),
                slug: SlugUtils.from(name.text),
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                shortDescription: short.text.trim(),
                description: desc.text.trim(),
                imageUrl: imageUrl,
                imagePublicId: publicId,
                mrp: mrpVal,
                sellingPrice: sellVal,
                durationMinutes: int.tryParse(duration.text) ?? 60,
                featured: featured,
                popular: popular,
                createdAt: existing?.createdAt,
              ),
            );
            if (existing == null) {
              await CategoryRepository().bumpServiceCount(categoryId, 1);
            }
            Get.back();
            debugPrint(id);
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
  await Get.dialog(
    AlertDialog(
      title: Text(existing == null ? 'New offer' : 'Edit offer'),
      content: SizedBox(
        width: 460,
        child: Column(
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
              onChanged: (v) => type = v ?? 'percentage',
            ),
            TextField(controller: value, decoration: const InputDecoration(labelText: 'Value')),
            ImageUploader(url: imageUrl, onUploaded: (a) => imageUrl = a.url),
          ],
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
