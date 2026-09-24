import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/core/widgets/cards.dart';
import 'package:tamanna/core/widgets/media_kit.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/repositories/service_repository.dart';
import 'package:tamanna/features/request/booking_form.dart';
import 'package:tamanna/features/request/request_controller.dart';
import 'package:tamanna/features/shell/site_shell.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key});
  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  ServiceModel? service;
  List<ServiceModel> related = [];
  String? error;
  bool loading = true;
  String gallery = '';
  bool showBooking = false;
  final _bookingKey = GlobalKey();
  final _scroll = ScrollController();

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
      final relatedItems = await ServiceRepository().related(categoryId: item.categoryId, excludeId: item.id);
      setState(() {
        service = item;
        gallery = item.imageUrl;
        related = relatedItems;
        loading = false;
      });
      final request = Get.find<RequestController>();
      request.selectService(item);
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
  void dispose() {
    _scroll.dispose();
    super.dispose();
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
    final isMobile = Breakpoints.isMobile(context);
    final images = [s.imageUrl, ...s.gallery.where((e) => e.isNotEmpty)];
    final galleryCol = Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 14 : 20),
          child: CloudinaryImage(
            url: gallery.isEmpty ? s.imageUrl : gallery,
            height: isMobile ? 220 : 420,
            width: double.infinity,
          ),
        ),
        if (images.length > 1) ...[
          SizedBox(height: isMobile ? 8 : 12),
          SizedBox(
            height: isMobile ? 48 : 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => SizedBox(width: isMobile ? 6 : 8),
              itemBuilder: (context, i) {
                final url = images[i];
                final isSelected = (gallery.isEmpty ? s.imageUrl : gallery) == url;
                return GestureDetector(
                  onTap: () => setState(() => gallery = url),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE8590C) : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isMobile ? 7 : 9),
                      child: CloudinaryImage(
                        url: url,
                        width: isMobile ? 48 : 72,
                        height: isMobile ? 48 : 72,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
    final detailsCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.name,
          style: TextStyle(
            fontSize: isMobile ? 20 : 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        if (s.durationMinutes > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3ECE6),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF6E5E58)),
                const SizedBox(width: 3),
                Text(
                  '${s.durationMinutes} min',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6E5E58)),
                ),
              ],
            ),
          ),
        SizedBox(height: isMobile ? 10 : 16),
        Row(
          children: [
            PriceWidget(mrp: s.mrp, sellingPrice: s.sellingPrice),
            if (s.discountPercent > 0) ...[
              const SizedBox(width: 8),
              DiscountBadge(percent: s.discountPercent),
            ],
          ],
        ),
        SizedBox(height: isMobile ? 10 : 16),
        Text(
          s.shortDescription,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        if (s.includedItems.isNotEmpty) ...[
          SizedBox(height: isMobile ? 12 : 20),
          Text(
            "What's included",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          ...s.includedItems.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      e,
                      style: TextStyle(fontSize: isMobile ? 12.5 : 13.5, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        SizedBox(height: isMobile ? 12 : 16),
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
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const TamannaHeader(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.only(bottom: desktop ? 0 : 90),
              child: Column(
                children: [
                  ResponsiveContainer(
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: SiteBackButton(),
                      ),
                    ),
                  ),
                  ResponsiveContainer(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 28),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                galleryCol,
                                SizedBox(height: isMobile ? 16 : 24),
                                detailsCol,
                              ],
                            ),
                    ),
                  ),
                  ResponsiveContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About this service',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(s.description, style: TextStyle(fontSize: isMobile ? 13 : 14, color: AppColors.textSecondary, height: 1.4)),
                        SizedBox(height: isMobile ? 16 : 24),
                        if (s.benefits.isNotEmpty) ...[
                          Text(
                            'Benefits',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          ...s.benefits.map((e) => Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('• $e', style: TextStyle(fontSize: isMobile ? 13 : 14, color: AppColors.textSecondary)),
                              )),
                          SizedBox(height: isMobile ? 16 : 24),
                        ],
                        if (s.terms.isNotEmpty) ...[
                          Text(
                            'Good to know',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          ...s.terms.map((e) => Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(e, style: TextStyle(fontSize: isMobile ? 13 : 14, color: AppColors.textSecondary)),
                              )),
                          SizedBox(height: isMobile ? 16 : 24),
                        ],
                        if (related.isNotEmpty) ...[
                          const SectionHeader(title: 'You may also like'),
                          ServiceGrid(services: related),
                        ],
                        SizedBox(height: isMobile ? 32 : 48),
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
                label: 'Book Now',
                expand: true,
                onTap: _openBooking,
              ),
            ),
    );
  }
}
