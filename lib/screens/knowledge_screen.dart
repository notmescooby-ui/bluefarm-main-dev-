import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  KNOWLEDGE CENTER SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  int _selectedCategory = 0;

  static const _categories = [
    ('Feeding',   Icons.restaurant_outlined),
    ('Species',   Icons.set_meal_outlined),
    ('Diseases',  Icons.healing_outlined),
    ('Harvest',   Icons.agriculture_outlined),
    ('Breeding',  Icons.favorite_outline),
    ('Weather',   Icons.wb_cloudy_outlined),
  ];

  static final _content = <List<_KCard>>[
    // ── FEEDING ──────────────────────────────────────────────────────────────
    [
      _KCard('Feeding Frequency',
          Icons.access_time_outlined, const Color(0xFF059669),
          'Feed fish 2–3 times daily at fixed times. Morning (7am), noon (12pm), and evening (5pm). Consistent schedules reduce stress and improve FCR.',
          [
            'Use 2–3% of body weight as daily feed quantity',
            'Remove uneaten feed after 30 minutes to prevent water fouling',
            'Reduce feed by 50% during monsoon or cold spells below 20°C',
            'Observe feeding response — healthy fish eat within 10 minutes',
          ]),
      _KCard('Feed Types & Quality',
          Icons.grain_outlined, const Color(0xFF0097A7),
          'Feed quality directly impacts growth rate and water quality. Use pellets with 25–35% crude protein for most carps and catfish.',
          [
            'Floating pellets: easier to monitor consumption',
            'Sinking pellets: preferred for bottom feeders like catfish',
            'Protein requirements: Shrimp (35–40%), Carp (25–30%), Tilapia (28–32%)',
            'Check expiry dates — stale feed reduces nutrition and causes disease',
          ]),
      _KCard('Feed Conversion Ratio (FCR)',
          Icons.trending_up_outlined, const Color(0xFF7C3AED),
          'FCR measures how efficiently fish convert feed into body mass. A lower FCR means better efficiency. Ideal FCR is 1.2–1.8 for carps.',
          [
            'FCR = Total feed given ÷ Weight gained',
            'FCR above 2.5 indicates poor feed quality or overfeeding',
            'Track FCR monthly to detect health or water quality issues early',
            'High turbidity increases FCR as fish use energy to cope with stress',
          ]),
    ],
    // ── SPECIES ───────────────────────────────────────────────────────────────
    [
      _KCard('Rohu (Labeo rohita)',
          Icons.water_outlined, const Color(0xFF1565C0),
          'Most popular freshwater fish in India. Column feeder. Thrives in 25–32°C. Reaches 1–2 kg in 12 months.',
          [
            'Ideal stocking density: 4,000–6,000 fish/hectare',
            'Compatible with Catla and Mrigal in polyculture',
            'Feed: rice bran, mustard cake, groundnut cake',
            'Harvest size: 1–1.5 kg (12–18 months)',
            'Disease risk: EUS (Epizootic Ulcerative Syndrome) in monsoon',
          ]),
      _KCard('Catla (Catla catla)',
          Icons.water_outlined, const Color(0xFF0097A7),
          'Surface feeder. Fast grower reaching 2–3 kg in 12 months. Best stocked at 20–30% of polyculture pond.',
          [
            'Feeds on phytoplankton and zooplankton — enhances water quality',
            'Ideal water temperature: 26–32°C',
            'Avoid overstocking — causes stunted growth',
            'Can be combined with Rohu (40%) and Mrigal (30%)',
          ]),
      _KCard('Tilapia (Nile)',
          Icons.water_outlined, const Color(0xFF059669),
          'Hardy, disease-resistant species. Ideal for beginners. Monosex male culture preferred to prevent uncontrolled breeding.',
          [
            'Optimal temperature: 25–30°C, tolerates 15–40°C',
            'Stocking: 20,000–30,000 fish/hectare in intensive systems',
            'Reaches 400–600g in 6 months under good management',
            'Risk: reproduces rapidly if monosex culture not maintained',
          ]),
      _KCard('Vannamei Shrimp',
          Icons.water_outlined, const Color(0xFFD97706),
          'High-value export crop. Requires brackish water (5–25 ppt salinity). Sensitive to water quality — strict monitoring needed.',
          [
            'DO must stay above 5 mg/L at all times',
            'pH: 7.8–8.3, Temperature: 23–30°C',
            'Harvest at 20g body weight in 90–120 days',
            'Use probiotics to maintain gut health and water quality',
            'Avoid sudden salinity changes — causes stress and mortality',
          ]),
    ],
    // ── DISEASES ──────────────────────────────────────────────────────────────
    [
      _KCard('EUS – Epizootic Ulcerative Syndrome',
          Icons.healing_outlined, const Color(0xFFDC2626),
          'Fungal infection causing red ulcers on body surface. Most common during monsoon when temperature drops suddenly.',
          [
            'Symptoms: red bleeding ulcers, erratic swimming, appetite loss',
            'Cause: Aphanomyces invadans fungus, triggered by low temperature + rain',
            'Prevention: maintain pH 7–8, avoid sudden temperature changes',
            'Treatment: lime treatment (500 kg/ha), potassium permanganate bath',
            'Remove and isolate affected fish immediately',
          ]),
      _KCard('Bacterial Gill Disease',
          Icons.healing_outlined, const Color(0xFFD97706),
          'Caused by Flavobacterium species. Affects gill filaments reducing oxygen uptake. Common in overcrowded ponds.',
          [
            'Symptoms: gasping at surface, pale/swollen gills, lethargy',
            'Risk factors: overcrowding, high ammonia, low DO',
            'Prevention: maintain stocking density, aerate well',
            'Treatment: salt bath (3–5 g/L for 5 minutes), consult veterinarian',
          ]),
      _KCard('Dropsy (Aeromoniasis)',
          Icons.healing_outlined, const Color(0xFF7C3AED),
          'Bacterial infection by Aeromonas hydrophila. Causes fluid accumulation, bloating, scale protrusion.',
          [
            'Symptoms: bloated belly, protruding scales, popped eyes',
            'Trigger: poor water quality, organic overload, stress',
            'Prevention: regular water changes, avoid overfeeding',
            'Treatment: antibiotic under veterinary guidance only',
          ]),
      _KCard('White Spot (Ichthyophthiriasis)',
          Icons.healing_outlined, const Color(0xFF059669),
          'Parasitic infection causing white spots on skin and fins. Highly contagious — can wipe out entire stock.',
          [
            'Symptoms: white salt-like spots on skin, fish rubbing on walls',
            'Treatment: raise temperature to 30°C for 3 days if possible',
            'Salt treatment: 3–5 g/L for affected batches',
            'Quarantine all new fish for 2 weeks before stocking',
          ]),
    ],
    // ── HARVEST ───────────────────────────────────────────────────────────────
    [
      _KCard('When to Harvest',
          Icons.agriculture_outlined, const Color(0xFF059669),
          'Harvest when fish reach target market weight. For most species, this is 10–18 months after stocking.',
          [
            'Rohu/Catla: harvest at 1–1.5 kg (12–15 months)',
            'Tilapia: harvest at 400–600 g (5–6 months)',
            'Shrimp: harvest at 15–20 g (90–120 days)',
            'Monitor weight monthly using seine net sampling',
            'Harvest in morning when temperatures are cool to reduce mortality',
          ]),
      _KCard('Partial Harvest Strategy',
          Icons.agriculture_outlined, const Color(0xFF0097A7),
          'Selectively remove large fish while leaving smaller ones to grow. Maintains stocking density and reduces competition.',
          [
            'Use graded nets to harvest only market-size fish',
            'Partial harvest every 2–3 months improves overall yield',
            'Restock smaller fish after each partial harvest',
            'Reduces feeding cost while maintaining continuous income',
          ]),
      _KCard('Pre-Harvest Preparation',
          Icons.agriculture_outlined, const Color(0xFFD97706),
          'Proper preparation 2–3 days before harvest improves fish quality and price.',
          [
            'Stop feeding 24–48 hours before harvest to empty gut',
            'Test water quality — harvest only if parameters are normal',
            'Arrange transport containers with ice or aeration',
            'Contact buyers 3–5 days in advance to confirm price',
            'Plan harvest in early morning (5–8 AM) for best quality',
          ]),
    ],
    // ── BREEDING ──────────────────────────────────────────────────────────────
    [
      _KCard('Natural Breeding Triggers',
          Icons.favorite_outline, const Color(0xFF1565C0),
          'Most freshwater fish breed during monsoon. Temperature rise, fresh water inflow, and longer daylight trigger spawning.',
          [
            'Rohu/Catla: breed June–August at 27–30°C',
            'Catfish: breed May–July when temperature rises above 26°C',
            'Provide clean fresh water inflow to trigger spawning',
            'Spawning ratio: 1 male : 2–3 females for best results',
          ]),
      _KCard('Induced Breeding (Hormonal)',
          Icons.favorite_outline, const Color(0xFF7C3AED),
          'Hormone injection allows controlled breeding outside natural season. Used in hatcheries for year-round seed production.',
          [
            'Ovaprim (0.5 mL/kg body weight) is most commonly used',
            'Female injected first, male follows 6 hours later',
            'Eggs hatch in 18–24 hours at 28°C',
            'Fry require rotifers and zooplankton as first feed',
          ]),
      _KCard('Broodstock Selection',
          Icons.favorite_outline, const Color(0xFF059669),
          'Quality breeding stock is critical for disease-free, fast-growing offspring.',
          [
            'Select broodstock from disease-free certified hatcheries',
            'Choose fish with good body shape, no deformities',
            'Minimum age: 2 years for females, 1 year for males',
            'Feed broodstock high-protein diet (30–35%) for 3 months before breeding',
          ]),
    ],
    // ── WEATHER ───────────────────────────────────────────────────────────────
    [
      _KCard('Monsoon Management',
          Icons.wb_cloudy_outlined, const Color(0xFF1565C0),
          'Heavy rain dilutes pond water, lowers temperature, and increases turbidity. Disease risk rises significantly.',
          [
            'Check pH daily — heavy rain can drop pH to dangerous levels',
            'Apply lime (50–100 kg/ha) after every heavy rain',
            'Reduce feeding by 50% during prolonged cloudy weather',
            'Watch for EUS disease symptoms — most common in monsoon',
            'Ensure pond bunds are strong to prevent overflow and fish escape',
          ]),
      _KCard('Summer Heat Management',
          Icons.wb_sunny_outlined, const Color(0xFFD97706),
          'High temperatures reduce dissolved oxygen and accelerate ammonia buildup. Critical for fish survival.',
          [
            'Run aerators 24 hours during peak summer (April–June)',
            'Increase water level to maximum depth for thermal buffer',
            'Reduce stocking density if DO consistently falls below 5 mg/L',
            'Feed in early morning only — afternoon feeding spoils quickly',
            'Use shade nets over 30% of pond area to reduce evaporation',
          ]),
      _KCard('Winter Management',
          Icons.ac_unit_outlined, const Color(0xFF0097A7),
          'Fish metabolism slows below 20°C. Overfeeding in winter leads to water fouling and disease.',
          [
            'Reduce feeding to once daily when temperature drops below 22°C',
            'Stop feeding entirely below 15°C for carps',
            'Harvest early if temperatures are expected to drop severely',
            'Maintain water depth above 1.5 m for thermal insulation',
          ]),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // ── Category tabs ──────────────────────────────────────────────────────
      Container(
        height: 50,
        margin: const EdgeInsets.only(top: 4),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: _categories.length,
          itemBuilder: (ctx, i) {
            final (label, icon) = _categories[i];
            final active = i == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppTheme.lightAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active ? AppTheme.lightAccent : AppTheme.lightAccent.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Icon(icon, size: 15,
                      color: active ? Colors.white : AppTheme.lightAccent),
                  const SizedBox(width: 5),
                  Text(label,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: active ? Colors.white : AppTheme.lightAccent)),
                ]),
              ),
            );
          },
        ),
      ),

      // ── Cards ──────────────────────────────────────────────────────────────
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
          itemCount: _content[_selectedCategory].length,
          itemBuilder: (ctx, i) =>
              _KnowledgeCardWidget(card: _content[_selectedCategory][i]),
        ),
      ),
    ]);
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _KCard {
  final String title, body;
  final IconData icon;
  final Color color;
  final List<String> bullets;
  const _KCard(this.title, this.icon, this.color, this.body, this.bullets);
}

// ── Card widget ───────────────────────────────────────────────────────────────
class _KnowledgeCardWidget extends StatefulWidget {
  final _KCard card;
  const _KnowledgeCardWidget({super.key, required this.card});

  @override
  State<_KnowledgeCardWidget> createState() => _KnowledgeCardWidgetState();
}

class _KnowledgeCardWidgetState extends State<_KnowledgeCardWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.cardDecoration(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                    color: c.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(c.icon, color: c.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(c.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
              Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context).textTheme.bodySmall!.color!),
            ]),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.body,
                    style: TextStyle(fontSize: 13, height: 1.5,
                        color: Theme.of(context).textTheme.bodyMedium!.color!)),
                const SizedBox(height: 12),
                ...c.bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 6, height: 6, margin: const EdgeInsets.only(top: 5, right: 10),
                      decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                    ),
                    Expanded(child: Text(b,
                        style: const TextStyle(fontSize: 13, height: 1.4))),
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