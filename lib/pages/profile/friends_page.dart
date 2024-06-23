import 'package:flutter/material.dart';
import 'package:thumb_app/components/profile_page/friend_list.dart';
import 'package:thumb_app/pages/profile/search_profile_page.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('My Friends'), actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SearchProfilePage())),
              icon: const Icon(Icons.add))
        ]),
        body: const FriendList());
  }
}
