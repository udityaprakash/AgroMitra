import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/languageProvider.dart';
import 'package:agromitra/utils/data/deviceStorage.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class LanguageSelection extends StatefulWidget {
  @override
  _LanguageSelectionState createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  final List<Map<String, dynamic>> languages = [
    {'name': 'English', 'code': 'en', 'color': Colors.orange[100]},
    {'name': 'हिन्दी', 'code': 'hi', 'color': Colors.blue[100]},
    {'name': 'বাংলা', 'code': 'bn', 'color': Colors.green[100]},
    {'name': 'తెలుగు', 'code': 'te', 'color': Colors.blue[100]},
    {'name': 'मराठी', 'code': 'mr', 'color': Colors.pink[100]},
    {'name': 'தமிழ்', 'code': 'ta', 'color': Colors.pink[100]},
    {'name': 'اردو', 'code': 'ur', 'color': Colors.orange[100]},
    {'name': 'ગુજરાતી', 'code': 'gu', 'color': Colors.pink[100]},
    {'name': 'ಕನ್ನಡ', 'code': 'kn', 'color': Colors.green[100]},
    {'name': 'മലയാളം', 'code': 'ml', 'color': Colors.pink[100]},
    {'name': 'ଓଡ଼ିଆ', 'code': 'or', 'color': Colors.blue[100]},
    {'name': 'ਪੰਜਾਬੀ', 'code': 'pa', 'color': Colors.pink[100]},
    {'name': 'অসমীয়া', 'code': 'as', 'color': Colors.orange[100]},
    {'name': 'मैथिली', 'code': 'mai', 'color': Colors.orange[100]},
    {'name': 'ᱥᱟᱱᱛᱟᱲᱤ', 'code': 'sat', 'color': Colors.pink[100]},
    {'name': 'कॉशुर', 'code': 'ks', 'color': Colors.orange[100]},
    {'name': 'संस्कृतम्', 'code': 'sa', 'color': Colors.pink[100]},
    {'name': 'سنڌي', 'code': 'sd', 'color': Colors.blue[100]},
    {'name': 'कोंकणी', 'code': 'kok', 'color': Colors.pink[100]},
    {'name': 'মৈতৈলোন', 'code': 'mni', 'color': Colors.orange[100]},
    {'name': 'डोगरी', 'code': 'dgo', 'color': Colors.pink[100]},
    {'name': 'बर\'', 'code': 'brx', 'color': Colors.blue[100]},
    {'name': 'नेपाली', 'code': 'ne', 'color': Colors.orange[100]},
  ];

  int? selectedLanguageIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            Image.asset('assets/images/app_logo/appLogoImage.png', height: 50),
            SizedBox(width: 8), // Space between logo and text
            CustomTextWidget(
              text: 'AgroMitra',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              textColor: AppColors.primary,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.translate, color: AppColors.textPrimary, size: 30),
                SizedBox(width: 8), // Space between icon and text
                CustomTextWidget(
                  text: AppLocalizations.of(context)!.choosepreferedlang,
                  textColor: AppColors.textPrimary,
                  overflow: TextOverflow.clip,
                  fontSize: 15,
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedLanguageIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedLanguageIndex = index;
                      context
                          .read<LanguageProvider>()
                          .setLocale(Locale(languages[index]['code']!));
                    });
                  },
                  child: AnimatedContainer(
                    duration:
                        Duration(milliseconds: 300), // Add a smooth transition
                    height: 80, // Increased height for better rectangle
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: languages[index]['color'],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        width: isSelected ? 3.0 : 1.0,
                      ),
                    ),
                    child: Center(
                        child: CustomTextWidget(
                            text: languages[index]['name']!,
                            textColor: AppColors.textPrimary)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              backgroundColor: AppColors.secondary,
              textColor: AppColors.textPrimary,
              text: AppLocalizations.of(context)!.contin,
              onPressed: () async {
                if (selectedLanguageIndex != null) {
                  String selectedLanguage =
                      languages[selectedLanguageIndex!]['code'];
                  await StorageManager.saveData('Lang', selectedLanguage).then(
                    (value) => Navigator.pushNamed(context, '/login'),
                  );

                  // log('Selected Language: $selectedLanguage');
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text('You have selected: $selectedLanguage')),
                  // var j = await StorageManager.readData('Lang');
                  // log(j);
                  // );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: CustomTextWidget(
                            text: 'Please select a language',
                            textColor: AppColors.textSecondary)),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
