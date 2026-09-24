import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
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
          padding: const EdgeInsets.symmetric(vertical: 36),
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
                  Text('Offers', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text('Live savings on selected home rituals.', style: AppTextStyles.body),
                  const SizedBox(height: 24),
                  if (offers.isEmpty)
                    const EmptyState(title: 'No live offers', message: 'Check back soon for seasonal savings.')
                  else
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
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
