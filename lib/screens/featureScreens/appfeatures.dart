import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntoScreenState();
}

class _IntoScreenState extends State<IntroScreen> {
  int index = 0;

  var data = [
    {
      "titletext": "",
      "image": "0.svg"
    },
    {
      "titletext": "Precision Fertilizing, Maximum Yields and Higher Profits",
      "image": "1.svg"
    },
    {
      "titletext": "Get Soil Testing Services at your doorstep",
      "image": "2.svg"
    },
  ];

  updateincrementindex() {
    if (index < 2) {
      setState(() {
        index++;
      });
    }
  }

  updatedecrementindex() {
    if (index > 0) {
      setState(() {
        index--;
      });
    }
  }

  getText(){
    if(index == 0){
      return AppLocalizations.of(context)!.featurescr01;
    }else if(index == 1){
      return AppLocalizations.of(context)!.featurescr02;
    }else if(index == 2){
      return AppLocalizations.of(context)!.featurescr03;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        // backgroundColor: ui.backgroundclr,
        body: Stack(children: [
          
          Container(
            color: AppColors.background,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                Row(
                    mainAxisAlignment: index == 0
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (index > 0)
                        InkWell(
                          child: Image.asset('assets/images/icons/Arrow-Left.png',
                              width: 30, height: 30),
                          onTap:     
                          // IconButton(
                          //   icon: const Icon(Icons.arrow_back),
                          //   iconSize: 26,
                          //   onPressed: 
                          () {
                              updatedecrementindex();
                            },
                          // ),
                        ),
                        SizedBox(height: 50,),
                      if (index < 2)
                        InkWell(
                          onTap: (){
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Container(
                              margin: EdgeInsets.only(right:15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              width: 60,
                              height: 35,
                              child: Center(
                                child: CustomTextWidget(
                                  text: AppLocalizations.of(context)!.skip,
                                  textColor: AppColors.primary,
                                  fontSize: 15,
                                  isBold: true,
                                ),
                              )),
                        ),
                    ]),
                CustomTextWidget(text: 
                getText(),
                fontSize: 20,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.clip,
                // data[index]['titletext']!,
                 textColor: AppColors.textPrimary),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // CustomTextWidget(text: data[index]['description']!, textColor: AppColors.textPrimary),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                Container(
                  height: size.height / 2,
                  child:
                      SvgPicture.asset("assets/svgs/features/${data[index]['image']}"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (dotIndex) {
                    bool isSelected = index == dotIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          index = dotIndex;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: isSelected ? 30 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.grey,
                          borderRadius: BorderRadius.circular(isSelected ? 12 : 50),
                        ),
                      ),
                    );
                  }),
                ),
                CustomButton(
                      backgroundColor: AppColors.primary, 
                      textColor: AppColors.background, 
                      text:"  " + AppLocalizations.of(context)!.next + "  >",
                      onPressed: (){
                        if (index == 2) {
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          updateincrementindex();
                          setState(() {
                            
                          });
                        }
                      })
    
              ],
            ),
          ),
        ]));
  }
}