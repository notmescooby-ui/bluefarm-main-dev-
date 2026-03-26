import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class AIService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiKey =
      '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';

  Future<String> askClaude(String question, SensorData? data) async {
    final contextText = data != null
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
          'model': 'claude-haiku-4-5-20251001',
          'max_tokens': 512,
          'messages': [
            {
              'role': 'user',
              'content': '$contextText\n\nQuestion: $question',
            },
          ],
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final content = body['content'] as List<dynamic>;
        return (content.first as Map<String, dynamic>)['text'] as String? ??
            'No response received.';
      } else if (response.statusCode == 401) {
        return 'AI key invalid. Please update the API key.';
      } else if (response.statusCode == 429) {
        return 'AI rate limit reached. Please wait a moment and try again.';
      } else {
        return 'AI error (${response.statusCode}). Please try again.';
      }
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return 'AI request timed out. Check your connection and try again.';
      }
      return 'Connection error. Please check your internet and try again.';
    }
  }
}