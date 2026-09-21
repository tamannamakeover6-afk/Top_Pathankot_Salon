import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/utils/error_handler.dart';
import 'package:tamanna/data/models/package_model.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/repositories/booking_repository.dart';
import 'package:tamanna/data/repositories/package_repository.dart';
import 'package:tamanna/data/repositories/service_repository.dart';
import 'package:tamanna/features/auth/auth_controller.dart';

class BookingController extends GetxController {
  final repo = BookingRepository();
  final date = Rxn<DateTime>();
  final time = ''.obs;
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final notes = TextEditingController();
  final loading = false.obs;
  final error = ''.obs;
  final service = Rxn<ServiceModel>();
  final pack = Rxn<PackageModel>();

  @override
  void onInit() {
    super.onInit();
    final user = Get.find<AuthController>().currentUser.value;
    name.text = user?.name ?? '';
    phone.text = user?.phone ?? '';
    address.text = user?.address ?? '';
    _loadItem();
  }

  Future<void> _loadItem() async {
    final serviceSlug = Get.parameters['service'] ?? Get.parameters['serviceSlug'];
    final packageSlug = Get.parameters['package'] ?? Get.parameters['packageSlug'];
    if (serviceSlug != null && serviceSlug.isNotEmpty) {
      service.value = await ServiceRepository().bySlug(serviceSlug);
    } else if (packageSlug != null && packageSlug.isNotEmpty) {
      pack.value = await PackageRepository().bySlug(packageSlug);
    }
  }

  double get mrp => service.value?.mrp ?? pack.value?.mrp ?? 0;
  double get selling => service.value?.sellingPrice ?? pack.value?.sellingPrice ?? 0;
  String get itemName => service.value?.name ?? pack.value?.name ?? 'Service';

  Future<bool> submit() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      Get.toNamed('/login');
      return false;
    }
    if (date.value == null || time.value.isEmpty || name.text.isEmpty || phone.text.isEmpty || address.text.isEmpty) {
      error.value = 'Please complete date, time, name, phone and address.';
      return false;
    }
    loading.value = true;
    error.value = '';
    try {
      final id = await repo.create(
        userId: auth.currentUser.value!.uid,
        serviceId: service.value?.id,
        packageId: pack.value?.id,
        bookingDate: '${date.value!.year}-${date.value!.month.toString().padLeft(2, '0')}-${date.value!.day.toString().padLeft(2, '0')}',
        bookingTime: time.value,
        customerName: name.text.trim(),
        phone: phone.text.trim(),
        address: address.text.trim(),
        notes: notes.text.trim(),
      );
      Get.offNamed('/bookings/$id');
      return true;
    } catch (e) {
      error.value = ErrorHandler.message(e);
      return false;
    } finally {
      loading.value = false;
    }
  }

  List<String> get slots => AppConstants.timeSlots;

  @override
  void onClose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    notes.dispose();
    super.onClose();
  }
}
