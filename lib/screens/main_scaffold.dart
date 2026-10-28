import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/floating_bottom_bar.dart';
import 'explore/explore_map_screen.dart';
import 'bookings/bookings_screen.dart';
import 'my_chargers/my_chargers_screen.dart';
import 'host_earnings/host_earnings_screen.dart';
import 'user_profile/user_profile_screen.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Explore';
      case 1:
        return 'My Bookings';
      case 2:
        return 'My Chargers';
      case 3:
        return 'Earnings & Analytics';
      case 4:
        return 'User Profile';
      default:
        return 'Finder My Charger';
    }
  }

  String _getSubtitleForIndex(int index) {
    switch (index) {
      case 2:
      case 3:
        return 'Host Mode';
      default:
        return 'Finder My Charger';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ExploreMapScreen(onProfileTap: () => _onTabChanged(4)),
      const BookingsScreen(),
      const MyChargersScreen(),
      const HostEarningsScreen(),
      const UserProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: _getTitleForIndex(_currentIndex),
        subtitle: _getSubtitleForIndex(_currentIndex),
        onProfileTap: () => _onTabChanged(4),
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomBar(
              currentIndex: _currentIndex,
              onTap: _onTabChanged,
            ),
          ),
        ],
      ),
    );
  }
}
