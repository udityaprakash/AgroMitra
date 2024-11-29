class UrlProvider {
  static const String baseUrl = "https://sih-2024-orcin.vercel.app";

  static const String authBaseUrl = "${baseUrl}/farmer";
  static const String dataBaseUrl = "$baseUrl/data";


  static const String loginUrl = "${authBaseUrl}/login";
  static const String registerUrl = "${authBaseUrl}/signup";
  static const String sendOTP = "${registerUrl}/verifyotp/";
  static const String forgotPasswordUrl = "${loginUrl}/forgetpass";
  static const String resetPasswordSendOtp = "${forgotPasswordUrl}/verification";

  static const String userProfileUrl = "$dataBaseUrl/user-profile";
  static const String updateUserUrl = "$dataBaseUrl/update-user";
  static const String fetchPostsUrl = "$dataBaseUrl/posts";

  static const String uploadImageUrl = "$dataBaseUrl/upload-image";
  static const String fetchNotificationsUrl = "$dataBaseUrl/notifications";
}
