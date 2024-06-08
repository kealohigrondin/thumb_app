import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thumb_app/pages/bottom_nav_pages/profile_page.dart';
import 'package:thumb_app/pages/bottom_nav_pages/home_page.dart';
import 'package:thumb_app/pages/bottom_nav_pages/publish_ride_page.dart';
import 'package:thumb_app/pages/bottom_nav_pages/rides_page.dart';
import 'package:thumb_app/pages/bottom_nav_pages/search_page.dart';
import 'package:thumb_app/pages/chat_page.dart';

final bottomNavIndexProvider = StateProvider((ref) => 0);

class NavigationContainerPage extends ConsumerWidget {
  const NavigationContainerPage({super.key});

  static final bottomNavItems = [
    const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
    const NavigationDestination(icon: Icon(Icons.airport_shuttle), label: 'Rides'),
    const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
  ];

  static final pageTitles = ['Home', 'Find a ride', 'My Rides', 'Profile'];

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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(pageTitles[currentIndex]),
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => const ChatPage())),
                  icon: const Icon(Icons.chat, size: 25))
            ]),
        body: Padding(
          padding: const EdgeInsets.all(6),
          child: IndexedStack(index: currentIndex, children: pages),
        ),
        floatingActionButton: currentIndex == 3
            ? null
            : FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const PublishRidePage()))),
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
