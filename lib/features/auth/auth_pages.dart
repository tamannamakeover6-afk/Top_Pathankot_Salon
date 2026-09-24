import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/responsive/breakpoints.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_shadows.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/features/auth/auth_controller.dart';
import 'package:tamanna/features/shell/site_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = Get.find<AuthController>();
    final trimmedEmail = email.text.trim();
    final pass = password.text;
    if (trimmedEmail.isEmpty || pass.isEmpty) {
      auth.error.value = 'Please enter both email and password.';
      return;
    }
    final ok = await auth.login(trimmedEmail, pass);
    if (ok) {
      Get.offAllNamed('/');
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: isPassword ? obscurePassword : false,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textHint,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            prefixIcon: Icon(
              prefixIcon,
              size: 20,
              color: AppColors.rose,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: obscurePassword ? AppColors.textHint : AppColors.rose,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => obscurePassword = !obscurePassword);
                    },
                    tooltip: obscurePassword ? 'Show password' : 'Hide password',
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.rose, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final isMobile = Breakpoints.isMobile(context);

    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 32 : 56,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 22 : 36),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.soft,
                ),
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo500.png',
                          height: isMobile ? 38 : 46,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'WELCOME BACK',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign In',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(
                          fontSize: isMobile ? 22 : 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage your appointments, rituals and home beauty requests.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          fontSize: isMobile ? 12.5 : 13.5,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: isMobile ? 22 : 28),

                      // Email input
                      _buildField(
                        controller: email,
                        label: 'Email Address',
                        hint: 'name@example.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Password input with eye icon
                      _buildField(
                        controller: password,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleLogin(),
                      ),

                      // Error message banner
                      if (auth.error.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF2F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF5C6C6)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.danger,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.error.value,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Submit button
                      PrimaryButton(
                        label: auth.loading.value ? 'Signing in...' : 'Sign In',
                        expand: true,
                        onTap: auth.loading.value ? null : _handleLogin,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController name;
  late final TextEditingController phone;
  late final TextEditingController address;

  @override
  void initState() {
    super.initState();
    final user = Get.find<AuthController>().currentUser.value;
    name = TextEditingController(text: user?.name ?? '');
    phone = TextEditingController(text: user?.phone ?? '');
    address = TextEditingController(text: user?.address ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      return SiteShell(
        child: EmptyState(
          title: 'Please log in',
          message: 'Your profile is available after signing in.',
          action: 'Login',
          onAction: () => Get.toNamed('/login'),
        ),
      );
    }
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(auth.currentUser.value?.email ?? '', style: AppTextStyles.body),
                const SizedBox(height: 20),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 12),
                TextField(
                  controller: address,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Default address'),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Save',
                  onTap: () async {
                    final user = auth.currentUser.value!.copyWith(
                      name: name.text,
                      phone: phone.text,
                      address: address.text,
                    );
                    await auth.updateProfile(user);
                    Get.snackbar('Saved', 'Your profile has been updated.');
                  },
                ),
                const SizedBox(height: 12),
                if (auth.isAdmin)
                  SecondaryButton(label: 'Open admin', onTap: () => Get.toNamed('/admin')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
