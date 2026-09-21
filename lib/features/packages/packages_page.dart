import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/core/widgets/cards.dart';
import 'package:tamanna/core/widgets/media_kit.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/data/models/package_model.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/repositories/package_repository.dart';
import 'package:tamanna/data/repositories/service_repository.dart';
import 'package:tamanna/features/catalog/catalog_controller.dart';
import 'package:tamanna/features/shell/site_shell.dart';

class PackagesPage extends StatefulWidget {
  const PackagesPage({super.key});
  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  @override
  Widget build(BuildContext context) {
    final catalog = Get.find<CatalogController>();
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: FutureBuilder(
            future: catalog.allPackages(),
            builder: (context, snap) {
              if (snap.hasError) {
                return ErrorState(message: ErrorHandler.message(snap.error!), onRetry: () => setState(() {}));
              }
              if (!snap.hasData) {
                return const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator());
              }
              final packs = snap.data ?? [];
              if (packs.isEmpty) {
                return const EmptyState(title: 'No packages yet', message: 'Admin can publish beauty packages from the dashboard.');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Packages', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text('Thoughtful combinations, priced as a complete ritual.', style: AppTextStyles.body),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: packs.map((p) => PackageCard(pack: p)).toList(),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class PackageDetailPage extends StatefulWidget {
  const PackageDetailPage({super.key});
  @override
  State<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends State<PackageDetailPage> {
  PackageModel? pack;
  List<ServiceModel> included = [];
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final item = await PackageRepository().bySlug(Get.parameters['packageSlug'] ?? '');
      if (item == null) {
        setState(() {
          error = 'Package not found.';
          loading = false;
        });
        return;
      }
      final services = await ServiceRepository().byIds(item.serviceIds);
      setState(() {
        pack = item;
        included = services;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = ErrorHandler.message(e);
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const SiteShell(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
    if (error != null || pack == null) {
      return SiteShell(child: ErrorState(message: error ?? 'Not found', onRetry: _load));
    }
    final p = pack!;
    return SiteShell(
      child: Column(
        children: [
          CloudinaryImage(url: p.imageUrl, height: 320, width: double.infinity, radius: BorderRadius.zero),
          ResponsiveContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text(p.description, style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  PriceWidget(mrp: p.mrp, sellingPrice: p.sellingPrice),
                  Text('Save ₹${(p.mrp - p.sellingPrice).round()} · ${p.durationMinutes} min',
                      style: AppTextStyles.small),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Book this package',
                    onTap: () => Get.toNamed('/booking', parameters: {'package': p.slug}),
                  ),
                  const SizedBox(height: 32),
                  Text('Included services', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  ServiceGrid(services: included),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
