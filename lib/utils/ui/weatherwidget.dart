import 'package:agromitra/constant/color.dart';
import 'package:flutter/material.dart';

Widget weatherTile({child}) {
  return Container(
    width: double.infinity,
    height: 100,
    decoration: BoxDecoration(
      border: Border.all(
        color: AppColors.textSecondary,
        width: 2,
      ),
      color: AppColors.white,
      borderRadius: BorderRadius.circular(50),
    ),
    child: child,
  );
}
