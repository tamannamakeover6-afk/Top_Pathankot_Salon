import 'package:tamanna/core/utils/price_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('discount percent uses shared pricing logic', () {
    expect(PriceUtils.discountPercent(1000, 800), 20);
    expect(PriceUtils.sellingExceedsMrp(1000, 1200), isTrue);
    expect(PriceUtils.applyDiscount(price: 1000, discountType: 'percentage', discountValue: 10), 900);
  });
}
