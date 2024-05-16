import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thumb_app/pages/bottom_nav_pages/account_page.dart';
import 'package:thumb_app/pages/bottom_nav_pages/home_page.dart';
import 'package:thumb_app/pages/bottom_nav_pages/publish_ride_page.dart';
import 'package:thumb_app/pages/bottom_nav_pages/search_page.dart';

final bottomNavIndexProvider = StateProvider((ref) => 0);

class NavigationContainerPage extends ConsumerWidget {
  const NavigationContainerPage({super.key});

  static final bottomNavItems = [
    const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
    const NavigationDestination(icon: Icon(Icons.add), label: 'Publish'),
    const NavigationDestination(
        icon: Icon(Icons.airport_shuttle), label: 'Rides'),
    const NavigationDestination(icon: Icon(Icons.person), label: 'Account'),
  ];

  static final pages = [
    const HomePage(),
    const SearchPage(),
    const PublishRidePage(),
    Container(color: Colors.deepPurple),
    const AccountPage()
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(6),
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
