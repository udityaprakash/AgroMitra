import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/loading.dart';
import 'package:agromitra/utils/data/fetchInternetData.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';

// class CropPostsScreen extends StatelessWidget {

// final List<Map<String, dynamic>> cropPosts = [
//   {
//     "id": 4,
//     "name": "Wheat",
//     "title": "Wheat Cultivation in Winter - Overview",
//     "description":
//         "Wheat is a staple crop grown in many regions, especially in winter (Rabi) in India. The ideal sowing time is December, with cool weather favorable for growth. Wheat requires well-drained, fertile soil with a pH between 6 and 7.5. Begin by preparing the soil with plowing and harrowing to break clods and enhance aeration. Organic manure or compost should be added to improve soil fertility. Ensure that seeds are sown at a depth of 2-3 inches, with rows spaced 6-8 inches apart. Wheat thrives under full sunlight, so ensure it receives at least 6 hours of daily exposure. Regular irrigation is necessary, but avoid waterlogging. Apply fertilizers based on soil tests, especially nitrogen, phosphorus, and potassium. The flowering phase requires careful irrigation to prevent yield loss. Use pendimethalin herbicide before sowing to control weeds, and check the crop regularly for pests such as aphids and wheat weevil.",
//     "image":
//         "https://wholegrainscouncil.org/sites/default/files/thumbnails/image/15616367_ml-wheat-field.jpg"
//   },
//   {
//     "id": 5,
//     "name": "Wheat",
//     "title": "Soil Preparation for Wheat",
//     "description":
//         "Soil preparation is critical for wheat cultivation. In December, plow the soil deeply to ensure fine, aerated conditions. Use a harrow or cultivator to break large clods, allowing better water retention and root penetration. Add organic matter like compost or farmyard manure to improve the soil structure. Wheat grows best in loamy or sandy loam soils, with a pH between 6 and 7.5. If the soil is acidic, apply lime to adjust the pH. Fertilizers should be applied based on soil tests before sowing. Use a complete NPK fertilizer, as wheat requires balanced nutrition. Level the field after preparation to avoid uneven irrigation. If necessary, create furrows to ensure water flows evenly across the field. Proper soil preparation leads to better seed germination, reduces pest attacks, and supports healthy growth.",
//     "image":
//         "https://th.bing.com/th/id/OIP.zX9zUVAUW53VVWKgo4uDSwHaEj?w=299&h=184&c=7&r=0&o=5&dpr=1.3&pid=1.7"
//   },
//   {
//     "id": 6,
//     "name": "Wheat",
//     "title": "Choosing the Right Wheat Variety",
//     "description":
//         "Selecting the correct wheat variety is crucial for a successful harvest. Different wheat varieties are suited to specific climates and soils. In colder climates like Varanasi, select frost-resistant varieties that tolerate low temperatures. Varieties such as HD 2967, HD 3086, and K 9120 are ideal for such conditions. Key considerations when choosing a variety include yield potential, disease resistance, and the ability to withstand environmental stress like drought or waterlogging. Certified seed material should be procured from reputable sources to ensure high germination rates and disease-free planting. Early-maturing varieties are best for regions with short growing seasons, while late-maturing varieties are suited to longer seasons. A suitable wheat variety will maximize yield and reduce the risk of crop failure.",
//     "image":
//         "https://th.bing.com/th/id/OIP.5BgiV4Nts6IwG7Iho4UbqwHaFc?w=219&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7"
//   },
//   {
//     "id": 7,
//     "name": "Wheat",
//     "title": "Sowing Wheat Seeds",
//     "description":
//         "Sowing wheat seeds correctly is essential for a strong crop. Seeds should be sown when soil temperatures reach 10°C to 12°C, typically in December. Ensure that the soil is well-prepared with a fine, loose texture. Use a seed drill for uniform seed depth and spacing, typically 6-8 inches between rows and 2-3 inches deep for the seeds. The average seeding rate is 100-120 kg per hectare, but this may vary depending on the variety. Treat seeds with fungicides to prevent soil-borne diseases and apply pre-emergence herbicides to control weeds. Fertilizers like DAP or urea should be incorporated before sowing. Irrigate immediately after sowing to promote germination, but avoid overwatering. Thin plants if needed once seedlings emerge to ensure proper plant spacing.",
//     "image":
//         "https://th.bing.com/th/id/OIP.X8wfJBwlQQhY1uK8xhCiNAHaEK?w=294&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7"
//   },
//   {
//     "id": 8,
//     "name": "Wheat",
//     "title": "Irrigation Techniques for Wheat",
//     "description":
//         "Irrigation is critical in wheat cultivation, especially during dry spells. After sowing, water the field to aid seed germination. Once the seedlings emerge, irrigation should be done regularly but carefully to avoid waterlogging. Drip irrigation or furrow irrigation are effective methods. Drip irrigation conserves water and ensures consistent moisture, while furrow irrigation is more traditional but effective for larger fields. Pay special attention during the flowering stage, as inadequate water at this time can severely affect yields. The ideal number of irrigations is 5-6, depending on the soil type and climate. Clay soils retain moisture for longer periods, requiring less frequent irrigation, while sandy soils need more regular watering. Proper drainage is essential to avoid root damage from waterlogging.",
//     "image":
//         "https://th.bing.com/th/id/OIP.fUBDn5s4wFNUPN7NsOVV4gHaE8?w=256&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7"
//   }
// ];

class CropPostsScreen extends StatefulWidget {
  final String cropName;

  const CropPostsScreen({Key? key, required this.cropName}) : super(key: key);

  @override
  _CropPostsScreenState createState() => _CropPostsScreenState();
}

class _CropPostsScreenState extends State<CropPostsScreen> {
  var cropPosts = [];
  bool isloding = true;

  void initState() {
    super.initState();
    fetchPosts();
  }

  void fetchPosts() async {
    var response =
        FetchData(url: 'https://crop-django.onrender.com/' + widget.cropName.toLowerCase() );
    var details = await response.get();
    setState(() {
      cropPosts = details;
      isloding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbackground,
      appBar: AppBar(
        title: CustomTextWidget(text: widget.cropName, textColor: App),
        backgroundColor: AppColors.primary,
      ),
      body: isloding? loading() : ListView.builder(
        itemCount: cropPosts.length,
        itemBuilder: (context, index) {
          final post = cropPosts[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: Colors.white,
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  post['image'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post['description'],
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                        },
                        child: const Text('Read More'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
