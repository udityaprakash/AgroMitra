import 'dart:convert';
import 'dart:developer';
import 'package:agromitra/functions/autotranslator.dart';
import 'package:agromitra/functions/functionsfornpkvalues.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/loading.dart';
import 'package:agromitra/functions/showsnackbar.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:agromitra/utils/ui/custom-input-field.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GetNPKFromStateGOV extends StatefulWidget {
  final String stateName;
  final String districtName;

  GetNPKFromStateGOV({required this.stateName, required this.districtName});
  @override
  _GetNPKFromStateGOVState createState() => _GetNPKFromStateGOVState();
}

class _GetNPKFromStateGOVState extends State<GetNPKFromStateGOV> {
  // State Variables
  List<dynamic> states = [];
  List<dynamic> districts = [];
  List<dynamic> crops = [];
  List<dynamic> fertilizerRecommendations = [];
  String? selectedStateId;
  String? selectedDistrictId;
  String? selectedCrop;
  var occontroller = TextEditingController();
  var nicontroller = TextEditingController();
  var picontroller = TextEditingController();
  var kicontroller = TextEditingController();
  bool isloading = false;
  bool isDistrictLoading = false;
  bool isCropLoading = false;

  @override
  void initState() {
    super.initState();
    fetchStates();
  }

  Future<void> fetchStates() async {
    setState(() {
      isloading = true;
    });

    try {
      const String query = r"""
      query Query($getStateId: String) {
        getState(id: $getStateId)
      }
      """;

      final Map<String, dynamic> body = {
        "query": query,
      };

      final response =
          await http.post(Uri.parse('https://soilhealth4.dac.gov.in/'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          states = data['data']['getState'];
          final state = states.firstWhere(
              (s) => s['name'].toLowerCase() == widget.stateName.toLowerCase(),
              orElse: () => null);
          if (state == null) {
            if (state == null) {
              throw Exception("State not found");
            }
            selectedStateId = "63f871f5c660ddb223457dca";
            throw Exception("State not found");
          }
          selectedStateId = state['_id'];
        });
      } else {
        throw Exception('Failed to load states');
      }
    } catch (e) {
      print('Error fetching states: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch states: $e")),
      );
    } finally {
      await fetchCrops(selectedStateId!);
      await fetchDistricts(selectedStateId!);
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> fetchDistricts(String stateId) async {
    setState(() {
      isDistrictLoading = true;
      districts = [];
      selectedDistrictId = null;
    });

    try {
      var body = jsonEncode({
        "query": """
        query GetdistrictAndSubdistrictBystate(\$state: ID!, \$subdistrict: Boolean) {
          getdistrictAndSubdistrictBystate(state: \$state, subdistrict: \$subdistrict)
        }
      """,
        "variables": {"state": stateId, "subdistrict": false},
      });

      final districtsUrl = Uri.parse('https://soilhealth4.dac.gov.in/');
      final districtsResponse = await http.post(districtsUrl,
          headers: {'Content-Type': 'application/json'}, body: body);

      if (districtsResponse.statusCode == 200) {
        final districtsData = jsonDecode(districtsResponse.body);
        districts = districtsData['data']['getdistrictAndSubdistrictBystate'];

        if (districts.isEmpty) {
          throw Exception("No District Data found for current state");
        }

        // Find district matching widget's district name
        var matchedDistrict = districts.firstWhere(
            (d) => d['name'].toLowerCase() == widget.districtName.toLowerCase(),
            orElse: () => null);

        // Set selectedDistrictId, preferring matched district or first district
        selectedDistrictId = matchedDistrict?['_id'] ?? districts[0]['_id'];
      } else {
        throw Exception("Failed to fetch districts");
      }
    } catch (e) {
      print("Error fetching districts: $e");

      // Fallback to a default district if possible
      if (districts.isNotEmpty) {
        selectedDistrictId = districts[0]['_id'];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Exact District not found in Government Database showing nearest centers")),
      );
    } finally {
      setState(() {
        isDistrictLoading = false;
      });
      // Ensure crops are fetched for the current state
      await fetchCrops(stateId);
    }
  }

  Future<void> fetchCrops(String stateId) async {
    setState(() {
      isCropLoading = true;
      crops = [];
      selectedCrop = null;
    });

    try {
      const String query = r"""
      query GetCrops($state: String) {
        getCrops(state: $state) {
          id
          name
          GFRavailable
        }
      }
      """;

      final Map<String, dynamic> body = {
        "query": query,
        "variables": {"state": stateId},
      };

      final response = await http.post(
        Uri.parse('https://soilhealth4.dac.gov.in/'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          crops = data['data']['getCrops']
              .where((crop) =>
                  crop['GFRavailable'].toString().toLowerCase() == 'yes')
              .toList();
        });
      } else {
        throw Exception('Failed to load crops');
      }
    } catch (e) {
      print('Error fetching crops: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch crops: $e")),
      );
    } finally {
      setState(() {
        isCropLoading = false;
      });
    }
  }

