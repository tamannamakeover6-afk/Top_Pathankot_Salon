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
import 'package:tamanna/data/models/review_model.dart';
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
    final imgHeight = isMobile ? 115.0 : 160.0;
    final radius = isMobile ? 12.0 : 18.0;
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
            SizedBox(height: isMobile ? 6 : 10),
            Text(
              c.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              c.serviceCount > 0 ? '${c.serviceCount} services' : 'Explore',
              style: AppTextStyles.small.copyWith(
                fontSize: isMobile ? 11 : 12,
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
                          RatingWidget(rating: s.rating, count: s.reviewCount),
                          const Spacer(),
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
    final imgHeight = isMobile ? 120.0 : 190.0;
    final radius = isMobile ? 12.0 : 18.0;
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
                  top: isMobile ? 6 : 10,
                  left: isMobile ? 6 : 10,
                  child: Material(
                    color: const Color(0xFFE8590C), // Vibrant beauty accent orange
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _openQuickPreview(context, s),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 5 : 7),
                        child: Icon(Icons.remove_red_eye_outlined, size: isMobile ? 13 : 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                if (s.discountPercent > 0)
                  Positioned(
                    bottom: isMobile ? 6 : 10,
                    left: isMobile ? 6 : 10,
                    child: DiscountBadge(percent: s.discountPercent),
                  ),
              ],
            ),
          ),

          // 2. Details OUTSIDE the box, sitting directly on the page surface
          SizedBox(height: isMobile ? 6 : 10),
          GestureDetector(
            onTap: () => Get.toNamed('/services/${s.slug}'),
            child: Text(
              s.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(
                fontSize: isMobile ? 12.5 : 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 3 : 6),
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
                        fontSize: isMobile ? 13 : 15,
                      ),
                    ),
                    if (s.durationMinutes > 0)
                      TextSpan(
                        text: ' · ${s.durationMinutes}m',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          fontSize: isMobile ? 10.5 : 13,
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
                    fontSize: isMobile ? 10.5 : 12,
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

class PackageCard extends StatelessWidget {
  final PackageModel pack;
  final double? width;
  const PackageCard({super.key, required this.pack, this.width});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final cardWidth = width ?? (isMobile ? 260.0 : 320.0);
    return GestureDetector(
      onTap: () => Get.toNamed('/packages/${pack.slug}'),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(isMobile ? 14 : 18),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CloudinaryImage(
              url: pack.imageUrl,
              height: isMobile ? 135 : 170,
              width: double.infinity,
              radius: BorderRadius.vertical(top: Radius.circular(isMobile ? 14 : 18)),
              preset: CloudinaryPreset.banner,
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DiscountBadge(percent: pack.discountPercent),
                  SizedBox(height: isMobile ? 6 : 8),
                  Text(pack.name, style: AppTextStyles.title.copyWith(fontSize: isMobile ? 14 : 16)),
                  const SizedBox(height: 4),
                  Text(
                    '${pack.serviceIds.length} services · ${pack.durationMinutes} min',
                    style: AppTextStyles.small.copyWith(fontSize: isMobile ? 11 : 12),
                  ),
                  SizedBox(height: isMobile ? 6 : 10),
                  PriceWidget(mrp: pack.mrp, sellingPrice: pack.sellingPrice),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  final bool expand;
  const OfferCard({super.key, required this.offer, this.expand = false});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return Container(
      width: expand ? double.infinity : (isMobile ? 270 : 360),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(isMobile ? 14 : 18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CloudinaryImage(
            url: offer.bannerUrl,
            height: isMobile ? 120 : 150,
            width: double.infinity,
            radius: BorderRadius.zero,
            preset: CloudinaryPreset.banner,
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: isMobile ? 13.5 : 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  offer.discountType == 'fixed'
                      ? '₹${offer.discountValue.round()} off'
                      : '${offer.discountValue.round()}% off selected rituals',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    color: const Color(0xFFE8D5C8),
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 12),
                TextButton(
                  onPressed: () => Get.toNamed('/categories'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Browse', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return Container(
      width: isMobile ? 260 : 320,
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isMobile ? 14 : 18),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isMobile ? 16 : 20,
                backgroundColor: AppColors.cream,
                child: Text(
                  review.userName.isEmpty ? 'T' : review.userName[0],
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppTextStyles.title.copyWith(fontSize: isMobile ? 13 : 15),
                    ),
                    RatingWidget(rating: review.rating.toDouble()),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(review.review, maxLines: 4, overflow: TextOverflow.ellipsis, style: AppTextStyles.body),
          const SizedBox(height: 10),
          Text(review.itemName, style: AppTextStyles.caption),
        ],
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
        mainAxisSpacing: isMobile ? 16 : 24,
        crossAxisSpacing: isMobile ? 12 : 20,
        mainAxisExtent: isMobile ? 218 : 285,
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
          borderRadius: BorderRadius.circular(isMobile ? 12 : 18),
          child: Shimmer.fromColors(
            baseColor: AppColors.cream,
            highlightColor: AppColors.surface,
            child: Container(
              height: isMobile ? 120 : 190,
              width: double.infinity,
              color: AppColors.cream,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 10),
        Shimmer.fromColors(
          baseColor: AppColors.cream,
          highlightColor: AppColors.surface,
          child: Container(height: isMobile ? 12 : 14, width: 140, color: AppColors.cream),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        Shimmer.fromColors(
          baseColor: AppColors.cream,
          highlightColor: AppColors.surface,
          child: Container(height: isMobile ? 10 : 12, width: 90, color: AppColors.cream),
        ),
      ],
    );
  }
}
