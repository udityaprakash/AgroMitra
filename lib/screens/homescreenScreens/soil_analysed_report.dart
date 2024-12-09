import 'dart:ui';

import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/autotranslator.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SoilDataAnalyzed extends StatefulWidget {
  final Map<String, dynamic> soilData;

  const SoilDataAnalyzed({Key? key, required this.soilData}) : super(key: key);

  @override
  _SoilDataAnalyzedState createState() => _SoilDataAnalyzedState();
}


class _SoilDataAnalyzedState extends State<SoilDataAnalyzed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbackground,
      appBar: AppBar( 
        title: CustomTextWidget(text: AppLocalizations.of(context)!.soil_analysis, textColor: AppColors.white, fontSize: 20,),
        backgroundColor: AppColors.primary,
        elevation: 5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentAnalysisCard(),

            const SizedBox(height: 16),

            _buildSoilTypeCard(),

            const SizedBox(height: 16),

            _buildBestCropsToGrow(),

            const SizedBox(height: 16),

            _buildCustomCropSelection(),

            const SizedBox(height: 16),

            // _buildRecentSamples(),

            // const SizedBox(height: 16),

            _buildRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAnalysisCard() {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 32, color: Colors.black),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(text: AppLocalizations.of(context)!.currentAnalysis, textColor: AppColors.textPrimary, isBold: true,),
                    // Text(
                    //   'Current Analysis',
                    //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    // ),
                    CustomTextWidget(text: AppLocalizations.of(context)!.fieldSection, textColor: AppColors.textHint)
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatTile(AppLocalizations.of(context)!.pHLevel, '6.8', 0),
                _buildStatTile(AppLocalizations.of(context)!.moisture, '42%', 1),
              ],
            ),
            const SizedBox(height: 16),
            _buildNutrientBar(AppLocalizations.of(context)!.nitrogen, 0.75, '0.75 kg/ha'),
            _buildNutrientBar(AppLocalizations.of(context)!.phosphorus, 0.60, '0.60 kg/ha'),
            _buildNutrientBar(AppLocalizations.of(context)!.potassium, 0.85, '0.85 kg/ha'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, int index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: index == 0 ? Color.fromARGB(255, 232, 255, 237) :const Color.fromARGB(255, 213, 234, 255),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(text: title,isBold: true, textColor: index == 0 ? const Color.fromARGB(255, 33, 99, 24) : const Color.fromARGB(255, 18, 86, 212)),
          const SizedBox(height: 8),
          CustomTextWidget(text: value, textColor: index == 0 ? const Color.fromARGB(255, 33, 99, 24) : const Color.fromARGB(255, 18, 86, 212), fontSize: 25, isBold: true),
        ],
      ),
    );
  }

  Widget _buildNutrientBar(String title, double value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextWidget(text: title, textColor: AppColors.textPrimary),
            CustomTextWidget(text: unit, textColor: AppColors.textPrimary),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          color: Colors.black,
          backgroundColor: Colors.grey[300],
          minHeight: 10,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSoilTypeCard() {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(24),
                ),
              child: Icon(Icons.terrain, size: 32, color: const Color.fromARGB(255, 130, 103, 27)),
              ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                CustomTextWidget(text: AppLocalizations.of(context)!.soilType, textColor: AppColors.textPrimary, isBold: true,),
                // CustomTextWidget(text: , textColor: AppColors.textHint),
                AutoTranslator().buildTranslatedText(context, 'clay loamy')
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestCropsToGrow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(text: AppLocalizations.of(context)!.bestCropsToGrow, textColor: AppColors.textPrimary, isBold: true,),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildCropCard('https://imgs.search.brave.com/5wCarlbEu2qsKumvJ94-tV0jeoE0uYIvzv2kHMekLq8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvNDgz/Njc3NjU5L3Bob3Rv/L3doZWF0LWdyYWlu/cy5qcGc_cz02MTJ4/NjEyJnc9MCZrPTIw/JmM9Zm16ZmhzMFdw/b0JjaEk3Z2hoNkx6/dkVfXy1YR2ZFVDFX/OGxEZ0F0aXNxST0','Wheat', 'High success rate'),

            _buildCropCard('https://imgs.search.brave.com/m5FHIf_K8jpld4PXfDXdwCf0jIsI8PO-CWqYUZ6ssGQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvMTgw/MTk4MTA3L3Bob3Rv/L2Nvcm4tZmllbGQu/anBnP3M9NjEyeDYx/MiZ3PTAmaz0yMCZj/PTNmTG1TdU1ESVRl/eEd5MjhLOTF3S3VH/Rk84cTc3OElPZ05E/eUZvLTNhOEU9','Corn', 'Good compatibility'),
            _buildCropCard('https://imgs.search.brave.com/yUtvh7YQufmJgmUXjmX28oBvxLJAqVlWKlP41Aa9Uzs/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5nZXR0eWltYWdl/cy5jb20vaWQvMTIw/NDQ3MTkyNi9waG90/by9zb3liZWFuLWNy/b3AtMjAyMC1pbi10/aGUtc3RhdGUtb2Yt/cGFyYW4lQzMlQTEt/aW4tYnJhemlsLmpw/Zz9zPTYxMng2MTIm/dz0wJms9MjAmYz1x/NkxtSjB5dnY5YVYx/MVBqZ0VaM3dxaENp/UXZHNGJLTy1sbG5h/c2tWdldrPQ','Soybean', 'Optimal conditions'),
            _buildCropCard('https://imgs.search.brave.com/Ck55_SHaJeXHTq-G56YW0rz6Nd0DSjyd-IUZLxY7Ghc/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzAxLzAzLzI2LzQx/LzM2MF9GXzEwMzI2/NDEzMl9WRFFJZkp2/YUVNcEw1WmpVM1g5/a3JhRUppcmJSQ1pr/WS5qcGc','Barley', 'Suitable pH level'),
          ],
        ),
      ],
    );
  }

  Widget _buildCropCard(String imageurl,String title, String subtitle) {
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey[300],
              child: Image.network(imageurl, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            CustomTextWidget(text: title, textColor: AppColors.textPrimary, isBold: true,),
            CustomTextWidget(text: subtitle, textColor: AppColors.textHint)
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCropSelection() {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextWidget(text: AppLocalizations.of(context)!.customCropSelection, textColor: AppColors.textPrimary, isBold: true,fontSize: 18,),
            const SizedBox(height: 8),
            TextField(
              style: customTextStyle(color: AppColors.textHint, size: 15),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchForCrops,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildChip(AppLocalizations.of(context)!.rice),
                _buildChip(AppLocalizations.of(context)!.cotton),
                _buildChip(AppLocalizations.of(context)!.sugarcane),
                // _buildChip(AppLocalizations.of(context)!.addCustom, isAddCustom: true),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: CustomButton(backgroundColor: AppColors.primary, textColor: AppColors.white, text: AppLocalizations.of(context)!.analyzeCompatibility, onPressed: () {
                  
                  }),
                ),
                CustomTextWidget(text: '   56%', textColor: AppColors.error, isBold: true, fontSize: 16,),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, {bool isAddCustom = false}) {
    return Chip(
      label: Text(label),
      backgroundColor: isAddCustom ? AppColors.white : Colors.grey[200],
    );
  }

  // Widget _buildRecentSamples() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text('Recent Samples',
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //       const SizedBox(height: 8),
  //       ListTile(
  //         leading: Icon(Icons.science, color: Colors.black),
  //         title: const Text('Sample #2847'),
  //         subtitle: const Text('2 hours ago'),
  //         trailing: const Icon(Icons.chevron_right),
  //         onTap: () {},
  //       ),
  //       ListTile(
  //         leading: Icon(Icons.science, color: Colors.black),
  //         title: const Text('Sample #2846'),
  //         subtitle: const Text('5 hours ago'),
  //         trailing: const Icon(Icons.chevron_right),
  //         onTap: () {},
  //       ),
  //     ],
  //   );
  // }

  Widget _buildRecommendations() {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextWidget(text:AppLocalizations.of(context)!.recommendations, textColor: AppColors.textPrimary, isBold: true,),
            const SizedBox(height: 8),
            _buildRecommendationItem(
              AppLocalizations.of(context)!.increaseNitrogen,
              AppLocalizations.of(context)!.addOrganicCompost,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildRecommendationItem(
              AppLocalizations.of(context)!.adjustIrrigation,
              AppLocalizations.of(context)!.reduceWateringFrequency,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String subtitle, Color iconColor) {
    return Row(
      children: [
        Icon(Icons.circle, color: iconColor, size: 12),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(text: title, textColor: AppColors.textPrimary, isBold: true, overflow: TextOverflow.clip,),
              CustomTextWidget(text: subtitle,overflow: TextOverflow.clip, textColor: AppColors.textHint),
            ],
          ),
        ),
      ],
    );
  }
}