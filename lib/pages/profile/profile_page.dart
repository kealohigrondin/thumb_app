import 'package:flutter/material.dart';
import 'package:thumb_app/components/profile_page/profile_header.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/login_page.dart';
import 'package:thumb_app/pages/profile/friends_page.dart';
import 'package:thumb_app/pages/profile/garage_page.dart';
import 'package:thumb_app/components/shared/loading_page.dart';
import 'package:thumb_app/pages/profile/profile_edit_page.dart';
import 'package:thumb_app/pages/profile/ride_history_page.dart';
import 'package:thumb_app/services/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.authId});

  final String? authId;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Profile> _profile;
  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      if (mounted) {
        ShowErrorSnackBar(
            context, 'Unexpected error occurred.', error.toString());
      }
    } finally {
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
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
                  return ListView(
                    children: [
                      ProfileHeader(profile: snapshot.data!),
                      ListTile(
                        title: const Row(
                          children: [
                            Icon(Icons.airport_shuttle),
                            SizedBox(width: 8),
                            Text('Rides'),
                          ],
                        ),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const RideHistoryPage())),
                      ),
                      ListTile(
                          title: const Row(
                            children: [
                              Icon(Icons.group),
                              SizedBox(width: 8),
                              Text('Friends'),
                            ],
                          ),
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FriendsPage(
                                        authId: supabase.auth.currentUser!.id,
                                      )))),
                      ListTile(
                          title: const Row(children: [
                            Icon(Icons.garage),
                            SizedBox(width: 8),
                            Text('Garage')
                          ]),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const GaragePage()))),
                      const Divider(),
                      ListTile(
                          title: const Row(children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit Profile'),
                          ]),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfileEditPage()))),
                      ListTile(
                        title: const Row(children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Sign out'),
                        ]),
                        onTap: _signOut,
                      )
                    ],
                  );

                default:
                  return const Center(
                      child: Text('Something unaccounted for has occurred...'));
              }
            }));
  }
}
