import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
          child: GNav(
            curve: Curves.easeOutExpo,
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Colors.white,
            iconSize: 26,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: Duration(milliseconds: 500),
            tabBackgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.8),
            color: Colors.grey[600],
            tabs: [
              GButton(
                icon: Icons.home_rounded,
                text: 'Home',
                textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              GButton(
                icon: Icons.smart_toy_rounded,
                text: 'Chatbot',
                textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              GButton(
                icon: Icons.person_rounded,
                text: 'Profile',
                textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ],
            selectedIndex: currentIndex,
            onTabChange: onTap,
          ),
        ),
      ),
    );
  }
}
