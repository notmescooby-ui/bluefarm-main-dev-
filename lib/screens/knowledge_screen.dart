import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../localization/app_translations.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  int _sel = 0;

  List<(String, IconData)> get _cats => [
        (AppTranslations.get('feeding'),  Icons.restaurant_outlined),
        (AppTranslations.get('species'),  Icons.set_meal_outlined),
        (AppTranslations.get('diseases'), Icons.healing_outlined),
        (AppTranslations.get('harvest'),  Icons.agriculture_outlined),
        (AppTranslations.get('breeding'), Icons.favorite_outline),
        (AppTranslations.get('weather'),  Icons.wb_cloudy_outlined),
      ];

  static final _content = <List<_K>>[
    // ── FEEDING ──────────────────────────────────────────────────────────────
    [
      _K('Feeding Frequency & Schedule', Icons.access_time_outlined,
          const Color(0xFF059669),
          'Feed fish 2–3 times daily at fixed intervals. Consistent timing reduces stress and trains fish to come to feeding spots, dramatically improving FCR and growth rates.',
          [
            'Feed at 7 AM, 12 PM, and 5 PM — morning feeding is the most important',
            'Use 2–3% of total body weight as the daily feed amount',
            'Remove uneaten feed within 30 minutes to prevent ammonia spikes',
            'Observe feeding response — healthy fish eat vigorously within 5–8 minutes',
            'Reduce feeding by 50% during monsoon, cloudy weather, or when temperature drops below 20°C',
            'Stop feeding entirely if DO falls below 3 mg/L — fish will not eat and uneaten feed worsens crisis',
          ]),
      _K('Feed Types, Quality & Protein Needs', Icons.grain_outlined,
          const Color(0xFF0097A7),
          'Feed quality has the single biggest impact on growth rate, water quality, and farm profitability. Use species-appropriate protein levels for maximum efficiency.',
          [
            'Floating pellets: easiest to monitor consumption, ideal for surface feeders like Catla',
            'Sinking pellets: essential for bottom feeders like Magur catfish and Mrigal',
            'Protein requirements by species: Shrimp 35–40%, Tilapia 28–32%, Carp 25–30%, Catfish 30–35%',
            'Use certified feed from reputed manufacturers — cheap feed increases FCR and disease risk',
            'Check manufacturing date — never use feed older than 3 months (fat oxidation reduces nutrition)',
            'Supplement with natural feed: rice bran, groundnut cake, mustard oil cake for carps',
          ]),
      _K('Feed Conversion Ratio (FCR)', Icons.trending_up_outlined,
          const Color(0xFF7C3AED),
          'FCR = kg of feed given ÷ kg of weight gained. A lower FCR means better efficiency and higher profit. Tracking FCR monthly can reveal hidden problems early.',
          [
            'Ideal FCR by species: Carp 1.5–2.0, Tilapia 1.2–1.6, Shrimp 1.4–1.8, Catfish 1.5–2.0',
            'FCR above 2.5 signals overfeeding, poor quality feed, disease, or poor water quality',
            'Weigh a sample of fish monthly (20–30 fish using a dipnet) to calculate weight gain',
            'High turbidity increases FCR — fish expend energy coping with poor water, eat less efficiently',
            'Track FCR in a register — sudden rise is the earliest warning sign of a health problem',
            'Improving FCR by 0.3 points on a 1-tonne harvest saves approximately ₹9,000 in feed costs',
          ]),
      _K('Feeding During Stress Periods', Icons.warning_amber_outlined,
          const Color(0xFFD97706),
          'Fish under stress should receive reduced feeding until conditions stabilize. Overfeeding during stress causes rapid water deterioration.',
          [
            'Reduce to 50% feeding during: monsoon onset, disease outbreaks, temperature swings >3°C/day',
            'Stop feeding 24–48 hours before harvest to empty gut — improves shelf life and market price',
            'Never feed in first 24 hours after stocking new fish — let them settle and acclimatise',
            'After adding lime or chemicals, skip one feeding to avoid interaction with digestive system',
            'In winter below 18°C, feed every other day only — metabolism is too slow for daily feeding',
          ]),
    ],

    // ── SPECIES ──────────────────────────────────────────────────────────────
    [
      _K('Rohu (Labeo rohita)', Icons.water_outlined, const Color(0xFF1565C0),
          'The most commercially important freshwater fish in India. A column feeder that thrives in polyculture systems. Hardy, fast-growing and in high demand in most Indian markets.',
          [
            'Optimal temperature: 25–32°C; tolerates 18–38°C short-term',
            'Ideal stocking density: 4,000–6,000 fish/hectare in polyculture',
            'Combine with Catla (20–30%) and Mrigal (20–30%) for full pond utilization',
            'Natural feed: phytoplankton, zooplankton, decaying plant matter, supplementary feed',
            'Growth: 1–1.5 kg in 12–15 months; premium market size is 1.2 kg+',
            'Disease risk: EUS during monsoon; Dropsy in overcrowded ponds',
            'Harvesting tip: rohu fetch 10–20% higher price in early morning live-fish markets',
          ]),
      _K('Catla (Catla catla)', Icons.water_outlined, const Color(0xFF0097A7),
          'The fastest-growing Indian major carp. A surface feeder that cleans pond surface and feeds on plankton. Essential in polyculture systems — improves water clarity.',
          [
            'Surface feeder — does not compete with Rohu or Mrigal for food',
            'Optimal temperature: 26–32°C; grows fastest in summer months',
            'Stocking: 2,000–3,000 fish/hectare (20–30% of total stocking)',
            'Reaches 2–3 kg in 12 months under good management',
            'Never overstock — stunted growth occurs rapidly in crowded ponds',
            'Feeds on phytoplankton — high Catla density helps control algae bloom',
            'Price premium: live Catla commands 15–25% higher price than dead fish',
          ]),
      _K('Tilapia — Nile & Monosex', Icons.water_outlined,
          const Color(0xFF059669),
          'Hardy, disease-resistant, and profitable. Monosex (all-male) culture is essential to prevent uncontrolled breeding.',
          [
            'Always use monosex (all-male) fingerlings from certified hatcheries to prevent breeding',
            'Optimal temperature: 25–30°C; tolerates 15–40°C — most temperature-resilient species',
            'Intensive culture: 20,000–30,000 fish/hectare with continuous aeration',
            'Feed protein 28–32%; reaches 400–600g in 5–6 months',
            'Disease resistant — rarely affected by EUS or Dropsy; main risk is parasites in dense culture',
            'Market demand: growing rapidly in restaurants, hotels, and frozen export markets',
            'Low FCR of 1.2–1.4 makes Tilapia one of the most cost-efficient species in India',
          ]),
      _K('Pangasius (Basa/Swai)', Icons.water_outlined,
          const Color(0xFF7C3AED),
          'Extremely fast-growing catfish species. Can be farmed at very high densities with continuous aeration.',
          [
            'Can be stocked at 50,000–80,000 fish/hectare in intensive systems with heavy aeration',
            'Grows to 1 kg in just 5–6 months — fastest-growing commercially viable fish in India',
            'Tolerates low DO better than most species but DO should still stay above 3 mg/L',
            'Feed: 28–30% protein pellets; FCR 1.4–1.6 under good management',
            'Mostly processed and sold as boneless fillets; requires processing unit linkage for best price',
            'Water change of 20–30% per week is essential in intensive Pangasius culture',
          ]),
      _K('Vannamei Shrimp', Icons.water_outlined, const Color(0xFFD97706),
          'Highest value aquaculture crop in India. Demands strict water quality management.',
          [
            'Salinity: 5–25 ppt (brackish water essential); not suitable for freshwater ponds',
            'Critical parameters: DO >5 mg/L always, pH 7.8–8.3, Temperature 23–30°C',
            'Stocking: 60–80 PLs/m² in semi-intensive; 100–120 PLs/m² in intensive systems',
            'Harvest at 15–20g body weight in 90–120 days for best price',
            'Use probiotics weekly to maintain beneficial bacteria and prevent Vibrio disease',
            'WSSV (White Spot Syndrome Virus) is the deadliest threat — test seedstock before stocking',
            'Biosecurity is non-negotiable: disinfect all equipment, nets, and entry points',
          ]),
    ],

    // ── DISEASES ─────────────────────────────────────────────────────────────
    [
      _K('EUS — Epizootic Ulcerative Syndrome', Icons.healing_outlined,
          const Color(0xFFDC2626),
          'The most widespread and devastating fish disease in Indian aquaculture. Peaks during monsoon and early winter when temperatures drop suddenly.',
          [
            'Symptoms: red-brown ulcers on body and head, erratic swimming, fish gathering at surface',
            'Trigger: sudden temperature drop of 3–5°C + rain; weakens immune system allowing fungal invasion',
            'Prevention: maintain pH 7.5–8.0 (lime treatment prevents EUS outbreaks)',
            'Treatment: 500 kg/ha agricultural lime applied across pond immediately on first signs',
            'Potassium permanganate bath: 10 mg/L for 30–60 minutes for moderate infections',
            'Remove and destroy severely infected fish — do not sell EUS-infected fish',
            'Report to district fisheries office — EUS is a notifiable disease in India',
          ]),
      _K('Bacterial Gill Disease', Icons.healing_outlined,
          const Color(0xFFD97706),
          'Caused by Flavobacterium columnare. Destroys gill tissue reducing oxygen uptake. Most common in overcrowded ponds with high organic load.',
          [
            'Symptoms: fish gasping at surface, pale or brown-grey gills, reduced appetite, lethargy',
            'Risk factors: stocking density too high, ammonia above 0.1 mg/L, organic overload',
            'Diagnosis: examine gill tissue — healthy gills are bright red; diseased gills look pale/patchy',
            'Prevention: maintain stocking density, regular water changes, proper feeding management',
            'Emergency treatment: salt bath at 3–5 g/L for 5–10 minutes reduces bacterial load',
            'Antibiotic treatment only under licensed veterinary guidance — do not self-medicate',
            'Increase aeration immediately — gill disease fish cannot absorb oxygen efficiently',
          ]),
      _K('Dropsy (Aeromoniasis)', Icons.healing_outlined,
          const Color(0xFF7C3AED),
          'Bacterial infection by Aeromonas hydrophila. Stress and poor water quality weaken immunity allowing bacteria to infect fish.',
          [
            'Symptoms: bloated abdomen (fluid accumulation), protruding scales, bulging eyes (exophthalmia)',
            'Trigger: sudden water quality crash, temperature stress, handling stress, overcrowding',
            'Water quality response: reduce feeding immediately, increase water change to 30% daily',
            'Prevention is the only reliable strategy — this disease has poor treatment success rate',
            'Salt treatment (3 g/L) reduces osmotic stress and can slow progression',
            'Severely affected fish rarely recover — remove and destroy to prevent spread',
            'Autopsy the fish: pus-filled organs confirm Aeromonas; report persistent outbreaks to fisheries',
          ]),
      _K('White Spot Disease (Ich)', Icons.healing_outlined,
          const Color(0xFF059669),
          'Ichthyophthirius multifiliis parasite. Highly contagious — can wipe out entire pond stock within days.',
          [
            'Symptoms: white salt-grain sized spots on fins and body, fish rubbing against walls',
            'Life cycle: parasite detaches from fish to reproduce freely in water — only vulnerable at free-swimming stage',
            'Treatment window: act within first 48–72 hours or losses become severe',
            'Raise water temperature to 30°C for 3 days if possible — speeds up parasite life cycle',
            'Formalin bath: 25 ml/m³ for 1 hour (use with caution, can suffocate fish)',
            'Salt: 3 g/L as long-term bath (7 days) reduces parasite load significantly',
            'CRITICAL: quarantine all new fish for minimum 2 weeks before introducing to main pond',
          ]),
      _K('Nutritional Deficiencies', Icons.healing_outlined,
          const Color(0xFF1565C0),
          'Non-infectious diseases caused by inadequate diet. Often misdiagnosed as infectious disease.',
          [
            'Vitamin C deficiency: scoliosis (spinal deformity), hemorrhaging at fin bases',
            'Vitamin D deficiency: soft bones, poor growth, skeletal abnormalities in fry and fingerlings',
            'Lipid imbalance (rancid feed): liver damage, erratic swimming, high mortality in young fish',
            'Solution: always use fresh, certified feed from reputable manufacturer',
            'Protein deficiency: stunted growth, thin body, pale coloration — increase protein percentage',
            'Diagnosis: improved condition within 1–2 weeks of feed change confirms nutritional cause',
          ]),
    ],

    // ── HARVEST ──────────────────────────────────────────────────────────────
    [
      _K('When & How to Harvest', Icons.agriculture_outlined,
          const Color(0xFF059669),
          'Timing your harvest correctly maximizes profit. The goal is to harvest at market-preferred sizes, during periods of high demand.',
          [
            'Rohu/Catla: harvest at 1–1.5 kg (12–15 months) — smaller fish fetch lower price/kg',
            'Tilapia: harvest at 400–600g (5–6 months); monosex tilapia grow uniformly',
            'Shrimp: harvest at 15–20g in 90–120 days; waiting longer risks disease and weight loss',
            'Pangasius: harvest at 1 kg (5–6 months); processors pay premium for uniform sizes',
            'Always harvest in early morning (5–8 AM) when temperatures are cool — reduces mortality',
            'Stop feeding 24–48 hours before harvest to empty gut',
            'Seine net sampling monthly: weigh 30 fish to estimate average weight and total stock biomass',
          ]),
      _K('Partial Harvest Strategy', Icons.agriculture_outlined,
          const Color(0xFF0097A7),
          'Partial harvesting removes market-ready fish while smaller fish continue growing. Provides regular income rather than one large annual harvest.',
          [
            'Grade nets with 4–6 cm mesh let undersized fish escape while capturing market-size fish',
            'Partial harvest every 2–3 months — provides monthly/quarterly income stream for farmers',
            'After removing large fish, restock with fingerlings to maintain production cycle continuously',
            'Reduces competition for feed and space — remaining fish grow faster after partial harvest',
            'Ideal for polyculture ponds where different species reach market size at different times',
            'Record each partial harvest weight, species, and price received to track seasonal price trends',
          ]),
      _K('Pre-Harvest Preparation', Icons.agriculture_outlined,
          const Color(0xFFD97706),
          'Proper preparation 3–5 days before harvest significantly improves fish quality and enables better pricing.',
          [
            'Contact buyers 5–7 days in advance — advance booking ensures fair price and immediate payment',
            'Test water quality the day before harvest — abnormal parameters increase transport mortality',
            'Stop feeding 24–48 hours before harvest — empty gut fish have longer shelf life',
            'Prepare harvest equipment: seine nets, oxygen tanks/aerators for transport, ice, weighing scale',
            'Check all nets for damage — torn nets during harvest cause fish escape and injury',
            'Harvest in morning, transport before 10 AM to destination to avoid heat buildup in containers',
            'Maintain live fish transport at 15–18°C with aeration — mortality below 2% is achievable',
          ]),
      _K('Posting Harvest Listings on BlueFarm', Icons.storefront_outlined,
          const Color(0xFF1565C0),
          'The Harvest tab lets you post your available fish stock directly to buyers on the platform.',
          [
            'Go to Harvest tab → Add Harvest → Fill in species, quantity, average weight, price per kg',
            'Add notes about quality (e.g., "fresh harvest today", "live fish available", "minimum order 50 kg")',
            'Your listing appears immediately on the Buyer marketplace',
            'Buyers will contact you through the app — negotiate delivery/pickup arrangement directly',
            'Update your listing status to "Sold" once transaction is complete',
            'Post listings 2–3 days before harvest to get advance orders and secure a buyer beforehand',
            'Accurate weight and price information builds buyer trust and repeat business',
          ]),
    ],

    // ── BREEDING ─────────────────────────────────────────────────────────────
    [
      _K('Natural Breeding — Triggers & Conditions', Icons.favorite_outline,
          const Color(0xFF1565C0),
          'Understanding natural breeding cycles helps farmers plan stocking and manage pond populations.',
          [
            'Rohu, Catla, Mrigal: natural breeding triggered by monsoon onset (June–August) at 27–30°C',
            'Trigger factors: rising temperature, fresh water inflow, turbid water, longer daylight',
            'Provide spawning substrate: aquatic vegetation or synthetic fiber spawning mops in breeding ponds',
            'Brood ratio: 1 male : 2–3 females gives best fertilization rate for carp species',
            'Catfish (Magur): breed April–June when temperature exceeds 26°C; build nests in shallow areas',
            'Tilapia: breed year-round in warm weather — avoid in production ponds unless monosex culture',
            'Separate breeding pond from production pond — juvenile fish are vulnerable to predation by adults',
          ]),
      _K('Induced Breeding with Hormones', Icons.favorite_outline,
          const Color(0xFF7C3AED),
          'Hormone-induced breeding allows controlled seed production independent of seasonal cycles.',
          [
            'Ovaprim injection: 0.5 mL/kg body weight for females; 0.2 mL/kg for males',
            'Inject female first; male is injected 6 hours later when female shows spawning readiness',
            'Eggs are fertilized in a dry container — add milt (sperm) and mix gently with a feather',
            'Transfer fertilized eggs to hatching troughs with clean aerated water at 28°C',
            'Eggs hatch in 18–24 hours at 28°C; 12–14 hours at 30°C; slower at lower temperatures',
            'Newly hatched larvae (sac fry) live off yolk sac for 48–72 hours — no external feeding needed',
            'After yolk absorption: feed rotifers, Artemia nauplii, or commercial micro-pellets (200–400 micron)',
          ]),
      _K('Broodstock Selection & Nutrition', Icons.favorite_outline,
          const Color(0xFF059669),
          'High-quality broodstock is the foundation of profitable hatchery operations.',
          [
            'Select broodstock from certified disease-free hatcheries with documented breeding records',
            'Physical criteria: uniform body shape, no deformities, bright eyes, intact fins, active behavior',
            'Minimum age: females 2–3 years, males 1–2 years for Indian major carps',
            'Pre-spawning conditioning: feed high-protein diet (30–35%) for 2–3 months before breeding season',
            'Vitamin E supplementation: 200 mg/kg feed improves egg quality and fertilization rate',
            'Maintain broodstock separate from production fish — avoid stress from handling or seining',
            'Replace broodstock every 3–4 years to maintain genetic diversity and breeding performance',
          ]),
    ],

    // ── WEATHER ──────────────────────────────────────────────────────────────
    [
      _K('Monsoon Management (June–September)', Icons.wb_cloudy_outlined,
          const Color(0xFF1565C0),
          'Monsoon is the highest-risk period for fish diseases and pond management problems.',
          [
            'Check pH daily during monsoon — heavy rain can drop pH to 5.5–6.0 within hours',
            'Apply agricultural lime (100–150 kg/ha) after every significant rainfall to maintain pH 7.5+',
            'Reduce feeding by 50% during heavy rain or prolonged cloudy weather — fish metabolism slows',
            'Inspect pond bunds daily — soft soil + heavy rain can cause bund collapse and fish escape',
            'Monitor for EUS symptoms (ulcers) weekly — onset is rapid in monsoon conditions',
            'Avoid stocking new fish during active monsoon — fingerlings are most vulnerable',
            'Drain excess water through screened outlet to maintain optimal water level',
          ]),
      _K('Summer Heat Management (March–June)', Icons.wb_sunny_outlined,
          const Color(0xFFD97706),
          'High summer temperatures reduce dissolved oxygen, accelerate ammonia production, and stress fish.',
          [
            'Run aerators 24 hours/day during April–June when temperatures regularly exceed 32°C',
            'Maintain maximum water depth — deep water provides thermal buffer (keep above 1.5 m)',
            'Feed only in early morning (6–8 AM) before temperature peaks — afternoon feed spoils quickly',
            'Reduce stocking density if DO consistently falls below 4 mg/L despite aeration',
            'Use shade nets over 20–30% of pond area to reduce direct solar heating',
            'Increase water exchange rate during heat waves — bring in cooler groundwater if available',
            'Stock summer-tolerant species like Tilapia or Pangasius if experiencing recurrent summer kills',
          ]),
      _K('Winter Management (November–February)', Icons.ac_unit_outlined,
          const Color(0xFF0097A7),
          'Fish are cold-blooded — metabolism, appetite, and immune function all slow in cold water.',
          [
            'Reduce feeding to once daily when water temperature drops below 22°C',
            'Stop feeding entirely when temperature falls below 15°C for carps — they enter torpor state',
            'Catfish (Magur, Singhi) can be fed lightly even at 12°C — they are more cold-tolerant than carps',
            'Maintain water depth above 1.5–2 m to insulate fish from surface cold',
            'Winter is ideal harvest time in many regions — fish have high fat content and excellent texture',
            'Avoid handling or seining fish in very cold water — cold-stressed fish have high mortality',
            'Check for Saprolegnia (white cotton fungus) growth in winter — common in stressed cold fish',
          ]),
      _K('Weather & Disease Risk Calendar', Icons.calendar_month_outlined,
          const Color(0xFFDC2626),
          'Different seasons bring different disease risks. Knowing what to watch for each month helps farmers take preventive action.',
          [
            'January–February: Saprolegnia fungus, slow growth — watch for white cotton patches on fish body',
            'March–April: temperature rise — watch for Aeromoniasis (Dropsy) in stressed fish',
            'May–June: peak heat — dissolved oxygen drops, gill disease and ammonia toxicity most likely',
            'July–August: EUS season peak — apply lime preventively, inspect fish weekly for ulcers',
            'September–October: post-monsoon recovery — good growth period, restock if needed',
            'November–December: water cooling — reduce feed, prepare for possible Saprolegnia outbreaks',
            'Year-round: maintain feeding records, water quality logs, and fish health observations',
          ]),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final cats = _cats;
    return Column(children: [
  const SizedBox(height: 16), // 👈 ADD THIS LINE (controls gap)
      // ── Category tabs — top alignment fixed with consistent padding ────────
      Container(
  height: 50,
  margin: const EdgeInsets.only(top: 16), // 👈 main fix
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: cats.length,
          itemBuilder: (_, i) {
            final (label, icon) = cats[i];
            final active = i == _sel;
            return GestureDetector(
              onTap: () => setState(() => _sel = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.lightAccent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active
                          ? AppTheme.lightAccent
                          : AppTheme.lightAccent.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Icon(icon,
                      size: 15,
                      color: active
                          ? Colors.white
                          : AppTheme.lightAccent),
                  const SizedBox(width: 5),
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? Colors.white
                              : AppTheme.lightAccent)),
                ]),
              ),
            );
          },
        ),
      ),

      // ── Content list ──────────────────────────────────────────────────────
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
          itemCount: _content[_sel].length,
          itemBuilder: (_, i) =>
              _CardWidget(card: _content[_sel][i]),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _K {
  final String title, body;
  final IconData icon;
  final Color color;
  final List<String> bullets;
  const _K(this.title, this.icon, this.color, this.body, this.bullets);
}

class _CardWidget extends StatefulWidget {
  final _K card;
  const _CardWidget({super.key, required this.card});

  @override
  State<_CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<_CardWidget> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.cardDecoration(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: c.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(c.icon, color: c.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(c.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14))),
              Icon(
                  _open
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context).textTheme.bodySmall!.color!),
            ]),
          ),
          if (_open) ...[
            Divider(
                height: 1,
                color: Theme.of(context).dividerColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(c.body,
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .color!)),
                const SizedBox(height: 12),
                ...c.bullets.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                        Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(
                                top: 5, right: 10),
                            decoration: BoxDecoration(
                                color: c.color,
                                shape: BoxShape.circle)),
                        Expanded(
                            child: Text(b,
                                style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.45))),
                      ]),
                    )),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}