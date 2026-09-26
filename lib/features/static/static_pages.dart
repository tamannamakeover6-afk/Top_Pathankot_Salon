import 'package:flutter/material.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/features/shell/site_shell.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Tamanna',
                style: isMobile
                    ? AppTextStyles.h2.copyWith(fontSize: 22)
                    : AppTextStyles.h1,
              ),
              const SizedBox(height: 12),
              Text(
                'Tamanna brings professional beauty and wellness rituals to your home across Pathankot, Sujanpur and nearby areas (145001). From facials and waxing to hair spa, party makeup and bridal prep — every service is designed around comfort, transparency and care.',
                style: isMobile ? AppTextStyles.body.copyWith(fontSize: 13.5) : AppTextStyles.body,
              ),
              const SizedBox(height: 12),
              Text(
                'We are not a walk-in salon chain. We come to you — doorstep salon for ladies, bridal makeup artist home service, and grooming packages without leaving home.',
                style: isMobile ? AppTextStyles.body.copyWith(fontSize: 13.5) : AppTextStyles.body,
              ),
              const SizedBox(height: 16),
              Text('Service area: ${AppConstants.serviceArea}', style: AppTextStyles.title.copyWith(fontSize: isMobile ? 14 : 18)),
              const SizedBox(height: 8),
              Text(
                'Popular bookings: home service parlour near Sujanpur Pathankot · bridal / party makeup at home · facial, waxing & hair spa doorstep packages.',
                style: TextStyle(fontSize: isMobile ? 12.5 : 14, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 28),
              // Digital Partner Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C1C1412),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/pb_it_hub_logo.jpg',
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Digital Partner & Development',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppConstants.developerName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Website engineered and crafted by PB_IT_hub. Driving modern digital beauty and service experiences across Punjab.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => launchUrl(
                                Uri.parse(AppConstants.developerInstagram),
                                mode: LaunchMode.externalApplication,
                              ),
                              icon: const Icon(Icons.open_in_new, size: 14),
                              label: const Text('Visit PB_IT_hub on Instagram'),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/pb_it_hub_logo.jpg',
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DIGITAL PARTNER & DEVELOPMENT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: AppColors.gold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  AppConstants.developerName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Website engineered and crafted by PB_IT_hub. Powering local commerce & digital discovery across Punjab.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            onPressed: () => launchUrl(
                              Uri.parse(AppConstants.developerInstagram),
                              mode: LaunchMode.externalApplication,
                            ),
                            icon: const Icon(Icons.open_in_new, size: 15),
                            label: const Text('Connect with PB_IT_hub'),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: isMobile ? 24 : 40),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});
  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact',
                style: isMobile
                    ? AppTextStyles.h2.copyWith(fontSize: 22)
                    : AppTextStyles.h1,
              ),
              const SizedBox(height: 12),
              Text(
                'Call or WhatsApp to book a home appointment in Pathankot, Sujanpur or nearby (${AppConstants.pincode}).',
                style: isMobile ? AppTextStyles.body.copyWith(fontSize: 13.5) : AppTextStyles.body,
              ),
              const SizedBox(height: 8),
              Text('Service area: ${AppConstants.serviceArea}', style: AppTextStyles.small),
              const SizedBox(height: 6),
              Text(
                'Bridal makeup · party makeup · facial · waxing · hair spa — at your doorstep.',
                style: TextStyle(fontSize: isMobile ? 12 : 13, color: AppColors.textSecondary),
              ),
              SizedBox(height: isMobile ? 16 : 20),
              PrimaryButton(
                label: 'Call ${AppConstants.phone}',
                onTap: () => launchUrl(Uri.parse('tel:${AppConstants.phone}')),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'WhatsApp',
                onTap: () => launchUrl(Uri.parse(
                  'https://wa.me/${AppConstants.whatsapp}?text=${Uri.encodeComponent(AppConstants.supportMessage)}',
                )),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Instagram',
                onTap: () => launchUrl(
                  Uri.parse(AppConstants.instagram),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              SizedBox(height: isMobile ? 24 : 40),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: isMobile
                    ? AppTextStyles.h2.copyWith(fontSize: 22)
                    : AppTextStyles.h1,
              ),
              const SizedBox(height: 12),
              Text(
                'Tamanna collects only the information needed to create your account, complete home-service bookings and improve the experience. We do not sell personal data. Booking details are visible to you and authorized Tamanna administrators.',
                style: isMobile ? AppTextStyles.body.copyWith(fontSize: 13.5) : AppTextStyles.body,
              ),
              SizedBox(height: isMobile ? 24 : 40),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms & Conditions',
                style: isMobile
                    ? AppTextStyles.h2.copyWith(fontSize: 22)
                    : AppTextStyles.h1,
              ),
              const SizedBox(height: 12),
              Text(
                'Bookings are service requests. Final confirmation depends on professional availability. Please provide an accurate address and share any allergies. Prices shown at booking are recalculated from live catalog data. Cancelled or completed bookings cannot always be reversed.',
                style: isMobile ? AppTextStyles.body.copyWith(fontSize: 13.5) : AppTextStyles.body,
              ),
              SizedBox(height: isMobile ? 24 : 40),
            ],
          ),
        ),
      ),
    );
  }
}
