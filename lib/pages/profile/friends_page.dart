import 'package:flutter/material.dart';
import 'package:thumb_app/components/profile_page/friend_list.dart';
import 'package:thumb_app/components/profile_page/profile_search.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/profile/visiting_profile_page.dart';
import 'package:thumb_app/services/supabase_service.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key, required this.authId});

  final String authId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Friends'), actions: [
          if (authId == supabase.auth.currentUser!.id)
            IconButton(
                onPressed: () async {
                  final Profile? result = await showSearch(
                      context: context,
                      delegate: ProfileSearch('Search by first name, last name, or email'));
                  if (result != null && context.mounted) {
                    debugPrint('${result.firstName} ${result.lastName} clicked');
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VisitingProfilePage(authId: result.authId)));
                  }
                },
                icon: const Icon(Icons.add))
        ]),
        body: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: const TabBar(tabs: [Tab(text: 'Following'), Tab(text: 'Followers')]),
            body: TabBarView(
              children: [
                FriendList(
                    type: 'FOLLOWING', queryFn: () => SupabaseService.getFollowingProfiles(authId)),
                FriendList(
                    type: 'FOLLOWERS', queryFn: () => SupabaseService.getFollowerProfiles(authId)),
              ],
            ),
          ),
        ));
  }
}
