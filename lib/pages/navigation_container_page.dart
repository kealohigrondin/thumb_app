import 'package:flutter/material.dart';
import 'package:thumb_app/pages/account_page.dart';

class NavigationContainerPage extends StatelessWidget {
  const NavigationContainerPage({super.key});

  static final bottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find a ride'),
    const BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account')
  ];


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavItems,
      ),
      body: const Center(child: AccountPage(),)
    );
  }
}
