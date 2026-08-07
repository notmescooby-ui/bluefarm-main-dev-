import 'package:flutter/material.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _Article {
  final String title;
  final String body;
  const _Article(this.title, this.body);
}

class _Topic {
  final String id;
  final String label;
  final IconData icon;
  final String blurb;
  final List<_Article> articles;

  const _Topic(this.id, this.label, this.icon, this.blurb, this.articles);
}

const _topics = [
  _Topic(
    "feed",
    "Feeding",
    Icons.restaurant_menu,
    "Schedules, protein needs, feed conversion ratio.",
    [
      _Article("How much to feed each day", "Feed roughly 2–4% of biomass daily, split into two meals. Adjust down in cold water and when fish look full 15 minutes after feeding."),
      _Article("Choosing the right feed", "Fingerlings need 30–35% protein; grow-out fish do well on 25–28%. Prefer floating pellets to check appetite."),
      _Article("Feed conversion ratio (FCR)", "Track weekly. Good FCR for carps is 1.5–1.8. If FCR rises, check water quality first — usually the cause."),
    ]
  ),
  _Topic(
    "species",
    "Species guides",
    Icons.set_meal,
    "Rohu, Catla, Tilapia and more.",
    [
      _Article("Indian major carps", "Rohu, Catla and Mrigal share water beautifully — Catla feeds on the surface, Rohu mid-column, Mrigal on the bottom. Stock 40:30:30."),
      _Article("Tilapia", "Fast-growing and hardy. Watch overpopulation; use monosex fingerlings when possible."),
    ]
  ),
  _Topic(
    "disease",
    "Diseases",
    Icons.favorite_border,
    "White spot, gill disease, dropsy.",
    [
      _Article("White spot disease (Ich)", "Small white grains on skin and fins. Raise temperature slightly and treat with salt bath (2–3 g/L) for 30 minutes over several days."),
      _Article("Bacterial gill disease", "Fish gasp at surface; gills look pale. Reduce stocking pressure, improve aeration, consult a fisheries officer for antibiotics."),
      _Article("Dropsy", "Bloated body and pinecone-like scales. Isolate affected fish; often a sign of poor water — check ammonia."),
    ]
  ),
  _Topic(
    "breed",
    "Breeding",
    Icons.egg_alt_outlined,
    "Induced breeding, hatchery basics.",
    [
      _Article("Induced breeding of carps", "Use HCG or synthetic hormones for brooders during monsoon. Maintain water at 27–29°C for best hatch rate."),
    ]
  ),
  _Topic(
    "weather",
    "Weather & risk",
    Icons.cloud_queue,
    "Disease risk by season.",
    [
      _Article("Monsoon risks", "Sudden rain drops temperature and pH. Watch for gill disease outbreaks in the first week after heavy rain."),
      _Article("Summer heat", "Above 32°C, oxygen falls. Aerate at dawn and reduce feeding by 20%."),
    ]
  ),
  _Topic(
    "harvest",
    "Harvest",
    Icons.eco_outlined,
    "Timing, grading, transport.",
    [
      _Article("When to harvest", "Rohu and Catla reach market size (1–1.2 kg) in 10–12 months. Sample-weigh 20 fish monthly to plan the harvest."),
      _Article("Live transport", "Chill water to 20–22°C before transport, use aerated tanks, and limit density to 100 kg/m³ for short trips."),
    ]
  ),
];

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  String? _openTopicId;

  @override
  Widget build(BuildContext context) {
    if (_openTopicId != null) {
      final topic = _topics.firstWhere((t) => t.id == _openTopicId);
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F5),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20, right: 20, bottom: 10,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F1A2A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topic.blurb.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextButton.icon(
                  onPressed: () => setState(() => _openTopicId = null),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0F1A2A), size: 16),
                  label: const Text(
                    "All topics",
                    style: TextStyle(
                      color: Color(0xFF0F1A2A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final a = topic.articles[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE5E5E0),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F1A2A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            a.body,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: const Color(0xFF0F1A2A).withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: topic.articles.length,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F5),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20, right: 20, bottom: 20,
            ),
            sliver: const SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Knowledge Center",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F1A2A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "EVERYTHING YOU NEED TO FARM WELL",
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search topics, diseases, feeds…",
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final t = _topics[index];
                  return GestureDetector(
                    onTap: () => setState(() => _openTopicId = t.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE5E5E0),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1A2A).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(t.icon, color: const Color(0xFF0F1A2A), size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF0F1A2A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.blurb,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _topics.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
