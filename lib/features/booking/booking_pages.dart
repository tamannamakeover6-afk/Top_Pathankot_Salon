import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/theme/app_text_styles.dart';
import 'package:tamanna/core/utils/date_parser.dart';
import 'package:tamanna/core/widgets/media_kit.dart';
import 'package:tamanna/core/widgets/ui_kit.dart';
import 'package:tamanna/data/models/booking_model.dart';
import 'package:tamanna/data/repositories/booking_repository.dart';
import 'package:tamanna/features/auth/auth_controller.dart';
import 'package:tamanna/features/booking/booking_controller.dart';
import 'package:tamanna/features/shell/site_shell.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      Future.microtask(() => Get.toNamed('/login'));
    }
    final c = Get.put(BookingController());
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Book at home', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(c.itemName, style: AppTextStyles.body),
                const SizedBox(height: 24),
                PriceWidget(mrp: c.mrp, sellingPrice: c.selling),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(c.date.value == null
                      ? 'Select date'
                      : DateFormat('EEE, d MMM yyyy').format(c.date.value!)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null) c.date.value = picked;
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: c.slots
                      .map(
                        (slot) => ChoiceChip(
                          label: Text(slot),
                          selected: c.time.value == slot,
                          onSelected: (_) => c.time.value = slot,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextField(controller: c.name, decoration: const InputDecoration(labelText: 'Your name')),
                const SizedBox(height: 12),
                TextField(controller: c.phone, decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 12),
                TextField(
                  controller: c.address,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Home address'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c.notes,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes (allergies, parking, etc.)'),
                ),
                if (c.error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(c.error.value, style: const TextStyle(color: AppColors.danger)),
                ],
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Summary', style: AppTextStyles.title),
                      const SizedBox(height: 8),
                      PriceWidget(mrp: c.mrp, sellingPrice: c.selling),
                      Text('Final amount is taken from live catalog pricing.', style: AppTextStyles.small),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: c.loading.value ? 'Confirming...' : 'Confirm request',
                  expand: true,
                  onTap: c.loading.value ? null : () => c.submit(),
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

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      return SiteShell(
        child: EmptyState(
          title: 'Sign in required',
          message: 'Log in to view your bookings.',
          action: 'Login',
          onAction: () => Get.toNamed('/login'),
        ),
      );
    }
    return SiteShell(
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: StreamBuilder(
            stream: BookingRepository().watchMine(auth.currentUser.value!.uid),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator());
              }
              final items = snap.data ?? [];
              if (items.isEmpty) {
                return const EmptyState(title: 'No bookings yet', message: 'When you request a service, it will appear here.');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My bookings', style: AppTextStyles.h1),
                  const SizedBox(height: 20),
                  ...items.map(
                    (b) => ListTile(
                      leading: CloudinaryImage(url: b.itemImage, width: 56, height: 56),
                      title: Text(b.itemName),
                      subtitle: Text('${b.bookingDate} · ${b.bookingTime} · ${BookingStatus.labels[b.status] ?? b.status}'),
                      trailing: Text('₹${b.finalAmount.round()}'),
                      onTap: () => Get.toNamed('/bookings/${b.id}'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id'] ?? '';
    return SiteShell(
      child: ResponsiveContainer(
        child: FutureBuilder(
          future: BookingRepository().byId(id),
          builder: (context, snap) {
            final b = snap.data;
            if (b == null) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Text('Booking not found.'),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking confirmed request', style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  Text(b.itemName, style: AppTextStyles.title),
                  Text('${b.bookingDate} at ${b.bookingTime}'),
                  Text(b.address),
                  const SizedBox(height: 12),
                  Text('Status: ${BookingStatus.labels[b.status] ?? b.status}'),
                  PriceWidget(mrp: b.mrp, sellingPrice: b.finalAmount),
                  Text('Created ${DateParser.prettyDateTime(b.createdAt)}'),
                  const SizedBox(height: 20),
                  if (b.status != BookingStatus.cancelled && b.status != BookingStatus.completed)
                    SecondaryButton(
                      label: 'Cancel request',
                      onTap: () async {
                        final uid = Get.find<AuthController>().currentUser.value?.uid ?? '';
                        await BookingRepository().cancel(id, uid);
                        Get.offNamed('/bookings');
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
