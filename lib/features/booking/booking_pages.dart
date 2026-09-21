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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Container(
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
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0E6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.spa_outlined,
                              color: Color(0xFFE8590C),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Schedule Home Service',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  c.itemName,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          PriceWidget(mrp: c.mrp, sellingPrice: c.selling),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Date selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.calendar_today_outlined, size: 15, color: Color(0xFFE8590C)),
                              SizedBox(width: 6),
                              Text(
                                'Select Date',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.edit_calendar_outlined, size: 14, color: Color(0xFFE8590C)),
                            label: Text(
                              c.date.value == null ? 'Choose Date' : DateFormat('d MMM yyyy').format(c.date.value!),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE8590C)),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 60)),
                                initialDate: c.date.value ?? DateTime.now(),
                              );
                              if (picked != null) c.date.value = picked;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Time slots
                      Row(
                        children: const [
                          Icon(Icons.access_time_rounded, size: 15, color: Color(0xFFE8590C)),
                          SizedBox(width: 6),
                          Text(
                            'Select Time Slot',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: c.slots.map((slot) {
                          final isSelected = c.time.value == slot;
                          return InkWell(
                            onTap: () => c.time.value = slot,
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE8590C) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFE8590C) : const Color(0xFFE6DCD5),
                                  width: 1.1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 13,
                                    color: isSelected ? Colors.white : const Color(0xFF8A7A73),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    slot,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Customer fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: c.name,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Your Full Name',
                                prefixIcon: const Icon(Icons.person_outline_rounded, size: 17, color: Color(0xFF8A7A73)),
                                filled: true,
                                fillColor: Colors.white,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE6DCD5)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: c.phone,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Phone Number',
                                prefixText: '+91 ',
                                prefixIcon: const Icon(Icons.phone_outlined, size: 17, color: Color(0xFF8A7A73)),
                                filled: true,
                                fillColor: Colors.white,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE6DCD5)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: c.address,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Home Address (House / Flat No, Street, Landmark)',
                          prefixIcon: const Icon(Icons.location_on_outlined, size: 17, color: Color(0xFF8A7A73)),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE6DCD5)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: c.notes,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Special Notes / Preferences (Optional)',
                          prefixIcon: const Icon(Icons.edit_note_rounded, size: 17, color: Color(0xFF8A7A73)),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE6DCD5)),
                          ),
                        ),
                      ),

                      if (c.error.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(c.error.value, style: const TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],

                      const SizedBox(height: 18),
                      // Summary box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF7F4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEADBCE)),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Total Payable', style: TextStyle(fontSize: 11, color: Color(0xFF8A7A73))),
                                Text('Pay after service at home', style: TextStyle(fontSize: 10, color: Color(0xFF3E7A5C), fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const Spacer(),
                            PriceWidget(mrp: c.mrp, sellingPrice: c.selling),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: c.loading.value ? 'Confirming Appointment...' : 'Confirm Appointment',
                        expand: true,
                        onTap: c.loading.value ? null : () => c.submit(),
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
