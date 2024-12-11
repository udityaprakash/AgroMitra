import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/loading.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // Fetch notifications from the API
  Future<void> fetchNotifications() async {
    const String url = '${UrlProvider.baseUrlbytushar}/notifications'; // API URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            notifications = data['notifications'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Error: API success flag is false');
        }
      } else {
        // Handle unsuccessful API response (non-200 status)
        setState(() {
          isLoading = false;
        });
        print('Failed to load notifications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  Future<void> _performRefresh() async {
    setState(() {
      isLoading = true;
    });
    await fetchNotifications();
    // await _getRecommendedCrops();

    setState(() {
      isLoading = false;
    });
  }

  // Get color based on notification priority
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red.shade100;
      case 2:
        return Colors.orange.shade100;
      case 3:
        return Colors.grey.shade200;
      default:
        return Colors.white;
    }
  }

  // Get the icon based on the type of notification
  IconData getIcon(String icon) {
    switch (icon) {
      case 'weather':
        return Icons.cloud;
      case 'market':
        return Icons.trending_down;
      case 'pests':
        return Icons.bug_report;
      case 'health':
        return Icons.local_florist;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbackground,
      appBar: AppBar(
        title: CustomTextWidget(
          text: AppLocalizations.of(context)!.notification,
          textColor: AppColors.white,
          fontSize: 20,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: RefreshIndicator(
        onRefresh: _performRefresh,
        
        child: isLoading
            ? Center(child: loading())
            : notifications.isEmpty
                ? Center(child: CustomTextWidget(text: AppLocalizations.of(context)!.notification , textColor: AppColors.textPrimary)) // Text localization
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final tags = notification['tags'] ?? [];
                        return Card(
                          color: getPriorityColor(notification['priority'] ?? 'low'),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            minTileHeight: 100,
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                getIcon(notification['icon'] ?? ''),
                                color: Colors.black54,
                              ),
                            ),
                            title: CustomTextWidget(text: notification['title'] ?? '', textColor: AppColors.textPrimary, isBold: true),
                            subtitle: CustomTextWidget(text: notification['description'] ?? '', textColor: AppColors.textPrimary, overflow: TextOverflow.clip,),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    // Handle mark as read
                                    // Update the state if necessary
                                  },
                                ),
                                // IconButton(
                                //   icon: Icon(Icons.share, color: Colors.blue),
                                //   onPressed: () {
                                //     // Handle share functionality
                                //   },
                                // ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
