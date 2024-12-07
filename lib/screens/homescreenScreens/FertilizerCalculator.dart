import 'dart:convert';
import 'dart:developer';

import 'package:agromitra/constant/color.dart';
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
  String? selectedStateId;
  String? selectedCrop;
  var occontroller = TextEditingController();
  var nicontroller = TextEditingController();
  var picontroller = TextEditingController();
  var kicontroller = TextEditingController();

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
        title: CustomTextWidget(text: 'Fertilizer Calculator', textColor: AppColors.white, fontSize: 20,)
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                  hint: CustomTextWidget(text: 'Select State', textColor: AppColors.textHint, fontSize: 20,),
                  style: customTextStyle(color: AppColors.textPrimary, size: 20),
                  
                  borderRadius: BorderRadius.circular(8),
                  value: selectedStateId,
                  isExpanded: true,
                  items: states.map((state) {
                    return DropdownMenuItem<String>(
                      value: state['_id'],
                      child: CustomTextWidget(text: state['name'], fontSize: 18,fontWeight: FontWeight.w500, textColor: AppColors.textPrimary),
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
                  hint: CustomTextWidget(text: 'Select Crop', textColor: AppColors.textHint, fontSize: 20,),
                  style: customTextStyle(color: AppColors.textPrimary, size: 20),
                  value: selectedCrop,
                  items: crops.map((crop) {
                    return DropdownMenuItem<String>(
                      value: crop['id'],
                      child: Text(crop['name']),
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
                    CustomTextWidget(text: 'Soil Parameters',fontSize: 20,isBold: true, textColor: AppColors.textPrimary),
                    SizedBox(height: 16),
                    // Organic Carbon
                    CustomTextField(hintText: 'Organic Carbon (%)', controller: occontroller),
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
                    CustomTextField(hintText: 'Nitrogen (N) Kg/ha', controller: nicontroller),
                    // TextField(
                    //   decoration: InputDecoration(
                    //     labelText: 'Nitrogen (N) Kg/ha',
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   keyboardType: TextInputType.number,
                    // ),
                    SizedBox(height: 16),
                    // Phosphorus
                    CustomTextField(hintText: 'Phosphorus (P) Kg/ha', controller: picontroller),
                    // TextField(
                    //   decoration: InputDecoration(
                    //     labelText: 'Phosphorus (P) Kg/ha',
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   keyboardType: TextInputType.number,
                    // ),
                    SizedBox(height: 16),
                    // Potassium
                    CustomTextField(hintText: 'Potassium (K) Kg/ha', controller: kicontroller),
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
                      child: CustomButton(backgroundColor: AppColors.primary, textColor: AppColors.white, text: 'Get Recommendations', onPressed: (){

                      })
                    ),
                  ],
                ),
              ),
              SizedBox( height: 16),
              Container(
                height: 450,
                
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
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        indicatorColor: Colors.black,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: 'Organic'),
                          Tab(text: 'Chemical'),
                        ],
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          physics: BouncingScrollPhysics(), // For swipe transition effect
                          children: [
                            // Organic Tab Content
                            ListView(
                              children: [
                                // First Organic Item
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Misthaufen16.JPG/340px-Misthaufen16.JPG',
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Farmyard Manure',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Application Rate: 5-6 tons/hectare\nEstimated Cost: \$120-150/ton',
                                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Recommended',
                                            style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                // Second Organic Item
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Misthaufen16.JPG/340px-Misthaufen16.JPG',
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Vermicompost',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Application Rate: 2.5 tons/hectare\nEstimated Cost: \$200-250/ton',
                                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.yellow[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Alternative',
                                            style: TextStyle(
                                              color: Colors.orange[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Chemical Tab Content
                            Center(
                              child: Text(
                                'Chemical Recommendations Coming Soon',
                                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

        
            ],
          ),
        ),
      ),
    );
  }
}