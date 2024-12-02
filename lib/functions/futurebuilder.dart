import 'package:flutter/material.dart';

Widget customFutureBuilder<T>({
  required Future<T> future,
  required Widget Function(BuildContext, T) onSuccess,
  Widget? onErrorWidget,
  Widget? loadingWidget,
}) {
  return FutureBuilder<T>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return loadingWidget ??
            Center(child: SizedBox(height: 100, child: CircularProgressIndicator()));
      } else if (snapshot.hasError) {
        return onErrorWidget ?? 
            Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData) {
        return onSuccess(context, snapshot.data!);
      } else {
        return Center(child: Text('No data available'));
      }
    },
  );
}
