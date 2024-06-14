import 'package:flutter/material.dart';
import 'package:thumb_app/components/search_page/search_card.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/enums/ride_passenger_status.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/data/types/ride.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/loading_page.dart';
import 'package:thumb_app/pages/profile_edit_page.dart';
import 'package:thumb_app/styles/button_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.authId});

  final String? authId;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Profile> _profile;
  late Future<List<Ride>> _rideHistoryList;

  Future<List<Ride>> _getRideHistory() async {
    if (supabase.auth.currentUser == null) {
      return [];
    }
    try {
      final passengerRides = await supabase
          .from('ride_passenger')
          .select('ride(*)')
          .eq('passenger_user_id', supabase.auth.currentUser!.id)
          .inFilter('status', [
        RidePassengerStatus.confirmed.toShortString(),
        RidePassengerStatus.requested.toShortString()
      ]).lte('ride.datetime', DateTime.now());
      final passengerRideList =
          passengerRides.map((item) => Ride.fromJson(item['ride'])).toList();
      final driverRides = await supabase
          .from('ride')
          .select()
          .eq('driver_user_id', supabase.auth.currentUser!.id)
          .lte('datetime', DateTime.now());
      List<Ride> result =
          driverRides.map((item) => Ride.fromJson(item)).toList();
      result += passengerRideList;
      result.sort((ride1, ride2) => ride1.dateTime.compareTo(ride2.dateTime));
      return result;
    } catch (err) {
      debugPrint(err.toString());
      return [];
    }
  }

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

  Future<void> _refreshHistory() async {
    setState(() {
      _rideHistoryList = _getRideHistory();
    });
  }

  Future<Profile> _getProfile() async {
    try {
      final result = await supabase
          .from('profile')
          .select()
          .eq('auth_id', widget.authId ?? supabase.auth.currentUser!.id)
          .single();
      return Profile.fromJson(result);
    } catch (error) {
      if (mounted) {
        ShowErrorSnackBar(
            context, 'Unexpected error occurred.', error.toString());
      }
      return Profile();
    }
  }

  Future<void> _refresh() async {
    final result = _getProfile();
    setState(() {
      _profile = result;
    });
  }

  @override
  void initState() {
    super.initState();
    _profile = _getProfile();
    _rideHistoryList = _getRideHistory();
  }

  // TODO: refresh when navigating back from edit profile page
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refresh,
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
                        Expanded(
                            child: DefaultTabController(
                          length: 3,
                          child: Scaffold(
                            appBar: const TabBar(
                              tabs: [
                                Tab(child: Text('Friends')),
                                Tab(child: Text('My Garage')),
                                Tab(child: Text('Ride History')),
                              ],
                            ),
                            body: TabBarView(
                              children: [
                                const Text('friends'),
                                const Text('cars'),
                                RefreshIndicator(
                                  onRefresh: _refreshHistory,
                                  child: FutureBuilder(
                                      future: _rideHistoryList,
                                      builder: (BuildContext context,
                                              AsyncSnapshot<List<Ride>>
                                                  snapshot) =>
                                          renderRideList(context, snapshot)),
                                ),
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
