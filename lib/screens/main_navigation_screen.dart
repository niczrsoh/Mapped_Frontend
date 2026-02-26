import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/session/session_dashboard_screen.dart';
import '../screens/home_screen.dart';
import '../forum/forum_screen.dart';
import '../coachBot/coachBot_screen.dart';
import '../account/account_screen.dart';
// Import the controller (adjust path as needed)
import '../controller/bottom_nav_controller.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (index) => GlobalKey<NavigatorState>(),
  );

  late final BottomNavController _navController;

  @override
  void initState() {
    super.initState();
    // Get or create the controller
    _navController = Get.put(BottomNavController());
    // Set initial index if provided (optional)
    _navController.changeIndex(widget.initialIndex);
  }

  static final List<Widget> _pages = [
    HomeScreen(),
    SessionDashboardScreen(),
    ForumScreen(),
    CoachBotScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    if (_navController.selectedIndex.value == index) {
      // Pop to first route of the current tab
      _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    } else {
      _navController.changeIndex(index);
    }
  }

  Widget _buildOffstageNavigator(int index) {
    return Obx(() => Offstage(
          offstage: _navController.selectedIndex.value != index,
          child: Navigator(
            key: _navigatorKeys[index],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => _pages[index],
                settings: settings,
              );
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final currentIndex = _navController.selectedIndex.value;
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[currentIndex].currentState!.maybePop();

        if (isFirstRouteInCurrentTab) {
          if (currentIndex != 0) {
            _navController.changeIndex(0);
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
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
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 0),
      child: Container(
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
            _buildNavItem(Icons.sports_gymnastics_outlined, 'home'.tr(), 0),
            _buildNavItem(
              Icons.fitness_center_outlined,
              'home_nav_session'.tr(),
              1,
            ),
            _buildNavItem(Icons.forum_outlined, 'forum'.tr(), 2),
            _buildNavItem(
              Icons.smart_toy_outlined,
              'home_nav_coach_bot'.tr(),
              3,
            ),
            _buildNavItem(
              Icons.account_circle_outlined,
              'home_nav_account'.tr(),
              4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Obx(() {
      final isSelected = _navController.selectedIndex.value == index;
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
    });
  }
}