import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/loading_page.dart';
import 'package:thumb_app/pages/profile_edit_page.dart';
import 'package:thumb_app/pages/search_profile_page.dart';
import 'package:thumb_app/styles/button_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.authId});

  final String authId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Profile> _profile;

  List<Widget> _getActionButtons() {
    if (supabase.auth.currentUser!.id == widget.authId) {
      return [
        FilledButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Add Friends'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SearchProfilePage())),
            style: squareSmallButton)
      ];
    } else {
      return [const Text('not current user')];
    }
  }

  Future<Profile> _getProfile() async {
    //final user = supabase.auth.currentUser;
    try {
      final result = await supabase
          .from('profile')
          .select()
          .eq('auth_id', widget.authId)
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
  }

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
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => debugPrint('profile photo tapped'),
                                child: CircleAvatar(
                                    radius: 45,
                                    child:
                                        Image.asset('assets/images/user.png')),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${snapshot.data!.firstName} ${snapshot.data!.lastName}',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(snapshot.data!.email),
                                ],
                              ),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(snapshot.data!.bio),
                                ),
                                supabase.auth.currentUser!.id == widget.authId
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
                                        onPressed: () => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    const SearchProfilePage())),
                                        style: squareSmallButton),
                              ])
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('data loaded'));
                default:
                  return const Center(
                      child: Text('Something unaccounted for has occurred...'));
              }
            }));
  }
}
