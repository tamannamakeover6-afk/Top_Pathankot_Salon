import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_radius.dart';
import 'package:tamanna/data/services/cloudinary_service.dart';

class CloudinaryImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final CloudinaryPreset preset;
  final BorderRadius? radius;

  const CloudinaryImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.preset = CloudinaryPreset.card,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePreset =
        (width != null && width!.isFinite && width! <= 96) ? CloudinaryPreset.thumb : preset;
    final resolved = CloudinaryService.transform(url, preset: effectivePreset);
    final r = radius ?? AppRadius.card;
    if (resolved.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: AppColors.cream, borderRadius: r),
        child: Image.asset("assets/images/empty_photo.png",fit: BoxFit.cover),
      );
    }

    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    final logicalW = width != null && width!.isFinite ? width! : CloudinaryService.widthFor(effectivePreset).toDouble();
    final cacheWidth = (logicalW * dpr).round().clamp(80, CloudinaryService.widthFor(effectivePreset) * 2);

    return ClipRRect(
      borderRadius: r,
      child: ColoredBox(
        color: AppColors.cream,
        child: Image.network(
          resolved,
          key: ValueKey(resolved),
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          cacheWidth: cacheWidth,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Shimmer.fromColors(
              baseColor: AppColors.cream,
              highlightColor: AppColors.surface,
              child: Container(width: width, height: height, color: AppColors.cream),
            );
          },
          errorBuilder: (context, error, stack) => Container(
            width: width,
            height: height,
            color: AppColors.cream,
            child: Image.asset("assets/images/empty_photo.png",fit: BoxFit.cover)
          ),
        ),
      ),
    );
  }
}

class DiscountBadge extends StatelessWidget {
  final double percent;
  const DiscountBadge({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    if (percent <= 0) return const SizedBox.shrink();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '${percent.round()}% OFF',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class PriceWidget extends StatelessWidget {
  final double mrp;
  final double sellingPrice;
  final bool compact;
  const PriceWidget({
    super.key,
    required this.mrp,
    required this.sellingPrice,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (sellingPrice <= 0 && mrp <= 0) {
      return Text(
        'Price on request',
        style: TextStyle(
          fontSize: compact ? 13 : 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      );
    }
    return Row(
      children: [
        Text(
          '₹${sellingPrice.round()}',
          style: TextStyle(
            fontSize: compact ? 16 : 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (mrp > sellingPrice) ...[
          const SizedBox(width: 8),
          Text(
            '₹${mrp.round()}',
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              color: AppColors.textHint,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

class RatingWidget extends StatelessWidget {
  final double rating;
  final int count;
  const RatingWidget({super.key, required this.rating, this.count = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Text('($count)', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
        ],
      ],
    );
  }
}
