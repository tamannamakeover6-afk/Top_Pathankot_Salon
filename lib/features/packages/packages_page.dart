import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/core/widgets/cards.dart';
import 'package:tamanna/core/widgets/media_kit.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/data/models/package_model.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/repositories/package_repository.dart';
import 'package:tamanna/data/repositories/service_repository.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/features/catalog/catalog_controller.dart';
import 'package:tamanna/features/request/booking_form.dart';
import 'package:tamanna/features/request/request_controller.dart';
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
              final isMobile = Breakpoints.isMobile(context);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Packages',
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Thoughtful combinations, priced as a complete ritual.', style: TextStyle(fontSize: isMobile ? 13 : 15, color: AppColors.textSecondary)),
                  SizedBox(height: isMobile ? 16 : 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = Breakpoints.gridCount(context);
                      final gap = isMobile ? 12.0 : 20.0;
                      final itemWidth = (width - gap * (columns - 1)) / columns;
                      return Wrap(
                        spacing: gap,
                        runSpacing: isMobile ? 16 : 24,
                        alignment: WrapAlignment.start,
                        children: packs.map((p) => PackageCard(pack: p, width: itemWidth)).toList(),
                      );
                    },
                  ),
                  SizedBox(height: isMobile ? 24 : 40),
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
  bool showBooking = false;
  final _bookingKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _openBooking() {
    setState(() => showBooking = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBooking());
  }

  void _scrollToBooking() {
    final ctx = _bookingKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350), alignment: 0.08, curve: Curves.easeOut);
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
      final request = Get.find<RequestController>();
      request.selectPackage(item);
      if (request.pendingOpenBooking && mounted) {
        request.pendingOpenBooking = false;
        setState(() => showBooking = true);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBooking());
      }
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
    final isMobile = Breakpoints.isMobile(context);
    return SiteShell(
      child: Column(
        children: [
          CloudinaryImage(
            url: p.imageUrl,
            height: isMobile ? 190 : 320,
            width: double.infinity,
            radius: BorderRadius.zero,
          ),
          ResponsiveContainer(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Text(
                    p.description,
                    style: TextStyle(fontSize: isMobile ? 13 : 15, color: AppColors.textSecondary, height: 1.4),
                  ),
                  SizedBox(height: isMobile ? 10 : 16),
                  Row(
                    children: [
                      PriceWidget(mrp: p.mrp, sellingPrice: p.sellingPrice),
                      const SizedBox(width: 8),
                      DiscountBadge(percent: p.discountPercent),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Save ₹${(p.mrp - p.sellingPrice).round()} · ${p.durationMinutes} min',
                    style: TextStyle(fontSize: isMobile ? 11.5 : 13, color: AppColors.textHint),
                  ),
                  SizedBox(height: isMobile ? 14 : 20),
                  PrimaryButton(
                    label: 'Book Now',
                    onTap: _openBooking,
                  ),
                  if (showBooking) ...[
                    SizedBox(height: isMobile ? 16 : 28),
                    Container(
                      key: _bookingKey,
                      padding: EdgeInsets.all(isMobile ? 14 : 24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(isMobile ? 14 : 20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const BookingForm(),
                    ),
                  ],
                  SizedBox(height: isMobile ? 24 : 32),
                  Text(
                    'Included services',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  ServiceGrid(services: included),
                  SizedBox(height: isMobile ? 24 : 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
