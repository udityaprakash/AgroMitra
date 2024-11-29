import 'package:agromitra/utils/data/deviceStorage.dart';
import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'हिन्दी', 'code': 'hi'},
    {'name': 'বাংলা', 'code': 'bn'},
    {'name': 'తెలుగు', 'code': 'te'},
    {'name': 'मराठी', 'code': 'mr'},
    {'name': 'தமிழ்', 'code': 'ta'},
    {'name': 'اردو', 'code': 'ur'},
    {'name': 'ગુજરાતી', 'code': 'gu'},
    {'name': 'ಕನ್ನಡ', 'code': 'kn'},
    {'name': 'മലയാളം', 'code': 'ml'},
    {'name': 'ଓଡ଼ିଆ', 'code': 'or'},
    {'name': 'ਪੰਜਾਬੀ', 'code': 'pa'},
    {'name': 'অসমীয়া', 'code': 'as'},
    {'name': 'मैथिली', 'code': 'mai'},
    {'name': 'ᱥᱟᱱᱛᱟᱲᱤ', 'code': 'sat'},
    {'name': 'कॉशुर', 'code': 'ks'},
    {'name': 'संस्कृतम्', 'code': 'sa'},
    {'name': 'سنڌي', 'code': 'sd'},
    {'name': 'कोंकणी', 'code': 'kok'},
    {'name': 'মৈতৈলোন', 'code': 'mni'},
    {'name': 'डोगरी', 'code': 'dgo'},
    {'name': 'बर\'', 'code': 'brx'},
    {'name': 'नेपाली', 'code': 'ne'},
  ];

  Locale _selectedLocale = const Locale('en');

  Locale get selectedLocale => _selectedLocale;

  Future<void> initializeLocale() async {
    String? savedLanguageCode = await StorageManager.readData('Lang');
    _selectedLocale = Locale(savedLanguageCode ?? 'en');
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _selectedLocale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _selectedLocale = const Locale('en');
    notifyListeners();
  }
}
