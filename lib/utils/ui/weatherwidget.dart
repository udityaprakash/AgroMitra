import 'package:agromitra/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

Widget weatherTile({child}) {
  return Container(
    width: double.infinity,
    height: 100,
    decoration: BoxDecoration(
      border: Border.all(
        color: AppColors.textSecondary,
        width: 2,
      ),
      color: AppColors.white,
      borderRadius: BorderRadius.circular(50),
    ),
    child: child,
  );
}

class WeatherIconMapper {
  static IconData getIcon(String code) {
    switch (code) {
      case '01d':
        return WeatherIcons.day_sunny;
      case '01n':
        return WeatherIcons.night_clear;
      case '02d':
        return WeatherIcons.day_cloudy;
      case '02n':
        return WeatherIcons.night_alt_cloudy;
      case '03d':
      case '03n':
        return WeatherIcons.cloud;
      case '04d':
      case '04n':
        return WeatherIcons.cloudy;
      case '09d':
      case '09n':
        return WeatherIcons.showers;
      case '10d':
        return WeatherIcons.day_rain;
      case '10n':
        return WeatherIcons.night_alt_rain;
      case '11d':
      case '11n':
        return WeatherIcons.thunderstorm;
      case '13d':
      case '13n':
        return WeatherIcons.snow; 
      case '50d':
      case '50n':
        return WeatherIcons.fog;
      default:
        return WeatherIcons.na;
    }
  }
   static Color getIconColor(String code) {
    switch (code) {
      case '01d':
        return Colors.yellow;
      case '01n':
        return Colors.blueGrey;
      case '02d':
        return Colors.orangeAccent;
      case '02n':
        return Colors.indigo;
      case '03d':
      case '03n':
        return Colors.grey;
      case '04d':
      case '04n':
        return Colors.blueGrey;
      case '09d':
      case '09n':
        return Colors.lightBlueAccent;
      case '10d':
        return Colors.blue;
      case '10n':
        return Colors.deepPurpleAccent;
      case '11d':
      case '11n':
        return Colors.deepPurple;
      case '13d':
      case '13n':
        return Colors.white;
      case '50d':
      case '50n':
        return Colors.grey.shade600;
      default:
        return Colors.red;
    }
  }
}
