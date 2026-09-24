import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text('Sign in to book and manage your home services.', style: AppTextStyles.body),
                  const SizedBox(height: 24),
                  TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  if (auth.error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(auth.error.value, style: const TextStyle(color: AppColors.danger)),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: auth.loading.value ? 'Signing in...' : 'Login',
                    expand: true,
                    onTap: auth.loading.value
                        ? null
                        : () async {
                            final ok = await auth.login(email.text, password.text);
                            if (ok) Get.offAllNamed('/');
                          },
                  ),
                ],
              );
            }),
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
