import 'dart:developer';

import 'package:agromitra/functions/autotranslator.dart';
import 'package:agromitra/functions/locations.dart';
import 'package:agromitra/utils/data/deviceStorage.dart';
import 'package:agromitra/utils/data/fetchInternetData.dart';
import 'package:agromitra/utils/data/models/weathermodel.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:agromitra/utils/ui/weatherwidget.dart';
import 'package:floating_bottom_bar/animated_bottom_navigation_bar.dart'
    as floa;
import 'package:flutter/material.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart'; // Add this for log functionality

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String lang = "Loading...";
  String token = "Loading...";
  String email = "Loading...";
  late Future<WeatherResponse> futureWeather;
  Position? location; // Make location nullable

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
    
    try {
      location = await determinePosition();
      log('Location: $location');
      futureWeather = fetchWeather();
    } catch (e) {
      log('Error getting location: $e');
    }

    setState(() {
      lang = fetchedLang;
      token = fetchedToken;
      email = fetchedemail;
    });
  }

  Future<WeatherResponse> fetchWeather() async {
    if (location == null) {
      throw Exception('Location not available');
    }

    final requestresponse = await FetchData(
      url: UrlProvider.fetchweatherUrl + location!.latitude.toString() + "/" + location!.longitude.toString(),
      headers: {'Content-Type': 'application/json'}
    );

    final response = await requestresponse.get();
    log('Weather response: ${response}');
    if (response['success'] == true) {
      return WeatherResponse.fromJson(response);
      // return weatherResponse.FromJson(response);
    } else {
      throw Exception('Failed to load weather data');
    }
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
              SizedBox(
                child: (location == null) ? SizedBox(height:100) : FutureBuilder<WeatherResponse>(
                  future: futureWeather,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: SizedBox(height: 100, child: CircularProgressIndicator()));
                    } else if (snapshot.hasError) {
                      log('error: ${snapshot.error}');
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      var data = snapshot.data!.data;
                      log('Data: ${data.coord.lat}');
                      // return CustomTextWidget(
                      //   text: 'Weather: ${data.weather[0].main}',
                      //   textColor: AppColors.textPrimary,
                      //   fontSize: 18.0,
                      //   overflow: TextOverflow.clip,
                      // );

                      return weatherTile(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomTextWidget(
                                text: '${data.name}',
                                textColor: AppColors.textPrimary,
                                fontSize: 18.0,
                                overflow: TextOverflow.clip,
                                ),
                                AutoTranslator()
                    .buildTranslatedText(context, '${data.weather[0].description}'),
                                
                              ],
                            ),
                           CustomTextWidget(
                            text: '${data.main.temp} °C',
                            textColor: AppColors.textPrimary,
                            fontSize: 18.0,
                            overflow: TextOverflow.clip,
                           ),
                          ],
                        ));
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                ),
              ),
              CustomTextWidget(
                text: "Welcome to the Home Screen! $lang and $token location is $location",
                textColor: AppColors.textPrimary,
                fontSize: 18.0,
                overflow: TextOverflow.clip,
              ),
              Container(
                child: AutoTranslator()
                    .buildTranslatedText(context, "Hello, how are you?"),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: floa.AnimatedBottomNavigationBar(
        barColor: AppColors.white,
        controller: floa.FloatingBottomBarController(initialIndex: 0),
        bottomBar: [
          floa.BottomBarItem(
            icon: Icon(Icons.home, size: 24, color: AppColors.textSecondary),
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
            icon: Icon(Icons.photo, size: 24, color: AppColors.textSecondary),
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
            icon: const Icon(Icons.person,
                size: 24, color: AppColors.textSecondary),
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
            icon: const Icon(Icons.settings,
                size: 24, color: AppColors.textSecondary),
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
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
