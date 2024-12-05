import 'dart:convert';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/autotranslator.dart';
import 'package:agromitra/functions/loading.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WeatherForecastScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  // Constructor to accept latitude and longitude
  WeatherForecastScreen({required this.latitude, required this.longitude});

  @override
  _WeatherForecastScreenState createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  late List<dynamic> weatherData;
  bool isLoading = true;
  String errorMessage = '';

  // Map of weather codes to conditions and icons
  final Map<int, Map<String, dynamic>> weatherCodeMap = {
    0: {
      "condition": "Clear sky",
      "icon": Icons.wb_sunny,
      "color": Colors.yellow
    },
    1: {
      "condition": "Mainly clear",
      "icon": Icons.cloud,
      "color": Colors.lightBlueAccent
    },
    2: {
      "condition": "Partly cloudy",
      "icon": Icons.cloud,
      "color": Colors.grey
    },
    3: {"condition": "Overcast", "icon": Icons.cloud, "color": Colors.blueGrey},
    45: {
      "condition": "Fog",
      "icon": Icons.visibility_off,
      "color": Colors.blueGrey
    },
    48: {
      "condition": "Depositing rime fog",
      "icon": Icons.visibility_off,
      "color": Colors.blueGrey
    },
    51: {
      "condition": "Light drizzle",
      "icon": Icons.beach_access,
      "color": Colors.blue
    },
    53: {
      "condition": "Moderate drizzle",
      "icon": Icons.beach_access,
      "color": Colors.blue
    },
    55: {
      "condition": "Dense drizzle",
      "icon": Icons.beach_access,
      "color": Colors.blue
    },
    56: {
      "condition": "Light freezing drizzle",
      "icon": Icons.ac_unit,
      "color": Colors.lightBlue
    },
    57: {
      "condition": "Dense freezing drizzle",
      "icon": Icons.ac_unit,
      "color": Colors.lightBlue
    },
    61: {
      "condition": "Light rain",
      "icon": Icons.beach_access,
      "color": Colors.blue
    },
    63: {
      "condition": "Moderate rain",
      "icon": Icons.beach_access,
      "color": Colors.blueAccent
    },
    65: {
      "condition": "Heavy rain",
      "icon": Icons.beach_access,
      "color": Colors.blueAccent
    },
    66: {
      "condition": "Light freezing rain",
      "icon": Icons.ac_unit,
      "color": Colors.lightBlue
    },
    67: {
      "condition": "Heavy freezing rain",
      "icon": Icons.ac_unit,
      "color": Colors.lightBlue
    },
    71: {
      "condition": "Light snow",
      "icon": Icons.ac_unit,
      "color": Colors.white
    },
    73: {
      "condition": "Moderate snow",
      "icon": Icons.ac_unit,
      "color": Colors.white
    },
    75: {
      "condition": "Heavy snow",
      "icon": Icons.ac_unit,
      "color": Colors.white
    },
    77: {
      "condition": "Snow grains",
      "icon": Icons.ac_unit,
      "color": Colors.white
    },
    80: {
      "condition": "Light rain showers",
      "icon": Icons.beach_access,
      "color": Colors.blue
    },
    81: {
      "condition": "Moderate rain showers",
      "icon": Icons.beach_access,
      "color": Colors.blueAccent
    },
    82: {
      "condition": "Violent rain showers",
      "icon": Icons.beach_access,
      "color": Colors.blueAccent
    },
    85: {
      "condition": "Light snow showers",
      "icon": Icons.ac_unit,
      "color": Colors.white
    },
    86: {
      "condition": "Heavy snow showers",
      "icon": Icons.ac_unit,
      "color": Colors.white
    },
    95: {
      "condition": "Thunderstorm",
      "icon": Icons.flash_on,
      "color": Colors.deepPurple
    },
    96: {
      "condition": "Thunderstorm with light hail",
      "icon": Icons.flash_on,
      "color": Colors.deepPurple
    },
    99: {
      "condition": "Thunderstorm with heavy hail",
      "icon": Icons.flash_on,
      "color": Colors.deepPurple
    },
  };

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    // Construct the URL and headers
    final String url = UrlProvider.sevenDayWeatherUrl;
    final Map<String, dynamic> body = {
      "latitude": widget.latitude,
      "longitude": widget.longitude,
    };

    // Make the POST request
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data["success"]) {
          setState(() {
            weatherData = data["data"];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Failed to fetch data";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Request failed with status: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _performRefresh() async {
    setState(() {
      isLoading = true;
    });
    await fetchWeatherData();
    // await _getRecommendedCrops();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.newbackground,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: CustomTextWidget(
            text: AppLocalizations.of(context)!.weather_forecast,
            textColor: AppColors.white,
            overflow: TextOverflow.clip,
            fontSize: 25,
            textAlign: TextAlign.start,
          ),
          backgroundColor: AppColors.primary,
        ),
        body: RefreshIndicator(
          onRefresh: _performRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.newbackground,
          child: isLoading
              ? Center(child: loading())
              : errorMessage.isNotEmpty
                  ? Center(
                      child: CustomTextWidget(
                      text: errorMessage.toString(),
                      textColor: Colors.black,
                      fontSize: 18,
                      isBold: true,
                      textAlign: TextAlign.start,
                    ))
                  : ListView.builder(
                      itemCount: weatherData.length,
                      itemBuilder: (context, index) {
                        final dayData = weatherData[index];
                        final date = dayData['date'];
                        final maxTemp = dayData['max_temp'];
                        final minTemp = dayData['min_temp'];
                        final weatherCode = dayData['weather_code'];

                        // Get the weather condition and icon based on the weather code
                        final weatherCondition =
                            weatherCodeMap[weatherCode]!['condition'];
                        final weatherIcon =
                            weatherCodeMap[weatherCode]!['icon'];
                        final iconColor = weatherCodeMap[weatherCode]!['color'];

                        return Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20), // Add margin between items
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                                0, 158, 158, 158), // Background color
                            borderRadius: BorderRadius.circular(
                                15), // Border radius for rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                    55, 0, 0, 0), // Shadow color
                                blurRadius: 4, // Blur effect
                                offset: Offset(0, 2), // Offset of the shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                                15), // Padding inside the container
                            child: Row(
                              children: [
                                // Icon
                                Icon(weatherIcon, color: iconColor, size: 40),
                                SizedBox(
                                    width: 15), // Space between icon and text
                                // Text content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomTextWidget(
                                        text: date,
                                        textColor: Colors.black,
                                        fontSize: 18,
                                        isBold: true,
                                        textAlign: TextAlign.start,
                                      ),
                                      SizedBox(height: 5),
                                      AutoTranslator().buildTranslatedText(
                                        context,
                                        "Max Soil Temp: "+maxTemp.toString()+" °C",
                                        textColor: Colors.black,
                                        fontSize: 16.0,
                                        textAlign: TextAlign.start,
                                        isBold: false),
                                      // CustomTextWidget(
                                      //   text: "Max Soil Temp: $maxTemp°C",
                                      //   textColor: Colors.black,
                                      //   overflow: TextOverflow.clip,
                                      //   fontSize: 16,
                                      //   textAlign: TextAlign.start,
                                      // ),
                                      SizedBox(height: 5),
                                      AutoTranslator().buildTranslatedText(
                                        context,
                                        "Min Soil Temp: "+minTemp.toString()+" °C",
                                        textColor: Colors.black,
                                        fontSize: 16.0,
                                        textAlign: TextAlign.start,
                                        isBold: false),
                                      SizedBox(height: 5),
                                      AutoTranslator().buildTranslatedText(
                                        context,
                                        "Environmental condition: $weatherCondition",
                                        textColor: Colors.black,
                                        fontSize: 16.0,
                                        textAlign: TextAlign.start,
                                        isBold: false),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ));
  }
}
