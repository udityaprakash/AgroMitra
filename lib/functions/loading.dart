import 'package:agromitra/constant/color.dart';
import 'package:flutter/material.dart';

Widget loading({height, width}){
  return Center(
    child: Container(
      height: height ?? 40,
      width: width ?? 40,
      child: CircularProgressIndicator(color: AppColors.primary,)),
  );
}