import 'dart:developer';

import 'package:agromitra/functions/showsnackbar.dart';
import 'package:agromitra/utils/data/deviceStorage.dart';
import 'package:agromitra/utils/data/fetchInternetData.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:flutter/material.dart';

dynamic continuewithgoogle(id, email, fullname,photoUrl, context) async {
  try {
    final lang = await StorageManager.readData('Lang');
    log('here languagereceived is :'+lang.toString());
    final fetchData = FetchData(
      url: UrlProvider.googleoauthUrl,
      headers: {'Content-Type': 'application/json'},
      body: {
        "id": id,
        "email": email,
        "fullname": fullname,
        "language": lang.toString(),
        "profile_pic":photoUrl.toString(),
        "loginType": "google"
      },
    );
    final response = await fetchData.post();
    if(response['success'] == true){
      await StorageManager.saveData('token', response['token']);
      await StorageManager.saveData('email', email);
      await StorageManager.saveData(
          'farmer_name',
          fullname,
        );
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/mainScreen');
    }else{
      showSnackbarAutoTranslated(context, response['msg']);

    }
    return response;
  } catch (e) {
    log(e.toString());
  }
}
