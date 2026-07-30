import re

with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Fix Banner Title
text = text.replace("title: 'Namaste, \!',", "title: 'Namaste, \!',")
text = text.replace("title: 'Namaste, !',", "title: 'Namaste, \!',")

# 2. Add imports
if 'recommendation_questionnaire_screen.dart' not in text:
    text = text.replace("import '../models/sensor_data.dart';", "import '../models/sensor_data.dart';\nimport 'recommendation_questionnaire_screen.dart';")

# 3. Modify Smart recommendations block and remove Aquabot block
# I will use a robust replacement strategy.
# Let's locate the sliver list delegate items.
# We will just write a new _HomeScreenState build method entirely if it's easier, or just string replace.

# Remove AquaBot status block:
aquabot_start = text.find('// AquaBot status')
aquabot_end = text.find('// Readings', aquabot_start)
if aquabot_start != -1 and aquabot_end != -1:
    text = text[:aquabot_start] + text[aquabot_end:]

# Replace Smart Recommendations block
rec_start = text.find('// Smart recommendations')
rec_end = text.find('// Quick actions', rec_start)

new_rec_block = '''// Smart recommendations
                    if (worst != "good") ...[
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFDC2626)),
                          const SizedBox(width: 8),
                          const Text(
                            "Action Required",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1F3C)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "One or more pond parameters are out of safe range. Analyze the issue now to get an AI-driven smart recommendation plan.",
                              style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  String param = "pH";
                                  if (r.tempStatus == "CRITICAL" || r.tempStatus == "WARNING") param = "Temperature";
                                  else if (r.turbStatus == "CRITICAL" || r.turbStatus == "WARNING") param = "Turbidity";
                                  
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => RecommendationQuestionnaireScreen(
                                    parameter: param,
                                    sensorData: r,
                                  )));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: const Text("Analyze Issue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 20, color: Color(0xFF059669)),
                          const SizedBox(width: 8),
                          const Text(
                            "Smart recommendations",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1F3C)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: const Text(
                          "Pond conditions are healthy. No immediate action required.",
                          style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    '''

if rec_start != -1 and rec_end != -1:
    text = text[:rec_start] + new_rec_block + text[rec_end:]

with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated home_screen.dart')
