import 'package:agromitra/constant/color.dart';
import 'package:agromitra/screens/homescreen.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Home Page', style: TextStyle(fontSize: 24)));
  }
}

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Community Page', style: TextStyle(fontSize: 24)));
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile Page', style: TextStyle(fontSize: 24)));
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Settings Page', style: TextStyle(fontSize: 24)));
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of StatefulWidgets (pages) to display on index change
  final List<Widget> _pages = [
    HomeScreen(),
    CommunityPage(),
    ProfilePage(),
    SettingsPage(),
  ];
  
  get developer => null;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Bottom Navigation Example')),
      body: _pages[_selectedIndex], // Display the page based on the selected index
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: customTextStyle(color: AppColors.primary, size: 12, weight: FontWeight.w900),
        unselectedLabelStyle: customTextStyle(color: AppColors.textSecondary, size: 12, weight: FontWeight.w900),
        currentIndex: _selectedIndex, // Update this with the current index
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          // developer.log('Selected Index: $_selectedIndex');
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups, size: 24),
            label: AppLocalizations.of(context)!.community,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 24),
            label: AppLocalizations.of(context)!.settings,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: AppLocalizations.of(context)!.profile,
          ),
          // BottomNavigationBarItem(
          //         icon: Icon(Icons.home, size: 24),
          //         label: '', // Remove label
          //         activeIcon: Column(
          //           children: [
          //             Icon(Icons.home, color: AppColors.primary, size: 24),
          //             Text('Home', style: TextStyle(color: AppColors.primary, fontSize: 12))
          //           ],
          //         ),
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.groups, size: 24),
          //         label: '', // Remove label
          //         activeIcon: Column(
          //           children: [
          //             Icon(Icons.groups, color: AppColors.primary, size: 24),
          //             Text('Community', style: TextStyle(color: AppColors.primary, fontSize: 12))
          //           ],
          //         ),
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.person, size: 24),
          //         label: '', // Remove label
          //         activeIcon: Column(
          //           children: [
          //             Icon(Icons.person, color: AppColors.primary, size: 24),
          //             Text('Profile', style: TextStyle(color: AppColors.primary, fontSize: 12))
          //           ],
          //         ),
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.settings, size: 24),
          //         label: '', // Remove label
          //         activeIcon: Column(
          //           children: [
          //             Icon(Icons.settings, color: AppColors.primary, size: 24),
          //             Text('Settings', style: TextStyle(color: AppColors.primary, fontSize: 12))
          //           ],
          //         ),
          //       ),
        ],
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
      ),
      floatingActionButton: (_selectedIndex == 0) ? CustomFloatingActionButton() : null,
    );
  }
}
