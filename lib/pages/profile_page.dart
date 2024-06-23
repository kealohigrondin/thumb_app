import 'package:flutter/material.dart';
import 'package:thumb_app/components/profile_page/friend_list.dart';
import 'package:thumb_app/components/profile_page/vehicle_list.dart';
import 'package:thumb_app/components/search_page/search_card.dart';
import 'package:thumb_app/components/shared/ride_list.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/data/types/ride.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/loading_page.dart';
import 'package:thumb_app/pages/profile_edit_page.dart';
import 'package:thumb_app/services/supabase_service.dart';
import 'package:thumb_app/styles/button_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.authId});

  final String? authId;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Profile> _profile;

  Widget renderRideList(
      BuildContext context, AsyncSnapshot<List<Ride>> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return const LoadingPage();
      case ConnectionState.done:
        if (snapshot.hasError) {
          return ListView.builder(
              itemCount: 1,
              itemBuilder: (ctx, index) => Text(snapshot.error.toString()));
        }
        if (snapshot.data!.isEmpty) {
          return ListView.builder(
              itemCount: 1,
              itemBuilder: (ctx, index) => const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Center(child: Text('No rides!')),
                  ));
        }
        return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) =>
                SearchCard(ride: snapshot.data![index]));
      default:
        return const Center(
            child: Text('Something unaccounted for has occurred...'));
    }
  }

  Future<void> _refreshProfile() async {
    final result = SupabaseService.getProfile(
        widget.authId ?? supabase.auth.currentUser!.id);
    setState(() {
      _profile = result;
    });
  }

  @override
  void initState() {
    super.initState();
    _profile = SupabaseService.getProfile(
        widget.authId ?? supabase.auth.currentUser!.id);
  }

  // TODO: refresh when navigating back from edit profile page
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refreshProfile,
        child: FutureBuilder(
            future: _profile,
            builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const LoadingPage();
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return ListView.builder(
                        itemCount: 1,
                        itemBuilder: (ctx, index) =>
                            Text(snapshot.error.toString()));
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                                radius: 45,
                                child: Image.asset('assets/images/user.png')),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${snapshot.data!.firstName} ${snapshot.data!.lastName}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text(snapshot.data!.email),
                              ],
                            ),
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(snapshot.data!.bio),
                              )),
                              supabase.auth.currentUser!.id ==
                                      snapshot.data!.authId
                                  ? TextButton.icon(
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit'),
                                      onPressed: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  const ProfileEditPage())),
                                      style: squareSmallButton)
                                  : FilledButton.icon(
                                      icon: const Icon(Icons.person_add),
                                      label: const Text('Add'),
                                      onPressed: () =>
                                          debugPrint('add friend clicked'),
                                      style: squareSmallButton),
                            ]),
                        const Expanded(
                            child: DefaultTabController(
                          length: 3,
                          child: Scaffold(
                            appBar: TabBar(
                              tabs: [
                                Tab(child: Text('Friends')),
                                Tab(child: Text('My Garage')),
                                Tab(child: Text('Ride History')),
                              ],
                            ),
                            body: TabBarView(
                              children: [
                                FriendList(),
                                VehicleList(),
                                RideList(
                                    queryFn: SupabaseService.getRideHistory,
                                    isActivityRideList: false)
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                  );

                default:
                  return const Center(
                      child: Text('Something unaccounted for has occurred...'));
              }
            }));
  }
}
