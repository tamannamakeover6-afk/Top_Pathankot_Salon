import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/features/search/search_controller.dart';
import 'package:tamanna/features/shell/site_shell.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SearchControllerX());
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search Tamanna', style: AppTextStyles.h1),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  onChanged: c.onChanged,
                  onSubmitted: c.commit,
                  decoration: const InputDecoration(
                    hintText: 'Search services, packages or categories',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                if (c.recent.isNotEmpty && c.query.isEmpty) ...[
                  Text('Recent', style: AppTextStyles.title),
                  Wrap(
                    spacing: 8,
                    children: c.recent
                        .map(
                          (e) => ActionChip(
                            label: Text(e),
                            onPressed: () {
                              c.query.value = e;
                              c.commit(e);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                if (c.loading.value) const LinearProgressIndicator(),
                if (c.results.isEmpty && c.query.isNotEmpty && !c.loading.value)
                  const EmptyState(title: 'No matches', message: 'Try another word, like facial, spa or bridal.'),
                ...c.results.map(
                  (hit) => ListTile(
                    leading: const Icon(Icons.spa_outlined),
                    title: Text(hit.title),
                    subtitle: Text('${hit.type} · ${hit.subtitle}'),
                    onTap: () => Get.toNamed(hit.route),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            );
          }),
        ),
      ),
    );
  }
}
