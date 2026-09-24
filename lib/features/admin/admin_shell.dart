import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/features/auth/auth_controller.dart';

class AdminShell extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onBack;
  const AdminShell({super.key, required this.title, required this.child, this.onBack});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1024;
    final isDashboard = Get.currentRoute == '/admin';
    final backAction = onBack ??
        (isDashboard
            ? null
            : () {
                final nav = Navigator.maybeOf(context);
                if (nav != null && nav.canPop()) {
                  nav.pop();
                } else {
                  Get.offNamed('/admin');
                }
              });
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEE8),
      drawer: wide ? null : const Drawer(child: _Side()),
      body: Row(
        children: [
          if (wide) const SizedBox(width: 250, child: _Side()),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 72,
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      if (!wide)
                        Builder(
                          builder: (ctx) => IconButton(
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                            icon: const Icon(Icons.menu),
                          ),
                        ),
                      if (backAction != null)
                        IconButton(onPressed: backAction, icon: const Icon(Icons.arrow_back)),
                      Expanded(child: Text(title, style: AppTextStyles.h3, overflow: TextOverflow.ellipsis)),
                      TextButton(onPressed: () => Get.toNamed('/'), child: const Text('View site')),
                      IconButton(
                        onPressed: () => Get.find<AuthController>().logout(),
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side();
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text('Tamanna Admin', style: AppTextStyles.title.copyWith(color: Colors.white)),
          ),
          _item('Dashboard', '/admin'),
          _item('Categories', '/admin/categories'),
          _item('Services', '/admin/services'),
          _item('Packages', '/admin/packages'),
          _item('Pricing', '/admin/pricing'),
          _item('Offers', '/admin/offers'),
        ],
      ),
    );
  }

  Widget _item(String label, String route) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () => Get.toNamed(route),
    );
  }
}

class AdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) return const RouteSettings(name: '/login');
    if (!auth.isAdmin) return const RouteSettings(name: '/');
    return null;
  }
}
