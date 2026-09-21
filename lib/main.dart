import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tamanna/bindings/initial_binding.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/routes/app_pages.dart';
import 'package:tamanna/core/routes/app_routes.dart';
import 'package:tamanna/core/theme/app_theme.dart';
import 'package:tamanna/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrintStack(stackTrace: stack);
    return true;
  };

  PaintingBinding.instance.imageCache.maximumSize = 400;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 120 << 20;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.hiveUserBox);
  await Hive.openBox(AppConstants.hiveUserListBox);
  await Hive.openBox(AppConstants.hivePrefsBox);

  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(const TamannaApp());
}

class TamannaApp extends StatelessWidget {
  const TamannaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tamanna | Beauty at Home',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      ),
    );
  }
}

class MyApp extends TamannaApp {
  const MyApp({super.key});
}
