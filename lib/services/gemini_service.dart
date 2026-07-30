import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_data.dart';

class GeminiService {
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  /// Generates a recommendation based on parameter, sensor data, and questionnaire answers.
  Future<Map<String, String>> generateRecommendation({
    required String affectedParameter,
    required SensorData sensorData,
    required Map<String, String> questionnaireAnswers,
  }) async {
    final prompt = '''
You are an expert aquaculture AI assistant helping a farmer with their pond. 
The pond's \$affectedParameter is currently outside the safe range.

Here are the current sensor readings:
- Temperature: \${sensorData.temperature} °C
- pH: \${sensorData.ph}
- Turbidity: \${sensorData.turbidity} NTU

The farmer answered a diagnostic questionnaire regarding this issue. 
Here are their answers:
\${questionnaireAnswers.entries.map((e) => 'Q: \${e.key}\\nA: \${e.value}').join('\\n')}

Based on the sensor data and their answers, provide a comprehensive recommendation.
Format your response EXACTLY as a JSON object with the following keys, and nothing else (no markdown wrappers like ```json, just raw JSON text):
{
  "problem": "Short description of the detected problem",
  "cause": "Possible cause based on their answers and sensor data",
  "immediate_actions": "Bullet points (use • character) of immediate actions to take",
  "preventive_measures": "Bullet points of long term preventive measures",
  "monitoring_advice": "Advice on how to monitor the situation"
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      
      // Clean up potential markdown formatting if the model still includes it
      final cleanedText = text.replaceAll(RegExp(r'^```json\n?'), '').replaceAll(RegExp(r'\n?```$'), '').trim();
      
      // Simple parse or fallback
      try {
        final Map<String, dynamic> parsed = jsonDecode(cleanedText);
        return {
          'problem': parsed['problem']?.toString() ?? 'Unknown problem',
          'cause': parsed['cause']?.toString() ?? 'Unable to determine cause',
          'immediate_actions': parsed['immediate_actions']?.toString() ?? '',
          'preventive_measures': parsed['preventive_measures']?.toString() ?? '',
          'monitoring_advice': parsed['monitoring_advice']?.toString() ?? '',
        };
      } catch (e) {
        // Fallback if parsing fails
        return {
          'problem': 'AI Response Parsing Error',
          'cause': 'The AI returned a format that could not be parsed.',
          'immediate_actions': text,
          'preventive_measures': '',
          'monitoring_advice': '',
        };
      }
    } catch (e) {
      return {
        'problem': 'AI Connection Error',
        'cause': 'Unable to reach the recommendation engine. \$e',
        'immediate_actions': 'Please check your internet connection.',
        'preventive_measures': '',
        'monitoring_advice': '',
      };
    }
  }

  /// Saves the interaction to Firestore for future analysis
  Future<void> saveRecommendationHistory({
    required String uid,
    required String affectedParameter,
    required SensorData sensorData,
    required Map<String, String> questionnaireAnswers,
    required Map<String, String> recommendation,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('recommendation_history').add({
        'uid': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'affected_parameter': affectedParameter,
        'sensor_data': {
          'temperature': sensorData.temperature,
          'ph': sensorData.ph,
          'turbidity': sensorData.turbidity,
        },
        'questionnaire': questionnaireAnswers,
        'recommendation': recommendation,
      });
    } catch (e) {
      print('Error saving recommendation history: \$e');
    }
  }
}
