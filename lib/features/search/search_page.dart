import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/features/search/search_controller.dart';
import 'package:tamanna/features/shell/site_shell.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SearchControllerX());
    final isMobile = Breakpoints.isMobile(context);
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 18 : 36),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Tamanna',
                  style: isMobile
                      ? AppTextStyles.h2.copyWith(fontSize: 22)
                      : AppTextStyles.h1,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                TextField(
                  autofocus: true,
                  onChanged: c.onChanged,
                  onSubmitted: c.commit,
                  decoration: const InputDecoration(
                    hintText: 'Search services, packages or categories',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                if (c.recent.isNotEmpty && c.query.isEmpty) ...[
                  Text('Recent', style: AppTextStyles.title.copyWith(fontSize: isMobile ? 15 : 18)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: c.recent
                        .map(
                          (e) => ActionChip(
                            label: Text(e, style: TextStyle(fontSize: isMobile ? 12 : 14)),
                            onPressed: () {
                              c.query.value = e;
                              c.commit(e);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
                SizedBox(height: isMobile ? 12 : 16),
                if (c.loading.value) const LinearProgressIndicator(),
                if (c.results.isEmpty && c.query.isNotEmpty && !c.loading.value)
                  const EmptyState(title: 'No matches', message: 'Try another word, like facial, spa or bridal.'),
                ...c.results.map(
                  (hit) => ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 16, vertical: isMobile ? 2 : 4),
                    leading: const Icon(Icons.spa_outlined),
                    title: Text(hit.title, style: TextStyle(fontSize: isMobile ? 13.5 : 15)),
                    subtitle: Text('${hit.type} · ${hit.subtitle}', style: TextStyle(fontSize: isMobile ? 11.5 : 13)),
                    onTap: () => Get.toNamed(hit.route),
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 40),
              ],
            );
          }),
        ),
      ),
    );
  }
}
