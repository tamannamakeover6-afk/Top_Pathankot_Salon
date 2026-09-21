import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamanna/core/theme/app_colors.dart';
import 'package:tamanna/features/request/request_controller.dart';

class RequestTray extends StatelessWidget {
  const RequestTray({super.key});

  @override
  Widget build(BuildContext context) {
    final request = Get.find<RequestController>();
    return Obx(() {
      if (request.items.isEmpty) return const SizedBox.shrink();
      return Material(
        elevation: 12,
        color: AppColors.ink,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.toNamed('/request'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${request.count} selected',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          request.items.map((e) => e.name).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFFE8D5C8), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '₹${request.total.round()}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8590C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Text('Confirm request'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
