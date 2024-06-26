import 'package:flutter/material.dart';
import 'package:thumb_app/components/profile_page/friend_list.dart';
import 'package:thumb_app/components/profile_page/profile_search.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/pages/profile/visiting_profile_page.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('My Friends'), actions: [
          IconButton(
              onPressed: () async {
                final Profile? result = await showSearch(
                    context: context,
                    delegate: ProfileSearch(
                        'Search by first name, last name, or email'));
                if (result != null && context.mounted) {
                  debugPrint('${result.firstName} ${result.lastName} clicked');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          VisitingProfilePage(authId: result.authId)));
                }
              },
              icon: const Icon(Icons.add))
        ]),
        body: const FriendList());
  }
}
