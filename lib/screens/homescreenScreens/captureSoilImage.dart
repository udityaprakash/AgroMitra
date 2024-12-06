import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/loading.dart';
import 'package:agromitra/functions/showsnackbar.dart';
import 'package:agromitra/utils/data/deviceStorage.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CaptureSoilImage extends StatefulWidget {
  @override
  _CaptureSoilImageState createState() => _CaptureSoilImageState();
}

class _CaptureSoilImageState extends State<CaptureSoilImage>
    with TickerProviderStateMixin {
  File? _topLeftImage;
  File? _topRightImage;
  File? _bottomLeftImage;
  File? _bottomRightImage;
  bool isloading = false;

  List<File> _indoorImages = [];
  final ImagePicker _picker = ImagePicker();

  late TabController _tabController;
  int _activeTabIndex = 0; // Tracks the active tab index

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _activeTabIndex = _tabController.index;
      });
    });
  }

  Future<void> _pickImage(ImageSource source, String corner) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          switch (corner) {
            case 'topLeft':
              _topLeftImage = File(pickedFile.path);
              break;
            case 'topRight':
              _topRightImage = File(pickedFile.path);
              break;
            case 'bottomLeft':
              _bottomLeftImage = File(pickedFile.path);
              break;
            case 'bottomRight':
              _bottomRightImage = File(pickedFile.path);
              break;
          }
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _showImagePickerSheet(String corner) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Padding(
                padding: const EdgeInsets.all(18.0),
                child: CustomTextWidget(
                    text: AppLocalizations.of(context)!.take_photo, fontSize: 18, textColor: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera, corner);
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.photo),
            //   title: CustomTextWidget(
            //       text: "Upload From Gallery", fontSize: 18, textColor: AppColors.textPrimary),
            //   onTap: () {
            //     Navigator.of(context).pop();
            //     _pickImage(ImageSource.gallery, corner);
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGetNPKValues() async {
    setState(() {
      isloading = true;
    });
    if (_activeTabIndex == 0) {
      // Outdoor tab selected
      if (_topLeftImage != null &&
          _topRightImage != null &&
          _bottomLeftImage != null &&
          _bottomRightImage != null) {
        List<File> outdoorImages = [
          _topLeftImage!,
          _topRightImage!,
          _bottomLeftImage!,
          _bottomRightImage!
        ];
        final response = await uploadImagesToBackend(outdoorImages, context);
        print("Outdoor Images Uploaded: $response");
        if(response.length != 4){
          _showErrorDialog(AppLocalizations.of(context)!.error_images_not_uploaded);
          return;
        }
        setState(() {
          isloading = false;
        });
        Navigator.of(context).pushNamed('/soilanalyis', arguments: {
          'images': response,
        });
      } else {
        // Show error for missing images
        _showErrorDialog(
            AppLocalizations.of(context)!.error_select_four_images);
      }
    } else {
      // Indoor tab selected
      if (_indoorImages.isNotEmpty) {
        final response = await uploadImagesToBackend(_indoorImages, context);
        print("Indoor Images Uploaded: $response");
        if(response.length != _indoorImages.length){
          _showErrorDialog(AppLocalizations.of(context)!.error_images_not_uploaded);
          return;
        }
        setState(() {
          isloading = false;
        });
        Navigator.of(context).pushNamed('/soilanalyis', arguments: {
          'images': response,
        });
      } else {
        // Show error for no indoor images
        _showErrorDialog(
            AppLocalizations.of(context)!.error_no_indoor_images);
      }
    }
    setState(() {
      isloading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.newbackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: CustomTextWidget(text: AppLocalizations.of(context)!.alert, fontSize: 25, textColor: AppColors.textPrimary),
        content: CustomTextWidget(text: message, textColor: AppColors.textHint, overflow: TextOverflow.clip,),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: CustomTextWidget(text: AppLocalizations.of(context)!.ok, fontSize: 20, textColor: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

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
                  text: AppLocalizations.of(context)!.take_photo, fontSize: 18, textColor: AppColors.textPrimary),
              onTap: () {
                Navigator.of(context).pop();
                _pickIndoorImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: CustomTextWidget(
                  text: AppLocalizations.of(context)!.upload_from_gallery, fontSize: 18, textColor: AppColors.textPrimary),
              onTap: () {
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
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _indoorImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  @override
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const SizedBox(); // Return an empty widget until initialized
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: AppColors.primary,
          title: CustomTextWidget(
              text: AppLocalizations.of(context)!.capture_soil_image,
              fontSize: 20,
              textColor: AppColors.newbackground),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              CustomTextWidget(
                  text: AppLocalizations.of(context)!.outdoor, fontSize: 20, textColor: AppColors.textHint),
              // Tab(text: "Outdoor"),
              CustomTextWidget(
                  text: AppLocalizations.of(context)!.indoor, fontSize: 20, textColor: AppColors.textHint),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Outdoor Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                      text: AppLocalizations.of(context)!.outdoor_scanning_tips,
                      overflow: TextOverflow.clip,
                      fontSize: 15,
                      textColor: AppColors.textPrimary),
                  SizedBox(height: 10),
                  CustomTextWidget(
                      text:
                          AppLocalizations.of(context)!.outdoor_scanning_instructions,
                      overflow: TextOverflow.clip,
                      fontSize: 15,
                      textColor: AppColors.textPrimary),
                  // Tab(text: "Outdoor"),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                            child: CustomTextWidget(
                                text:
                                  AppLocalizations.of(context)!.outdoor_scanning_info,
                                overflow: TextOverflow.clip,
                                fontSize: 15,
                                textColor: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                          left: 10,
                          child: GestureDetector(
                            onTap: () => _showImagePickerSheet('topLeft'),
                            child: _topLeftImage == null
                                ? Icon(Icons.camera_alt, size: 30)
                                : Image.file(
                                    _topLeftImage!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => _showImagePickerSheet('topRight'),
                            child: _topRightImage == null
                                ? Icon(Icons.camera_alt, size: 30)
                                : Image.file(
                                    _topRightImage!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: GestureDetector(
                            onTap: () => _showImagePickerSheet('bottomLeft'),
                            child: _bottomLeftImage == null
                                ? Icon(Icons.camera_alt, size: 30)
                                : Image.file(
                                    _bottomLeftImage!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => _showImagePickerSheet('bottomRight'),
                            child: _bottomRightImage == null
                                ? Icon(Icons.camera_alt, size: 30)
                                : Image.file(
                                    _bottomRightImage!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomTextWidget(
                              textAlign: TextAlign.center,
                                              text: AppLocalizations.of(context)!.camera_icon_instruction,overflow: TextOverflow.clip, fontSize: 18, textColor: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Indoor Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                      text: AppLocalizations.of(context)!.indoor_scanning_tips,
                      overflow: TextOverflow.clip,
                      fontSize: 15,
                      textColor: AppColors.textPrimary),
                  SizedBox(height: 10),
                  CustomTextWidget(
                      text:
                          AppLocalizations.of(context)!.indoor_scanning_instructions,
                      overflow: TextOverflow.clip,
                      fontSize: 15,
                      textColor: AppColors.textPrimary),
                  // Tab(text: "Outdoor"),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                            child: CustomTextWidget(
                                text:
                                    AppLocalizations.of(context)!
                                        .indoor_scanning_info,
                                overflow: TextOverflow.clip,
                                fontSize: 15,
                                textColor: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Text(
                  //   "Add multiple indoor soil images for a comprehensive analysis. Tap the '+' icon to add more images.",
                  //   style: TextStyle(fontSize: 16.0),
                  // ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ..._indoorImages.map(
                        (image) => Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Image.file(
                                image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _indoorImages.remove(image);
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showIndoorImagePicker();
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Icon(Icons.add, size: 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: !isloading? CustomButton(
            backgroundColor: AppColors.primary,
            textColor: AppColors.white,
            text: AppLocalizations.of(context)!.get_soil_analysed,
            onPressed: _handleGetNPKValues,
          ): loading(),
          // child: ElevatedButton(
          //   onPressed: _handleGetNPKValues,
          //   child: Text("Get NPK Values"),
          // ),
        ),
      ),
    );
  }
}

Future<dynamic> uploadImagesToBackend(
    List<File> images, BuildContext context) async {
  const String backendUrl =
      "https://sih-2024-orcin.vercel.app/farmer/storeanyimage";
  List<String> imageLinks = [];
  final token = await StorageManager.readData("token");
  // log('token value is $token');

  try {
    for (File image in images) {
      final String extension = image.path.split('.').last.toLowerCase();
      log('extension is $extension');
      final request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      log('image path is ${image.path}');
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path.toString(),
        contentType: MediaType('image', extension),
        filename: "uploadedfromApp.jpg",
      ));
      // Map<String, String> headers = {HttpHeaders.authorizationHeader: token};
      // request.headers.addAll(headers);
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      final response = await request.send();

      // if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);
      if (responseData['success'] == true) {
        imageLinks.add(responseData['imageurl']);
      } else {
        showSnackbarAutoTranslated(context, responseData['msg'].toString());
        throw Exception("${responseData.toString()}");
      }
      // } else {
      //   throw Exception("Failed to upload image. Status code: ${response.statusCode}");
      // }
    }

    return imageLinks;
  } catch (e) {
    log("Error uploading images: $e");
    return false;
  }
}
