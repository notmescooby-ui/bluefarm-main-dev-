class AppTranslations {

  static String currentLanguage = "en";

  static final Map<String, Map<String, String>> translations = {

    "en": {
      "choose_language": "Choose Language",
      "select_language": "Select your preferred language",
      "continue": "Continue",
      "login_google": "Continue with Google",
      "login_phone": "Continue with Phone",
      "signup_prompt": "First time? Dive with us by signing up!",
      "tagline": "Your aquaculture companion"
    },

    "hi": {
      "choose_language": "भाषा चुनें",
      "select_language": "जारी रखने के लिए भाषा चुनें",
      "continue": "जारी रखें",
      "login_google": "Google से जारी रखें",
      "login_phone": "फोन से जारी रखें",
      "signup_prompt": "पहली बार यहाँ? साइन अप करके जुड़ें!",
      "tagline": "आपका एक्वाकल्चर साथी"
    },

    "mr": {
      "choose_language": "भाषा निवडा",
      "select_language": "पुढे जाण्यासाठी भाषा निवडा",
      "continue": "सुरू ठेवा",
      "login_google": "Google सह सुरू ठेवा",
      "login_phone": "फोन सह सुरू ठेवा",
      "signup_prompt": "पहिल्यांदाच येथे? साइन अप करा!",
      "tagline": "तुमचा मत्स्यपालन साथी"
    },

    "te": {
      "choose_language": "భాషను ఎంచుకోండి",
      "select_language": "కొనసాగడానికి భాషను ఎంచుకోండి",
      "continue": "కొనసాగించండి",
      "login_google": "Google తో కొనసాగించండి",
      "login_phone": "ఫోన్‌తో కొనసాగించండి",
      "signup_prompt": "మొదటిసారి ఇక్కడా? సైన్ అప్ చేయండి!",
      "tagline": "మీ ఆక్వాకల్చర్ సహచరుడు"
    }

  };

  static String get(String key) {
    return translations[currentLanguage]![key] ?? key;
  }

}