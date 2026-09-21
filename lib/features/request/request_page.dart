import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/features/request/booking_form.dart';
import 'package:tamanna/features/request/request_controller.dart';
import 'package:tamanna/features/shell/site_shell.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final request = Get.find<RequestController>();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await request.hydrateFromRoute();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Obx(() {
                      if (request.items.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0E6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.spa_outlined,
                                  size: 32,
                                  color: Color(0xFFE8590C),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text('No Service Selected', style: AppTextStyles.h2),
                              const SizedBox(height: 8),
                              const Text(
                                'Select any beauty service or package to schedule a professional beautician visit at your home.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                label: 'Explore Services',
                                icon: Icons.arrow_forward_rounded,
                                onTap: () => Get.toNamed('/categories'),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const BookingForm(),
                      );
                    }),
            ),
          ),
        ),
      ),
    );
  }
}
