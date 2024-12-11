import 'dart:convert';
import 'dart:developer';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/loading.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class FetchIdsAndCenters extends StatefulWidget {
  final String stateName;
  final String districtName;

  FetchIdsAndCenters({required this.stateName, required this.districtName});

  @override
  _FetchIdsAndCentersState createState() => _FetchIdsAndCentersState();
}

class _FetchIdsAndCentersState extends State<FetchIdsAndCenters> {
  String? stateId;
  String? districtId;
  bool isLoading = false;
  List testCenters = [];
  double latitude = 78.07956579140655; // Default Latitude
  double longitude = 17.59572682812818; // Default Longitude

  @override
  void initState() {
    super.initState();
    fetchStateAndDistrictId();
  }

  Future<void> fetchStateAndDistrictId() async {
    setState(() {
      isLoading = true;
    });

    var stateBody = jsonEncode({
      "query": """
    query GetState(\$getStateId: String) {
      getState(id: \$getStateId)
    }
  """,
      "variables": {"countryCode": "IN"}
    });

    try {
      // Step 1: Fetch State ID
      final statesUrl = Uri.parse('https://soilhealth4.dac.gov.in/');
      final statesResponse = await http.post(statesUrl,
          headers: {
            'Content-Type': 'application/json',
          },
          body: stateBody);
      if (statesResponse.statusCode == 200) {
        final statesData = jsonDecode(statesResponse.body);
        final states = statesData['data']['getState'] as List;
        final state = states.firstWhere(
            (s) => s['name'].toLowerCase() == widget.stateName.toLowerCase(),
            orElse: () => null);
        if (state == null) {
          throw Exception("State not found");
        }
        stateId = state['_id'];
      } else {
        throw Exception("Failed to fetch states");
      }

      var body = jsonEncode({
        "query": """
          query GetdistrictAndSubdistrictBystate(\$state: ID!, \$subdistrict: Boolean) {
            getdistrictAndSubdistrictBystate(state: \$state, subdistrict: \$subdistrict)
          }
        """,
        "variables": {
          "countryCode": "IN",
          "state": stateId,
        },
      });

      // Step 2: Fetch District ID
      final districtsUrl = Uri.parse('https://soilhealth4.dac.gov.in/');
      final districtsResponse = await http.post(districtsUrl,
          headers: {'Content-Type': 'application/json'}, body: body);

      if (districtsResponse.statusCode == 200) {
        final districtsData = jsonDecode(districtsResponse.body);
        final districts =
            districtsData['data']['getdistrictAndSubdistrictBystate'] as List;
        final district = districts.firstWhere(
            (d) => d['name'].toLowerCase() == widget.districtName.toLowerCase(),
            orElse: () => null);
        if (district == null) {
          throw Exception("District not found in Government Database showing nearest centers");
        }
        districtId = district['_id'];
        // districtId = "63f874fac660ddb22345c5ce";
      } else {
        throw Exception("Failed to fetch districts");
      }

      await fetchTestCenters();
    } catch (e) {
      districtId = "63f874fac660ddb22345c5ce";
      await fetchTestCenters();
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchTestCenters() async {
    final centersUrl = Uri.parse('https://soilhealth4.dac.gov.in/');
    final centersResponse = await http.post(centersUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "query": """
            \n          query GetTestCenters(\$state: String, \$district: String) {\n            getTestCenters(state: \$state, district: \$district) {\n              id\n              name\n              region\n              timing\n              STLdetails {\n                phone\n              }\n              address\n              authenticatedUser\n              createdAt\n              updatedAt\n              email\n            }\n          }\n        
          """,
          "variables": {"state": stateId, "district": districtId}
        }));

    if (centersResponse.statusCode == 200) {
      final centersData = jsonDecode(centersResponse.body);
      setState(() {
        testCenters = centersData['data']['getTestCenters'] ?? [];
        // log(testCenters.toString());
      });
    } else {
      throw Exception("Failed to fetch test centers");
    }
  }

  void updateLatLng(double lat, double lon) {
    latitude = lat;
    longitude = lon;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbackground,
      appBar: AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
        title: CustomTextWidget(text: 'Agri Labs', textColor: AppColors.white, fontSize: 20,),
        backgroundColor: AppColors.primary,
        ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : testCenters.isEmpty
              ? Center(child: Text("No test centers found"))
              : Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 1,
                      color: Colors.grey.shade200,
                      child: GestureDetector(
                        onTap: () {
                          // Example of changing Lat/Lon on tap
                          updateLatLng(25.0, 81.0);
                        },
                        child: Center(
                          child: FlutterLocationPicker(onPicked: (location) {
                            updateLatLng(latitude, longitude);
                          },
                          // initialLatitude: latitude,
                          // initialLongitude: longitude,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8,
                                color: Colors.black26,
                                offset: Offset(0, -2),
                              )
                            ],
                          ),
                          child: ListView.builder(
                            itemCount: testCenters.length,
                            itemBuilder: (context, index) {
                              final center = testCenters[index];
                              return ListTile(
                                
                                onTap: () {
                                  // Example of changing Lat/Lon on tap
                                  double lat = double.tryParse(center['region']['geolocation']['coordinates'][0].toString()) ?? 0.0;
                                  double lng = double.tryParse(center['region']['geolocation']['coordinates'][1].toString()) ?? 0.0;
                                  log(center['region']['geolocation']
                                          ['coordinates'][0].toString()+" "+
                                      center['region']['geolocation']
                                          ['coordinates'][1].toString());
                                  updateLatLng(lat, lng);
                                  },
                                title: Text(center['name']),
                                subtitle: Text(
                                    center['address']?? "N/A"),
                                trailing: InkWell(child: Icon(Icons.call), onTap: () async {
                                  final Uri dialUrl = Uri(scheme: 'tel', path: center['STLdetails']['phone']);
                                  if (await canLaunch(dialUrl.toString())) {
                                    await launch(dialUrl.toString());
                                  } else {
                                    // If the dialer can't be launched, show an error
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Could not launch dialer")),
                                    );
                                  }
                                },),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
