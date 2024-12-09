import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/languageProvider.dart';
import 'package:agromitra/main.dart';
import 'package:agromitra/utils/data/deviceStorage.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool cropAlertsEnabled = true;
  bool marketUpdatesEnabled = false;
  bool weatherNotificationsEnabled = true;
  bool isDarkMode = false;
  bool locationEnabled = true;
  late String selectedLanguageCode;

  void initState() {
    super.initState();
    selectedLanguageCode =
        context.read<LanguageProvider>().selectedLocale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: CustomTextWidget(
            text: AppLocalizations.of(context)!.settings, textColor: AppColors.white, fontSize: 20),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Language Preferences
          _buildSectionHeader(AppLocalizations.of(context)!.languagePreferences),
          DropdownButtonFormField<String>(
            value: context.read<LanguageProvider>().selectedLocale.languageCode,
            items: languages.map((language) {
              return DropdownMenuItem<String>(
                value: language['code'],
                alignment: Alignment.center,
                child: CustomTextWidget(
                    text: language['name'],
                    textColor: AppColors.textPrimary,
                    fontSize: 16),
              );
            }).toList(),
            onChanged: (value) async {
              // LanguageProvider().setLocale(Locale(value!));
              context.read<LanguageProvider>().setLocale(Locale(value!));
              await StorageManager.saveData('Lang', value);
              setState(() {
                selectedLanguageCode = value!;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          SizedBox(height: 24),

          // Account Management
          _buildSectionHeader(AppLocalizations.of(context)!.accountManagement),
          ListTile(
            leading: Icon(Icons.person),
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.editProfile,
                textColor: AppColors.textPrimary,
                fontSize: 16),
            onTap: () {
              // Navigate to Edit Profile Screen
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.logout, textColor: AppColors.textPrimary, fontSize: 16),
            onTap: () {
              // Perform Logout
            },
          ),
          SizedBox(height: 24),

          // Location Settings
          _buildSectionHeader(AppLocalizations.of(context)!.locationSettings),
          SwitchListTile(
                title: CustomTextWidget(
                    text: AppLocalizations.of(context)!.changeLocation,
                    textColor: AppColors.textPrimary,
                    fontSize: 16),
                activeColor: AppColors.primary,
                inactiveTrackColor: AppColors.newbackground,
                onChanged: (value) {
                  setState(() {
                    cropAlertsEnabled = value;
                  });
                },
                value: locationEnabled,
              ),
          SizedBox(height: 24),

          // Notification Preferences
          _buildSectionHeader(AppLocalizations.of(context)!.notificationPreferences),
          SwitchListTile(
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.cropAlerts,
                textColor: AppColors.textPrimary,
                fontSize: 16),
            value: cropAlertsEnabled,
            activeColor: AppColors.primary,
            inactiveTrackColor: AppColors.newbackground,
            onChanged: (value) {
              setState(() {
                cropAlertsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.marketUpdates,
                textColor: AppColors.textPrimary,
                fontSize: 16),
            value: marketUpdatesEnabled,
            activeColor: AppColors.primary,
            inactiveTrackColor: AppColors.newbackground,
            onChanged: (value) {
              setState(() {
                marketUpdatesEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.weatherNotifications,
                textColor: AppColors.textPrimary,
                fontSize: 16),
            value: weatherNotificationsEnabled,
            activeColor: AppColors.primary,
            inactiveTrackColor: AppColors.newbackground,
            onChanged: (value) {
              setState(() {
                weatherNotificationsEnabled = value;
              });
            },
          ),
          SizedBox(height: 24),

          // Theme Settings
          _buildSectionHeader(AppLocalizations.of(context)!.themeSettings),
          SwitchListTile(
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.darkMode,
                textColor: AppColors.textPrimary,
                fontSize: 16),
            value: isDarkMode,
            activeColor: AppColors.primary,
            inactiveTrackColor: AppColors.newbackground,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
            },
          ),
          SizedBox(height: 24),

          // Help & Support
          _buildSectionHeader(AppLocalizations.of(context)!.helpSupport),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.faqs, textColor: AppColors.textPrimary, fontSize: 16),
            onTap: () {
              // Navigate to FAQs Screen
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_support),
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.contactSupport,
                textColor: AppColors.textPrimary,
                fontSize: 16),
            onTap: () {
              // Navigate to Contact Support Screen
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.tutorials,
                textColor: AppColors.textPrimary,
                fontSize: 16),
            onTap: () {
              // Navigate to Tutorials Screen
            },
          ),
          SizedBox(height: 24),

          // Privacy & Legal
          _buildSectionHeader(AppLocalizations.of(context)!.privacyLegal),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.privacyPolicy,
                textColor: AppColors.textPrimary,
                fontSize: 16),
            onTap: () {
              // Navigate to Privacy Policy Screen
            },
          ),
          ListTile(
            leading: Icon(Icons.gavel),
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.termsAndConditions,
                textColor: AppColors.textPrimary,
                fontSize: 16),
            onTap: () {
              // Navigate to Terms & Conditions Screen
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever),
            title: CustomTextWidget(
                text: AppLocalizations.of(context)!.dataDeletionRequest,
                textColor: AppColors.textPrimary,
                fontSize: 16),
            onTap: () {
              // Navigate to Data Deletion Request Screen
            },
          ),
        ],
      ),
    );
  }

  // Helper widget for section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CustomTextWidget(
        text: title,
        textColor: AppColors.textSecondary,
        fontSize: 18,
        isBold: true,
      ),
    );
  }
}
