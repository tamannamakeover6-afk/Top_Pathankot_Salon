import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/core/utils/price_utils.dart';
import 'package:tamanna/features/request/request_controller.dart';

class BookingForm extends StatelessWidget {
  const BookingForm({super.key});

  @override
  Widget build(BuildContext context) {
    final request = Get.find<RequestController>();
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner
          _HeaderBanner(),
          const SizedBox(height: 20),

          // 2. Compact Date Selector
          _CompactDateSection(request: request),
          const SizedBox(height: 20),

          // 3. Compact Time Slot Selector
          _CompactTimeSection(request: request),
          const SizedBox(height: 22),

          // 4. Contact & Address Details
          _CustomerDetailsSection(request: request),
          const SizedBox(height: 20),

          // 5. Professional Appointment Summary
          _AppointmentSummary(request: request),
          const SizedBox(height: 16),

          // Error Message (if any)
          if (request.error.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF8B4B4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFC81E1E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.error.value,
                      style: const TextStyle(
                        color: Color(0xFFC81E1E),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 6. Action Button
          _BookingActionButton(request: request),
        ],
      );
    });
  }
}

class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            children: const [
              Text(
                'Schedule Home Service',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Choose your preferred slot. Professional beautician visits your home.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5EE),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFC4E5CE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.verified_outlined, size: 12, color: Color(0xFF2B7A4B)),
              SizedBox(width: 4),
              Text(
                'Pay After Service',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B7A4B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactDateSection extends StatelessWidget {
  final RequestController request;
  const _CompactDateSection({required this.request});

  Future<void> _pickCustomDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = request.date.value != null && !request.date.value!.isBefore(today)
        ? request.date.value!
        : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE8590C),
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      request.selectDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dates = request.upcomingDates;
      final selectedDate = request.date.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () => _pickCustomDate(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFFD5BE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.calendar_month_outlined, size: 14, color: Color(0xFFE8590C)),
                        SizedBox(width: 4),
                        Text(
                          'More Dates',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE8590C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < dates.length; index++) ...[
                  if (index > 0) const SizedBox(width: 8),
                  _DateChip(
                    date: dates[index],
                    selected: selectedDate != null &&
                        selectedDate.year == dates[index].year &&
                        selectedDate.month == dates[index].month &&
                        selectedDate.day == dates[index].day,
                    dayLabel: index == 0
                        ? 'TODAY'
                        : index == 1
                            ? 'TMRW'
                            : DateFormat('EEE').format(dates[index]).toUpperCase(),
                    onTap: () => request.selectDate(dates[index]),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final String dayLabel;
  final VoidCallback onTap;

  const _DateChip({
    required this.date,
    required this.selected,
    required this.dayLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 58,
          height: 66,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8590C) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? const Color(0xFFE8590C) : const Color(0xFFE6DCD5),
              width: selected ? 1.8 : 1.1,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x40E8590C),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayLabel,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: selected ? Colors.white : const Color(0xFF8A7A73),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Text(
                DateFormat('MMM').format(date),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white70 : const Color(0xFF8A7A73),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactTimeSection extends StatelessWidget {
  final RequestController request;
  const _CompactTimeSection({required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            // Period Filter Pills: All | Morning | Afternoon | Evening
            Obx(() {
              final active = request.selectedPeriod.value;
              return Row(
                children: [
                  _periodTab('All', 'all', active),
                  const SizedBox(width: 4),
                  _periodTab('Morning', 'morning', active),
                  const SizedBox(width: 4),
                  _periodTab('Afternoon', 'afternoon', active),
                  const SizedBox(width: 4),
                  _periodTab('Evening', 'evening', active),
                ],
              );
            }),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final slots = request.filteredSlots;
          if (slots.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No slots available in this period.', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
            );
          }
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slots.map((slot) {
              final isSelected = request.time.value == slot;
              return InkWell(
                onTap: () => request.time.value = slot,
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
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x2EE8590C),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
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
          );
        }),
      ],
    );
  }

  Widget _periodTab(String label, String key, String activeKey) {
    final isSelected = activeKey == key;
    return InkWell(
      onTap: () => request.selectedPeriod.value = key,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C1412) : const Color(0xFFF3ECE6),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6E5E58),
          ),
        ),
      ),
    );
  }
}

