import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.title, required this.iconData, required this.navigationDestination});

  final String title;
  final IconData iconData;
  final Widget navigationDestination;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => navigationDestination)),
          child: Card(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    iconData,
                    size: 48,
                  ),
                )
              ],
            ),
          ),
    ));
  }
}
