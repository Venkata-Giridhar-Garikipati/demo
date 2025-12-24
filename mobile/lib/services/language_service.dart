import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;
    
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'ta':
        return 'தமிழ்';
      case 'kn':
        return 'ಕನ್ನಡ';
      case 'ml':
        return 'മലയാളം';
      case 'gu':
        return 'ગુજરાતી';
      case 'or':
        return 'ଓଡ଼ିଆ';
      case 'pa':
        return 'ਪੰਜਾਬੀ';
      case 'te':
        return 'తెలుగు';
      case 'ur':
        return 'اردو';
      case 'mr':
        return 'मराठी';
      case 'as':
        return 'অসমীয়া';
      case 'bn':
        return 'বাংলা';
      case 'gu':
        return 'ગુજરાતી';
      case 'kn':
        return 'ಕನ್ನಡ';
      case 'ml':
        return 'മലയാളം';
      case 'ta':
        return 'தமிழ்';
      case 'te':
        return 'తెలుగు';
      case 'ur':
        return 'اردو';
      case 'mr':
        return 'मराठी';
      case 'as':
        return 'অসমীয়া';
      case 'bn':
        return 'বাংলা';
      case 'gu':
        return 'ગુજરાતી';
      case 'kn':
        return 'ಕನ್ನಡ';
      case 'ml':
        return 'മലയാളം';
      case 'ta':
        return 'தமிழ்';
      case 'te':
        return 'తెలుగు';
      case 'ur':
        return 'اردو';
      case 'mr':
        return 'मराठी';
      case 'as':
        return 'অসমীয়া';
      case 'bn':
        return 'বাংলা';
      default:
        return 'English';
    }
  }
}
