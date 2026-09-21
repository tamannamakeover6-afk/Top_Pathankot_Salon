import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_shadows.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/features/auth/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class TamannaHeader extends StatelessWidget {
  final bool solid;
  const TamannaHeader({super.key, this.solid = true});

  @override
  Widget build(BuildContext context) {
    final desktop = Breakpoints.isDesktop(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: solid ? AppColors.surface.withValues(alpha: 0.96) : Colors.transparent,
        boxShadow: solid ? AppShadows.header : [],
      ),
      child: SafeArea(
        bottom: false,
        child: ResponsiveContainer(
          child: SizedBox(
            height: 76,
            child: Row(
              children: [
                InkWell(
                  onTap: () => Get.toNamed('/'),
                  child: Row(
                    children: [
                      Image.asset('assets/images/logo.png', height: 42),
                      const SizedBox(width: 10),
                      Text(AppConstants.appName, style: AppTextStyles.h3.copyWith(fontSize: 22)),
                    ],
                  ),
                ),
                const Spacer(),
                if (desktop) ...[
                  _Nav('Home', '/'),
                  _Nav('Categories', '/categories'),
                  _Nav('Packages', '/packages'),
                  _Nav('Offers', '/offers'),
                  _Nav('Reviews', '/reviews'),
                  IconButton(
                    onPressed: () => Get.toNamed('/search'),
                    icon: const Icon(Icons.search),
                  ),
                  _Account(),
                  const SizedBox(width: 8),
                  PrimaryButton(label: 'Book a Service', onTap: () => Get.toNamed('/categories')),
                ] else ...[
                  IconButton(onPressed: () => Get.toNamed('/search'), icon: const Icon(Icons.search)),
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
            ListTile(title: const Text('Categories'), onTap: () => Get.toNamed('/categories')),
            ListTile(title: const Text('Packages'), onTap: () => Get.toNamed('/packages')),
            ListTile(title: const Text('Offers'), onTap: () => Get.toNamed('/offers')),
            ListTile(title: const Text('Reviews'), onTap: () => Get.toNamed('/reviews')),
            ListTile(title: const Text('About'), onTap: () => Get.toNamed('/about')),
            ListTile(title: const Text('Contact'), onTap: () => Get.toNamed('/contact')),
            const SizedBox(height: 8),
            PrimaryButton(label: 'Book a Service', expand: true, onTap: () => Get.toNamed('/categories')),
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
          if (v == 'bookings') Get.toNamed('/bookings');
          if (v == 'logout') auth.logout();
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'profile', child: Text('Profile')),
          const PopupMenuItem(value: 'bookings', child: Text('My Bookings')),
          if (auth.isAdmin) const PopupMenuItem(value: 'admin', child: Text('Admin')),
          const PopupMenuItem(value: 'logout', child: Text('Logout')),
        ],
      );
    });
  }
}

class TamannaFooter extends StatelessWidget {
  const TamannaFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConstants.appName, style: AppTextStyles.h3.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(AppConstants.tagline, style: AppTextStyles.body.copyWith(color: const Color(0xFFD9C8BD))),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _link('About', '/about'),
                _link('Contact', '/contact'),
                _link('Privacy', '/privacy'),
                _link('Terms', '/terms'),
                _link('Offers', '/offers'),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              children: [
                TextButton(
                  onPressed: () => launchUrl(Uri.parse('tel:${AppConstants.phone}')),
                  child: const Text('Call', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () => launchUrl(Uri.parse(
                    'https://wa.me/${AppConstants.whatsapp}?text=${Uri.encodeComponent(AppConstants.supportMessage)}',
                  )),
                  child: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('© ${DateTime.now().year} Tamanna Home Beauty Services',
                style: AppTextStyles.caption.copyWith(color: const Color(0xFFB9A89D))),
          ],
        ),
      ),
    );
  }

  Widget _link(String label, String route) =>
      TextButton(onPressed: () => Get.toNamed(route), child: Text(label, style: const TextStyle(color: Colors.white)));
}

class SiteShell extends StatelessWidget {
  final Widget child;
  final bool transparentHeader;
  const SiteShell({super.key, required this.child, this.transparentHeader = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          TamannaHeader(solid: !transparentHeader),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
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
