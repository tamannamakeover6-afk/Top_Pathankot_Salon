import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamanna/core/constants/app_constants.dart';
import 'package:tamanna/core/utils/price_utils.dart';
import 'package:tamanna/core/utils/slug_utils.dart';
import 'package:tamanna/data/models/category_model.dart';
import 'package:tamanna/data/models/service_model.dart';

class ParlourDataSeeder {
  static final _db = FirebaseFirestore.instance;

  static const List<Map<String, dynamic>> categoryTemplates = [
    {
      'slug': 'threading',
      'name': 'Threading',
      'description': 'Precise threading rituals for clean, shaped brows and smooth facial skin.',
      'imageUrl': 'https://images.unsplash.com/photo-1598256989800-fe5f95da9787?auto=format&fit=crop&w=600&q=80',
      'sortOrder': 1,
    },
    {
      'slug': 'bleach-detan',
      'name': 'Bleach & De-Tan',
      'description': 'Tan removal, radiant skin glow, and relaxing manicure-pedicure rituals.',
      'imageUrl': 'https://images.unsplash.com/photo-1512290900672-1f02e6a0d3bf?auto=format&fit=crop&w=600&q=80',
      'sortOrder': 2,
    },
    {
      'slug': 'waxing',
      'name': 'Waxing',
      'description': 'Hygienic Normal & premium Italian Rica wax for super smooth, hair-free skin.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'sortOrder': 3,
    },
    {
      'slug': 'cleanup',
      'name': 'Cleanup',
      'description': 'Deep pore cleansing, blackhead removal, fruit & gold glow cleanups.',
      'imageUrl': 'https://images.unsplash.com/photo-1519415510236-718bdfcd89c8?auto=format&fit=crop&w=600&q=80',
      'sortOrder': 4,
    },
    {
      'slug': 'facial',
      'name': 'Facial & Glow',
      'description': 'Luxury rejuvenating facials. Every facial includes a complimentary relaxing back massage.',
      'imageUrl': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
      'sortOrder': 5,
    },
    {
      'slug': 'hair',
      'name': 'Hair Care & Styling',
      'description': 'Haircuts, organic spa, root touch-ups, highlights, smoothening & nano plastia.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'sortOrder': 6,
    },
  ];

