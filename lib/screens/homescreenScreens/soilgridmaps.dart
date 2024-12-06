import 'dart:convert';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/loading.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class SoilGridMap extends StatefulWidget {
  final double lat;
  final double lon;
  final String lang;

  const SoilGridMap({required this.lat, required this.lon, required this.lang, Key? key})
      : super(key: key);

  @override
  _SoilGridMapState createState() => _SoilGridMapState();
}

class _SoilGridMapState extends State<SoilGridMap> {
  late Future<Map<String, dynamic>> _soilData;

  // Function to fetch soil data from API
  Future<Map<String, dynamic>> fetchSoilData(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('https://dev-rest.isric.org/soilgrids/v2.0/properties/query?lon=${lon}&lat=${lat}&property=cec&property=nitrogen&property=phh2o&property=soc&value=mean&value=Q0.05&value=Q0.95#'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load soil data');
    }
  }

  // Function to show bottom sheet with soil details
  void _showSoilGridDetails(BuildContext context, double latitude, double longitude) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,  // Ensures the content can scroll
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (BuildContext context) {
        return SoilGridDetailsSheet(latitude: latitude, longitude: longitude, soilData: fetchSoilData(latitude, longitude));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _soilData = fetchSoilData(widget.lat, widget.lon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbackground,
      appBar: AppBar(
        shadowColor: AppColors.cardShadow,
        elevation: 10,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CustomTextWidget(
          text: AppLocalizations.of(context)!.soil_grid,
          textColor: Colors.white,
          fontSize: 20.0,
          isBold: true,
        ),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _soilData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: loading());
          } else if (snapshot.hasError) {
            return Center(child: CustomTextWidget(
              text: AppLocalizations.of(context)!.somethingWentWrong,
              textColor: Colors.red,
              fontSize: 16.0,
              isBold: true,
            ));
          } else if (!snapshot.hasData) {
            return Center(child: CustomTextWidget(
              text: AppLocalizations.of(context)!.no_data,
              textColor: Colors.grey,
              fontSize: 16.0,
              isBold: true,
            ));
          }

          return FlutterLocationPicker(
            initPosition: LatLong(widget.lat, widget.lon),
            initZoom: 11,
            minZoomLevel: 5,
            maxZoomLevel: 16,
            trackMyPosition: false,
            mapLanguage: widget.lang,
            selectLocationButtonText: AppLocalizations.of(context)!.get_soil_details,
            selectLocationButtonStyle: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.primary),
            ),
            selectedLocationButtonTextStyle: TextStyle(
              fontFamily: 'Parkinsans',
              color: AppColors.white,
              fontSize: 16,
            ),
            selectLocationButtonLeadingIcon: const Icon(
              Icons.grid_3x3,
              color: AppColors.warning,
            ),
            onPicked: (pickedData) {
              _showSoilGridDetails(context, pickedData.latLong.latitude, pickedData.latLong.longitude);
            },
            onChanged: (pickedData) {
              print("Marker moved to Latitude: ${pickedData.latLong.latitude}");
              print("Marker moved to Longitude: ${pickedData.latLong.longitude}");
            },
            onError: (error) {
              print("Error: $error");
            },
          );
        },
      ),
    );
  }
}

class SoilGridDetailsSheet extends StatelessWidget {
  final double latitude;
  final double longitude;
  final Future<Map<String, dynamic>> soilData;

  const SoilGridDetailsSheet({required this.latitude, required this.longitude, required this.soilData, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: soilData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: loading());
        } else if (snapshot.hasError) {
          return Center(child: CustomTextWidget(
            text: AppLocalizations.of(context)!.somethingWentWrong,
            textColor: Colors.red,
            fontSize: 16.0,
            isBold: true,
          ));
        } else if (!snapshot.hasData) {
          return Center(child: CustomTextWidget(
            text: AppLocalizations.of(context)!.no_data,
            textColor: Colors.grey,
            fontSize: 16.0,
            isBold: true,
          ));
        }

        // Extracting soil nitrogen and pH data
        var nitrogenData = snapshot.data?['properties']['layers']
            .firstWhere((layer) => layer['name'] == 'nitrogen')['depths'];
        var phData = snapshot.data?['properties']['layers']
            .firstWhere((layer) => layer['name'] == 'phh2o')['depths'];
        var socData = snapshot.data?['properties']['layers']
            ?.firstWhere((layer) => layer['name'] == 'soc')['depths'];    

        return SingleChildScrollView(  // Added for scrolling the content
          child: Container(
            padding: EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  text: AppLocalizations.of(context)!.soil_grid_details,
                  textColor: Colors.black,
                  fontSize: 18.0,
                  isBold: true,
                ),
                SizedBox(height: 10),
                CustomTextWidget(
                  text: AppLocalizations.of(context)!.latitude +'$latitude',
                  textColor: Colors.black,
                  fontSize: 16.0,
                ),
                CustomTextWidget(
                  text: AppLocalizations.of(context)!.longitude+'$longitude',
                  textColor: Colors.black,
                  fontSize: 16.0,
                ),
                SizedBox(height: 20),
                CustomTextWidget(
                  text: AppLocalizations.of(context)!.nitrogen_levels,
                  textColor: Colors.black,
                  fontSize: 16.0,
                  isBold: true,
                ),
                ...nitrogenData.map((depth) {
                  return CustomTextWidget(
                    text: '${depth['label']}: '+AppLocalizations.of(context)!.mean+': ${depth['values']['mean']}',
                    textColor: Colors.black,
                    fontSize: 14.0,
                  );
                }).toList(),
                SizedBox(height: 20),
                CustomTextWidget(
                  text: AppLocalizations.of(context)!.ph_levels,
                  textColor: Colors.black,
                  fontSize: 16.0,
                  isBold: true,
                ),
                ...phData.map((depth) {
                  return CustomTextWidget(
                    text: '${depth['label']}: '+AppLocalizations.of(context)!.mean+': ${depth['values']['mean'] / 10}',
                    textColor: Colors.black,
                    fontSize: 14.0,
                  );
                }).toList(),
                SizedBox(height: 20),
                CustomTextWidget(
                  text: AppLocalizations.of(context)!.soc_levels,
                  textColor: Colors.black,
                  fontSize: 16.0,
                  isBold: true,
                ),
                ...socData.map((depth) {
                  return CustomTextWidget(
                    text: '${depth['label']}: '+AppLocalizations.of(context)!.mean+': ${depth['values']['mean']}',
                    textColor: Colors.black,
                    fontSize: 14.0,
                  );
                }).toList(),
                SizedBox(height: 20),
                CustomButton(
                  text: AppLocalizations.of(context)!.close,
                  textColor: AppColors.white,
                  backgroundColor: AppColors.primary,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  // child: CustomTextWidget(
                  //   text: AppLocalizations.of(context)!.close,
                  //   textColor: AppColors.white,
                  //   fontSize: 16.0,
                  // ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
