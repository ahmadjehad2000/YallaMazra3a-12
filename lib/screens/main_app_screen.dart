// main_app_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart'; //correct import
import '../providers/villa_provider.dart'; //correct import
import 'my_bookings_screen.dart';
import 'profile_screen.dart';
import 'villa_listings_screen.dart';
import 'moderator_screen.dart'; // Import the correct ModeratorScreen

class MainAppScreen extends StatefulWidget {
  final bool isModerator;
  final bool isAdmin;

  const MainAppScreen({Key? key, this.isModerator = false, this.isAdmin=false}) : super(key: key);

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> with TickerProviderStateMixin {
  int _currentIndex = 2;
  late final AnimationController _switchController;
  late final List<Widget> _screens;
  late final List<BottomNavigationBarItem> _tabs;

  @override
  void initState() {
    super.initState();

    _screens = [
      const ServicesScreen(),
      const MyBookingsScreen(),
      const HomeContent(),
      const ProfileScreen(),
      if (widget.isModerator || widget.isAdmin) const ModeratorScreen(),
    ];

    _tabs = [
      const BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'خدماتي'),
      const BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'حجوزاتي'),
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'الصفحة الرئيسية'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'بروفايل'),
      if (widget.isModerator || widget.isAdmin)
        const BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), label: 'شغلي'),
    ];

    _switchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    _switchController.reverse().then((_) {
      setState(() => _currentIndex = index);
      _switchController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.article_outlined),
          onPressed: () { },
        ),
        title: const Text('يلا مزرعة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () { },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.7)),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _switchController.drive(
                Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: _screens[_currentIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white.withOpacity(0.9),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: _tabs,
      ),
    );
  }
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('خدماتي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
    );
  }
}


class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            BigCircleButton(
              icon: Icons.location_on_outlined,
              label: 'يلا',
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (_, __, ___) => const VillaListingsScreen(),
                    transitionsBuilder: (_, anim, __, child) {
                      return FadeTransition(opacity: anim, child: child);
                    },
                  ),
                );
              },
            ),
            PlanetButton(
              icon: Icons.visibility_outlined,
              label: 'رؤيتنا',
              angle: -pi / 4,
              radius: 120,
              onTap: () { },
            ),
            PlanetButton(
              icon: Icons.monetization_on_outlined,
              label: 'فور سيل',
              angle: pi / 4,
              radius: 120,
              onTap: () { },
            ),
            PlanetButton(
              icon: Icons.lightbulb_outline,
              label: 'نصائح',
              angle: pi,
              radius: 120,
              onTap: () { },
            ),
          ],
        ),
      ),
    );
  }
}

class BigCircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BigCircleButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlanetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double angle;
  final double radius;
  final VoidCallback onTap;

  const PlanetButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.angle,
    required this.radius,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double size = 60;
    final double x = radius * cos(angle);
    final double y = radius * sin(angle);

    return Transform.translate(
      offset: Offset(x, y),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Theme.of(context).primaryColor),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
