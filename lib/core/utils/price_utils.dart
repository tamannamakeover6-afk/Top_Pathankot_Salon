class PriceUtils {
  static double toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static double calculateDiscountPercent(double? mrp, double? sellingPrice) {
    if (mrp == null || sellingPrice == null) return 0;
    return discountPercent(mrp, sellingPrice);
  }

  static double discountPercent(double mrp, double sellingPrice) {
    if (mrp <= 0 || sellingPrice >= mrp) return 0;
    return ((mrp - sellingPrice) / mrp) * 100;
  }

  static double applyDiscount({
    required double price,
    required String discountType,
    required double discountValue,
  }) {
    if (discountType == 'fixed') {
      return (price - discountValue).clamp(0, price);
    }
    return (price * (1 - (discountValue / 100))).clamp(0, price);
  }

  static String format(num amount) {
    final value = amount.toDouble();
    if (value == value.roundToDouble()) {
      return '₹${value.toStringAsFixed(0)}';
    }
    return '₹${value.toStringAsFixed(2)}';
  }

  static String percentLabel(double percent) {
    if (percent <= 0) return '';
    return '${percent.round()}% OFF';
  }

  static bool sellingExceedsMrp(double mrp, double selling) =>
      mrp > 0 && selling > mrp;
}
