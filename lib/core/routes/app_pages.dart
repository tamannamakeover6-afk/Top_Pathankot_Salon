import 'package:get/get.dart';
import 'package:tamanna/core/routes/app_routes.dart';
import 'package:tamanna/features/admin/admin_pages.dart';
import 'package:tamanna/features/admin/admin_shell.dart';
import 'package:tamanna/features/auth/auth_pages.dart';
import 'package:tamanna/features/booking/booking_pages.dart';
import 'package:tamanna/features/categories/categories_page.dart';
import 'package:tamanna/features/home/home_page.dart';
import 'package:tamanna/features/offers/offers_pages.dart';
import 'package:tamanna/features/packages/packages_page.dart';
import 'package:tamanna/features/search/search_page.dart';
import 'package:tamanna/features/services/service_detail_page.dart';
import 'package:tamanna/features/static/static_pages.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(name: AppRoutes.categories, page: () => const CategoriesPage()),
    GetPage(name: AppRoutes.categoryDetail, page: () => const CategoryDetailPage()),
    GetPage(name: AppRoutes.subcategory, page: () => const CategoryDetailPage()),
    GetPage(name: AppRoutes.serviceDetail, page: () => const ServiceDetailPage()),
    GetPage(name: AppRoutes.packages, page: () => const PackagesPage()),
    GetPage(name: AppRoutes.packageDetail, page: () => const PackageDetailPage()),
    GetPage(name: AppRoutes.offers, page: () => const OffersPage()),
    GetPage(name: AppRoutes.search, page: () => const SearchPage()),
    GetPage(name: AppRoutes.reviews, page: () => const ReviewsPage()),
    GetPage(name: AppRoutes.booking, page: () => const BookingPage()),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.signup, page: () => const SignupPage()),
    GetPage(name: AppRoutes.profile, page: () => const ProfilePage()),
    GetPage(name: AppRoutes.myBookings, page: () => const MyBookingsPage()),
    GetPage(name: AppRoutes.bookingDetail, page: () => const BookingDetailPage()),
    GetPage(name: AppRoutes.about, page: () => const AboutPage()),
    GetPage(name: AppRoutes.contact, page: () => const ContactPage()),
    GetPage(name: AppRoutes.privacy, page: () => const PrivacyPage()),
    GetPage(name: AppRoutes.terms, page: () => const TermsPage()),
    GetPage(name: AppRoutes.admin, page: () => const AdminDashboardPage(), middlewares: [AdminGuard()]),
    GetPage(name: AppRoutes.adminCategories, page: () => const AdminCategoriesPage(), middlewares: [AdminGuard()]),
    GetPage(name: AppRoutes.adminSubcategories, page: () => const AdminSubcategoriesPage(), middlewares: [AdminGuard()]),
    GetPage(name: AppRoutes.adminServices, page: () => const AdminServicesPage(), middlewares: [AdminGuard()]),
    GetPage(name: AppRoutes.adminPackages, page: () => const AdminPackagesPage(), middlewares: [AdminGuard()]),
    GetPage(name: AppRoutes.adminPricing, page: () => const AdminPricingPage(), middlewares: [AdminGuard()]),
    GetPage(name: AppRoutes.adminOffers, page: () => const AdminOffersPage(), middlewares: [AdminGuard()]),
    GetPage(name: AppRoutes.adminReviews, page: () => const AdminReviewsPage(), middlewares: [AdminGuard()]),
  ];
}
