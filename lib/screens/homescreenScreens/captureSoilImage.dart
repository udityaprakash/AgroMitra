import 'dart:convert';
import 'dart:io';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CaptureSoilImage extends StatefulWidget {
  @override
  _CaptureSoilImageState createState() => _CaptureSoilImageState();
}

class _CaptureSoilImageState extends State<CaptureSoilImage> with TickerProviderStateMixin{
  File? _topLeftImage;
  File? _topRightImage;
  File? _bottomLeftImage;
  File? _bottomRightImage;

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
              title: Text("Take a Photo"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera, corner);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Upload from Gallery"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery, corner);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGetNPKValues() async {
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
        final response = await uploadImagesToBackend(outdoorImages);
        print("Outdoor Images Uploaded: $response");
      } else {
        // Show error for missing images
        _showErrorDialog("Please select all four corner images for outdoor analysis.");
      }
    } else {
      // Indoor tab selected
      if (_indoorImages.isNotEmpty) {
        final response = await uploadImagesToBackend(_indoorImages);
        print("Indoor Images Uploaded: $response");
      } else {
        // Show error for no indoor images
        _showErrorDialog("Please add at least one image for indoor analysis.");
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
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
            title: Text("Take a Photo"),
            onTap: () {
              Navigator.of(context).pop();
              _pickIndoorImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo),
            title: Text("Upload from Gallery"),
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
            icon: Icon(Icons.arrow_back, color: AppColors.white,),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: AppColors.primary,
          title: CustomTextWidget(text: "Capture Soil Image",fontSize: 20, textColor: AppColors.newbackground),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              CustomTextWidget(text: "Outdoor",fontSize: 20, textColor: AppColors.newbackground),
              // Tab(text: "Outdoor"),
              CustomTextWidget(text: "Indoor",fontSize: 20, textColor: AppColors.newbackground),
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
                  CustomTextWidget(text: "Outdoor Scanning Tips:",overflow: TextOverflow.clip, fontSize: 15, textColor: AppColors.textPrimary),
                  SizedBox(height: 10),
                  CustomTextWidget(text: "Take 4 images of your soil from different spots in the field for an average analysis.",overflow: TextOverflow.clip, fontSize: 15, textColor: AppColors.textPrimary),
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
                        Icon(Icons.info, color: AppColors.textPrimary,),
                        SizedBox(width: 10),
                        Expanded(child: CustomTextWidget( text: "Keep 5-10 meters between samples Hold camera 30cm above ground Avoid shadows in frame",overflow: TextOverflow.clip,fontSize: 15, textColor: AppColors.textPrimary)),
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
                          child: Text(
                            "Tap a corner to add an image",
                            textAlign: TextAlign.center,
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
                  CustomTextWidget(text: "Indoor Scanning Tips:",overflow: TextOverflow.clip, fontSize: 15, textColor: AppColors.textPrimary),
                  SizedBox(height: 10),
                  CustomTextWidget(text: "Take a single image or multiple images with proper lighting for precise analysis.",overflow: TextOverflow.clip, fontSize: 15, textColor: AppColors.textPrimary),
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
                        Icon(Icons.info, color: AppColors.textPrimary,),
                        SizedBox(width: 10),
                        Expanded(child: CustomTextWidget( text: "Use consistent lighting, Place sample on white background and Keep camera steady. Image should not be blurred",overflow: TextOverflow.clip,fontSize: 15, textColor: AppColors.textPrimary)),
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
          child: CustomButton(backgroundColor: AppColors.primary, textColor: AppColors.white, text: 'Get Soil Analysed', onPressed: _handleGetNPKValues,),
          // child: ElevatedButton(
          //   onPressed: _handleGetNPKValues,
          //   child: Text("Get NPK Values"),
          // ),
        ),
      ),
    );
  }
}

Future<dynamic> uploadImagesToBackend(List<File> images) async {
  const String backendUrl = "http.backend.com"; // Backend URL
  List<String> imageLinks = [];

  try {
    for (File image in images) {
      final request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        if (responseData['url'] != null) {
          imageLinks.add(responseData['url']);
        } else {
          throw Exception("No URL found in the response.");
        }
      } else {
        throw Exception("Failed to upload image. Status code: ${response.statusCode}");
      }
    }

    return imageLinks;
  } catch (e) {
    print("Error uploading images: $e");
    return false;
  }
}
