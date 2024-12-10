class UrlProvider {
  static const String baseUrl = "https://sih-2024-orcin.vercel.app";
  static const String baseUrlOfMl = "https://crop-django.onrender.com";
  static const String baseUrlbytushar =
      "https://sih-agromitra-new-server-psi.vercel.app";

  //auth here
  static const String authBaseUrl = "${baseUrl}/farmer";
  static const String dataBaseUrl = "$baseUrl/data";
  static const String googleoauthUrl = "${authBaseUrl}/googleoauth";

  static const String loginUrl = "${authBaseUrl}/login";
  static const String registerUrl = "${authBaseUrl}/signup";
  static const String sendOTP = "${registerUrl}/verifyotp/";
  static const String forgotPasswordUrl = "${loginUrl}/forgetpass";
  static const String resetPasswordSendOtp =
      "${forgotPasswordUrl}/verification";
  static const String setNewPasswordUrl = "${forgotPasswordUrl}/setpassword";

  //chatbot
  static const String chatbotUrl = "${baseUrlbytushar}/ask";
  static const String sevenDayWeatherUrl =
      "${baseUrlbytushar}/getnextsevendaysweather";

  static const String getNPKValuesUrl =
      "https://npk-final-api.onrender.com/predict_npk";

  //home screen
  static const String fetchweatherUrl = "${authBaseUrl}/weather/";
  static const String recommendcropURL = "${baseUrlOfMl}/predict/";

  static const String userProfileUrl = "$dataBaseUrl/user-profile";
  static const String updateUserUrl = "$dataBaseUrl/update-user";
  static const String fetchPostsUrl = "$dataBaseUrl/posts";

  static const String uploadImageUrl = "$dataBaseUrl/upload-image";
  static const String fetchNotificationsUrl = "$dataBaseUrl/notifications";
}
