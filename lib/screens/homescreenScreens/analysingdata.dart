import 'dart:convert';
import 'dart:developer';

import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/showsnackbar.dart';
import 'package:agromitra/utils/data/fetchInternetData.dart';
import 'package:agromitra/utils/data/models/npk_values.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SoilAnalysisScreen extends StatefulWidget {
  final List<String> images;

  SoilAnalysisScreen({required this.images});

  @override
  _SoilAnalysisScreenState createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  double progress = 0.5;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    simulateProgress();
    cycleImages();
    // gettoanalyzedScreen();
    fetchAndNavigate();
  }

  void gettoanalyzedScreen() async {
    // _soilDataFuture = _soilDataService.fetchSoilData(widget.images);
    // log(_soilDataFutur);

    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/soilAnalyzedReport',
          arguments: {
            // 'soilData': {
            //   'ph': 6.5,
            //   'nitrogen': 0.5,
            //   'phosphorus': 0.3,
            //   'potassium': 0.2,
            // },
          });
    });
  }

  Future<void> fetchAndNavigate() async {
    try {
      final response = await fetchSoilData(widget.images);

      if (response['success'] == true) {
        log(response.toString());
        Navigator.pushReplacementNamed(
          context,
          '/soilAnalyzedReport',
          arguments: {
            'soilData': response, // Pass the data to the next screen
          },
        );
      } else {
        log(response.toString());
        log('Soil analysis failed: ${response.toString()}');
        customShowSnackbar(context, 'Some of the image does not contain soil');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('this image does not contain soil')),
        // );
        Navigator.of(context).pop();
      }
    } catch (e) {
      log('Error fetching soil data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching soil data.')),
      );
    }
  }

  Future<Map<String, dynamic>> fetchSoilData(List<String> imageUrls) async {
    const String apiUrl = UrlProvider.getNPKValuesUrl;

    // Prepare request body
    final Map<String, dynamic> body = {
      'image_urls': imageUrls,
    };

    try {
      FetchData fetchData = FetchData(
        url: apiUrl,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final response = await fetchData.postUnhandled();
      // log(response.toString());
      // Parse and return the response
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error fetching soil data: $e');
    }
  }

  void simulateProgress() {
    Future.delayed(Duration(milliseconds: 1), () {
      setState(() {
        progress += 0.005;
        if (progress > 1.0) progress = 0.0;
        simulateProgress();
      });
    });
  }

  void cycleImages() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % widget.images.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbackground,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 250,
            margin: EdgeInsets.all(50),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(widget.images[currentIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                  'https://image-resource.creatie.ai/144550874980048/144550874980050/bbb02b6b263acc62063bd42c246941ca.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Icon(Icons.science, size: 36, color: Colors.black),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextWidget(
                text: AppLocalizations.of(context)!.analyzingSoilImages,
                textColor: AppColors.textPrimary,
                fontSize: 20,
                isBold: true,
                overflow: TextOverflow.clip,
              ),
              SizedBox(height: 16),
              CustomTextWidget(
                  text: AppLocalizations.of(context)!.processingSamples,
                  textColor: AppColors.textPrimary)
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomTextWidget(
                  text: AppLocalizations.of(context)!.didYouKnow,
                  textColor: AppColors.textSecondary,
                  overflow: TextOverflow.clip,
                ),
                // SizedBox(height: 8),
                // Text(
                //   "contain up to 1 billion bacteria!",
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: Color(0xFF374151),
                //   ),
                //   textAlign: TextAlign.center,
                // ),
              ],
            ),
          ),
          Container(
            width: 250,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              color: Color(0xFFE5E7EB),
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  color: Colors.black,
                ),
              ),
            ),
          ),
          CustomTextWidget(
              text: AppLocalizations.of(context)!.processDuration,
              textColor: AppColors.textSecondary)
        ],
      ),
    );
  }
}
