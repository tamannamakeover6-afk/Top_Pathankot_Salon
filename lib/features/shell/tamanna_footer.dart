import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/routes/app_routes.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:url_launcher/url_launcher.dart';

class TamannaFooter extends StatelessWidget {
  const TamannaFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isTablet = Breakpoints.isTablet(context);

    return Container(
      color: const Color(0xFF140F0D), // Premium deep warm charcoal
      child: Column(
        children: [
          // 1. Trust & Quality Perks Bar
          _TrustPerksBar(isMobile: isMobile),

          // Divider
          Container(height: 1, color: const Color(0xFF241B18)),

          // 2. Main Footer Body (Responsive Grid / Stack)
          ResponsiveContainer(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 36,
              vertical: isMobile ? 36 : 52,
            ),
            child: isMobile
                ? _buildMobileLayout(context)
                : _buildDesktopLayout(context, isTablet),
          ),

          // Divider
          Container(height: 1, color: const Color(0xFF241B18)),

          // 3. Bottom Bar: Copyright & "Made By Pb_IT_HUB"
          _BottomAttributionBar(isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Col 1: Brand & Mission
        Expanded(
          flex: isTablet ? 3 : 4,
          child: _BrandColumn(),
        ),
        const SizedBox(width: 40),

        // Col 2: Services
        Expanded(
          flex: 2,
          child: _ColumnSection(
            title: 'Services',
            links: [
              _LinkData('All Categories', AppRoutes.categories),
              _LinkData('Bridal & Packages', AppRoutes.packages),
              _LinkData('Special Offers', AppRoutes.offers),
              _LinkData('Book Service', AppRoutes.booking),
            ],
          ),
        ),
        const SizedBox(width: 32),

        // Col 3: Company
        Expanded(
          flex: 2,
          child: _ColumnSection(
            title: 'Company',
            links: [
              _LinkData('About Tamanna', AppRoutes.about),
              _LinkData('Contact & Support', AppRoutes.contact),
              _LinkData('Privacy Policy', AppRoutes.privacy),
              _LinkData('Terms of Service', AppRoutes.terms),
            ],
          ),
        ),
        const SizedBox(width: 32),

        // Col 4: Contact & Hours
        Expanded(
          flex: isTablet ? 3 : 3,
          child: _ContactHoursColumn(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BrandColumn(),
        const SizedBox(height: 32),

        // 2-column grid for Services & Company
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ColumnSection(
                title: 'Services',
                links: [
                  _LinkData('Categories', AppRoutes.categories),
                  _LinkData('Packages', AppRoutes.packages),
                  _LinkData('Offers', AppRoutes.offers),
                  _LinkData('Book Now', AppRoutes.booking),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _ColumnSection(
                title: 'Company',
                links: [
                  _LinkData('About Us', AppRoutes.about),
                  _LinkData('Contact', AppRoutes.contact),
                  _LinkData('Privacy', AppRoutes.privacy),
                  _LinkData('Terms', AppRoutes.terms),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Contact & Hours
        _ContactHoursColumn(),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// TRUST PERKS BAR
// -----------------------------------------------------------------------------
class _TrustPerksBar extends StatelessWidget {
  final bool isMobile;
  const _TrustPerksBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final perks = [
      _PerkItem(
        icon: Icons.verified_user_outlined,
        title: '100% Certified Experts',
        subtitle: 'Trained & vetted beauty professionals',
      ),
      _PerkItem(
        icon: Icons.sanitizer_outlined,
        title: 'Hygienic & Single-Use',
        subtitle: 'Sealed disposables & sanitized kits',
      ),
      _PerkItem(
        icon: Icons.home_repair_service_outlined,
        title: 'Salon At Your Doorstep',
        subtitle: 'At-home beauty across Pathankot 145001',
      ),
      _PerkItem(
        icon: Icons.payments_outlined,
        title: 'Pay After Service',
        subtitle: 'No advance fee · 100% satisfaction',
      ),
    ];

    return Container(
      color: const Color(0xFF191311),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 36,
        vertical: isMobile ? 18 : 22,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isMobile
              ? Wrap(
                  runSpacing: 14,
                  spacing: 14,
                  children: perks
                      .map((p) => SizedBox(
                            width: (MediaQuery.sizeOf(context).width - 48) / 2,
                            child: _buildPerkTile(p, compact: true),
                          ))
                      .toList(),
                )
              : Row(
                  children: perks
                      .map((p) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: _buildPerkTile(p, compact: false),
                            ),
                          ))
                      .toList(),
                ),
        ),
      ),
    );
  }

  Widget _buildPerkTile(_PerkItem item, {required bool compact}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: compact ? 34 : 40,
          height: compact ? 34 : 40,
          decoration: BoxDecoration(
            color: const Color(0xFF241B18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF382C27)),
          ),
          child: Icon(item.icon, size: compact ? 17 : 20, color: const Color(0xFFE8590C)),
        ),
        SizedBox(width: compact ? 8 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontSize: compact ? 11.5 : 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: compact ? 10 : 11.5,
                  color: const Color(0xFF9E8E87),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PerkItem {
  final IconData icon;
  final String title;
  final String subtitle;
  const _PerkItem({required this.icon, required this.title, required this.subtitle});
}

// -----------------------------------------------------------------------------
// BRAND COLUMN
// -----------------------------------------------------------------------------
class _BrandColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Name + Tag
        Row(
          children: [
            Text(
              AppConstants.appName,
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF2B1D18),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE8590C).withValues(alpha: 0.5)),
              ),
              child: const Text(
                'HOME SALON',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE8590C),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Premium doorstep beauty & wellness services designed for modern lifestyles. Certified beauty experts, sealed single-use kits, and personalized care in the sanctuary of your home.',
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Color(0xFFB5A49C),
          ),
        ),
        const SizedBox(height: 20),

        // Action Buttons: Call + WhatsApp
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _FooterActionButton(
              icon: Icons.phone_in_talk_rounded,
              label: 'Call Direct',
              color: const Color(0xFF261D1A),
              textColor: Colors.white,
              borderColor: const Color(0xFF3F302A),
              onTap: () => launchUrl(Uri.parse('tel:${AppConstants.phone}')),
            ),
            _FooterActionButton(
              icon: Icons.chat_rounded,
              label: 'WhatsApp Book',
              color: const Color(0xFF25D366),
              textColor: Colors.white,
              onTap: () => launchUrl(Uri.parse(
                'https://wa.me/${AppConstants.whatsapp}?text=${Uri.encodeComponent(AppConstants.supportMessage)}',
              )),
            ),
            _FooterActionButton(
              icon: Icons.camera_alt_outlined,
              label: 'Instagram',
              color: const Color(0xFF261D1A),
              textColor: Colors.white,
              borderColor: const Color(0xFF3F302A),
              onTap: () => launchUrl(
                Uri.parse(AppConstants.instagram),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION COLUMN (LINKS)
// -----------------------------------------------------------------------------
class _ColumnSection extends StatelessWidget {
  final String title;
  final List<_LinkData> links;
  const _ColumnSection({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xFFE8590C),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),
        ...links.map((link) => _HoverFooterLink(label: link.label, route: link.route)),
      ],
    );
  }
}

class _LinkData {
  final String label;
  final String route;
  const _LinkData(this.label, this.route);
}

class _HoverFooterLink extends StatefulWidget {
  final String label;
  final String route;
  const _HoverFooterLink({required this.label, required this.route});

  @override
  State<_HoverFooterLink> createState() => _HoverFooterLinkState();
}

class _HoverFooterLinkState extends State<_HoverFooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Get.toNamed(widget.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: _hovered ? 6 : 0,
                height: 2,
                margin: EdgeInsets.only(right: _hovered ? 6 : 0),
                color: const Color(0xFFE8590C),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 140),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
                  color: _hovered ? Colors.white : const Color(0xFFB5A49C),
                  letterSpacing: 0.1,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CONTACT & HOURS COLUMN
// -----------------------------------------------------------------------------
class _ContactHoursColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOURS & SUPPORT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xFFE8590C),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),

        _contactRow(
          icon: Icons.access_time_rounded,
          title: 'Working Hours',
          value: 'Mon – Sun: 9:00 AM – 8:00 PM',
        ),
        const SizedBox(height: 12),
        _contactRow(
          icon: Icons.phone_android_rounded,
          title: 'Direct Line',
          value: AppConstants.phone,
          onTap: () => launchUrl(Uri.parse('tel:${AppConstants.phone}')),
        ),
        const SizedBox(height: 12),
        _contactRow(
          icon: Icons.mail_outline_rounded,
          title: 'Customer Help',
          value: AppConstants.email,
          onTap: () => launchUrl(Uri.parse('mailto:${AppConstants.email}')),
        ),
        const SizedBox(height: 12),
        _contactRow(
          icon: Icons.location_on_outlined,
          title: 'Service Area',
          value: AppConstants.serviceArea,
        ),
        const SizedBox(height: 12),
        _contactRow(
          icon: Icons.camera_alt_outlined,
          title: 'Instagram',
          value: '@tama.nnabeautysalon',
          onTap: () => launchUrl(
            Uri.parse(AppConstants.instagram),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFF241B18),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: const Color(0xFFE8590C)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8C7C75), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFFDCD0C8), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: row),
      );
    }
    return row;
  }
}

