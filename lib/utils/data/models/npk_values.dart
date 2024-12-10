import 'dart:convert';
import 'package:agromitra/utils/data/urls.dart';
import 'package:http/http.dart' as http;

class SoilData {
  final double kValue;
  final double nValue;
  final double pValue;
  final double phValue;
  final String soilType;
  final bool success;

  SoilData({
    required this.kValue,
    required this.nValue,
    required this.pValue,
    required this.phValue,
    required this.soilType,
    required this.success,
  });

  // Factory method to create an instance from JSON response
  factory SoilData.fromJson(Map<String, dynamic> json) {
    return SoilData(
      kValue: json['k_value'] as double,
      nValue: json['n_value'] as double,
      pValue: json['p_value'] as double,
      phValue: json['ph_value'] as double,
      soilType: json['soil_type'] as String,
      success: json['success'] as bool,
    );
  }
}

class SoilDataService {
  // Base URL for the API
  static const String apiUrl = UrlProvider.getNPKValuesUrl;

  // Method to fetch soil data
  Future<SoilData> fetchSoilData(List<String> imageUrls) async {
    final Map<String, dynamic> body = {
      'image_urls': imageUrls,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      return SoilData.fromJson(data);
      
    } catch (e) {
      throw Exception('Error fetching soil data: $e');
    }
  }
}
