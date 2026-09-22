import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/cards.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/features/catalog/catalog_controller.dart';
import 'package:tamanna/features/shell/site_shell.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final catalog = Get.find<CatalogController>();

  @override
  void initState() {
    super.initState();
    catalog.loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: Obx(() {
        if (catalog.homeError.isNotEmpty) {
          return ErrorState(
            message: catalog.homeError.value,
            onRetry: catalog.loadHome,
          );
        }
        return Column(
          children: [
            const _Hero(),
            const SizedBox(height: 56),
            ResponsiveContainer(
              child: Column(
                children: [
                  SectionHeader(
                    eyebrow: 'Browse',
                    title: 'Find your ritual',
                    subtitle:
                        'Categories you can book at home, on your schedule.',
                    action: 'All categories',
                    onAction: () => Get.toNamed('/categories'),
                  ),
                  _CategoryRow(),
                  const SizedBox(height: 64),
                  SectionHeader(
                    eyebrow: 'Popular',
                    title: 'Services to book',
                    action: 'View all',
                    onAction: () => Get.toNamed('/categories'),
                  ),
                  if (catalog.loadingHome.value)
                    const SizedBox(height: 280, child: SkeletonServiceCard())
                  else if (catalog.homeServices.isEmpty)
                    EmptyState(
                      title: 'Catalog coming soon',
                      message:
                          'Services will appear here once the admin publishes them.',
                    )
                  else
                    ServiceGrid(services: catalog.homeServices),
                  if (catalog.offers.isNotEmpty) ...[
                    const SizedBox(height: 64),
                    SectionHeader(
                      eyebrow: 'This week',
                      title: 'Live offers',
                      action: 'All offers',
                      onAction: () => Get.toNamed('/offers'),
                    ),
                    _HScroll(
                      empty: 'No live offers right now.',
                      children: catalog.offers
                          .map((o) => OfferCard(offer: o))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 64),
                  SectionHeader(
                    eyebrow: 'Bundles',
                    title: 'Packages made for home',
                    action: 'All packages',
                    onAction: () => Get.toNamed('/packages'),
                  ),
                  _HScroll(
                    empty: 'Packages will appear here.',
                    children: catalog.packages
                        .map((p) => PackageCard(pack: p))
                        .toList(),
                  ),
                  const SizedBox(height: 72),
                  const _Why(),
                  const SizedBox(height: 72),
                  SectionHeader(
                    eyebrow: 'Kind words',
                    title: 'Guest reviews',
                    action: 'Read more',
                    onAction: () => Get.toNamed('/reviews'),
                  ),
                  _HScroll(
                    empty: 'Reviews will appear after completed bookings.',
                    children: catalog.reviews
                        .map((r) => ReviewCard(review: r))
                        .toList(),
                  ),
                  const SizedBox(height: 72),
                  const _Cta(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();
  @override
  Widget build(BuildContext context) {
    final desktop = Breakpoints.isDesktop(context);
    return Container(
      color: AppColors.cream,
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: desktop ? 64 : 36),
          child: desktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _heroCopy(desktop)),
                    const SizedBox(width: 40),
                    const Expanded(child: HeroImage()),
                  ],
                )
              : Column(
                  children: [
                    _heroCopy(desktop),
                    const SizedBox(height: 28),
                    const HeroImage(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _heroCopy(bool desktop) {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AT-HOME BEAUTY',
            style: AppTextStyles.caption.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: 12),
          Text(
            'The salon experience,\nquietly brought home.',
            style: desktop ? AppTextStyles.display : AppTextStyles.h1,
          ),
          const SizedBox(height: 16),
          Text(
            'Facials, waxing, hair spa, bridal prep and more — booked around your day, in your space.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PrimaryButton(
                label: 'Explore Services',
                onTap: () => Get.toNamed('/categories'),
              ),
              SecondaryButton(
                label: 'Request now',
                onTap: () => Get.toNamed('/categories'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeroImage extends StatelessWidget {
  const HeroImage({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delayMs: 80,
      child: Container(
        // color: Colors.white,
        child: Image.asset(
          'assets/images/banner.png', // Apni asset file ka path yahan dalein
          height: 420,
          width: double.infinity,
          fit: BoxFit.fitWidth, // Banner ko clean fit karne ke liye
        ),
      ),
    );
  }
}

// class HeroImage extends StatelessWidget {
//   const HeroImage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return FadeInUp(
//       delayMs: 80,
//       child: const CloudinaryImage(
//         url: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?auto=format&fit=crop&w=1400&q=80',
//         height: 420,
//         width: double.infinity,
//       ),
//     );
//   }
// }

class _CategoryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cats = Get.find<CatalogController>().categories;
    if (cats.isEmpty) {
      return const EmptyState(
        title: 'No categories yet',
        message: 'Ask an admin to publish the catalog.',
      );
    }
    final isMobile = Breakpoints.isMobile(context);
    final count = Breakpoints.gridCount(context, max: 5);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        mainAxisSpacing: isMobile ? 14 : 20,
        crossAxisSpacing: isMobile ? 12 : 20,
        mainAxisExtent: isMobile ? 175 : 225,
      ),
      itemBuilder: (_, i) => CategoryCard(category: cats[i]),
    );
  }
}

class _HScroll extends StatelessWidget {
  final List<Widget> children;
  final String empty;
  const _HScroll({required this.children, required this.empty});
  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(empty),
      );
    }
    return SizedBox(
      height: 360,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => children[i],
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemCount: children.length,
      ),
    );
  }
}

class _Why extends StatelessWidget {
  const _Why();
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'At-home service', 'No travel. No waiting rooms.'),
      (
        Icons.verified_outlined,
        'Verified professionals',
        'Trained specialists you can trust.',
      ),
      (
        Icons.payments_outlined,
        'Transparent pricing',
        'MRP, offer price and duration, clearly shown.',
      ),
      (
        Icons.chat_outlined,
        'WhatsApp request',
        'Send selected services, date and time in one message.',
      ),
      (
        Icons.spa_outlined,
        'Premium products',
        'Thoughtful formulas for skin and hair.',
      ),
      (
        Icons.schedule_outlined,
        'Convenient hours',
        'Slots that fit around your day.',
      ),
    ];
    final count = Breakpoints.gridCount(context, max: 3);
    return Column(
      children: [
        const SectionHeader(
          eyebrow: 'Why Tamanna',
          title: 'Care that comes to you',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            mainAxisExtent: 140,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (_, i) {
            final item = items[i];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.$1, color: AppColors.rose),
                  const SizedBox(height: 12),
                  Text(item.$2, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(item.$3, style: AppTextStyles.small),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 28),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text(
            'Bring the salon experience home.',
            style: AppTextStyles.h2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Request a Service',
            onTap: () => Get.toNamed('/categories'),
          ),
        ],
      ),
    );
  }
}
