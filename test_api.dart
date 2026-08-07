import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  const apiKey = 'AIzaSyAuOvUu13aw-_s8c_pifCXzavgl4SxWhoM';
  
  final modelsToTest = [
    'gemini-1.5-pro',
    'gemini-1.5-flash-8b',
    'gemini-2.0-flash-lite-preview-02-05',
    'gemini-pro',
    'gemini-1.0-pro'
  ];

  for (var modelName in modelsToTest) {
    try {
      print('\\nTesting model: \$modelName');
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
      );
      final response = await model.generateContent([
        Content.text('Say hello.')
      ]);
      print('SUCCESS Response: ${response.text ?? 'empty'}');
      return; // Exit on first success
    } catch (e) {
      print('Failed: $e');
    }
  }
}
