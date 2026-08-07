import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_data.dart';

class OpenAIService {
  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// Generates a recommendation based on parameter, sensor data, and questionnaire answers.
  Future<Map<String, String>> generateRecommendation({
    required String affectedParameter,
    required SensorData sensorData,
    required Map<String, String> questionnaireAnswers,
  }) async {
    const prompt = '''
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
      String text = '';
      try {
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer \$_apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-4o-mini',
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'temperature': 0.7,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          text = data['choices'][0]['message']['content'] ?? '{}';
        } else {
          throw Exception('OpenAI API Error: \${response.body}');
        }
      } catch (e) {
        if (affectedParameter.toLowerCase().contains('ph')) {
          text = '''{
            "problem": "pH is outside the optimal range (6.5 - 9.0)",
            "cause": "High pH is often caused by excessive algae photosynthesis. Low pH can result from high organic decomposition or acidic rainfall.",
            "immediate_actions": "• For high pH: Apply agricultural gypsum or alum to buffer the water.\\n• For low pH: Apply agricultural limestone.",
            "preventive_measures": "• Regularly monitor alkalinity.\\n• Avoid overfeeding to prevent excessive organic buildup.\\n• Manage algae blooms.",
            "monitoring_advice": "Check pH twice daily, at dawn (lowest) and late afternoon (highest)."
          }''';
        } else if (affectedParameter.toLowerCase().contains('temperature')) {
          text = '''{
            "problem": "Temperature is outside the safe range",
            "cause": "Extreme weather conditions, shallow pond depth, or lack of shade.",
            "immediate_actions": "• Increase aeration to prevent thermal stratification.\\n• Add fresh, cooler water if available.",
            "preventive_measures": "• Provide artificial shading or plant trees along the bank.\\n• Maintain optimal pond depth (1.5 - 2 meters).",
            "monitoring_advice": "Monitor water temperature daily, especially during extreme weather."
          }''';
        } else if (affectedParameter.toLowerCase().contains('turbidity')) {
          text = '''{
            "problem": "Abnormal turbidity levels detected",
            "cause": "Suspended soil particles from heavy rainfall, overpopulation, or dense phytoplankton blooms.",
            "immediate_actions": "• Apply alum or gypsum to settle suspended clay particles.\\n• Reduce feeding temporarily to minimize organic load.",
            "preventive_measures": "• Plant grass on pond dikes to prevent soil erosion.\\n• Maintain proper stocking density.",
            "monitoring_advice": "Use a Secchi disk weekly to measure water transparency (ideal 30-45 cm)."
          }''';
        } else {
          text = '''{
            "problem": "Detected abnormality in \$affectedParameter",
            "cause": "Possible environmental stress or equipment issue based on sensor data.",
            "immediate_actions": "• Check the equipment.\\n• Adjust \$affectedParameter levels immediately.",
            "preventive_measures": "• Regular maintenance.\\n• Monitor closely.",
            "monitoring_advice": "Observe daily for changes."
          }''';
        }
      }
      
      final cleanedText = text.replaceAll(RegExp(r'^```json\\n?'), '').replaceAll(RegExp(r'\\n?```\$'), '').trim();
      
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
      // Handle error silently
    }
  }
}
