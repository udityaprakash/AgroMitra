import 'dart:developer';

import 'package:agromitra/functions/autotranslator.dart';
import 'package:agromitra/utils/data/deviceStorage.dart';
import 'package:floating_bottom_bar/animated_bottom_navigation_bar.dart'
    as floa;
import 'package:flutter/material.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer; // Add this for log functionality

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String lang = "Loading...";
  String token = "Loading...";
  String email = "Loading...";

  // GlobalKey for Scaffold to open the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Track the selected index for the bottom navbar
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    String fetchedLang = await StorageManager.readData('Lang') ?? 'Unknown';
    String fetchedToken = await StorageManager.readData('token') ?? 'Unknown';
    String fetchedemail = await StorageManager.readData('email') ?? 'Unknown';

    setState(() {
      lang = fetchedLang;
      token = fetchedToken;
      email = fetchedemail;
    });
  }

  // Function to handle bottom navbar item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Image.asset('assets/images/icons/menu.png',
        //       width: 30, height: 30),
        //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        // ),
        shadowColor: AppColors.cardShadow,
        elevation: 10,
        title: CustomTextWidget(
          text: AppLocalizations.of(context)!.agromitra,
          textColor: Colors.white,
          fontSize: 20.0,
          isBold: true,
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              CustomTextWidget(
                text: "Welcome to the Home Screen! $lang and $token",
                textColor: AppColors.textPrimary,
                fontSize: 18.0,
                overflow: TextOverflow.clip,
              ),
              Container(
                child: AutoTranslator().buildTranslatedText(context, "Hello, how are you?"),
          //       child: FutureBuilder<String>(future:  _autoTranslator.translateToAppLanguage("Hello, how are you?"),
          //        builder: (context, snapshot) {
          //   if (snapshot.connectionState == ConnectionState.waiting) {
          //     return CircularProgressIndicator();
          //   }

          //   if (snapshot.hasError) {
          //     return Text('Error: ${snapshot.error}');
          //   }

          //   return Text('${snapshot.data}');
          // },),
              ),
            ],
          ),
        ),
      ),
      // drawer: Drawer(
      //   backgroundColor: AppColors.background,
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: <Widget>[
      //       UserAccountsDrawerHeader(
      //         decoration: BoxDecoration(color: AppColors.primary),
      //         accountName: Text('Username'),
      //         accountEmail: Text('$email'),
      //         currentAccountPicture: CircleAvatar(
      //           backgroundColor: AppColors.background,
      //           child: Icon(Icons.person, color: AppColors.primary),
      //         ),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.home),
      //         title: Text('home'),
      //         onTap: () {
      //           Navigator.pushReplacementNamed(context, '/home');
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.settings),
      //         title: Text('settings'),
      //         onTap: () {
      //           Navigator.pushReplacementNamed(context, '/settings');
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.logout),
      //         title: Text('logout'),
      //         onTap: () async {
      //           await StorageManager.deleteAllData();
      //           Navigator.pushReplacementNamed(context, '/');
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      bottomNavigationBar: floa.AnimatedBottomNavigationBar(
        barColor: AppColors.white,
        controller: floa.FloatingBottomBarController(initialIndex: 0),
        bottomBar: [
          floa.BottomBarItem(
            icon:Icon(Icons.home, size: 24, color: AppColors.textSecondary ),
            iconSelected: const Icon(Icons.home, color: AppColors.primary),
            title: 'Home',
            titleStyle: TextStyle(color: AppColors.textSecondary),
            dotColor: AppColors.primary,
            onTap: (value) {
              setState(() {
                _selectedIndex = value;
              });
              developer.log('Home $_selectedIndex');
            },
          ),
          floa.BottomBarItem(
            icon:Icon(Icons.photo, size: 24, color: AppColors.textSecondary),
            iconSelected: const Icon(Icons.photo, color: AppColors.primary),
            title: 'Search',
            titleStyle: TextStyle(color: AppColors.textSecondary),
            dotColor: AppColors.primary,
            onTap: (value) {
              setState(() {
                _selectedIndex = value;
              });
              developer.log('Search $_selectedIndex');
            },
          ),
          floa.BottomBarItem(
            icon: const Icon(Icons.person, size: 24, color: AppColors.textSecondary),
            iconSelected: const Icon(Icons.person, color: AppColors.primary),
            title: 'Profile',
            titleStyle: TextStyle(color: AppColors.textSecondary),
            dotColor: AppColors.primary,
            onTap: (value) {
              setState(() {
                _selectedIndex = value;
              });
              developer.log('Profile $_selectedIndex');
            },
          ),
          floa.BottomBarItem(
            icon: const Icon(Icons.settings, size: 24, color: AppColors.textSecondary),
            iconSelected: const Icon(Icons.settings, color: AppColors.primary),
            title: 'Settings',
            titleStyle: TextStyle(color: AppColors.textSecondary),
            dotColor: AppColors.primary,
            onTap: (value) {
              setState(() {
                _selectedIndex = value;
              });
              developer.log('Settings $value');
            },
          ),
        ],
        bottomBarCenterModel: floa.BottomBarCenterModel(
          centerBackgroundColor: AppColors.primary,
          centerIcon: const floa.FloatingCenterButton(
            child: Icon(Icons.add, color: AppColors.white),
          ),
          centerIconChild: [
            floa.FloatingCenterButtonChild(
              child: const Icon(Icons.camera, color: AppColors.white),
              onTap: () => developer.log('Item1'),
            ),
            // floa.FloatingCenterButtonChild(
            //   child: Icon(Icons.notifications, color: AppColors.white),
            //   onTap: () => developer.log('Item2'),
            // ),
            // FloatingCenterButtonChild(
            //   child: const Icon(Icons.ac_unit_outlined, color: AppColors.white),
            //   onTap: () => developer.log('Item3'),
            // ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
