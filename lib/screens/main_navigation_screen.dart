import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/screens/session_dashboard_screen.dart';
import 'package:mapped_frontend/screens/session_dashboard_screen.dart';
import '../screens/home_screen.dart';
import '../screens/forum_screen.dart';
import '../screens/coachBot_screen.dart';
import '../screens/account_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (index) => GlobalKey<NavigatorState>(),
  );

  static final List<Widget> _pages = [
    const HomeScreen(),
    const SessionDashboardScreen(),
    ForumScreen(),
    CoachBotScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // If tapped the same tab, pop to first route
      _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => _pages[index],
            settings: settings,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab = !await _navigatorKeys[_selectedIndex]
            .currentState!
            .maybePop();

        if (isFirstRouteInCurrentTab) {
          // If we're on the first route of the current tab, and there's only one tab,
          // we might want to exit the app. Or you can handle it differently.
          if (_selectedIndex != 0) {
            // Switch to home tab if not already there
            setState(() {
              _selectedIndex = 0;
            });
            return false;
          }
        }
        return !isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(
          children: List.generate(
            _pages.length,
            (index) => _buildOffstageNavigator(index),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C23),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.sports_gymnastics_outlined, "Home", 0),
          _buildNavItem(Icons.fitness_center_outlined, "Session", 1),
          _buildNavItem(Icons.forum_outlined, "Forum", 2),
          _buildNavItem(Icons.smart_toy_outlined, "Coach Bot", 3),
          _buildNavItem(Icons.account_circle_outlined, "Account", 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected
                ? const Color(0xFF00FF66)
                : const Color(0xFFEFE4F8),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isSelected
                  ? const Color(0xFF00FF66)
                  : const Color(0xFFEFE4F8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
