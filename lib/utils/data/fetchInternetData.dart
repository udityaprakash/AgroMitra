import 'dart:convert'; // For JSON decoding
import 'dart:developer';
import 'package:http/http.dart' as http; // Import the http package

class FetchData {
  final String url;
  final Map<String, String>? headers; // Optional headers
  final dynamic body; // Optional body for POST requests

  FetchData({required this.url, this.headers, this.body});

  /// GET request
  Future<dynamic> get() async {
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      // Handle response
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Parse JSON response
      } else {
        return jsonDecode(response.body);
      }
    } catch (e) {
      return null;
    }
  }

  /// POST request
  /// // Add manual redirect handling
// Future<dynamic> post() async {
//   try {
//     var response = await http.post(
//       Uri.parse(url),
//       headers: headers,
//       body: body != null ? jsonEncode(body) : null,
//     );

//     // Check for redirect status codes
//     if (response.statusCode == 308 || response.statusCode == 301 || response.statusCode == 302) {
//       // Extract new location from headers
//       String? newLocation = response.headers['location'];
//       if (newLocation != null) {
//         // Retry request with new URL
//         response = await http.post(
//           Uri.parse(newLocation),
//           headers: headers,
//           body: body != null ? jsonEncode(body) : null,
//         );
//       }
//     }

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to post data: ${response.statusCode}');
//     }
//   } catch (e) {
//     throw Exception('POST request error: $e');
//   }
// }
  Future<dynamic> post() async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body != null
            ? jsonEncode(body)
            : null, // Encode body to JSON if provided
      );
      log('here $response');

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // Parse JSON response
      } else {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception('POST request error: $e');
    }
  }
}