  static const List<Map<String, dynamic>> rawServices = [
    // ---------------------------------------------
    // 1. Threading
    // ---------------------------------------------
    {
      'id': 'srv_eyebrows',
      'catSlug': 'threading',
      'name': 'Eyebrows Threading',
      'sellingPrice': 30.0,
      'mrp': 50.0,
      'durationMinutes': 10,
      'shortDescription': 'Precise eyebrow shaping with sterilized organic thread.',
      'description': 'Gentle eyebrow threading to give your arches a clean, sharp, and natural definition.',
      'imageUrl': 'https://images.unsplash.com/photo-1598256989800-fe5f95da9787?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Pre-threading powder', 'Precision eyebrow shaping', 'Soothing aloe vera gel massage'],
    },
    {
      'id': 'srv_upperlips',
      'catSlug': 'threading',
      'name': 'Upperlips Threading',
      'sellingPrice': 10.0,
      'mrp': 30.0,
      'durationMinutes': 5,
      'shortDescription': 'Quick upper lip hair removal for clear skin.',
      'description': 'Fast and painless upper lip hair removal leaving skin completely smooth.',
      'imageUrl': 'https://images.unsplash.com/photo-1598256989800-fe5f95da9787?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Sanitizing wipe', 'Upper lip threading', 'Calming moisturizer'],
    },
    {
      'id': 'srv_forehead',
      'catSlug': 'threading',
      'name': 'Forehead Threading',
      'sellingPrice': 10.0,
      'mrp': 30.0,
      'durationMinutes': 5,
      'shortDescription': 'Clean forehead hair removal for a brighter face look.',
      'description': 'Smooths and cleans hair along the forehead hairline for an even tone.',
      'imageUrl': 'https://images.unsplash.com/photo-1598256989800-fe5f95da9787?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Antiseptic cleanse', 'Forehead threading', 'Soothing toner'],
    },

    // ---------------------------------------------
    // 2. Bleach & Detan
    // ---------------------------------------------
    {
      'id': 'srv_bleach_detan',
      'catSlug': 'bleach-detan',
      'name': 'Bleach / De-Tan (Face & Neck)',
      'sellingPrice': 120.0,
      'mrp': 200.0,
      'durationMinutes': 20,
      'shortDescription': 'Instant sun-tan removal and skin brightening treatment.',
      'description': 'Removes deep tan, evens skin tone, and restores natural radiance on the face and neck.',
      'imageUrl': 'https://images.unsplash.com/photo-1512290900672-1f02e6a0d3bf?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Deep cleansing', 'De-tan / bleach application', 'Skin calming pack'],
    },
    {
      'id': 'srv_niconi_detan',
      'catSlug': 'bleach-detan',
      'name': 'Niconi Bleach / De-Tan',
      'sellingPrice': 200.0,
      'mrp': 350.0,
      'durationMinutes': 25,
      'shortDescription': 'Premium gentle Niconi de-tan formula with zero burning.',
      'description': 'Hypoallergenic Niconi bleach and de-tan formulation for sensitive skin brightening.',
      'imageUrl': 'https://images.unsplash.com/photo-1512290900672-1f02e6a0d3bf?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Niconi gentle pre-cleanser', 'Active de-tan layer', 'Cooling mist & pack'],
    },
    {
      'id': 'srv_raaga_o3_detan',
      'catSlug': 'bleach-detan',
      'name': 'Raaga / O3+ Luxury De-Tan',
      'sellingPrice': 350.0,
      'mrp': 550.0,
      'durationMinutes': 30,
      'shortDescription': 'High-performance Kojic acid & milk de-tan by Raaga / O3+.',
      'description': 'Advanced dermatologist-trusted de-tan pack that visibly clarifies blemishes and sun tan in one session.',
      'imageUrl': 'https://images.unsplash.com/photo-1512290900672-1f02e6a0d3bf?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['O3+ / Raaga skin prep', 'Detan creamy massage', 'Anti-pigmentation mask'],
    },
    {
      'id': 'srv_meni_pedi',
      'catSlug': 'bleach-detan',
      'name': 'Meni - Pedi (Manicure & Pedicure Combo)',
      'sellingPrice': 500.0,
      'mrp': 850.0,
      'durationMinutes': 50,
      'shortDescription': 'Complete luxury hand and feet grooming and relaxation ritual.',
      'description': 'Herbal soak, dead skin scrubbing, nail cut & file, cuticle care, and soothing massage for hands and feet.',
      'imageUrl': 'https://images.unsplash.com/photo-1519415510236-718bdfcd89c8?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Warm aroma soak', 'Heel & foot exfoliation', 'Cuticle & nail shaping', 'Relaxing cream massage'],
    },

    // ---------------------------------------------
    // 3. Waxing (Normal & Rica)
    // ---------------------------------------------
    {
      'id': 'srv_norm_wax_hands',
      'catSlug': 'waxing',
      'name': 'Normal Wax - Hands',
      'sellingPrice': 150.0,
      'mrp': 250.0,
      'durationMinutes': 20,
      'shortDescription': 'Full arms hair removal with soothing herbal wax.',
      'description': 'Smooth and clean full hands waxing followed by post-wax cooling gel.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Pre-wax prep', 'Full hands wax', 'Post-wax astringent'],
    },
    {
      'id': 'srv_norm_wax_half_legs',
      'catSlug': 'waxing',
      'name': 'Normal Wax - Half Legs',
      'sellingPrice': 100.0,
      'mrp': 180.0,
      'durationMinutes': 20,
      'shortDescription': 'Quick lower legs waxing for smooth calves and knees.',
      'description': 'Gentle half leg hair removal for clean and refreshed legs.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Half leg waxing', 'Cooling lotion'],
    },
    {
      'id': 'srv_norm_wax_full_legs',
      'catSlug': 'waxing',
      'name': 'Normal Wax - Full Legs',
      'sellingPrice': 200.0,
      'mrp': 350.0,
      'durationMinutes': 30,
      'shortDescription': 'Complete full legs hair removal for silky soft finish.',
      'description': 'Thorough full legs hair removal using single-use disposable strips.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Full legs waxing', 'Sanitizing wipe', 'Aloe cooling massage'],
    },
    {
      'id': 'srv_norm_wax_under_arms',
      'catSlug': 'waxing',
      'name': 'Normal Wax - Under Arms',
      'sellingPrice': 50.0,
      'mrp': 100.0,
      'durationMinutes': 10,
      'shortDescription': 'Hygienic underarms hair removal.',
      'description': 'Quick and hygienic underarms hair removal with soothing post-wax treatment.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Underarms waxing', 'Soothing wipe'],
    },
    {
      'id': 'srv_norm_wax_side_locks',
      'catSlug': 'waxing',
      'name': 'Normal Wax - Side Locks',
      'sellingPrice': 50.0,
      'mrp': 100.0,
      'durationMinutes': 10,
      'shortDescription': 'Facial side locks waxing for a neat profile.',
      'description': 'Cleans facial side locks smoothly for a well-groomed face structure.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Side locks wax', 'Calming gel'],
    },
    {
      'id': 'srv_norm_wax_face',
      'catSlug': 'waxing',
      'name': 'Normal Wax - Face Wax',
      'sellingPrice': 100.0,
      'mrp': 180.0,
      'durationMinutes': 15,
      'shortDescription': 'Full face gentle hair removal for smooth makeup application.',
      'description': 'Removes peach fuzz and facial hair cleanly for instant glow.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Full face wax', 'Ice roller / cooling gel'],
    },

    // Rica Wax (Italian Liposoluble)
    {
      'id': 'srv_rica_wax_hands',
      'catSlug': 'waxing',
      'name': 'Rica Wax - Hands',
      'sellingPrice': 300.0,
      'mrp': 500.0,
      'durationMinutes': 25,
      'shortDescription': 'Italian Rica Liposoluble wax for full arms. 100% colophony-free.',
      'description': 'Pain-free Rica wax enriched with avocado oil to remove tan and root hairs cleanly without irritation.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Rica pre-wax oil', 'Full hands Rica wax', 'Rica post-wax calming lotion'],
    },
    {
      'id': 'srv_rica_wax_half_legs',
      'catSlug': 'waxing',
      'name': 'Rica Wax - Half Legs',
      'sellingPrice': 200.0,
      'mrp': 350.0,
      'durationMinutes': 25,
      'shortDescription': 'Rica wax for lower legs. Prevents ingrown hairs and removes tan.',
      'description': 'Superior liposoluble Rica wax for smooth, glowing calves with minimal redness.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Rica prep lotion', 'Half leg Rica wax', 'Rica after-wax oil'],
    },
    {
      'id': 'srv_rica_wax_full_legs',
      'catSlug': 'waxing',
      'name': 'Rica Wax - Full Legs',
      'sellingPrice': 400.0,
      'mrp': 650.0,
      'durationMinutes': 40,
      'shortDescription': 'Full legs Rica wax for long-lasting silky smoothness.',
      'description': 'Dermatologically safe Italian Rica wax covering full legs for flawless tan-free finish.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Pre-wax cleansing', 'Full legs Rica wax', 'Nourishing after-wax oil'],
    },
    {
      'id': 'srv_rica_wax_under_arms',
      'catSlug': 'waxing',
      'name': 'Rica Wax - Under Arms',
      'sellingPrice': 80.0,
      'mrp': 150.0,
      'durationMinutes': 10,
      'shortDescription': 'Gentle Rica wax for sensitive underarm skin.',
      'description': 'Lightens underarms skin and pulls out shortest hairs painlessly.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Rica prep oil', 'Underarms Rica wax', 'Soothing post-wax mist'],
    },
    {
      'id': 'srv_rica_wax_side_locks',
      'catSlug': 'waxing',
      'name': 'Rica Wax - Side Locks',
      'sellingPrice': 80.0,
      'mrp': 150.0,
      'durationMinutes': 10,
      'shortDescription': 'Sensitive Rica facial wax for side locks.',
      'description': 'Zero skin peeling Rica wax tailored specifically for gentle facial hair removal.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Rica facial prep', 'Side locks Rica wax', 'Calming serum'],
    },
    {
      'id': 'srv_rica_wax_face',
      'catSlug': 'waxing',
      'name': 'Rica Wax - Face Wax',
      'sellingPrice': 150.0,
      'mrp': 250.0,
      'durationMinutes': 15,
      'shortDescription': 'Premium full face Rica wax with natural soothing oils.',
      'description': 'Removes fine facial hair without bumps, leaving your face glowing and silky.',
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Pre-wax barrier oil', 'Full face Rica wax', 'Soothing aloe pack'],
    },

    // ---------------------------------------------
    // 4. Cleanup
    // ---------------------------------------------
    {
      'id': 'srv_fruit_cleanup',
      'catSlug': 'cleanup',
      'name': 'Fruit Cleanup',
      'sellingPrice': 200.0,
      'mrp': 350.0,
      'durationMinutes': 30,
      'shortDescription': 'Fresh mixed fruit extract cleanup for glowing, hydrated skin.',
      'description': 'Deep pore cleansing, gentle fruit scrub, blackhead removal, and refreshing fruit pack.',
      'imageUrl': 'https://images.unsplash.com/photo-1519415510236-718bdfcd89c8?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Cleansing milk', 'Fruit scrub', 'Steam & extraction', 'Hydrating fruit pack'],
    },
    {
      'id': 'srv_whitening_cleanup',
      'catSlug': 'cleanup',
      'name': 'Whitening Cleanup',
      'sellingPrice': 300.0,
      'mrp': 500.0,
      'durationMinutes': 35,
      'shortDescription': 'Instantly brightens dull complexion and targets uneven tone.',
      'description': 'Advanced skin brightening cleanup using active whitening enzymes and botanical extracts.',
      'imageUrl': 'https://images.unsplash.com/photo-1519415510236-718bdfcd89c8?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Deep cleansing', 'Micro-exfoliation', 'Blackhead clearing', 'Whitening face pack'],
    },
    {
      'id': 'srv_vitamin_c_cleanup',
      'catSlug': 'cleanup',
      'name': 'Vitamin C Cleanup',
      'sellingPrice': 350.0,
      'mrp': 550.0,
      'durationMinutes': 35,
      'shortDescription': 'Antioxidant-rich Vitamin C cleanup for radiant, glowing skin.',
      'description': 'Combats pollution and free radical damage, boosting collagen and natural brightness.',
      'imageUrl': 'https://images.unsplash.com/photo-1519415510236-718bdfcd89c8?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Vitamin C cleanser', 'Orange peel scrub', 'Steam', 'Antioxidant glow pack'],
    },
    {
      'id': 'srv_richfeel_lotus_cleanup',
      'catSlug': 'cleanup',
      'name': 'Richfeel / Lotus Cleanup',
      'sellingPrice': 450.0,
      'mrp': 700.0,
      'durationMinutes': 40,
      'shortDescription': 'Herbal luxury cleanup with Richfeel / Lotus botanical science.',
      'description': 'Deeply cleanses congested pores and rejuvenates stressed skin with Lotus natural herbs.',
      'imageUrl': 'https://images.unsplash.com/photo-1519415510236-718bdfcd89c8?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Lotus herbal cleansing', 'Gentle grain scrub', 'Deep pore extraction', 'Lotus calming pack'],
    },
    {
      'id': 'srv_gold_cleanup',
      'catSlug': 'cleanup',
      'name': 'Gold Cleanup',
      'sellingPrice': 450.0,
      'mrp': 700.0,
      'durationMinutes': 40,
      'shortDescription': '24K gold dust cleanup for an instant festive shimmer.',
      'description': 'Formulated with gold bhashma to stimulate microcirculation and provide glowing skin.',
      'imageUrl': 'https://images.unsplash.com/photo-1519415510236-718bdfcd89c8?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Gold cleanser', 'Gold walnut scrub', 'Blackhead clearing', 'Radiant gold pack'],
    },

    // ---------------------------------------------
    // 5. Facial (All include Free Back Massage)
    // ---------------------------------------------
    {
      'id': 'srv_fruit_facial',
      'catSlug': 'facial',
      'name': 'Fruit Facial',
      'sellingPrice': 350.0,
      'mrp': 550.0,
      'durationMinutes': 45,
      'shortDescription': 'Nourishing natural fruit facial + Complimentary Back Massage.',
      'description': 'Infuses skin with fruit antioxidants and moisture. Includes a relaxing 10-minute back massage!',
      'imageUrl': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Fruit cleanser', 'Gentle scrub', 'Face & neck massage (15m)', 'Fruit mask', 'FREE Back Massage'],
    },
    {
      'id': 'srv_whitening_facial',
      'catSlug': 'facial',
      'name': 'Whitening Facial',
      'sellingPrice': 550.0,
      'mrp': 850.0,
      'durationMinutes': 50,
      'shortDescription': 'Skin de-pigmentation & glow facial + Complimentary Back Massage.',
      'description': 'Lightens sun spots and pigmentation patches while you enjoy a soothing back massage.',
      'imageUrl': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Skin lightening cleanser', 'Micro scrub', 'Glow massage cream', 'Brightening peel-off pack', 'FREE Back Massage'],
    },
    {
      'id': 'srv_vitamin_c_facial',
      'catSlug': 'facial',
      'name': 'Vitamin C Facial',
      'sellingPrice': 550.0,
      'mrp': 850.0,
      'durationMinutes': 50,
      'shortDescription': 'High-potency Vitamin C collagen boost + Complimentary Back Massage.',
      'description': 'Restores youthful firmness and radiant glow with Vitamin C serum and relaxing back therapy.',
      'imageUrl': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Vitamin C cleanse', 'Exfoliating polish', 'Collagen massage gel', 'Vitamin C face mask', 'FREE Back Massage'],
    },
    {
      'id': 'srv_diamond_facial',
      'catSlug': 'facial',
      'name': 'Diamond Facial',
      'sellingPrice': 650.0,
      'mrp': 1000.0,
      'durationMinutes': 55,
      'shortDescription': 'Diamond ash microdermabrasion facial + Complimentary Back Massage.',
      'description': 'Polishes dead cells, refines skin texture, and adds glass-skin diamond shine. Back massage included.',
      'imageUrl': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Diamond cleanser', 'Diamond scrub', 'Skin firming massage', 'Diamond sheen pack', 'FREE Back Massage'],
    },
    {
      'id': 'srv_gold_facial',
      'catSlug': 'facial',
      'name': 'Gold Facial',
      'sellingPrice': 650.0,
      'mrp': 1000.0,
      'durationMinutes': 55,
      'shortDescription': 'Opulent 24K gold facial for bridal glow + Complimentary Back Massage.',
      'description': 'Timeless gold facial with natural revitalizers to firm skin and impart a luminous golden sheen.',
      'imageUrl': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Gold cleansing gel', 'Gold dust scrub', '24K gold massage cream', 'Gold peel-off mask', 'FREE Back Massage'],
    },
    {
      'id': 'srv_richfeel_lotus_facial',
      'catSlug': 'facial',
      'name': 'Richfeel / Lotus Facial',
      'sellingPrice': 750.0,
      'mrp': 1200.0,
      'durationMinutes': 60,
      'shortDescription': 'Premium herbal rejuvenation facial + Complimentary Back Massage.',
      'description': 'Holistic botanical therapy combining Lotus natural actives for pure, radiant skin and deep relaxation.',
      'imageUrl': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Botanical cleanser', 'Lotus walnut scrub', 'Deep tissue facial massage', 'Calming herbal pack', 'FREE Back Massage'],
    },
    {
      'id': 'srv_hydra_facial',
      'catSlug': 'facial',
      'name': 'Hydra Facial',
      'sellingPrice': 1000.0,
      'mrp': 1800.0,
      'durationMinutes': 60,
      'shortDescription': 'Intense aqua-infusion hydra facial + Complimentary Back Massage.',
      'description': 'Multi-step hydra therapy to infuse hyaluronic acid, deeply extract debris, and lock in glass skin glow.',
      'imageUrl': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Hydra cleanse', 'Aqua exfoliation', 'Hyaluronic hydration massage', 'Cooling hydro-gel mask', 'FREE Back Massage'],
    },
    {
      'id': 'srv_o3_facial',
      'catSlug': 'facial',
      'name': 'O3+ Luxury Facial',
      'sellingPrice': 1500.0,
      'mrp': 2500.0,
      'durationMinutes': 75,
      'shortDescription': 'Signature dermatological O3+ bridal facial + Complimentary Back Massage.',
      'description': 'Award-winning O3+ whitening & brightening ritual. Treats tanning, dullness and pigmentation with visible results.',
      'imageUrl': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['O3+ multi-active cleanser', 'O3+ micro-peel', 'O3+ cellular tonic & massage', 'O3+ rubberizing brightening mask', 'FREE Back Massage'],
    },

    // ---------------------------------------------
    // 6. Hair Care & Styling
    // ---------------------------------------------
    {
      'id': 'srv_hair_trimming',
      'catSlug': 'hair',
      'name': 'Hair Trimming',
      'sellingPrice': 80.0,
      'mrp': 150.0,
      'durationMinutes': 15,
      'shortDescription': 'Splits ends removal and shape maintenance.',
      'description': 'Clean trimming to maintain length while removing damaged and split ends.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Sectioning', 'Split ends trimming', 'Light hair serum'],
    },
    {
      'id': 'srv_uv_cut',
      'catSlug': 'hair',
      'name': 'U / V Shape Hair Cut',
      'sellingPrice': 120.0,
      'mrp': 200.0,
      'durationMinutes': 20,
      'shortDescription': 'Classic U-cut or V-cut to enhance natural bounce.',
      'description': 'Flattering silhouette haircut tailored to your preferred curve or angle.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Styling consultation', 'U/V precision haircut', 'Quick blow-dry setting'],
    },
    {
      'id': 'srv_layers_step_cut',
      'catSlug': 'hair',
      'name': 'Layers / Step Cut',
      'sellingPrice': 150.0,
      'mrp': 250.0,
      'durationMinutes': 30,
      'shortDescription': 'Volumizing layered or step haircut.',
      'description': 'Adds dimension, feathering, and incredible volume to medium or long hair.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Hair texture analysis', 'Multi-layer haircut', 'Volume blow-dry & blast'],
    },
    {
      'id': 'srv_hair_wash',
      'catSlug': 'hair',
      'name': 'Hair Wash',
      'sellingPrice': 100.0,
      'mrp': 180.0,
      'durationMinutes': 15,
      'shortDescription': 'Invigorating shampoo cleanse and scalp refresh.',
      'description': 'Removes oil, dust and product residue with deep cleansing salon shampoo.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Deep cleansing wash', 'Conditioning rinse', 'Towel dry'],
    },
    {
      'id': 'srv_treatment_hair_wash',
      'catSlug': 'hair',
      'name': 'Treatment Hair Wash',
      'sellingPrice': 150.0,
      'mrp': 250.0,
      'durationMinutes': 25,
      'shortDescription': 'Targeted anti-dandruff or intense keratin repair wash.',
      'description': 'Therapeutic shampoo and mask wash for colored, treated, or dry hair.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Treatment shampoo', 'Deep moisture conditioner mask', 'Scalp pressure point massage'],
    },
    {
      'id': 'srv_hair_spa',
      'catSlug': 'hair',
      'name': "Hair Spa Ritual (L'Oreal / Matrix)",
      'sellingPrice': 500.0,
      'mrp': 900.0,
      'durationMinutes': 45,
      'shortDescription': 'Deep conditioning spa with steam and relaxing head massage.',
      'description': 'Revives frizzy, dull hair with nourishing spa cream, hot towel steam, and scalp acupressure.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Spa wash', 'Nourishing cream massage (20m)', 'Steam & rinse', 'Keratin shine serum'],
    },
    {
      'id': 'srv_normal_root_touch_up',
      'catSlug': 'hair',
      'name': 'Normal Root Touch Up',
      'sellingPrice': 250.0,
      'mrp': 450.0,
      'durationMinutes': 30,
      'shortDescription': 'Quick gray hair coverage on visible roots.',
      'description': 'Seamless root color application for natural blending and 100% gray coverage.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Color consultation', 'Precision root application', 'Color lock rinse'],
    },
    {
      'id': 'srv_streax_root_touch_up',
      'catSlug': 'hair',
      'name': 'Streax Root Touch Up',
      'sellingPrice': 500.0,
      'mrp': 800.0,
      'durationMinutes': 40,
      'shortDescription': 'Streax professional gloss root touch-up with argan oil.',
      'description': 'Long-lasting root color with rich pigments and argan oil softness.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Streax color formulation', 'Root application', 'Post-color conditioning'],
    },
    {
      'id': 'srv_loreal_root_touch_up',
      'catSlug': 'hair',
      'name': "L'Oreal Majirel Root Touch Up",
      'sellingPrice': 800.0,
      'mrp': 1300.0,
      'durationMinutes': 45,
      'shortDescription': "Premium ammonia-safe L'Oreal Majirel root coverage.",
      'description': "World's leading professional root color providing multidimensional shine and zero damage.",
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ["L'Oreal Majirel color", 'Incell & Ionene G treatment', 'Color seal wash'],
    },
    {
      'id': 'srv_global_highlights',
      'catSlug': 'hair',
      'name': 'Global Highlights',
      'sellingPrice': 1000.0,
      'mrp': 1800.0,
      'durationMinutes': 90,
      'shortDescription': 'Trendy streaks and highlights (Caramel, Honey, Chocolate).',
      'description': 'Foil highlights placed throughout hair to create rich contrast and radiant dimension.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Shade selection', 'Foil sectioning & lightening', 'Toning wash', 'Blow-dry style'],
    },
    {
      'id': 'srv_global_colour',
      'catSlug': 'hair',
      'name': 'Global Hair Colour',
      'sellingPrice': 1500.0,
      'mrp': 2500.0,
      'durationMinutes': 90,
      'shortDescription': 'Full head uniform rich hair color application.',
      'description': 'Root to tip luxurious transformation with complete even tone and mirror shine.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Global color application', 'Color-protect mask wash', 'Signature blow-dry finish'],
    },
    {
      'id': 'srv_smoothening',
      'catSlug': 'hair',
      'name': 'Hair Smoothening',
      'sellingPrice': 2000.0,
      'mrp': 3500.0,
      'durationMinutes': 120,
      'shortDescription': 'Silky, straight, and frizz-free manageable hair treatment.',
      'description': 'Deep chemical smoothening with keratin bonds to straighten wavy and curly hair seamlessly.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Keratin prep wash', 'Smoothening cream', 'Precision flat iron seal', 'Neutralizing mask'],
    },
    {
      'id': 'srv_nano_plastia',
      'catSlug': 'hair',
      'name': 'Nano Plastia Hair Treatment',
      'sellingPrice': 3000.0,
      'mrp': 5000.0,
      'durationMinutes': 150,
      'shortDescription': 'Formaldehyde-free revolutionary organic hair straightening.',
      'description': 'Next-gen organic hair reconstruction using amino acids and collagen for extreme gloss and poker-straight hair.',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      'includedItems': ['Clarifying wash', 'Nano plastia bio-infusion', 'Thermal nanotherapy iron', 'Silk protein sealant'],
    },
  ];

  /// Runs the full seed operation into Firestore
  static Future<Map<String, int>> seedAll({Function(String status)? onProgress}) async {
    final catCol = _db.collection(Collections.categories);
    final srvCol = _db.collection(Collections.services);

    onProgress?.call('Fetching existing categories...');
    final existingCatsSnap = await catCol.get();
    final catMap = <String, String>{}; // slug -> docId

    for (final doc in existingCatsSnap.docs) {
      final s = doc.data()['slug']?.toString() ?? '';
      if (s.isNotEmpty) catMap[s] = doc.id;
    }

    // 1. Upsert Categories
    int catsAdded = 0;
    for (final t in categoryTemplates) {
      final slug = t['slug'] as String;
      final docId = catMap[slug] ?? 'cat_$slug';

      onProgress?.call('Updating category: ${t['name']}...');
      await catCol.doc(docId).set({
        'name': t['name'],
        'slug': slug,
        'description': t['description'],
        'imageUrl': t['imageUrl'],
        'sortOrder': t['sortOrder'],
        'active': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      catMap[slug] = docId;
      catsAdded++;
    }

    // 2. Upsert Services
    int srvAdded = 0;
    final categoryCounts = <String, int>{};

    for (final s in rawServices) {
      final catSlug = s['catSlug'] as String;
      final categoryId = catMap[catSlug] ?? 'cat_$catSlug';
      final srvId = s['id'] as String;
      final name = s['name'] as String;
      final mrp = (s['mrp'] as num).toDouble();
      final selling = (s['sellingPrice'] as num).toDouble();
      final discount = PriceUtils.discountPercent(mrp, selling);

      onProgress?.call('Adding service: $name (₹${selling.round()})...');

      await srvCol.doc(srvId).set({
        'name': name,
        'slug': SlugUtils.from(name),
        'nameLower': SlugUtils.searchable(name),
        'searchKeywords': SlugUtils.keywords('$name ${s['shortDescription']}'),
        'categoryId': categoryId,
        'shortDescription': s['shortDescription'],
        'description': s['description'],
        'imageUrl': s['imageUrl'],
        'mrp': mrp,
        'sellingPrice': selling,
        'discountPercent': discount,
        'durationMinutes': s['durationMinutes'],
        'includedItems': s['includedItems'],
        'popular': (s['id'] == 'srv_o3_facial' || s['id'] == 'srv_rica_wax_full_legs' || s['id'] == 'srv_hair_spa'),
        'active': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
      srvAdded++;
    }

    // 3. Update category service counts
    onProgress?.call('Updating category counts...');
    for (final entry in categoryCounts.entries) {
      await catCol.doc(entry.key).update({'serviceCount': entry.value});
    }

    return {
      'categories': catsAdded,
      'services': srvAdded,
    };
  }
}
