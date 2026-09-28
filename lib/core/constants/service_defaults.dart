class ServiceDefaults {
  static const Map<String, String> _knownDescriptions = {
    // Bleach services
    'herbalbleach':
        'Gentle herbal bleach enriched with natural botanical extracts. Safely lightens facial hair with zero burning and leaves skin soft, even, and radiant.',
    'dtanbleach':
        'Dual-action de-tan bleach that reverses harsh sun tanning, lightens facial hair, and brings out an instant bright, golden glow.',
    'oxylifebleach':
        'Oxygen-infused bleach that revives dull, tired skin, unclogs pores, and delivers an instant salon-like luminous radiance.',
    'goldbleach':
        'Classic 24K gold bleach that imparts a rich, golden radiance to your face, perfect for weddings, parties, and festive occasions.',
    'diamondbleach':
        'Luxury diamond-dust bleach for bridal glow, deep skin purification, and sparkling long-lasting brightness.',
    'facebleach':
        'Safe and gentle facial bleach to lighten facial hair, eliminate dullness, and give your complexion an immediate healthy glow.',
    'armsbleach':
        'Deep de-tan and lightening bleach for full arms to remove uneven tanning and restore your skin’s natural tone.',
    'legsbleach':
        'Brightening and tan-removal bleach ritual for legs, leaving skin smooth, even-toned, and radiant.',
    'fullbodybleach':
        'Complete full-body bleaching ritual using skin-safe herbal formulations to lighten hair and even out skin complexion from head to toe.',

    // Wax services
    'ricawaxarms':
        'Gentle Italian Rica liposoluble wax for full arms. 100% colophony-free, removes tan and fine hairs painlessly without skin redness.',
    'ricawaxlegs':
        'Superior liposoluble Rica wax for full legs. Leaves calves and thighs silky smooth, prevents ingrown hairs, and eliminates tan.',
    'ricawaxface':
        'Sensitive facial Rica wax tailored specifically for delicate facial skin. Zero skin peeling and painless fine hair removal.',
    'ricawaxunderarms':
        'Pain-free Rica wax enriched with soothing botanical oils. Lightens sensitive underarm skin and pulls out shortest hairs cleanly.',
    'ricawaxsidelocks':
        'Precision side locks waxing with gentle Rica formula for a clean, sculpted, hair-free hairline.',
    'honeywaxarms':
        'Traditional warm natural honey wax for full arms. Leaves skin soft, fresh, and cleanly hair-free.',
    'honeywaxlegs':
        'Warm soothing honey wax for legs. Affordable and effective hair removal leaving skin completely smooth.',

    // Threading
    'eyebrowsthreading':
        'Precision eyebrow shaping with sanitized antibacterial cotton thread followed by soothing aloe vera massage.',
    'upperlipsthreading':
        'Fast and gentle upper lip hair removal for clean, smooth skin around the lips.',
    'foreheadthreading':
        'Clean forehead hairline threading for an even, brighter facial definition.',
    'fullfacethreading':
        'Complete facial threading covering eyebrows, upper lip, chin, and side locks for an ultra-smooth, makeup-ready finish.',

    // Facial & Cleanup
    'o3facial':
        'Premium brightening O3+ professional facial for bridal radiance, deep pigmentation control, and glowing rejuvenation.',
    'fruitfacial':
        'Nourishing natural fruit facial rich in vitamins and antioxidants to revive tired skin and restore natural bounce.',
    'goldfacial':
        'Rejuvenating gold facial that boosts cellular regeneration, firms facial contours, and leaves a luminous festive glow.',
    'cleanup':
        'Deep pore cleansing, blackhead/whitehead extraction, and pore-refining soothing pack for fresh, energized skin.',

    // Hair
    'hairspa':
        'Intensive nourishing salon hair spa with scalp massage, deep-conditioning cream therapy, and steam infusion to tame frizz and restore shine.',
    'roottouchup':
        'Flawless grey coverage and seamless root blending using premium ammonia-free, scalp-safe hair colors.',
    'headmassage':
        'Traditional relaxing warm herbal oil champi to melt away stress, stimulate blood circulation, and nourish hair roots.',

    // Mehndi & Nails
    'bridalmehndi':
        'Exquisite traditional and modern bridal henna patterns made with 100% natural, skin-safe organic henna cones for a deep dark stain.',
    'partymehndi':
        'Intricate designer front-and-back hand mehndi art tailored for parties, Karwa Chauth, and special celebrations.',
    'manicure':
        'Relaxing hand spa ritual including nail shaping, cuticle treatment, gentle scrub, and moisturizing hand massage.',
    'pedicure':
        'Rejuvenating foot spa ritual with warm soak, heel scrubbing, cuticle grooming, and relaxing foot massage.',
  };

  static String _cleanKey(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static String getDescription({required String name, String? categoryId}) {
    final key = _cleanKey(name);
    for (final entry in _knownDescriptions.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }
    return 'Enjoy professional $name in the comfort of your home. Delivered by certified salon experts using sanitized, single-use tools and premium branded products.';
  }

  static String getShortDescription({required String name, String? categoryId}) {
    final key = _cleanKey(name);
    for (final entry in _knownDescriptions.entries) {
      if (key.contains(entry.key) || entry.key.contains(entry.key)) {
        final text = entry.value;
        final firstDot = text.indexOf('.');
        if (firstDot > 15) {
          return text.substring(0, firstDot + 1);
        }
        return text;
      }
    }
    return 'Professional $name service delivered with expert care at your doorstep.';
  }
}
