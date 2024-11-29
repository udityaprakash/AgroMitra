import 'package:agromitra/utils/data/deviceStorage.dart';
import 'package:flutter/material.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String lang = "Loading...";
  String token = "Loading...";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    String fetchedLang = await StorageManager.readData('Lang') ?? 'Unknown';
    String fetchedToken = await StorageManager.readData('token') ?? 'Unknown';

    setState(() {
      lang = fetchedLang;
      token = fetchedToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        title: CustomTextWidget(
          text: AppLocalizations.of(context)!.agromitra,
          textColor: Colors.white,
          fontSize: 20.0,
          isBold: true,
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Center(
        child: CustomTextWidget(
          text: "Welcome to the Home Screen! $lang and $token",
          textColor: AppColors.textPrimary,
          fontSize: 18.0,
          overflow: TextOverflow.clip,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await StorageManager.deleteAllData();
          Navigator.pushReplacementNamed(context, '/');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomTextWidget(
                text: "Floating Action Button Pressed!",
                textColor: Colors.white,
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
