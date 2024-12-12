import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:agromitra/functions/loading.dart';
import 'package:http/http.dart' as http;
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/screens/homescreenScreens/captureSoilImage.dart';
import 'package:agromitra/utils/data/fetchInternetData.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UploadSoilHeathCard extends StatefulWidget {
  const UploadSoilHeathCard({super.key});

  @override
  State<UploadSoilHeathCard> createState() => _UploadSoilHeathCardState();
}

class _UploadSoilHeathCardState extends State<UploadSoilHeathCard> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _indoorImages = [];
  dynamic nutrientData;
  bool isloading = false;
  void _showIndoorImagePicker() {
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: CustomTextWidget(
                  text: AppLocalizations.of(context)!.take_photo,
                  fontSize: 18,
                  textColor: AppColors.textPrimary),
              onTap: () {
                setState(){
                  isloading = true;
                }
                Navigator.of(context).pop();
                _pickIndoorImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: CustomTextWidget(
                  text: AppLocalizations.of(context)!.upload_from_gallery,
                  fontSize: 18,
                  textColor: AppColors.textPrimary),
              onTap: () {
                setState(){
                  isloading = true;
                }
                Navigator.of(context).pop();
                _pickIndoorImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickIndoorImage(ImageSource source) async {
    try {
      final pickedFile =
          await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _indoorImages.add(File(pickedFile.path));
        });
        log("Image path: ${pickedFile.path}");
        var links = await uploadImagesToBackend(_indoorImages, context);
        log("Links: ${links[0].toString()}");
        
        // final res = FetchData(
        //     url: UrlProvider.baseUrlbytushar + "/upload-image",
        //     headers: {"Content-Type": "application/json"},
        //     body: jsonEncode({"imageUrl": links[0].toString()}));

        final res = http.post(
          Uri.parse("https://soil-health-card.onrender.com/extract_soil_health_card"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"image_url": "${links[0].toString()}"}));

        // final res = FetchData(
        //     url: "https://soil-health-card.onrender.com/extract_soil_health_card",
        //     headers: {"Content-Type": "application/json"},
        //     body: jsonEncode({"image_url": "${links[0].toString()}"})); 
        final response = await res.then((value) => jsonDecode(value.body));
        log("Response: ${response.toString()}");
        
        setState(() {
          isloading = false;
          if(response['success'] == true)
          nutrientData = response;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Soil Health Card'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (nutrientData == null) ? ElevatedButton(
              onPressed: _showIndoorImagePicker,
              child: isloading? loading() : CustomTextWidget(
                text: "Upload Soil Health Card",
                fontSize: 18,
                textColor: AppColors.textPrimary,
              ),
            ) : Container(
              child: Column(
                children: [
                  CustomTextWidget(
                    text: "NPK Values",
                    fontSize: 18,
                    textColor: AppColors.textPrimary,
                  ),
                  CustomTextWidget(
                    text: "N: ${nutrientData['data']['Nitrogen']} kg/ha",
                    fontSize: 18,
                    textColor: AppColors.textPrimary,
                  ),
                  CustomTextWidget(
                    text: "OC: ${nutrientData['data']['Organic Carbon']} %",
                    fontSize: 18,
                    textColor: AppColors.textPrimary,
                  ),
                  CustomTextWidget(
                    text: "K: ${nutrientData['data']['Phosphorus']} kg/ha",
                    fontSize: 18,
                    textColor: AppColors.textPrimary,
                  ),
                  CustomTextWidget(
                    text: "P: ${nutrientData['data']['Potassium']} kg/ha",
                    fontSize: 18,
                    textColor: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