// -----------------------------------------------------------------------------
// FOOTER ACTION BUTTON (CALL / WHATSAPP)
// -----------------------------------------------------------------------------
class _FooterActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _FooterActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  State<_FooterActionButton> createState() => _FooterActionButtonState();
}

class _FooterActionButtonState extends State<_FooterActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withValues(alpha: 0.85) : widget.color,
            borderRadius: BorderRadius.circular(8),
            border: widget.borderColor != null
                ? Border.all(color: _hovered ? const Color(0xFFE8590C) : widget.borderColor!)
                : null,
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 15, color: widget.textColor),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: widget.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BOTTOM ATTRIBUTION BAR (INCLUDING BOLD LINE: "Made By Pb_IT_HUB")
// -----------------------------------------------------------------------------
class _BottomAttributionBar extends StatelessWidget {
  final bool isMobile;
  const _BottomAttributionBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F0B0A),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 36,
        vertical: 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // BOLD LINE PROMINENTLY DISPLAYED AS REQUESTED
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1714),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8590C).withValues(alpha: 0.45)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22E8590C),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFE8590C)),
                    SizedBox(width: 7),
                    Text(
                      'Made By Pb_IT_HUB',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              // Copyright & Quick Legal Links
              if (isMobile) ...[
                Text(
                  '© ${DateTime.now().year} Tamanna Home Beauty Services. All rights reserved.',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF80716A)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legalLink('Privacy Policy', AppRoutes.privacy),
                    const Text('  ·  ', style: TextStyle(color: Color(0xFF5A4C46), fontSize: 11)),
                    _legalLink('Terms', AppRoutes.terms),
                    const Text('  ·  ', style: TextStyle(color: Color(0xFF5A4C46), fontSize: 11)),
                    _legalLink('Support', AppRoutes.contact),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Text(
                      '© ${DateTime.now().year} Tamanna Home Beauty Services. All rights reserved.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8C7C75)),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _legalLink('Privacy Policy', AppRoutes.privacy),
                        const SizedBox(width: 18),
                        _legalLink('Terms of Service', AppRoutes.terms),
                        const SizedBox(width: 18),
                        _legalLink('Contact Support', AppRoutes.contact),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _legalLink(String title, String route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Get.toNamed(route),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF9E8E87),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
