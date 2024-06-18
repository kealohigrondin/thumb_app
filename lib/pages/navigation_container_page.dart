import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thumb_app/pages/chat_list_page.dart';
import 'package:thumb_app/pages/notifications_page.dart';
import 'package:thumb_app/pages/profile_page.dart';
import 'package:thumb_app/pages/home_page.dart';
import 'package:thumb_app/pages/rides_page.dart';
import 'package:thumb_app/pages/search_page.dart';
import 'package:thumb_app/pages/search_profile_page.dart';
import 'package:thumb_app/pages/settings_page.dart';

final bottomNavIndexProvider = StateProvider((ref) => 0);

class NavigationContainerPage extends ConsumerWidget {
  const NavigationContainerPage({super.key});

  static final bottomNavItems = [
    const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
    const NavigationDestination(
        icon: Icon(Icons.airport_shuttle), label: 'Rides'),
    const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
  ];

  static final pageTitles = ['Activity', 'Find a ride', 'My Rides', 'Profile'];

  static final pages = [
    const HomePage(),
    const SearchPage(),
    const RidesPage(),
    const ProfilePage()
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(pageTitles[currentIndex]),
              ],
            ),
            actions: [
              currentIndex == 3
                  ? IconButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const SearchProfilePage())),
                      icon: const Icon(Icons.search, size: 25))
                  : Container(),
              currentIndex == 3
                  ? IconButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const SettingsPage())),
                      icon: const Icon(Icons.settings, size: 25))
                  : Container(),
              currentIndex != 3
                  ? IconButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const ChatListPage())),
                      icon: const Icon(Icons.chat, size: 25))
                  : Container(),
              IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const NotificationsPage())),
                  icon: const Icon(Icons.notifications_rounded, size: 25)),
            ]),
        body: Padding(
          padding: const EdgeInsets.only(left: 2, right: 2),
          child: IndexedStack(index: currentIndex, children: pages),
        ),
        bottomNavigationBar: NavigationBar(
          indicatorColor: theme.primaryColor,
          destinations: bottomNavItems,
          selectedIndex: currentIndex,
          onDestinationSelected: (value) {
            ref.read(bottomNavIndexProvider.notifier).update((state) => value);
          },
        ));
  }
}