class _CustomerDetailsSection extends StatelessWidget {
  final RequestController request;
  const _CustomerDetailsSection({required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.person_pin_circle_outlined, size: 15, color: Color(0xFFE8590C)),
            SizedBox(width: 6),
            Text(
              'Your Contact & Home Address',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 420;
            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      controller: request.name,
                      hint: 'Your Full Name',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInput(
                      controller: request.phone,
                      hint: '10-digit Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      prefixText: '+91 ',
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _buildInput(
                  controller: request.name,
                  hint: 'Your Full Name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 8),
                _buildInput(
                  controller: request.phone,
                  hint: '10-digit Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  prefixText: '+91 ',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        _buildInput(
          controller: request.address,
          hint: 'House / Flat, street, landmark — Pathankot ${AppConstants.pincode}',
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        _buildInput(
          controller: request.notes,
          hint: 'Any preferences, allergies, or notes (optional)',
          icon: Icons.edit_note_rounded,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF9A8A84)),
        prefixIcon: Icon(icon, size: 17, color: const Color(0xFF8A7A73)),
        prefixText: prefixText,
        prefixStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE6DCD5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE6DCD5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8590C), width: 1.4),
        ),
      ),
    );
  }
}

class _AppointmentSummary extends StatelessWidget {
  final RequestController request;
  const _AppointmentSummary({required this.request});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = request.date.value;
      final time = request.time.value;
      final slotSelected = date != null && time.isNotEmpty;

      return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEADBCE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, size: 15, color: Color(0xFFE8590C)),
              const SizedBox(width: 6),
              const Text(
                'Booking Summary',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (request.totalMinutes > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAE4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF6E5E58)),
                      const SizedBox(width: 3),
                      Text(
                        '~${request.totalMinutes} mins',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6E5E58)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Items selected
          if (request.items.isNotEmpty)
            ...request.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8590C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      PriceUtils.format(item.sellingPrice),
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 6),
          // Scheduled Slot Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: slotSelected ? const Color(0xFFFFF3EB) : Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: slotSelected ? const Color(0xFFF9C8A8) : const Color(0xFFEADBCE),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  slotSelected ? Icons.event_available_rounded : Icons.info_outline_rounded,
                  size: 14,
                  color: slotSelected ? const Color(0xFFE8590C) : const Color(0xFF8A7A73),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    slotSelected
                        ? 'Scheduled: ${DateFormat('EEE, d MMM').format(date)} at $time'
                        : 'Choose a date and time slot above to schedule visit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: slotSelected ? FontWeight.w700 : FontWeight.w500,
                      color: slotSelected ? const Color(0xFFC04603) : const Color(0xFF8A7A73),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEADBCE)),
          const SizedBox(height: 10),

          // Total Price Row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Amount', style: TextStyle(fontSize: 11, color: Color(0xFF8A7A73))),
                  const Text(
                    'Payable after service',
                    style: TextStyle(fontSize: 10, color: Color(0xFF3E7A5C), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Spacer(),
              if (request.totalSavings > 0) ...[
                Text(
                  PriceUtils.format(request.totalMrp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9A8A84),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                PriceUtils.format(request.total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    });
  }
}

class _BookingActionButton extends StatelessWidget {
  final RequestController request;
  const _BookingActionButton({required this.request});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = request.sending.value;
      return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: isLoading ? null : request.sendWhatsApp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp brand green
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.chat_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Book on WhatsApp',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFF8A7A73)),
            SizedBox(width: 4),
            Text(
              'No advance payment required · Pay directly after home service',
              style: TextStyle(fontSize: 11, color: Color(0xFF8A7A73)),
            ),
          ],
        ),
      ],
    );
    });
  }
}
