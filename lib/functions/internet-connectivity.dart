import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class ConnectivityProvider with ChangeNotifier {
  late bool _isOnline = true; // Assume online by default
  bool get isOnline => _isOnline;
  Timer? _timer;

  ConnectivityProvider() {
    _checkConnection();
    _timer = Timer.periodic(Duration(seconds: 17), (timer) {
      _checkConnection();
    });
  }

  void _checkConnection() async {
    bool previousStatus = _isOnline;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isOnline = true;
      } else {
        _isOnline = false;
      }
    } on SocketException catch (_) {
      _isOnline = false;
    }

    // Only notify listeners if the status has changed
    if (previousStatus != _isOnline) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}


// class ConnectivityProvider with ChangeNotifier {
//   late bool _isOnline = false;
//   bool get isOnline => _isOnline;
//   ConnectivityProvider() {
//     Connectivity _connectivity = Connectivity();
//     _connectivity.onConnectivityChanged.listen((result) async {
//       if (result == ConnectivityResult.none) {
//         _isOnline = false;
//         notifyListeners();
//       } else {
//         _isOnline = true;
//         notifyListeners();
//       }
//     });
//   }
// }
