import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_radius.dart';
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
import 'package:tamanna/features/auth/auth_controller.dart';
import 'package:tamanna/features/favorites/favorites_controller.dart';

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
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: () => Get.toNamed('/categories/${c.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, hover ? -6 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
            boxShadow: hover ? AppShadows.hover : AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: AnimatedScale(
                  scale: hover ? 1.05 : 1,
                  duration: const Duration(milliseconds: 280),
                  child: CloudinaryImage(
                    url: c.imageUrl,
                    height: 150,
                    width: double.infinity,
                    radius: BorderRadius.zero,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: AppTextStyles.title),
                    const SizedBox(height: 4),
                    Text(
                      c.serviceCount > 0 ? '${c.serviceCount} services' : 'Explore',
                      style: AppTextStyles.small,
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
                          Get.toNamed('/booking', parameters: {'service': s.slug});
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
    final fav = Get.find<FavoritesController>();
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hover ? AppColors.rose.withValues(alpha: 0.5) : AppColors.border.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: hover ? AppShadows.hover : AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with top-left eye preview & top-right heart wishlist
            Stack(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed('/services/${s.slug}'),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: AnimatedScale(
                      scale: hover ? 1.04 : 1,
                      duration: const Duration(milliseconds: 260),
                      child: CloudinaryImage(
                        url: s.imageUrl,
                        height: 180,
                        width: double.infinity,
                        radius: BorderRadius.zero,
                        preset: CloudinaryPreset.card,
                      ),
                    ),
                  ),
                ),
                // Top-Left Quick Preview Eye Icon (Orange/Accent circular badge)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Material(
                    color: const Color(0xFFE8590C), // Vibrant beauty accent orange
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _openQuickPreview(context, s),
                      child: const Padding(
                        padding: EdgeInsets.all(7),
                        child: Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                // Top-Right Favorite/Wishlist Heart Icon
                Positioned(
                  top: 10,
                  right: 10,
                  child: Obx(() {
                    final on = fav.isFavorite(s.id);
                    return Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => fav.toggle(s.id),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            on ? Icons.favorite : Icons.favorite_border,
                            color: const Color(0xFFE8590C),
                            size: 18,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            // Card Content matching reference screenshot
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Title
                  GestureDetector(
                    onTap: () => Get.toNamed('/services/${s.slug}'),
                    child: Text(
                      s.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Price and duration row with right-aligned circular "+" button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '₹${s.sellingPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (s.durationMinutes > 0)
                                    TextSpan(
                                      text: ' / ${s.durationMinutes}minutes',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (s.mrp > s.sellingPrice) ...[
                              const SizedBox(height: 2),
                              Text(
                                '₹${s.mrp.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Circular Orange/Accent "+" Quick Add / Book Button
                      Material(
                        color: const Color(0xFFE8590C),
                        shape: const CircleBorder(),
                        elevation: 1,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Get.toNamed('/booking', parameters: {'service': s.slug}),
                          child: const Padding(
                            padding: EdgeInsets.all(7),
                            child: Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  final PackageModel pack;
  const PackageCard({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/packages/${pack.slug}'),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.card,
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CloudinaryImage(url: pack.imageUrl, height: 170, width: double.infinity, preset: CloudinaryPreset.banner),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DiscountBadge(percent: pack.discountPercent),
                  const SizedBox(height: 8),
                  Text(pack.name, style: AppTextStyles.title),
                  const SizedBox(height: 6),
                  Text(
                    '${pack.serviceIds.length} services · ${pack.durationMinutes} min',
                    style: AppTextStyles.small,
                  ),
                  const SizedBox(height: 10),
                  PriceWidget(mrp: pack.mrp, sellingPrice: pack.sellingPrice),
                  const SizedBox(height: 6),
                  Text(
                    'Save ₹${(pack.mrp - pack.sellingPrice).round()}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.success),
                  ),
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
  const OfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CloudinaryImage(
            url: offer.bannerUrl,
            height: 150,
            width: double.infinity,
            radius: BorderRadius.zero,
            preset: CloudinaryPreset.banner,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.title, style: AppTextStyles.title.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(
                  offer.discountType == 'fixed'
                      ? '₹${offer.discountValue.round()} off'
                      : '${offer.discountValue.round()}% off selected rituals',
                  style: AppTextStyles.small.copyWith(color: const Color(0xFFE8D5C8)),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Browse',
                  onTap: () => Get.toNamed('/offers'),
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
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.cream,
                child: Text(review.userName.isEmpty ? 'T' : review.userName[0]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: AppTextStyles.title.copyWith(fontSize: 15)),
                    RatingWidget(rating: review.rating.toDouble()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
    final count = Breakpoints.gridCount(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: count == 1 ? 0.92 : 0.72,
      ),
      itemBuilder: (_, i) => ServiceCard(service: services[i]),
    );
  }
}

class SkeletonServiceCard extends StatelessWidget {
  const SkeletonServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cream,
      highlightColor: AppColors.surface,
      child: Container(
        decoration: BoxDecoration(color: AppColors.cream, borderRadius: AppRadius.card),
      ),
    );
  }
}

class AuthGateNote {
  static void requireLogin() {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      Get.toNamed('/login');
    }
  }
}
