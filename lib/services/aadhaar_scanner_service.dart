import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class AadhaarScannerService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  /// Opens the camera/gallery, prevents memory crashes, and runs OCR validation.
  Future<Map<String, dynamic>> scanAndValidateAadhaar({
    required ImageSource source,
    required String expectedUserName,
  }) async {
    try {
      // 🚀 THE CRASH FIX: imageQuality: 50 compresses the image so the app doesn't run out of RAM!
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );

      if (pickedFile == null) {
        return {'success': false, 'message': 'No image selected.'};
      }

      File imageFile = File(pickedFile.path);

      // 1. Process the Image with Google ML Kit
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      String scannedText = recognizedText.text.toLowerCase();

      // 2. Validation: Check for "Government of India"
      bool hasGovtText = scannedText.contains("government of india") ||
          scannedText.contains("भारत सरकार");

      // 3. Validation: Look for the 12-digit Aadhaar Number
      // Matches 12 digits, allowing for optional spaces (e.g., 1234 5678 9012 or 123456789012)
      RegExp aadhaarRegex = RegExp(r'\d{4}\s?\d{4}\s?\d{4}');
      String? foundAadhaarNumber = aadhaarRegex.stringMatch(scannedText);
      bool hasValidNumber = foundAadhaarNumber != null;

      // 4. Validation: Check if the user's name is on the card
      // We clean both strings to remove extra spaces for a better match
      String cleanExpectedName =
          expectedUserName.toLowerCase().replaceAll(' ', '');
      String cleanScannedText = scannedText.replaceAll(' ', '');
      bool isNameMatched = cleanScannedText.contains(cleanExpectedName);

      // 5. Final Decision Logic
      if (!hasGovtText) {
        return {
          'success': false,
          'message': 'Invalid Document: "Government of India" not found.'
        };
      }
      if (!hasValidNumber) {
        return {
          'success': false,
          'message': 'Invalid Document: 12-digit Aadhaar number not found.'
        };
      }
      if (!isNameMatched) {
        return {
          'success': false,
          'message':
              'Name Mismatch: The name on the card does not match your registered name.'
        };
      }

      // If all checks pass!
      return {
        'success': true,
        'message': 'Aadhaar Verified Successfully!',
        'aadhaar_number': foundAadhaarNumber,
        'image_file': imageFile, 
      };
    } catch (e) {
      debugPrint("🚨 OCR ERROR: $e");
      return {
        'success': false,
        'message': 'An error occurred while scanning the document.'
      };
    }
  }

  // Always dispose of the recognizer when done to free up memory
  void dispose() {
    _textRecognizer.close();
  }
}
