import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_shadows.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/media_kit.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/data/models/category_model.dart';
import 'package:tamanna/data/models/offer_model.dart';
import 'package:tamanna/data/models/package_model.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/services/cloudinary_service.dart';
import 'package:tamanna/features/request/request_controller.dart';

class CategoryCard extends StatefulWidget {
  final CategoryModel category;
  const CategoryCard({super.key, required this.category});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.category;
    final isMobile = Breakpoints.isMobile(context);
    final imgHeight = isMobile ? 95.0 : 160.0;
    final radius = isMobile ? 10.0 : 18.0;
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: () => Get.toNamed('/categories/${c.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image box with rounded corners and subtle hover lift
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              transform: Matrix4.translationValues(0, hover ? -4 : 0, 0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: hover ? AppShadows.hover : AppShadows.soft,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: CloudinaryImage(
                  url: c.imageUrl,
                  height: imgHeight,
                  width: double.infinity,
                  radius: BorderRadius.circular(radius),
                ),
              ),
            ),
            // Details outside the box
            SizedBox(height: isMobile ? 5 : 10),
            Text(
              c.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(
                fontSize: isMobile ? 12.5 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              c.serviceCount > 0 ? '${c.serviceCount} services' : 'Explore',
              style: AppTextStyles.small.copyWith(
                fontSize: isMobile ? 10.5 : 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final ServiceModel service;
  const ServiceCard({super.key, required this.service});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool hover = false;

  void _openQuickPreview(BuildContext context, ServiceModel s) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CloudinaryImage(
                    url: s.imageUrl,
                    height: 240,
                    width: double.infinity,
                    radius: BorderRadius.zero,
                    preset: CloudinaryPreset.detail,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.ink, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  if (s.discountPercent > 0)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: DiscountBadge(percent: s.discountPercent),
                    ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: AppTextStyles.h2.copyWith(fontSize: 22)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text('${s.durationMinutes} minutes', style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${s.sellingPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                          ),
                          if (s.mrp > s.sellingPrice) ...[
                            const SizedBox(width: 8),
                            Text(
                              '₹${s.mrp.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.shortDescription.isNotEmpty ? s.shortDescription : s.description,
                        style: AppTextStyles.body,
                      ),
                      if (s.includedItems.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text("What's included", style: AppTextStyles.title.copyWith(fontSize: 15)),
                        const SizedBox(height: 8),
                        ...s.includedItems.take(4).map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(item, style: AppTextStyles.small)),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'View Details',
                        onTap: () {
                          Navigator.of(context).pop();
                          Get.toNamed('/services/${s.slug}');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Book Now',
                        onTap: () {
                          Navigator.of(context).pop();
                          final request = Get.find<RequestController>();
                          request.pendingOpenBooking = true;
                          Get.toNamed('/services/${s.slug}');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final isMobile = Breakpoints.isMobile(context);
    final imgHeight = isMobile ? 110.0 : 190.0;
    final radius = isMobile ? 10.0 : 18.0;
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Box (Rounded container with subtle shadow & hover lift)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            transform: Matrix4.translationValues(0, hover ? -4 : 0, 0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: hover ? AppShadows.hover : AppShadows.soft,
            ),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed('/services/${s.slug}'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: AnimatedScale(
                      scale: hover ? 1.03 : 1.0,
                      duration: const Duration(milliseconds: 260),
                      child: CloudinaryImage(
                        url: s.imageUrl,
                        height: imgHeight,
                        width: double.infinity,
                        radius: BorderRadius.circular(radius),
                        preset: CloudinaryPreset.card,
                      ),
                    ),
                  ),
                ),
                // Top-Left Quick Preview Eye Icon (Orange/Accent circular badge)
                Positioned(
                  top: isMobile ? 5 : 10,
                  left: isMobile ? 5 : 10,
                  child: Material(
                    color: const Color(0xFFE8590C), // Vibrant beauty accent orange
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _openQuickPreview(context, s),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 4.5 : 7),
                        child: Icon(Icons.remove_red_eye_outlined, size: isMobile ? 12 : 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                if (s.discountPercent > 0)
                  Positioned(
                    bottom: isMobile ? 5 : 10,
                    left: isMobile ? 5 : 10,
                    child: DiscountBadge(percent: s.discountPercent),
                  ),
              ],
            ),
          ),

          // 2. Details OUTSIDE the box, sitting directly on the page surface
          SizedBox(height: isMobile ? 5 : 10),
          GestureDetector(
            onTap: () => Get.toNamed('/services/${s.slug}'),
            child: Text(
              s.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(
                fontSize: isMobile ? 12 : 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 2 : 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '₹${s.sellingPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 12.5 : 15,
                      ),
                    ),
                    if (s.durationMinutes > 0)
                      TextSpan(
                        text: ' · ${s.durationMinutes}m',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          fontSize: isMobile ? 10 : 13,
                        ),
                      ),
                  ],
                ),
              ),
              if (s.mrp > s.sellingPrice) ...[
                const SizedBox(height: 1),
                Text(
                  '₹${s.mrp.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: isMobile ? 10 : 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class PackageCard extends StatefulWidget {
  final PackageModel pack;
  final double? width;
  const PackageCard({super.key, required this.pack, this.width});

  @override
  State<PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final pack = widget.pack;
    final isMobile = Breakpoints.isMobile(context);
    final cardWidth = widget.width ?? (isMobile ? 140.0 : 220.0);
    final imgHeight = isMobile ? 105.0 : 160.0;
    final radius = isMobile ? 10.0 : 18.0;

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              transform: Matrix4.translationValues(0, hover ? -4 : 0, 0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: hover ? AppShadows.hover : AppShadows.soft,
              ),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed('/packages/${pack.slug}'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: AnimatedScale(
                        scale: hover ? 1.03 : 1.0,
                        duration: const Duration(milliseconds: 260),
                        child: CloudinaryImage(
                          url: pack.imageUrl,
                          height: imgHeight,
                          width: double.infinity,
                          radius: BorderRadius.circular(radius),
                          preset: CloudinaryPreset.card,
                        ),
                      ),
                    ),
                  ),
                  if (pack.discountPercent > 0)
                    Positioned(
                      bottom: isMobile ? 5 : 10,
                      left: isMobile ? 5 : 10,
                      child: DiscountBadge(percent: pack.discountPercent),
                    ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 5 : 10),
            GestureDetector(
              onTap: () => Get.toNamed('/packages/${pack.slug}'),
              child: Text(
                pack.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title.copyWith(
                  fontSize: isMobile ? 12 : 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(height: isMobile ? 2 : 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '₹${pack.sellingPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 12.5 : 15,
                        ),
                      ),
                      if (pack.durationMinutes > 0)
                        TextSpan(
                          text: ' · ${pack.durationMinutes}m',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                            fontSize: isMobile ? 10 : 13,
                          ),
                        ),
                    ],
                  ),
                ),
                if (pack.mrp > pack.sellingPrice) ...[
                  const SizedBox(height: 1),
                  Text(
                    '₹${pack.mrp.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: isMobile ? 10 : 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 1),
                  Text(
                    '${pack.serviceIds.length} services',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isMobile ? 10 : 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OfferCard extends StatefulWidget {
  final OfferModel offer;
  final bool expand;
  const OfferCard({super.key, required this.offer, this.expand = false});

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  bool hover = false;

  String get _discountLabel {
    final o = widget.offer;
    return o.discountType == 'fixed'
        ? '₹${o.discountValue.round()} off'
        : '${o.discountValue.round()}% off';
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final isMobile = Breakpoints.isMobile(context);
    final imgHeight = isMobile ? 105.0 : 160.0;
    final radius = isMobile ? 10.0 : 18.0;
    final cardWidth = widget.expand ? double.infinity : (isMobile ? 140.0 : 220.0);

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: SizedBox(
        width: cardWidth == double.infinity ? null : cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              transform: Matrix4.translationValues(0, hover ? -4 : 0, 0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: hover ? AppShadows.hover : AppShadows.soft,
              ),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed('/offers'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: AnimatedScale(
                        scale: hover ? 1.03 : 1.0,
                        duration: const Duration(milliseconds: 260),
                        child: CloudinaryImage(
                          url: offer.bannerUrl,
                          height: imgHeight,
                          width: double.infinity,
                          radius: BorderRadius.circular(radius),
                          preset: CloudinaryPreset.card,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: isMobile ? 5 : 10,
                    left: isMobile ? 5 : 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 3 : 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8590C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _discountLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 9.5 : 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 5 : 10),
            GestureDetector(
              onTap: () => Get.toNamed('/offers'),
              child: Text(
                offer.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title.copyWith(
                  fontSize: isMobile ? 12 : 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(height: isMobile ? 2 : 6),
            Text(
              offer.description.isNotEmpty
                  ? offer.description
                  : 'Special offer on selected home rituals',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isMobile ? 10.5 : 13,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceGrid extends StatelessWidget {
  final List<ServiceModel> services;
  const ServiceGrid({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final count = Breakpoints.gridCount(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        mainAxisSpacing: isMobile ? 12 : 24,
        crossAxisSpacing: isMobile ? 10 : 20,
        mainAxisExtent: isMobile ? 200 : 285,
      ),
      itemBuilder: (_, i) => ServiceCard(service: services[i]),
    );
  }
}

class SkeletonServiceCard extends StatelessWidget {
  const SkeletonServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 10 : 18),
          child: Shimmer.fromColors(
            baseColor: AppColors.cream,
            highlightColor: AppColors.surface,
            child: Container(
              height: isMobile ? 110 : 190,
              width: double.infinity,
              color: AppColors.cream,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 5 : 10),
        Shimmer.fromColors(
          baseColor: AppColors.cream,
          highlightColor: AppColors.surface,
          child: Container(height: isMobile ? 12 : 14, width: 140, color: AppColors.cream),
        ),
        SizedBox(height: isMobile ? 3 : 6),
        Shimmer.fromColors(
          baseColor: AppColors.cream,
          highlightColor: AppColors.surface,
          child: Container(height: isMobile ? 10 : 12, width: 90, color: AppColors.cream),
        ),
      ],
    );
  }
}
