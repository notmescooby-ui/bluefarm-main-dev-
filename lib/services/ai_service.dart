import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class AIService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiKey = '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'; // rotate your old key!

 Future<String> askClaude(String question, SensorData? data) async {
  if (data == null) {
    return 'No sensor data available.';
  }

  final List<String> advice = [];

  // 🔴 pH
  if (data.ph < 6.5) {
    advice.add('• pH is LOW → Add lime and improve aeration');
  } else if (data.ph > 8.5) {
    advice.add('• pH is HIGH → Add fresh water and reduce algae');
  }

  // 🔴 Temperature
  if (data.temperature < 24) {
    advice.add('• Temp LOW → Reduce feeding, maintain warmth');
  } else if (data.temperature > 30) {
    advice.add('• Temp HIGH → Increase aeration, add cool water');
  }

  // 🔴 Turbidity
  if (data.turbidity == 0) {
    advice.add('• Sensor issue → Check turbidity sensor connection');
  } else if (data.turbidity > 100) {
    advice.add('• Turbidity HIGH → Stop overfeeding, filter water');
  } else if (data.turbidity < 1) {
    advice.add('• Water too clear → Add nutrients for plankton');
  }

  // ✅ All normal
  if (advice.isEmpty) {
    return '✅ All parameters normal. Maintain feeding schedule and monitor regularly.';
  }

  return advice.join('\n');
}
}
