import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/profile_photo.dart';
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
import 'package:thumb_app/styles/button_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.visiting, this.authId});

  final bool visiting;
  final String? authId;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Profile> _profile;
  late Future<bool> _isFollowing;

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      if (mounted) {
        ShowErrorSnackBar(context, 'Unexpected error occurred.', error.toString());
      }
    } finally {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    }
  }

  void _follow() async {
    try {
      await SupabaseService.follow(widget.authId!);
      if (mounted) {
        ShowSuccessSnackBar(context, 'Account followed.');
      }
    } catch (err) {
      if (mounted) {
        ShowErrorSnackBar(context, 'Error following account. Try again later.', 'profilePage.follow(): ${err.toString()}');
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _unfollow() async {
    try {
      await SupabaseService.unfollow(widget.authId!, supabase.auth.currentUser!.id);
      if (mounted) {
        ShowSuccessSnackBar(context, 'Account unfollowed.');
      }
    } catch (err) {
      debugPrint(err.toString());
      if (mounted) {
        ShowErrorSnackBar(context, 'Error unfollowing account. Try again later.', 'profilePage.unfollow): ${err.toString()}');
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _refreshProfile() async {
    final result = SupabaseService.getProfile(widget.visiting ? widget.authId! : supabase.auth.currentUser!.id);
    setState(() {
      _profile = result;
    });
    if (widget.visiting) {
      _isFollowing = (widget.visiting ? SupabaseService.isFollowing(widget.authId!, supabase.auth.currentUser!.id) : null)!;
    }
  }

  @override
  void initState() {
    super.initState();
    _profile = SupabaseService.getProfile(widget.visiting ? widget.authId! : supabase.auth.currentUser!.id);
    if (widget.visiting && widget.authId != null) {
      _isFollowing = SupabaseService.isFollowing(widget.authId!, supabase.auth.currentUser!.id);
    }
  }

  Widget _getProfileHeader(Profile profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
      child: Column(children: [
        Row(children: [
          ProfilePhoto(initials: '${profile.firstName[0]}${profile.lastName[0]}', authId: profile.authId),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${profile.firstName} ${profile.lastName}', style: Theme.of(context).textTheme.titleMedium),
            Text(profile.email),
          ])
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
              child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(profile.bio),
          )),
          if (widget.visiting)
            FutureBuilder(
              future: _isFollowing,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return FilledButton(
                        onPressed: null,
                        style: squareSmallButton,
                        child: const Padding(padding: EdgeInsets.fromLTRB(0, 0, 2, 0), child: Text('Loading')));
                  case ConnectionState.done:
                    if (!snapshot.data!) {
                      return FilledButton.icon(
                          icon: const Padding(
                            padding: EdgeInsets.fromLTRB(2, 0, 0, 0),
                            child: Icon(Icons.person_add),
                          ),
                          label: const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 2, 0),
                            child: Text('Follow'),
                          ),
                          onPressed: _follow,
                          style: squareSmallButton);
                    } else {
                      return OutlinedButton.icon(
                          icon: const Padding(
                            padding: EdgeInsets.fromLTRB(2, 0, 0, 0),
                            child: Icon(Icons.person_remove),
                          ),
                          label: const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 2, 0),
                            child: Text('Unfollow'),
                          ),
                          onPressed: _unfollow,
                          style: squareSmallButton);
                    }
                  default:
                    return FilledButton(
                        onPressed: null,
                        style: squareSmallButton,
                        child: const Padding(padding: EdgeInsets.fromLTRB(0, 0, 2, 0), child: Text('Error')));
                }
              },
            ),
        ])
      ]),
    );
  }

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
                    return ListView.builder(itemCount: 1, itemBuilder: (ctx, index) => Text(snapshot.error.toString()));
                  }
                  return ListView(
                    children: [
                      _getProfileHeader(snapshot.data!),
                      ListTile(
                        title: const Row(
                          children: [
                            Icon(Icons.airport_shuttle),
                            SizedBox(width: 8),
                            Text('Rides'),
                          ],
                        ),
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) => RideHistoryPage(profile: snapshot.data!))),
                      ),
                      ListTile(
                          title: const Row(
                            children: [
                              Icon(Icons.group),
                              SizedBox(width: 8),
                              Text('Friends'),
                            ],
                          ),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FriendsPage(
                                    authId: snapshot.data!.authId,
                                  )))),
                      ListTile(
                          title: const Row(children: [Icon(Icons.garage), SizedBox(width: 8), Text('Garage')]),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GaragePage()))),
                      const Divider(),
                      if (!widget.visiting)
                        ListTile(
                            title: const Row(children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit Profile'),
                            ]),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileEditPage()))),
                      if (!widget.visiting)
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
                  return const Center(child: Text('Something unaccounted for has occurred...'));
              }
            }));
  }
}
