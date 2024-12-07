import 'dart:developer';

import 'package:agromitra/functions/autotranslator.dart';
import 'package:agromitra/functions/loading.dart';
import 'package:agromitra/functions/locations.dart';
import 'package:agromitra/utils/data/deviceStorage.dart';
import 'package:agromitra/utils/data/fetchInternetData.dart';
import 'package:agromitra/utils/data/models/weathermodel.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:agromitra/utils/ui/weatherwidget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:floating_bottom_bar/animated_bottom_navigation_bar.dart'
    as floa;
import 'package:flutter/material.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart'; // Add this for log functionality

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String lang = "Loading...";
  // String token = "Loading...";
  String name = "##";
  late Future<WeatherResponse> futureWeather;
  Position? location;
  bool isRefreshing = false;
  var weatherResponse;
  List<dynamic> crops = [];
  var i = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    String fetchedLang = await StorageManager.readData('Lang') ?? 'Loading...';
    // String fetchedToken = await StorageManager.readData('token') ?? 'Unknown';
    String fetchedname = await StorageManager.readData('farmer_name') ?? '##';
    // log('Lang: $fetchedname');

    try {
      location = await determinePosition();
      // log('Location: $location');
      futureWeather = fetchWeather();
      await _getRecommendedCrops();
    } catch (e) {
      log('Error getting location: $e');
    }

    setState(() {
      lang = fetchedLang;
      // token = fetchedToken;
      name = fetchedname;
    });
  }

  Future<WeatherResponse> fetchWeather() async {
    if (location == null) {
      throw Exception('Location not available');
    }

    final requestresponse = await FetchData(
        url: UrlProvider.fetchweatherUrl +
            location!.latitude.toString() +
            "/" +
            location!.longitude.toString(),
        headers: {'Content-Type': 'application/json'});

    final response = await requestresponse.get();
    // log('Weather response: ${response}');
    if (response['success'] == true) {
      return WeatherResponse.fromJson(response);
      // return weatherResponse.FromJson(response);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _getRecommendedCrops() async {
    final fetchresponse = FetchData(
      url: UrlProvider.recommendcropURL,
      headers: {'Content-Type': 'application/json'},
      body: {
        "latitude": location!.latitude,
        "longitude": location!.longitude,
        "soil_type": "Alluvial",
        "temperature": weatherResponse.main.temp,
        "humidity": weatherResponse.main.humidity,
        "month": getCurrentMonth().toString()
      },
    );
    var response = await fetchresponse.post();
    crops = response['recommended_crops'];
    // log("recomend crop response: $crops");

    if (i == 0) {
      i++;
      setState(() {});
    }
    // setState(() {

    // });
  }

  Future<void> _performRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    location = await determinePosition();
    futureWeather = fetchWeather();
    // await _getRecommendedCrops();

    setState(() {
      isRefreshing = false;
    });
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.newbackground,
      appBar: AppBar(
        shadowColor: AppColors.cardShadow,
        elevation: 10,
        title: CustomTextWidget(
          text: AppLocalizations.of(context)!.namaste +" " + name,
          textColor: Colors.white,
          fontSize: 20.0,
          isBold: true,
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              icon: Icon(
                Icons.notifications,
                color: AppColors.white,
              )),
          SizedBox(width: 10.0),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _performRefresh,
        // GestureDetector(
        //   onVerticalDragDown: (details) {
        //     // if (details.velocity.pixelsPerSecond.dy > 200 && !isRefreshing) {
        //       _performRefresh();
        //     // }
        //   },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child:
              // isRefreshing
              //     ? Center(
              //         child: loading(),
              //       )
              //     :
              Container(
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.only(top: 15.0),
            child: Column(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, '/weatherForecast',
                      arguments: {
                        'lat': location!.latitude,
                        'lon': location!.longitude,
                      });
                  },
                  child: Container(
                    height: 100,
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: (location == null)
                        ? loading()
                        : FutureBuilder<WeatherResponse>(
                            future: futureWeather,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return loading();
                              } else if (snapshot.hasError) {
                                log('error: ${snapshot.error}');
                                return Center(
                                    child: AutoTranslator().buildTranslatedText(
                                        context,
                                        'Error while fetching weather data'));
                              } else if (snapshot.hasData) {
                                var data = snapshot.data!.data;
                                weatherResponse = data;
                                _getRecommendedCrops();
                                return weatherTile(
                                    child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                        AutoTranslator().buildTranslatedText(
                                            context,
                                            '${data.weather[0].description}'),
                                      ],
                                    ),
                                    BoxedIcon(
                                      WeatherIconMapper.getIcon(
                                          data.weather[0].icon),
                                      color: WeatherIconMapper.getIconColor(
                                          data.weather[0].icon),
                                      size: 50,
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
                ),
                // CustomTextWidget(
                //   text:
                //       "Welcome to the Home Screen! $lang and $token location is $location",
                //   textColor: AppColors.textPrimary,
                //   fontSize: 18.0,
                //   overflow: TextOverflow.clip,
                // ),

                Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 4,
                            child: CustomTextWidget(
                              text: AppLocalizations.of(context)!.recommended_crops,
                              textColor: AppColors.textPrimary,
                              fontSize: 18.0,
                              isBold: true,
                            ),
                          ),  
                          // AutoTranslator().buildTranslatedText(
                          //     context, "Recommended Crops"),
                          // AutoTranslator().buildTranslatedText(
                          //     context, "See All",
                          //     textColor: AppColors.textHint),
                          // Expanded(
                          //   // flex: 2,
                          //   // child: CustomTextWidget(
                          //   //   text: AppLocalizations.of(context)!.see_all,
                          //   //   textColor: AppColors.textHint,
                          //   //   fontSize: 18.0,
                          //   //   isBold: true,
                          //   // ),
                          // ),
                        ],
                      ),
                      Container(
                        height: 200,
                        margin: EdgeInsets.only(bottom: 10.0),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: crops.length,
                          itemBuilder: (context, index) {
                            final crop = crops[index];
                            return Container(
                              margin: EdgeInsets.all(10.0),
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors
                                    .white,
                                borderRadius: BorderRadius.circular(20),
                                // border: Border.all(
                                //   color: AppColors
                                //       .background, // Replace with AppColors.cardShadow
                                //   width: 1,
                                // ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey
                                        .shade300, // Replace with AppColors.cardShadow
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                      child: Image.network(
                                        crop['image_url'] ?? '',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    flex: 1,
                                    child: AutoTranslator().buildTranslatedText(
                                        context,
                                        crop['crop_name'] ?? '--',
                                        isBold: false),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          //             Container(
          //   width: 300,
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     border: Border.all(color: Colors.grey, style: BorderStyle.values[1]),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(Icons.camera_alt, size: 40, color: Colors.grey),
          //       const SizedBox(height: 16),
          //       const Text(
          //         'Take a picture of your soil for instant analysis',
          //         textAlign: TextAlign.center,
          //         style: TextStyle(fontSize: 16, color: Colors.grey),
          //       ),
          //       const SizedBox(height: 16),
          //       ElevatedButton(
          //         onPressed: () {
          //           // Action for taking photo
          //         },
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.black,
          //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
          //         ),
          //         child: const Text('Take Photo', style: TextStyle(color: Colors.white)),
          //       ),
          //     ],
          //   ),
          // ),
                      Container(
                        width: double.infinity,
                        // height: 250,
                        margin: EdgeInsets.only(bottom: 20.0),
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextWidget(
                                  text: 'Scan Soil',
                                  textColor: AppColors.textPrimary,
                                  fontSize: 18.0,
                                  isBold: true,
                                ),
                                Icon(Icons.science_outlined, color: AppColors.primary),

                              ],
                            ),
                            SizedBox(height: 10),
                            DottedBorder(
                              color: Colors.grey,
                              strokeWidth: 2,
                              dashPattern: [8, 8],
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                            const SizedBox(height: 16),
                                            CustomTextWidget(text: 'Take a picture of your soil for instant analysis', textColor: AppColors.textHint, overflow: TextOverflow.clip, textAlign: TextAlign.center,),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushNamed(context, '/captureSoilImage');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                                              ),
                                              child: CustomTextWidget(text: 'Take Photo', textColor: Colors.white),
                                              // child: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                            ),
                          ],
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2, // Adjust as needed
                        shrinkWrap: true,

                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/captureSoilImage');
                            },
                            child: _buildCard(
                              // icon: Icons.camera_alt,
                              icon: Icons.calculate,
                              title: 'Fertilizer calculater',
                              // title: AppLocalizations.of(context)!.soil_analysis,
                              subtitle: "Calculate the amount of fertilizer needed",
                              // subtitle: AppLocalizations.of(context)!.scan_soil_with_camera,
                              badgeText: "85%",
                              badgeColor: Colors.grey.shade300,
                            ),
                          ),
                          _buildCard(
                            icon: Icons.eco,
                            title: AppLocalizations.of(context)!.organic_solutions,
                            subtitle: AppLocalizations.of(context)!.natural_alternatives_around_you,
                            badgeText: AppLocalizations.of(context)!.newk,
                            badgeTextColor: Colors.green,
                            badgeColor: Colors.green.shade100,
                            iconColor: Colors.green,
                          ),
                          InkWell(
                            onTap: () {
                              if(location == null || lang == "Loading...") {
                                
                                return;
                              }
                              Navigator.pushNamed(context, '/soilgridmap',
                                  arguments: {
                                    'lat': location!.latitude,
                                    'lon': location!.longitude,
                                    'lang': lang	
                                  });
                            },
                            child: _buildCard(
                              icon: Icons.grid_on,
                              title: AppLocalizations.of(context)!.soil_grid,
                              subtitle: AppLocalizations.of(context)!.digital_soil_mapping_data,
                            ),
                          ),
                          _buildCard(
                            icon: Icons.store,
                            title: AppLocalizations.of(context)!.agri_clinics,
                            subtitle: AppLocalizations.of(context)!.find_nearby_testing_clinics,
                            iconColor: Colors.purple,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: (_selectedIndex == 0) ? CustomFloatingActionButton() : null,
      

      // bottomNavigationBar: floa.AnimatedBottomNavigationBar(
      //   barColor: AppColors.white,
      //   controller: floa.FloatingBottomBarController(initialIndex: 0),
      //   bottomBar: [
      //     floa.BottomBarItem(
      //       icon: Icon(Icons.home, size: 24, color: AppColors.textSecondary),
      //       iconSelected: const Icon(Icons.home, color: AppColors.primary),
      //       title: 'Home',
      //       titleStyle: TextStyle(color: AppColors.textSecondary),
      //       dotColor: AppColors.primary,
      //       onTap: (value) {
      //         setState(() {
      //           _selectedIndex = value;
      //         });
      //         developer.log('Home $_selectedIndex');
      //       },
      //     ),
      //     floa.BottomBarItem(
      //       icon: Icon(Icons.photo, size: 24, color: AppColors.textSecondary),
      //       iconSelected: const Icon(Icons.photo, color: AppColors.primary),
      //       title: 'Community',
      //       titleStyle: TextStyle(color: AppColors.textSecondary),
      //       dotColor: AppColors.primary,
      //       onTap: (value) {
      //         setState(() {
      //           _selectedIndex = value;
      //         });
      //         developer.log('Community $_selectedIndex');
      //       },
      //     ),
      //     floa.BottomBarItem(
      //       icon: const Icon(Icons.person,
      //           size: 24, color: AppColors.textSecondary),
      //       iconSelected: const Icon(Icons.person, color: AppColors.primary),
      //       title: 'Profile',
      //       titleStyle: TextStyle(color: AppColors.textSecondary),
      //       dotColor: AppColors.primary,
      //       onTap: (value) {
      //         setState(() {
      //           _selectedIndex = value;
      //         });
      //         developer.log('Profile $_selectedIndex');
      //       },
      //     ),
      //     floa.BottomBarItem(
      //       icon: const Icon(Icons.settings,
      //           size: 24, color: AppColors.textSecondary),
      //       iconSelected: const Icon(Icons.settings, color: AppColors.primary),
      //       title: 'Settings',
      //       titleStyle: TextStyle(color: AppColors.textSecondary),
      //       dotColor: AppColors.primary,
      //       onTap: (value) {
      //         setState(() {
      //           _selectedIndex = value;
      //         });
      //         developer.log('Settings $value');
      //       },
      //     ),
      //   ],
      //   // bottomBarCenterModel: floa.BottomBarCenterModel(
      //   //   centerBackgroundColor: AppColors.primary,
      //   //   centerIcon: const floa.FloatingCenterButton(
      //   //     child: Icon(Icons.add, color: AppColors.white),
      //   //   ),
      //   //   centerIconChild: [
      //   //     floa.FloatingCenterButtonChild(
      //   //       child: const Icon(Icons.camera, color: AppColors.white),
      //   //       onTap: () => developer.log('Item1'),
      //   //     ),
      //   //   ],
      //   // ),
      // ),
      // resizeToAvoidBottomInset: false,
    );
  }
}

String getCurrentMonth() {
  final now = DateTime.now();
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  return months[now.month - 1];
}

class CustomFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        // Add your onPressed action here
        Navigator.pushNamed(context, '/chat');
        print('FAB pressed');
      },
      icon: const Icon(Icons.chat),
      label: AutoTranslator().buildTranslatedText(context, 'Ask Ai',
          textColor: AppColors.background),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }
}

Widget _buildCard({
  required IconData icon,
  required String title,
  required String subtitle,
  String? badgeText,
  Color? badgeColor,
  Color badgeTextColor = Colors.black,
  Color iconColor = Colors.black,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor),
                  if (badgeText != null) Spacer(),
                  if (badgeText != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: CustomTextWidget(
                        text: badgeText,
                        textColor: badgeTextColor,
                        fontSize: 12,
                        isBold: true,
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
              Spacer(),
              CustomTextWidget(
                text: title,
                textColor: AppColors.textPrimary,
                fontSize: 16,
                isBold: true,
                maxLines: 2,
              ),
              SizedBox(height: 4),
              CustomTextWidget(
                text: subtitle,
                textColor: AppColors.textHint,
                fontSize: 14,
                maxLines: 2,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}