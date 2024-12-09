import 'dart:convert';
import 'dart:developer';
import 'package:agromitra/functions/autotranslator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/loading.dart';
import 'package:agromitra/functions/showsnackbar.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:agromitra/utils/ui/custom-input-field.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StateAndCropSelector extends StatefulWidget {
  @override
  _StateAndCropSelectorState createState() => _StateAndCropSelectorState();
}

class _StateAndCropSelectorState extends State<StateAndCropSelector> {
  // State Variables
  List<dynamic> states = [];
  List<dynamic> crops = [];
  List<dynamic> fertilizerRecommendations = [];
  String? selectedStateId;
  String? selectedCrop;
  var occontroller = TextEditingController();
  var nicontroller = TextEditingController();
  var picontroller = TextEditingController();
  var kicontroller = TextEditingController();
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    fetchStates();
  }

  // Fetch states from backend
  Future<void> fetchStates() async {
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
        });
      } else {
        throw Exception('Failed to load states');
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  // Fetch crops based on selected state
  Future<void> fetchCrops(String stateId) async {
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
        log(data['data']['getCrops'].toString());
        setState(() {
          crops = data['data']['getCrops']
              .where((crop) =>
                  crop['GFRavailable'].toString().toLowerCase() == 'yes')
              .toList();
          selectedCrop = null;
        });
      } else {
        throw Exception('Failed to load crops');
      }
    } catch (e) {
      print('Error fetching crops: $e');
    }
  }

  Future<void> fetchRecommendations() async {
    const String query = """
      query Query(\$state: ID!, \$crops: [ID!], \$results: JSON!) {
        getRecommendations(state: \$state, crops: \$crops, results: \$results)
      }
    """;

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
      if(data['data']['getRecommendations'][0]['fertilizersdata'] == false ){
        showSnackbarAutoTranslated(context, 'No Recommendations Available');
      }else{

        fertilizerRecommendations = data['data']['getRecommendations'];
      }
      log(fertilizerRecommendations.toString());
    } else {
      showSnackbarAutoTranslated(context, 'Failed to load recommendations');
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
                          child: AutoTranslator().buildTranslatedText(context, state['name'],
                          fontSize: 18, fontWeight: FontWeight.w500,
                              textColor: AppColors.textPrimary ),
                          // child: CustomTextWidget(
                          //   text: AutoTranslator().buildTranslatedText(context, state['name']),
                          //     // text: state['name'],
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.w500,
                          //     textColor: AppColors.textPrimary),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStateId = value;
                          crops = [];
                        });
                        if (value != null) {
                          fetchCrops(value);
                        }
                      },
                      // decoration: InputDecoration(
                      //   labelText: 'Select State',
                      //   border: OutlineInputBorder(),
                      // ),
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
                      onChanged: (value) {
                        setState(() {
                          selectedCrop = value;
                        });
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
                      text: 'Soil Parameters',
                      fontSize: 20,
                      isBold: true,
                      textColor: AppColors.textPrimary),
                  SizedBox(height: 16),
                  // Organic Carbon
                  CustomTextField(
                      hintText: 'Organic Carbon (%)', controller: occontroller),
                  // TextField(
                  //   decoration: InputDecoration(
                  //     labelText: 'Organic Carbon (%)',
                  //     suffixIcon: Icon(
                  //       Icons.info_outline,
                  //       color: Colors.blue,
                  //     ),
                  //     border: OutlineInputBorder(),
                  //   ),
                  //   keyboardType: TextInputType.number,
                  // ),
                  SizedBox(height: 16),
                  // Nitrogen
                  CustomTextField(
                      hintText: 'Nitrogen (N) Kg/ha', controller: nicontroller),
                  // TextField(
                  //   decoration: InputDecoration(
                  //     labelText: 'Nitrogen (N) Kg/ha',
                  //     border: OutlineInputBorder(),
                  //   ),
                  //   keyboardType: TextInputType.number,
                  // ),
                  SizedBox(height: 16),
                  // Phosphorus
                  CustomTextField(
                      hintText: 'Phosphorus (P) Kg/ha',
                      controller: picontroller),
                  // TextField(
                  //   decoration: InputDecoration(
                  //     labelText: 'Phosphorus (P) Kg/ha',
                  //     border: OutlineInputBorder(),
                  //   ),
                  //   keyboardType: TextInputType.number,
                  // ),
                  SizedBox(height: 16),
                  // Potassium
                  CustomTextField(
                      hintText: 'Potassium (K) Kg/ha',
                      controller: kicontroller),
                  // TextField(
                  //   decoration: InputDecoration(
                  //     labelText: 'Potassium (K) Kg/ha',
                  //     border: OutlineInputBorder(),
                  //   ),
                  //   keyboardType: TextInputType.number,
                  // ),
                  SizedBox(height: 24),
                  // Calculate Button
                  SizedBox(
                      width: double.infinity,
                      child: !isloading ? CustomButton(
                          backgroundColor: AppColors.primary,
                          textColor: AppColors.white,
                          text: 'Get Recommendations',
                          onPressed: () async {
                            isloading = true;
                            setState(() {});
                            await fetchRecommendations();
                            isloading = false;
                            setState(() {});
                          }): loading()
                          ) ,
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
              // child: DefaultTabController(
              //   length: 2,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       TabBar(
              //         indicatorColor: Colors.black,
              //         labelColor: Colors.black,
              //         unselectedLabelColor: Colors.grey,
              //         tabs: [
              //           Tab(text: 'Organic'),
              //           Tab(text: 'Chemical'),
              //         ],
              //       ),
              //       SizedBox(height: 16),
              //       Expanded(
              //         child: TabBarView(
              //           physics:
              //               BouncingScrollPhysics(), // For swipe transition effect
              //           children: [
              //             // Organic Tab Content
              //             ListView(
              //               children: [
              //                 // First Organic Item
              //                 Card(
              //                   elevation: 2,
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(8),
              //                   ),
              //                   child: Padding(
              //                     padding: const EdgeInsets.all(16.0),
              //                     child: Row(
              //                       children: [
              //                         ClipRRect(
              //                           borderRadius:
              //                               BorderRadius.circular(8),
              //                           child: Image.network(
              //                             'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Misthaufen16.JPG/340px-Misthaufen16.JPG',
              //                             width: 60,
              //                             height: 60,
              //                             fit: BoxFit.cover,
              //                           ),
              //                         ),
              //                         SizedBox(width: 16),
              //                         Expanded(
              //                           child: Column(
              //                             crossAxisAlignment:
              //                                 CrossAxisAlignment.start,
              //                             children: [
              //                               Text(
              //                                 'Farmyard Manure',
              //                                 style: TextStyle(
              //                                   fontSize: 16,
              //                                   fontWeight: FontWeight.bold,
              //                                 ),
              //                               ),
              //                               SizedBox(height: 4),
              //                               Text(
              //                                 'Application Rate: 5-6 tons/hectare\nEstimated Cost: \$120-150/ton',
              //                                 style: TextStyle(
              //                                     fontSize: 14,
              //                                     color: Colors.grey[700]),
              //                               ),
              //                             ],
              //                           ),
              //                         ),
              //                         Container(
              //                           padding: EdgeInsets.symmetric(
              //                               horizontal: 8, vertical: 4),
              //                           decoration: BoxDecoration(
              //                             color: Colors.green[100],
              //                             borderRadius:
              //                                 BorderRadius.circular(12),
              //                           ),
              //                           child: Text(
              //                             'Recommended',
              //                             style: TextStyle(
              //                               color: Colors.green[800],
              //                               fontWeight: FontWeight.bold,
              //                               fontSize: 12,
              //                             ),
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ),
              //                 SizedBox(height: 16),
              //                 // Second Organic Item
              //                 Card(
              //                   elevation: 2,
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(8),
              //                   ),
              //                   child: Padding(
              //                     padding: const EdgeInsets.all(16.0),
              //                     child: Row(
              //                       children: [
              //                         ClipRRect(
              //                           borderRadius:
              //                               BorderRadius.circular(8),
              //                           child: Image.network(
              //                             'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Misthaufen16.JPG/340px-Misthaufen16.JPG',
              //                             width: 60,
              //                             height: 60,
              //                             fit: BoxFit.cover,
              //                           ),
              //                         ),
              //                         SizedBox(width: 16),
              //                         Expanded(
              //                           child: Column(
              //                             crossAxisAlignment:
              //                                 CrossAxisAlignment.start,
              //                             children: [
              //                               Text(
              //                                 'Vermicompost',
              //                                 style: TextStyle(
              //                                   fontSize: 16,
              //                                   fontWeight: FontWeight.bold,
              //                                 ),
              //                               ),
              //                               SizedBox(height: 4),
              //                               Text(
              //                                 'Application Rate: 2.5 tons/hectare\nEstimated Cost: \$200-250/ton',
              //                                 style: TextStyle(
              //                                     fontSize: 14,
              //                                     color: Colors.grey[700]),
              //                               ),
              //                             ],
              //                           ),
              //                         ),
              //                         Container(
              //                           padding: EdgeInsets.symmetric(
              //                               horizontal: 8, vertical: 4),
              //                           decoration: BoxDecoration(
              //                             color: Colors.yellow[100],
              //                             borderRadius:
              //                                 BorderRadius.circular(12),
              //                           ),
              //                           child: Text(
              //                             'Alternative',
              //                             style: TextStyle(
              //                               color: Colors.orange[800],
              //                               fontWeight: FontWeight.bold,
              //                               fontSize: 12,
              //                             ),
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //             // Chemical Tab Content
              //             ListView.builder(
              //               itemBuilder: (context, index) {
              //                 final recommendation =
              //                     fertilizerRecommendations[index];
              //                 return Card(
              //                   elevation: 2,
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(8),
              //                   ),
              //                   child: Padding(
              //                     padding: const EdgeInsets.all(16.0),
              //                     child: Row(
              //                       children: [
              //                         ClipRRect(
              //                           borderRadius:
              //                               BorderRadius.circular(8),
              //                           child: Image.network(
              //                             'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Misthaufen16.JPG/340px-Misthaufen16.JPG',
              //                             width: 60,
              //                             height: 60,
              //                             fit: BoxFit.cover,
              //                           ),
              //                         ),
              //                         SizedBox(width: 16),
              //                         Expanded(
              //                           child: Column(
              //                             crossAxisAlignment:
              //                                 CrossAxisAlignment.start,
              //                             children: [
              //                               Text(
              //                                 recommendation['name'],
              //                                 style: TextStyle(
              //                                   fontSize: 16,
              //                                   fontWeight: FontWeight.bold,
              //                                 ),
              //                               ),
              //                               SizedBox(height: 4),
              //                               Text(
              //                                 'Application Rate: ${recommendation['rate']} Kg/hectare\nEstimated Cost: \$${recommendation['cost']}',
              //                                 style: TextStyle(
              //                                     fontSize: 14,
              //                                     color: Colors.grey[700]),
              //                               ),
              //                             ],
              //                           ),
              //                         ),
              //                         Container(
              //                           padding: EdgeInsets.symmetric(
              //                               horizontal: 8, vertical: 4),
              //                           decoration: BoxDecoration(
              //                             color: Colors.green[100],
              //                             borderRadius:
              //                                 BorderRadius.circular(12),
              //                           ),
              //                           child: Text(
              //                             'Recommended',
              //                             style: TextStyle(
              //                               color: Colors.green[800],
              //                               fontWeight: FontWeight.bold,
              //                               fontSize: 12,
              //                             ),
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 );
              //               },
              //               itemCount: fertilizerRecommendations.length
              //               ),

              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Row(
                    children: [
                      CustomTextWidget(
                          text: 'Organic Recommendations',
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
                                    text: 'Farmyard Manure',
                                    textColor: AppColors.textPrimary,
                                    fontSize: 15,
                                    isBold: true),
                                SizedBox(height: 4),
                                CustomTextWidget(
                                  text: 'Application rate: 5-6tons/ha',
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
                                    text: 'Vermicompost',
                                    textColor: AppColors.textPrimary,
                                    fontSize: 15,
                                    isBold: true),
                                SizedBox(height: 4),
                                CustomTextWidget(
                                  text: 'Application Rate: 2.5 tons/ha',
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
            Container(
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
                    text: 'Chemical Recommendations',
                    fontSize: 20,
                    isBold: true,
                    textColor: AppColors.textPrimary,
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: (fertilizerRecommendations.isNotEmpty &&
                            fertilizerRecommendations[0]['fertilizersdata'] !=
                                null &&
                            fertilizerRecommendations[0]['fertilizersdata']
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
                                                text: recommendation['name'] ??
                                                    'Unknown',
                                                textColor:
                                                    AppColors.textPrimary,
                                                fontSize: 16,
                                                isBold: true),
                                            SizedBox(height: 4),
                                            CustomTextWidget(
                                                text:
                                                    'Application Rate: ${recommendation['values']} ${recommendation['unit']}',
                                                textColor:
                                                    AppColors.textPrimary,
                                                overflow: TextOverflow.clip,
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
                                            text: 'Recommended',
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
                            child: Text(
                              'No Recommendations Available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    // height: 330,
                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   borderRadius: BorderRadius.circular(12),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: Colors.black12,
                    //       blurRadius: 8,
                    //       offset: Offset(0, 2),
                    //     ),
                    //   ],
                    // ),
                    // padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomTextWidget(
                          text: 'OR',
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
                                            ['fertilizersdatacombTwo'][index];
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
                                                          'Unknown',
                                                      textColor:
                                                          AppColors.textPrimary,
                                                      fontSize: 16,
                                                      isBold: true),
                                                  SizedBox(height: 4),
                                                  CustomTextWidget(
                                                      text:
                                                          'Application Rate: ${recommendation['values']} ${recommendation['unit']}',
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
                                                  text: 'Alternate',
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
                                  child: CustomTextWidget(text: 'No Recommendations Available', textColor: AppColors.error),
                                ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ]),
        )));
  }
}
