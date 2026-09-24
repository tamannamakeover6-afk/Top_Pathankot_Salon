import 'package:flutter/material.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/features/shell/site_shell.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About Tamanna', style: AppTextStyles.h1),
              const SizedBox(height: 16),
              Text(
                'Tamanna brings professional beauty and wellness rituals to your home in Pathankot (145001). From facials and waxing to hair spa and bridal prep, every service is designed around comfort, transparency and care.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 16),
              Text(
                'We are not a walk-in salon chain. We come to you across Pathankot — with verified professionals, clear pricing and a booking flow that respects your time.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 20),
              Text('Service area: ${AppConstants.serviceArea}', style: AppTextStyles.title),
              const SizedBox(height: 40),
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
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact', style: AppTextStyles.h1),
              const SizedBox(height: 16),
              Text(
                'Call or message us to plan a home appointment in Pathankot (${AppConstants.pincode}).',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 12),
              Text('Service area: ${AppConstants.serviceArea}', style: AppTextStyles.small),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Call ${AppConstants.phone}',
                onTap: () => launchUrl(Uri.parse('tel:${AppConstants.phone}')),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'WhatsApp',
                onTap: () => launchUrl(Uri.parse(
                  'https://wa.me/${AppConstants.whatsapp}?text=${Uri.encodeComponent(AppConstants.supportMessage)}',
                )),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Instagram',
                onTap: () => launchUrl(
                  Uri.parse(AppConstants.instagram),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const SizedBox(height: 40),
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
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy Policy', style: AppTextStyles.h1),
              const SizedBox(height: 16),
              Text(
                'Tamanna collects only the information needed to create your account, complete home-service bookings and improve the experience. We do not sell personal data. Booking details are visible to you and authorized Tamanna administrators.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 40),
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
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terms & Conditions', style: AppTextStyles.h1),
              const SizedBox(height: 16),
              Text(
                'Bookings are service requests. Final confirmation depends on professional availability. Please provide an accurate address and share any allergies. Prices shown at booking are recalculated from live catalog data. Cancelled or completed bookings cannot always be reversed.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
