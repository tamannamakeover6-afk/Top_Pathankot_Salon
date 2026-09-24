import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_shadows.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/features/auth/auth_controller.dart';
import 'package:tamanna/features/shell/tamanna_footer.dart';

export 'package:tamanna/features/shell/tamanna_footer.dart';

bool isSiteHomeRoute([String? route]) {
  final r = (route ?? Get.currentRoute).split('?').first;
  return r.isEmpty || r == '/' || r == '/home';
}

void goSiteBack(BuildContext context) {
  final nav = Navigator.maybeOf(context);
  if (nav != null && nav.canPop()) {
    nav.pop();
    return;
  }
  if (Get.previousRoute.isNotEmpty &&
      Get.previousRoute != Get.currentRoute &&
      !isSiteHomeRoute(Get.previousRoute)) {
    Get.back();
    return;
  }
  Get.offAllNamed('/');
}

class SiteBackButton extends StatelessWidget {
  final bool compact;
  const SiteBackButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        tooltip: 'Back',
        onPressed: () => goSiteBack(context),
        icon: const Icon(Icons.arrow_back_rounded),
      );
    }
    return TextButton.icon(
      onPressed: () => goSiteBack(context),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class TamannaHeader extends StatelessWidget {
  final bool solid;
  const TamannaHeader({super.key, this.solid = true});

  @override
  Widget build(BuildContext context) {
    final desktop = Breakpoints.isDesktop(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: solid
            ? AppColors.surface.withValues(alpha: 0.96)
            : Colors.transparent,
        boxShadow: solid ? AppShadows.header : [],
      ),
      child: SafeArea(
        bottom: false,
        child: ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 76,
            child: Row(
              children: [
                InkWell(
                  onTap: () => Get.toNamed('/'),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Image.asset(
                      'assets/images/logo500.png',
                      // height: 60,
                      // width: 170,
                    ),
                  ),
                ),
                const Spacer(),
                if (desktop) ...[
                  _Nav('Home', '/'),
                  _Nav('Categories', '/categories'),
                  _Nav('Packages', '/packages'),
                  _Nav('Offers', '/offers'),
                  IconButton(
                    onPressed: () => Get.toNamed('/search'),
                    icon: const Icon(Icons.search),
                  ),
                  _Account(),
                  const SizedBox(width: 8),
                  PrimaryButton(
                    label: 'Request a Service',
                    onTap: () => Get.toNamed('/categories'),
                  ),
                ] else ...[
                  IconButton(
                    onPressed: () => Get.toNamed('/search'),
                    icon: const Icon(Icons.search),
                  ),
                  _Account(),
                  IconButton(
                    onPressed: () => _openMenu(context),
                    icon: const Icon(Icons.menu),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('Home'), onTap: () => Get.toNamed('/')),
            ListTile(
              title: const Text('Categories'),
              onTap: () => Get.toNamed('/categories'),
            ),
            ListTile(
              title: const Text('Packages'),
              onTap: () => Get.toNamed('/packages'),
            ),
            ListTile(
              title: const Text('Offers'),
              onTap: () => Get.toNamed('/offers'),
            ),
            ListTile(
              title: const Text('About'),
              onTap: () => Get.toNamed('/about'),
            ),
            ListTile(
              title: const Text('Contact'),
              onTap: () => Get.toNamed('/contact'),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Request a Service',
              expand: true,
              onTap: () => Get.toNamed('/categories'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  final String label;
  final String route;
  const _Nav(this.label, this.route);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Get.toNamed(route),
      child: Text(label, style: AppTextStyles.nav),
    );
  }
}

class _Account extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() {
      if (!auth.isLoggedIn) {
        return IconButton(
          onPressed: () => Get.toNamed('/login'),
          icon: const Icon(Icons.person_outline),
        );
      }
      return PopupMenuButton<String>(
        icon: const Icon(Icons.person_outline),
        onSelected: (v) {
          if (v == 'admin') Get.toNamed('/admin');
          if (v == 'profile') Get.toNamed('/profile');
          if (v == 'logout') auth.logout();
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'profile', child: Text('Profile')),
          if (auth.isAdmin)
            const PopupMenuItem(value: 'admin', child: Text('Admin')),
          const PopupMenuItem(value: 'logout', child: Text('Logout')),
        ],
      );
    });
  }
}

class SiteShell extends StatelessWidget {
  final Widget child;
  final bool transparentHeader;
  const SiteShell({
    super.key,
    required this.child,
    this.transparentHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final showBack = !isSiteHomeRoute();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          TamannaHeader(solid: !transparentHeader),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (showBack)
                    ResponsiveContainer(
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: SiteBackButton(),
                        ),
                      ),
                    ),
                  child,
                  const TamannaFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
