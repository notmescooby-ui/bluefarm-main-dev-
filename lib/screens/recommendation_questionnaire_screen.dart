import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/openai_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recommendation_result_screen.dart';

class RecommendationQuestionnaireScreen extends StatefulWidget {
  final String parameter; // 'pH', 'Temperature', or 'Turbidity'
  final SensorData sensorData;

  const RecommendationQuestionnaireScreen({
    super.key,
    required this.parameter,
    required this.sensorData,
  });

  @override
  State<RecommendationQuestionnaireScreen> createState() => _RecommendationQuestionnaireScreenState();
}

class _RecommendationQuestionnaireScreenState extends State<RecommendationQuestionnaireScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  List<String> get _questions {
    if (widget.parameter == 'pH') {
      return [
        'Have you changed the pond water in the last 24 hours? Please describe the volume and source.',
        'Have you added lime, fertilizers, medicines, or any chemicals recently? Which ones and how much?',
        'Has there been heavy rainfall in the last 48 hours?',
        'Have you noticed unusual fish behaviour (e.g. gasping, swimming slowly, staying at bottom)?',
      ];
    } else if (widget.parameter == 'Temperature') {
      return [
        'Is the pond exposed to direct sunlight for most of the day? Are there any shaded areas?',
        'Has there been a sudden weather change today? (e.g., sudden heatwave or cold front)',
        'Have you recently added fresh water to the pond? If so, what was the temperature difference?',
        'Have you noticed any unusual fish behaviour (e.g., near surface, reduced feeding)?',
      ];
    } else {
      // Turbidity
      return [
        'Has it rained heavily in the last 48 hours causing runoff into the pond?',
        'Have you recently added fish feed? Was there any excess uneaten feed?',
        'Is the pond water visibly muddy, cloudy, or brownish?',
        'Have you noticed excessive algae growth (green water)?',
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    for (final q in _questions) {
      _controllers[q] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate
    bool allFilled = true;
    for (final c in _controllers.values) {
      if (c.text.trim().isEmpty) {
        allFilled = false;
        break;
      }
    }

    if (!allFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions to get the best recommendation.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final answers = <String, String>{};
      for (final entry in _controllers.entries) {
        answers[entry.key] = entry.value.text.trim();
      }

      final ai = OpenAIService();
      final recommendation = await ai.generateRecommendation(
        affectedParameter: widget.parameter,
        sensorData: widget.sensorData,
        questionnaireAnswers: answers,
      );

      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      
      await ai.saveRecommendationHistory(
        uid: uid,
        affectedParameter: widget.parameter,
        sensorData: widget.sensorData,
        questionnaireAnswers: answers,
        recommendation: recommendation,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RecommendationResultScreen(
              recommendation: recommendation,
              parameter: widget.parameter,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating recommendation: \$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F1A2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "\${widget.parameter} Analysis",
          style: const TextStyle(
            color: Color(0xFF0F1A2A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1565C0)),
                  SizedBox(height: 24),
                  Text(
                    "Analyzing pond conditions...",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "DIAGNOSTIC QUESTIONNAIRE",
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your \${widget.parameter} is outside the safe range. Please provide some details so our AI can generate a precise action plan.",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF0F1A2A),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ..._questions.map((q) => _buildQuestionField(q)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Generate Recommendation",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionField(String question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F1A2A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controllers[question],
            maxLines: null,
            minLines: 3,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: "Type your answer here...",
              hintStyle: const TextStyle(color: Colors.black38),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
