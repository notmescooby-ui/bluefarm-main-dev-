import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class AIService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY';

  Future<String> askClaude(String question, SensorData? data) async {
    final context = data != null
        ? 'You are an aquaculture AI for BlueFarm, an IoT fish farm system '
          'in India. Current sensor readings: pH ${data.ph}, '
          'Temperature ${data.temperature}C, Turbidity ${data.turbidity} NTU. '
          'Be concise and practical for an Indian fish farmer.'
        : 'You are an aquaculture AI for BlueFarm fish farm monitoring. '
          'Be concise and practical for an Indian fish farmer.';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1000,
          'messages': [
            {'role': 'user', 'content': '$context\n\nQuestion: $question'}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['content'][0]['text'] as String;
      } else {
        return 'Error ${response.statusCode}. Please try again.';
      }
    } catch (e) {
      return 'Connection error. Please check your internet and try again.';
    }
  }
}
