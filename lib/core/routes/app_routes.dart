class AppRoutes {
  static const home = '/';
  static const categories = '/categories';
  static const categoryDetail = '/categories/:categorySlug';
  static const subcategory = '/categories/:categorySlug/:subcategorySlug';
  static const serviceDetail = '/services/:serviceSlug';
  static const packages = '/packages';
  static const packageDetail = '/packages/:packageSlug';
  static const offers = '/offers';
  static const search = '/search';
  static const reviews = '/reviews';
  static const booking = '/booking';
  static const login = '/login';
  static const signup = '/signup';
  static const profile = '/profile';
  static const myBookings = '/bookings';
  static const bookingDetail = '/bookings/:id';
  static const about = '/about';
  static const contact = '/contact';
  static const privacy = '/privacy';
  static const terms = '/terms';
  static const admin = '/admin';
  static const adminCategories = '/admin/categories';
  static const adminCategorySubs = '/admin/category/:categoryId';
  static const adminSubcategoryServices = '/admin/category/:categoryId/sub/:subcategoryId';
  static const adminSubcategories = '/admin/subcategories';
  static const adminServices = '/admin/services';

  static String adminCategory(String categoryId) => '/admin/category/$categoryId';

  static String adminSubcategory(String categoryId, String subcategoryId) =>
      '/admin/category/$categoryId/sub/$subcategoryId';
  static const adminPackages = '/admin/packages';
  static const adminPricing = '/admin/pricing';
  static const adminOffers = '/admin/offers';
  static const adminReviews = '/admin/reviews';
}
