import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/core/widgets/cards.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/features/catalog/catalog_controller.dart';
import 'package:tamanna/features/shell/site_shell.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = Get.find<CatalogController>();
    final isMobile = Breakpoints.isMobile(context);
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 18 : 36),
          child: FutureBuilder(
            future: catalog.allOffers(),
            builder: (context, snap) {
              if (snap.hasError) {
                return ErrorState(message: ErrorHandler.message(snap.error!), onRetry: () {});
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final offers = snap.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offers',
                    style: isMobile
                        ? AppTextStyles.h2.copyWith(fontSize: 22)
                        : AppTextStyles.h1,
                  ),
                  const SizedBox(height: 6),
                  Text('Live savings on selected home rituals.',
                      style: TextStyle(fontSize: isMobile ? 13 : 15, color: AppColors.textSecondary)),
                  SizedBox(height: isMobile ? 14 : 24),
                  if (offers.isEmpty)
                    const EmptyState(title: 'No live offers', message: 'Check back soon for seasonal savings.')
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final columns = Breakpoints.gridCount(context);
                        final gap = isMobile ? 10.0 : 20.0;
                        final itemWidth = (width - gap * (columns - 1)) / columns;
                        return Wrap(
                          spacing: gap,
                          runSpacing: isMobile ? 12 : 24,
                          alignment: WrapAlignment.start,
                          children: offers
                              .map(
                                (o) => SizedBox(
                                  width: itemWidth,
                                  child: OfferCard(offer: o, expand: true),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  SizedBox(height: isMobile ? 20 : 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
