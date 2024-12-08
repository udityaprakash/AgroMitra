import 'dart:developer';

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
            text: 'Settings', textColor: AppColors.white, fontSize: 20),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Language Preferences
          _buildSectionHeader('Language Preferences'),
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
          _buildSectionHeader('Account Management'),
          ListTile(
            leading: Icon(Icons.person),
            title: CustomTextWidget(
                text: 'Edit Profile',
                textColor: AppColors.textPrimary,
                fontSize: 16),
            onTap: () {
              // Navigate to Edit Profile Screen
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: CustomTextWidget(
                text: 'Logout', textColor: AppColors.textPrimary, fontSize: 16),
            onTap: () {
              // Perform Logout
            },
          ),
          SizedBox(height: 24),

          // Location Settings
          _buildSectionHeader('Location Settings'),
          SwitchListTile(
                title: CustomTextWidget(
                    text: 'Change Location',
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
          _buildSectionHeader('Notification Preferences'),
          SwitchListTile(
            title: CustomTextWidget(
                text: 'Crop Alerts',
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
                text: 'Market Updates',
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
                text: 'Weather Notifications',
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
          _buildSectionHeader('Theme Settings'),
          SwitchListTile(
            title: CustomTextWidget(
                text: 'Dark Mode',
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
          _buildSectionHeader('Help & Support'),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: CustomTextWidget(
                text: 'FAQs', textColor: AppColors.textPrimary, fontSize: 16),
            onTap: () {
              // Navigate to FAQs Screen
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_support),
            title: CustomTextWidget(
                text: 'Contact Support',
                textColor: AppColors.textPrimary,
                fontSize: 16),
            onTap: () {
              // Navigate to Contact Support Screen
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: CustomTextWidget(
                text: 'Tutorials',
                textColor: AppColors.textPrimary,
                fontSize: 16),
            onTap: () {
              // Navigate to Tutorials Screen
            },
          ),
          SizedBox(height: 24),

          // Privacy & Legal
          _buildSectionHeader('Privacy & Legal'),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: CustomTextWidget(
                text: 'Privacy Policy',
                textColor: AppColors.textPrimary,
                fontSize: 16),
            onTap: () {
              // Navigate to Privacy Policy Screen
            },
          ),
          ListTile(
            leading: Icon(Icons.gavel),
            title: CustomTextWidget(
                text: 'Terms & Conditions',
                textColor: AppColors.textPrimary,
                fontSize: 16),
            onTap: () {
              // Navigate to Terms & Conditions Screen
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever),
            title: CustomTextWidget(
                text: 'Data Deletion Request',
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