  Future<void> fetchRecommendations() async {
    const String query = """
      query Query(\$state: ID!, \$crops: [ID!], \$results: JSON!) {
        getRecommendations(state: \$state, crops: \$crops, results: \$results)
      }
    """;

    setState(() {
      fertilizerRecommendations = [];
    });

    if (selectedStateId == null || selectedCrop == null) {
      showSnackbarAutoTranslated(context, 'State and Crop must be selected');
    }

    if (occontroller.text.isEmpty ||
        nicontroller.text.isEmpty ||
        picontroller.text.isEmpty ||
        kicontroller.text.isEmpty) {
      showSnackbarAutoTranslated(
          context, 'One or more Macro Nutrients input fields are empty');
    }

    final Map<String, dynamic> variables = {
      "state": selectedStateId,
      "crops": [selectedCrop],
      "results": {
        "OC": occontroller.text,
        "n": nicontroller.text,
        "p": kicontroller.text,
        "k": picontroller.text
      }
    };

    final response = await http.post(
      Uri.parse('https://soilhealth4.dac.gov.in/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"query": query, "variables": variables}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data']['getRecommendations'][0]['fertilizersdata'] == false) {
        // showSnackbarAutoTranslated(context, 'No Recommendations Available');
        customShowSnackbar(
            context, AppLocalizations.of(context)!.noRecommendationsAvailable);
      } else {
        fertilizerRecommendations = data['data']['getRecommendations'];
      }
      log(fertilizerRecommendations.toString());
    } else {
      customShowSnackbar(
          context, AppLocalizations.of(context)!.somethingWentWrong);
    }
  }

  Future<void> fetchNutrientDashboard() async {
    try {
      final query = r"""query GetNutrientDashboardForPortal($state: ID, $district: ID,$block: ID, $village: ID, $cycle: String, $count: Boolean) {\n        getNutrientDashboardForPortal(state: $state, district: $district, village: $village, block: $block, cycle: $cycle, count: $count)\n      }""";


      final response = await http.post(
        Uri.parse('https://soilhealth4.dac.gov.in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "query": query,
          "variables": {
            "count": true,
            "cycle": "2024-25",
            "district": selectedDistrictId,
            "state": selectedStateId
          }
        }),
      );
    // log(await response.toString());

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log(response.statusCode.toString());

        // Assign values to controllers
        setState(() {
          assignNutrientControllerValues(jsonResponse);
        });
      }
    } catch (e) {
      log('Error fetching nutrient dashboard: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch nutrient data')),
      );
    }
  }

  void assignNutrientControllerValues(Map<String, dynamic> response) {
    try {
      // Check if the response has the expected structure
      if (response['data'] != null &&
          response['data']['getNutrientDashboardForPortal'] != null &&
          response['data']['getNutrientDashboardForPortal'].isNotEmpty) {
        // Get the first (and likely only) item in the list
        var nutrientData = response['data']['getNutrientDashboardForPortal'][0];

        // Check if results exist
        if (nutrientData['results'] != null) {
          var results = nutrientData['results'];
          log(results.toString());

          // Assign Nitrogen (N)
          if (results['n'] != null) {
            int lowN = results['n']['Low'] ?? 0;
            int mediumN = results['n']['Medium'] ?? 0;
            int highN = results['n']['High'] ?? 0;
            nicontroller.text = getnvalue(lowN, mediumN, highN).toString();
          }

          // Assign Phosphorus (P)
          if (results['p'] != null) {
            int lowP = results['p']['Low'] ?? 0;
            int mediumP = results['p']['Medium'] ?? 0;
            int highP = results['p']['High'] ?? 0;
            picontroller.text = getpvalue(lowP, mediumP, highP).toString();
          }

          // Assign Potassium (K)
          if (results['k'] != null) {
            int lowK = results['k']['Low'] ?? 0;
            int mediumK = results['k']['Medium'] ?? 0;
            int highK = results['k']['High'] ?? 0;
            kicontroller.text = getkvalue(lowK, mediumK, highK).toString();
          }

          // Assign Organic Carbon (OC)
          if (results['OC'] != null) {
            int lowOC = results['OC']['Low'] ?? 0;
            int mediumOC = results['OC']['Medium'] ?? 0;
            int highOC = results['OC']['High'] ?? 0;
            occontroller.text = getocvalue(lowOC, mediumOC, highOC).toString();
          }
        }
      }
    } catch (e) {
      print('Error assigning nutrient controller values: $e');
      // Optionally show a snackbar or handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to parse nutrient data')),
      );
    }
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
            backgroundColor: AppColors.primary,
            title: CustomTextWidget(
              text: AppLocalizations.of(context)!.fertilizerCalculator,
              textColor: AppColors.white,
              fontSize: 20,
            )),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            // State Dropdown
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      hint: CustomTextWidget(
                        text: AppLocalizations.of(context)!.selectState,
                        textColor: AppColors.textHint,
                        fontSize: 20,
                      ),
                      style: customTextStyle(
                          color: AppColors.textPrimary, size: 20),
                      borderRadius: BorderRadius.circular(8),
                      value: selectedStateId,
                      isExpanded: true,
                      items: states.map((state) {
                        return DropdownMenuItem<String>(
                          value: state['_id'],
                          child: CustomTextWidget(
                              text: state['name'].toString(),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              textColor: AppColors.textPrimary),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() {
                          selectedStateId = value;
                          districts = [];
                          crops = [];
                          selectedDistrictId = null;
                          selectedCrop = null;
                        });
                        if (value != null) {
                          await fetchDistricts(value);
                        }
                        // Call the function if all dropdowns have selected values
                        if (selectedStateId != null &&
                            selectedDistrictId != null &&
                            selectedCrop != null) {
                          await fetchNutrientDashboard();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      hint: CustomTextWidget(
                        text: "Select District",
                        textColor: AppColors.textHint,
                        fontSize: 20,
                      ),
                      style: customTextStyle(
                          color: AppColors.textPrimary, size: 20),
                      borderRadius: BorderRadius.circular(8),
                      value: selectedDistrictId,
                      isExpanded: true,
                      items: districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['_id'],
                          child: CustomTextWidget(
                              text: district['name'].toString(),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              textColor: AppColors.textPrimary),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() {
                          selectedDistrictId = value;
                          crops = [];
                          selectedCrop = null;
                        });
                        if (value != null && selectedStateId != null) {
                          await fetchCrops(selectedStateId!);
                        }
                        // Call the function if all dropdowns have selected values
                        if (selectedStateId != null &&
                            selectedDistrictId != null &&
                            selectedCrop != null) {
                          await fetchNutrientDashboard();
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Crop Dropdown
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: CustomTextWidget(
                        text: AppLocalizations.of(context)!.selectCrop,
                        textColor: AppColors.textHint,
                        fontSize: 20,
                      ),
                      style: customTextStyle(
                          color: AppColors.textPrimary, size: 20),
                      value: selectedCrop,
                      items: crops.map((crop) {
                        return DropdownMenuItem<String>(
                          value: crop['id'],
                          child: CustomTextWidget(
                              text: crop['name'],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              textColor: AppColors.textPrimary),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() {
                          selectedCrop = value;
                        });
                        // Call the function if all dropdowns have selected values
                        if (selectedStateId != null &&
                            selectedDistrictId != null &&
                            selectedCrop != null) {
                        // log("here it is"+selectedCrop.toString()+" "+selectedStateId.toString()+" "+selectedDistrictId.toString());
                          await fetchNutrientDashboard();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                      text: AppLocalizations.of(context)!.soilParameters,
                      fontSize: 20,
                      isBold: true,
                      textColor: AppColors.textPrimary),
                  SizedBox(height: 16),
                  // Organic Carbon
                  CustomTextField(
                      hintText: AppLocalizations.of(context)!.organicCarbon,
                      controller: occontroller),

                  SizedBox(height: 16),
                  // Nitrogen
                  CustomTextField(
                      hintText: AppLocalizations.of(context)!.nitrogenKgHa,
                      controller: nicontroller),
                  SizedBox(height: 16),
                  // Phosphorus
                  CustomTextField(
                      hintText: AppLocalizations.of(context)!.phosphorusKgHa,
                      controller: picontroller),
                  SizedBox(height: 16),
                  // Potassium
                  CustomTextField(
                      hintText: AppLocalizations.of(context)!.phosphorusKgHa,
                      controller: kicontroller),
                  SizedBox(height: 24),
                  // Calculate Button
                  SizedBox(
                      width: double.infinity,
                      child: !isloading
                          ? CustomButton(
                              backgroundColor: AppColors.primary,
                              textColor: AppColors.white,
                              text: AppLocalizations.of(context)!
                                  .getRecommendations,
                              onPressed: () async {
                                isloading = true;
                                setState(() {});
                                await fetchRecommendations();
                                isloading = false;
                                setState(() {});
                              })
                          : loading()),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              // color: AppColors.white,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.0),
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Row(
                    children: [
                      CustomTextWidget(
                          text: AppLocalizations.of(context)!
                              .organicRecommendations,
                          textColor: AppColors.textPrimary,
                          fontSize: 18,
                          isBold: true),
                    ],
                  ),
                  SizedBox(height: 16),
                  Card(
                    color: AppColors.newbackground,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Misthaufen16.JPG/340px-Misthaufen16.JPG',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextWidget(
                                    text: AppLocalizations.of(context)!
                                        .farmyardManure,
                                    textColor: AppColors.textPrimary,
                                    fontSize: 15,
                                    isBold: true),
                                SizedBox(height: 4),
                                CustomTextWidget(
                                  text: AppLocalizations.of(context)!
                                      .applicationRate5To6,
                                  textColor: AppColors.textPrimary,
                                  fontSize: 14,
                                  overflow: TextOverflow.clip,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    color: AppColors.newbackground,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                'https://t3.ftcdn.net/jpg/09/01/48/68/240_F_901486804_PwR6feYQbndkwf3jAfwfikVDBZL2IeXK.webp',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextWidget(
                                    text: AppLocalizations.of(context)!
                                        .vermicompost,
                                    textColor: AppColors.textPrimary,
                                    fontSize: 15,
                                    isBold: true),
                                SizedBox(height: 4),
                                CustomTextWidget(
                                  text: AppLocalizations.of(context)!
                                      .applicationRate25,
                                  textColor: AppColors.textPrimary,
                                  fontSize: 14,
                                  overflow: TextOverflow.clip,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 16),

            (fertilizerRecommendations.isNotEmpty &&
                    fertilizerRecommendations[0]['fertilizersdata'] != null &&
                    fertilizerRecommendations[0]['fertilizersdata'].isNotEmpty)
                ? Container(
                    // height: 330,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          text: AppLocalizations.of(context)!
                              .chemicalRecommendations,
                          fontSize: 20,
                          isBold: true,
                          textColor: AppColors.textPrimary,
                        ),
                        SizedBox(height: 16),
                        Container(
                          child: (fertilizerRecommendations.isNotEmpty &&
                                  fertilizerRecommendations[0]
                                          ['fertilizersdata'] !=
                                      null &&
                                  fertilizerRecommendations[0]
                                          ['fertilizersdata']
                                      .isNotEmpty)
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: fertilizerRecommendations[0]
                                          ['fertilizersdata']
                                      .length,
                                  itemBuilder: (context, index) {
                                    final recommendation =
                                        fertilizerRecommendations[0]
                                            ['fertilizersdata'][index];
                                    return Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CustomTextWidget(
                                                      text: recommendation[
                                                              'name'] ??
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .unknown,
                                                      textColor:
                                                          AppColors.textPrimary,
                                                      fontSize: 16,
                                                      isBold: true),
                                                  SizedBox(height: 4),
                                                  CustomTextWidget(
                                                      text:
                                                          '${AppLocalizations.of(context)!.applicationRate} ${recommendation['values']} ${recommendation['unit']}',
                                                      textColor:
                                                          AppColors.textPrimary,
                                                      overflow:
                                                          TextOverflow.clip,
                                                      fontSize: 14),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: CustomTextWidget(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .recommended,
                                                  textColor: Colors.green,
                                                  fontSize: 12,
                                                  isBold: true),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: CustomTextWidget(
                                      text: AppLocalizations.of(context)!
                                          .noRecommendationsAvailable,
                                      textColor: AppColors.error),
                                ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomTextWidget(
                                text: AppLocalizations.of(context)!.or,
                                fontSize: 20,
                                isBold: true,
                                textColor: AppColors.textPrimary,
                              ),
                              SizedBox(height: 16),
                              Container(
                                child: (fertilizerRecommendations.isNotEmpty &&
                                        fertilizerRecommendations[0]
                                                ['fertilizersdata'] !=
                                            null &&
                                        fertilizerRecommendations[0]
                                                ['fertilizersdata']
                                            .isNotEmpty)
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: fertilizerRecommendations[0]
                                                ['fertilizersdata']
                                            .length,
                                        itemBuilder: (context, index) {
                                          final recommendation =
                                              fertilizerRecommendations[0]
                                                      ['fertilizersdatacombTwo']
                                                  [index];
                                          return Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        CustomTextWidget(
                                                            text: recommendation[
                                                                    'name'] ??
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .unknown,
                                                            textColor: AppColors
                                                                .textPrimary,
                                                            fontSize: 16,
                                                            isBold: true),
                                                        SizedBox(height: 4),
                                                        CustomTextWidget(
                                                            text:
                                                                '${AppLocalizations.of(context)!.applicationRate} ${recommendation['values']} ${recommendation['unit']}',
                                                            textColor: AppColors
                                                                .textPrimary,
                                                            overflow:
                                                                TextOverflow
                                                                    .clip,
                                                            fontSize: 14),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: CustomTextWidget(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .alternate,
                                                        textColor: Colors.green,
                                                        fontSize: 12,
                                                        isBold: true),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: CustomTextWidget(
                                            text: AppLocalizations.of(context)!
                                                .noRecommendationsAvailable,
                                            textColor: AppColors.error),
                                      ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : CustomTextWidget(
                    text: AppLocalizations.of(context)!
                        .noRecommendationsAvailable,
                    textColor: AppColors.error),
          ]),
        )));
  }
}
