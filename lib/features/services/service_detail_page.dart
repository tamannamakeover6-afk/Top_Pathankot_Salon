import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/core/widgets/cards.dart';
import 'package:tamanna/core/widgets/media_kit.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/data/models/review_model.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/repositories/review_repository.dart';
import 'package:tamanna/data/repositories/service_repository.dart';
import 'package:tamanna/features/shell/site_shell.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key});
  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  ServiceModel? service;
  List<ReviewModel> reviews = [];
  List<ServiceModel> related = [];
  String? error;
  bool loading = true;
  String gallery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final slug = Get.parameters['serviceSlug'] ?? '';
      final item = await ServiceRepository().bySlug(slug);
      if (item == null) {
        setState(() {
          loading = false;
          error = 'Service not found.';
        });
        return;
      }
      final more = await Future.wait([
        ReviewRepository().fetchApproved(serviceId: item.id),
        ServiceRepository().related(categoryId: item.categoryId, excludeId: item.id),
      ]);
      setState(() {
        service = item;
        gallery = item.imageUrl;
        reviews = more[0] as List<ReviewModel>;
        related = more[1] as List<ServiceModel>;
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
    if (loading) {
      return const SiteShell(child: Padding(padding: EdgeInsets.all(48), child: SkeletonServiceCard()));
    }
    if (error != null || service == null) {
      return SiteShell(child: ErrorState(message: error ?? 'Not found', onRetry: _load));
    }
    final s = service!;
    final desktop = Breakpoints.isDesktop(context);
    final images = [s.imageUrl, ...s.gallery.where((e) => e.isNotEmpty)];
    final galleryCol = Column(
      children: [
        CloudinaryImage(url: gallery.isEmpty ? s.imageUrl : gallery, height: 420, width: double.infinity),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: images
              .map(
                (url) => GestureDetector(
                  onTap: () => setState(() => gallery = url),
                  child: CloudinaryImage(url: url, width: 72, height: 72),
                ),
              )
              .toList(),
        ),
      ],
    );
    final detailsCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.name, style: AppTextStyles.h1),
        const SizedBox(height: 8),
        RatingWidget(rating: s.rating, count: s.reviewCount),
        const SizedBox(height: 8),
        Text(
          s.durationMinutes > 0
              ? '${s.durationMinutes} minutes · At-home service'
              : 'At-home service',
          style: AppTextStyles.small,
        ),
        const SizedBox(height: 16),
        DiscountBadge(percent: s.discountPercent),
        const SizedBox(height: 12),
        PriceWidget(mrp: s.mrp, sellingPrice: s.sellingPrice),
        const SizedBox(height: 16),
        Text(s.shortDescription, style: AppTextStyles.body),
        const SizedBox(height: 20),
        if (s.includedItems.isNotEmpty) ...[
          Text("What's included", style: AppTextStyles.title),
          ...s.includedItems.map(
            (e) => ListTile(
              dense: true,
              leading: const Icon(Icons.check, color: AppColors.success),
              title: Text(e),
            ),
          ),
        ],
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Book Now',
          onTap: () => Get.toNamed('/booking', parameters: {'service': s.slug}),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const TamannaHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: desktop ? 0 : 90),
              child: Column(
                children: [
                  ResponsiveContainer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: desktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 6, child: galleryCol),
                                const SizedBox(width: 36),
                                Expanded(flex: 5, child: detailsCol),
                              ],
                            )
                          : Column(
                              children: [
                                galleryCol,
                                const SizedBox(height: 24),
                                detailsCol,
                              ],
                            ),
                    ),
                  ),
                  ResponsiveContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About this service', style: AppTextStyles.h3),
                        const SizedBox(height: 8),
                        Text(s.description, style: AppTextStyles.body),
                        const SizedBox(height: 24),
                        if (s.benefits.isNotEmpty) ...[
                          Text('Benefits', style: AppTextStyles.h3),
                          ...s.benefits.map((e) => Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('• $e', style: AppTextStyles.body),
                              )),
                          const SizedBox(height: 24),
                        ],
                        if (s.terms.isNotEmpty) ...[
                          Text('Good to know', style: AppTextStyles.h3),
                          ...s.terms.map((e) => Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(e, style: AppTextStyles.body),
                              )),
                          const SizedBox(height: 24),
                        ],
                        Text('Guest reviews', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        if (reviews.isEmpty)
                          const Text('No approved reviews yet.')
                        else
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: reviews.map((r) => ReviewCard(review: r)).toList(),
                          ),
                        const SizedBox(height: 32),
                        if (related.isNotEmpty) ...[
                          const SectionHeader(title: 'You may also like'),
                          ServiceGrid(services: related),
                        ],
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                  const TamannaFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: desktop
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              color: AppColors.surface,
              child: PrimaryButton(
                label: 'Book This Service',
                expand: true,
                onTap: () => Get.toNamed('/booking', parameters: {'service': s.slug}),
              ),
            ),
    );
  }
}
