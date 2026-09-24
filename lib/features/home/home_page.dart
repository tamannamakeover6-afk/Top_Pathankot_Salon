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
    final isMobile = Breakpoints.isMobile(context);
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
            SizedBox(height: isMobile ? 22 : 56),
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
                  SizedBox(height: isMobile ? 26 : 64),
                  SectionHeader(
                    eyebrow: 'Popular',
                    title: 'Services to book',
                    action: 'View all',
                    onAction: () => Get.toNamed('/categories'),
                  ),
               
                  if (catalog.homeServices.isEmpty)
                    EmptyState(
                      title: 'Catalog coming soon',
                      message:
                          'Services will appear here once the admin publishes them.',
                    )
                  else
                    ServiceGrid(services: catalog.homeServices),
                  if (catalog.offers.isNotEmpty) ...[
                    SizedBox(height: isMobile ? 26 : 64),
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
                  SizedBox(height: isMobile ? 26 : 64),
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
                  SizedBox(height: isMobile ? 28 : 72),
                  const _Why(),
                  SizedBox(height: isMobile ? 28 : 72),
                  const _Cta(),
                  SizedBox(height: isMobile ? 20 : 48),
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
    final isMobile = Breakpoints.isMobile(context);
    return Container(
      color: AppColors.cream,
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: desktop ? 64 : (isMobile ? 22 : 36)),
          child: desktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _heroCopy(desktop, isMobile)),
                    const SizedBox(width: 40),
                    const Expanded(child: HeroImage()),
                  ],
                )
              : Column(
                  children: [
                    _heroCopy(desktop, isMobile),
                    SizedBox(height: isMobile ? 18 : 28),
                    const HeroImage(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _heroCopy(bool desktop, bool isMobile) {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AT-HOME BEAUTY',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gold,
              fontSize: isMobile ? 11 : 12,
              letterSpacing: 0.6,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'The salon experience,\nquietly brought home.',
            style: desktop
                ? AppTextStyles.display
                : (isMobile
                    ? AppTextStyles.h1.copyWith(fontSize: 26, height: 1.18)
                    : AppTextStyles.h1),
          ),
          SizedBox(height: isMobile ? 10 : 16),
          Text(
            'Facials, waxing, hair spa, bridal prep and more — booked around your day, in your space.',
            style: isMobile
                ? AppTextStyles.body.copyWith(fontSize: 13.5, height: 1.4)
                : AppTextStyles.body,
          ),
          SizedBox(height: isMobile ? 16 : 28),
          Wrap(
            spacing: isMobile ? 10 : 12,
            runSpacing: isMobile ? 10 : 12,
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
    final isMobile = Breakpoints.isMobile(context);
    return FadeInUp(
      delayMs: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 14 : 20),
        child: Image.asset(
          'assets/images/banner.png',
          height: isMobile ? 165 : 380,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

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
        mainAxisSpacing: isMobile ? 10 : 20,
        crossAxisSpacing: isMobile ? 10 : 20,
        mainAxisExtent: isMobile ? 145 : 225,
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
    final isMobile = Breakpoints.isMobile(context);
    return SizedBox(
      height: isMobile ? 190 : 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemBuilder: (_, i) => children[i],
        separatorBuilder: (context, index) => SizedBox(width: isMobile ? 10 : 16),
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
    final isMobile = Breakpoints.isMobile(context);
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
            mainAxisExtent: isMobile ? 116 : 140,
            mainAxisSpacing: isMobile ? 10 : 16,
            crossAxisSpacing: isMobile ? 10 : 16,
          ),
          itemBuilder: (_, i) {
            final item = items[i];
            return Container(
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(isMobile ? 14 : 22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.$1, color: AppColors.rose, size: isMobile ? 20 : 24),
                  SizedBox(height: isMobile ? 6 : 12),
                  Text(
                    item.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isMobile
                        ? AppTextStyles.title.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600)
                        : AppTextStyles.title,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.$3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: isMobile
                        ? AppTextStyles.small.copyWith(fontSize: 10.5, height: 1.2)
                        : AppTextStyles.small,
                  ),
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
    final isMobile = Breakpoints.isMobile(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 26 : 48,
        horizontal: isMobile ? 18 : 28,
      ),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(isMobile ? 18 : 28),
      ),
      child: Column(
        children: [
          Text(
            'Bring the salon experience home.',
            style: isMobile
                ? AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 18)
                : AppTextStyles.h2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          PrimaryButton(
            label: 'Request a Service',
            onTap: () => Get.toNamed('/categories'),
          ),
        ],
      ),
    );
  }
}
