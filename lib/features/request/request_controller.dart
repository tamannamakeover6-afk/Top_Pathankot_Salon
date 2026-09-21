import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/utils/price_utils.dart';
import 'package:tamanna/data/models/package_model.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/repositories/package_repository.dart';
import 'package:tamanna/data/repositories/service_repository.dart';
import 'package:tamanna/features/auth/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestLine {
  final String id;
  final String kind;
  final String name;
  final String slug;
  final String imageUrl;
  final int durationMinutes;
  final double mrp;
  final double sellingPrice;

  final String description;

  const RequestLine({
    required this.id,
    required this.kind,
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.durationMinutes,
    required this.mrp,
    required this.sellingPrice,
    this.description = '',
  });

  factory RequestLine.service(ServiceModel s) => RequestLine(
        id: s.id,
        kind: 'service',
        name: s.name,
        slug: s.slug,
        imageUrl: s.imageUrl,
        durationMinutes: s.durationMinutes,
        mrp: s.mrp,
        sellingPrice: s.sellingPrice,
        description: s.shortDescription.isNotEmpty ? s.shortDescription : s.description,
      );

  factory RequestLine.package(PackageModel p) => RequestLine(
        id: p.id,
        kind: 'package',
        name: p.name,
        slug: p.slug,
        imageUrl: p.imageUrl,
        durationMinutes: p.durationMinutes,
        mrp: p.mrp,
        sellingPrice: p.sellingPrice,
        description: p.description,
      );
}

class RequestController extends GetxController {
  final items = <RequestLine>[].obs;
  final date = Rxn<DateTime>();
  final time = ''.obs;
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final notes = TextEditingController();
  final error = ''.obs;
  final sending = false.obs;
  bool pendingOpenBooking = false;

  final selectedPeriod = 'all'.obs;

  List<String> get slots => AppConstants.timeSlots;

  List<String> get morningSlots => slots.where((s) => s.contains('AM')).toList();
  List<String> get afternoonSlots => slots.where((s) => s.contains('PM') && (s.startsWith('12:') || s.startsWith('01:') || s.startsWith('02:') || s.startsWith('03:'))).toList();
  List<String> get eveningSlots => slots.where((s) => s.contains('PM') && (s.startsWith('04:') || s.startsWith('05:') || s.startsWith('06:') || s.startsWith('07:'))).toList();

  List<String> get filteredSlots {
    switch (selectedPeriod.value) {
      case 'morning':
        return morningSlots;
      case 'afternoon':
        return afternoonSlots;
      case 'evening':
        return eveningSlots;
      default:
        return slots;
    }
  }

  void selectDate(DateTime d) {
    date.value = DateTime(d.year, d.month, d.day);
  }

  List<DateTime> get upcomingDates {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = List.generate(
      14,
      (i) => today.add(Duration(days: i)),
    );
    if (date.value != null) {
      final sel = DateTime(date.value!.year, date.value!.month, date.value!.day);
      if (!dates.any((d) => d.year == sel.year && d.month == sel.month && d.day == sel.day)) {
        dates.insert(0, sel);
      }
    }
    return dates;
  }

  bool isSelected(String id) => items.any((e) => e.id == id);

  int get count => items.length;
  double get total => items.fold(0, (sum, e) => sum + e.sellingPrice);
  double get totalMrp => items.fold(0, (sum, e) => sum + (e.mrp > 0 ? e.mrp : e.sellingPrice));
  double get totalSavings => totalMrp - total;
  int get totalMinutes => items.fold(0, (sum, e) => sum + e.durationMinutes);

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    date.value ??= DateTime(now.year, now.month, now.day);
    if (time.value.isEmpty && slots.isNotEmpty) {
      time.value = slots.length > 1 ? slots[1] : slots.first; // Default 10:00 AM
    }
    final user = Get.find<AuthController>().currentUser.value;
    name.text = user?.name ?? '';
    phone.text = user?.phone ?? '';
    address.text = user?.address ?? '';
    ever(Get.find<AuthController>().currentUser, (user) {
      if (user == null) return;
      if (name.text.isEmpty) name.text = user.name;
      if (phone.text.isEmpty) phone.text = user.phone;
      if (address.text.isEmpty) address.text = user.address;
    });
  }

  void selectService(ServiceModel service) {
    items.assignAll([RequestLine.service(service)]);
  }

  void selectPackage(PackageModel pack) {
    items.assignAll([RequestLine.package(pack)]);
  }

  void remove(String id) => items.removeWhere((e) => e.id == id);

  Future<void> hydrateFromRoute() async {
    final serviceSlug = Get.parameters['service'] ?? '';
    final packageSlug = Get.parameters['package'] ?? '';
    if (serviceSlug.isNotEmpty) {
      final s = await ServiceRepository().bySlug(serviceSlug);
      if (s != null && !isSelected(s.id)) items.add(RequestLine.service(s));
    }
    if (packageSlug.isNotEmpty) {
      final p = await PackageRepository().bySlug(packageSlug);
      if (p != null && !isSelected(p.id)) items.add(RequestLine.package(p));
    }
  }

  String get message {
    final buffer = StringBuffer();
    buffer.writeln('Hello Tamanna, I would like to book a home beauty service.');
    buffer.writeln();
    buffer.writeln('Selected:');
    for (final item in items) {
      buffer.writeln(
        '• ${item.name} (${item.kind}) — ${PriceUtils.format(item.sellingPrice)} · ${item.durationMinutes} min',
      );
    }
    buffer.writeln();
    if (date.value != null) {
      buffer.writeln('Date: ${DateFormat('EEE, d MMM yyyy').format(date.value!)}');
    }
    if (time.value.isNotEmpty) buffer.writeln('Time: ${time.value}');
    if (name.text.trim().isNotEmpty) buffer.writeln('Name: ${name.text.trim()}');
    if (phone.text.trim().isNotEmpty) buffer.writeln('Phone: ${phone.text.trim()}');
    if (address.text.trim().isNotEmpty) buffer.writeln('Address: ${address.text.trim()}');
    if (notes.text.trim().isNotEmpty) buffer.writeln('Notes: ${notes.text.trim()}');
    buffer.writeln();
    buffer.writeln('Total: ${PriceUtils.format(total)}');
    if (totalMinutes > 0) buffer.writeln('Duration: about $totalMinutes minutes');
    return buffer.toString().trim();
  }

  Future<void> sendWhatsApp() async {
    error.value = '';
    if (items.isEmpty) {
      error.value = 'Add at least one service or package.';
      return;
    }
    if (date.value == null || time.value.isEmpty) {
      error.value = 'Please choose a date and time so we can confirm the visit.';
      return;
    }
    if (name.text.trim().isEmpty || phone.text.trim().isEmpty) {
      error.value = 'Please add your name and phone number.';
      return;
    }
    sending.value = true;
    try {
      final uri = Uri.parse(
        'https://wa.me/${AppConstants.whatsapp}?text=${Uri.encodeComponent(message)}',
      );
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) error.value = 'Could not open WhatsApp. Please try again.';
    } catch (_) {
      error.value = 'Could not open WhatsApp. Please try again.';
    } finally {
      sending.value = false;
    }
  }

  @override
  void onClose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    notes.dispose();
    super.onClose();
  }
}
