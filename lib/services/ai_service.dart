import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class AIService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiKey = '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'; // rotate or override with env

  Future<String> askClaude(String question, SensorData? data) async {
    if (data == null) {
      return 'No sensor data available.';
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'content-type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-3-haiku-20240307',
          'max_tokens': 400,
          'messages': [
            {
              'role': 'user',
              'content': question,
            }
          ]
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final content = body['content'] as List;
        if (content.isNotEmpty) {
          return content[0]['text'] as String;
        }
      }
    } catch (_) {
      // Fallback to local expert system
    }

    return _generateLocalFallback(question, data);
  }

  String _generateLocalFallback(String prompt, SensorData data) {
    // A smart rule-based generator that parses input details and provides structured advice
    final advice = <String>[];

    // Check if the prompt has specific question answers
    bool waterChanged = prompt.contains('Water changed in last 24h: Yes');
    bool chemicalsAdded = prompt.contains('Chemicals/lime/fertilizer recently: Yes');
    bool heavyRain = prompt.contains('Heavy rainfall recently: Yes');
    bool gaspingFish = prompt.contains('Fish gasping: Yes');
    bool directSun = prompt.contains('Direct sunlight: Yes');
    bool suddenWeather = prompt.contains('Sudden weather change: Yes');
    bool gatheringBottom = prompt.contains('Fish gathering: Yes');
    bool excessiveAlgae = prompt.contains('Excessive algae/mud: Yes');

    if (data.ph < 6.5) {
      advice.add('🔴 Low pH (${data.ph} pH): Water is too acidic.');
      if (heavyRain) {
        advice.add('  - Cause: Heavy rain has washed acidic runoff into your pond.');
      }
      if (chemicalsAdded) {
        advice.add('  - Cause: Recent fertilizer/chemical additions may have crashed the pH.');
      }
      if (waterChanged) {
        advice.add('  - Note: A recent water change was done, but pH remains low.');
      }
      advice.add('  - Immediate Action: Add agricultural lime (calcium carbonate) at 50 kg per acre. Run aerators immediately.');
    } else if (data.ph > 8.5) {
      advice.add('🔴 High pH (${data.ph} pH): Water is too alkaline.');
      if (excessiveAlgae) {
        advice.add('  - Cause: Dense algae blooms are removing carbon dioxide via photosynthesis, spiking pH.');
      }
      advice.add('  - Immediate Action: Swap 10-15% of the pond water. Add agricultural gypsum or organic buffers like peat extract.');
    }

    if (data.temperature < 24) {
      advice.add('🔴 Low Temperature (${data.temperature}°C): Fish metabolism is slowed down.');
      if (suddenWeather) {
        advice.add('  - Cause: Ambient cold weather front.');
      }
      advice.add('  - Immediate Action: Reduce daily feed amount by 50% to prevent wastage and water pollution. Raise water depth to buffer temp.');
    } else if (data.temperature > 30) {
      advice.add('🔴 High Temperature (${data.temperature}°C): Critical! Higher temperatures crash dissolved oxygen.');
      if (directSun) {
        advice.add('  - Cause: Direct solar heating.');
      }
      if (gaspingFish || gatheringBottom) {
        advice.add('  - Warning: Fish are gathering at the surface due to low dissolved oxygen.');
      }
      advice.add('  - Immediate Action: Run aerators 24/7. Pump in cooler groundwater if possible, and add shade nets.');
    }

    if (data.turbidity > 100) {
      advice.add('🔴 High Turbidity (${data.turbidity} NTU): Water contains too many suspended particles.');
      if (heavyRain) {
        advice.add('  - Cause: Muddy clay runoff from rain.');
      }
      if (chemicalsAdded) {
        advice.add('  - Cause: Organic wastes or excessive feeding.');
      }
      advice.add('  - Immediate Action: Reduce feeding. Apply alum (potassium aluminum sulfate) at 10-15 kg per acre to clump and settle the mud.');
    } else if (data.turbidity < 1) {
      advice.add('🔴 Low Turbidity (${data.turbidity} NTU): Water is too clear.');
      advice.add('  - Immediate Action: Clear water lacks natural food (plankton). Apply organic fertilizers (manure or single superphosphate) to boost plankton.');
    }

    if (advice.isEmpty) {
      return '✅ Water quality is excellent. Maintain regular monitoring and feeding schedules.';
    }

    return 'BlueFarm Smart Action Plan:\n\n' + advice.join('\n\n') + '\n\n*This recommendation was personalized based on your pond readings and inputs.*';
  }
}
