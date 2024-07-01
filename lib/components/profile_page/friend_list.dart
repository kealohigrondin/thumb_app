import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/profile_photo.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/components/shared/loading_page.dart';
import 'package:thumb_app/pages/profile/visiting_profile_page.dart';

class FriendList extends StatefulWidget {
  const FriendList({super.key, required this.queryFn});

  final Future<List<Profile>> Function() queryFn;

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  late Future<List<Profile>> _profileList;

  @override
  void initState() {
    super.initState();
    _profileList = widget.queryFn();
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _profileList = widget.queryFn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refreshHistory,
        child: FutureBuilder(
            future: _profileList,
            builder: (BuildContext context, AsyncSnapshot<List<Profile>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const LoadingPage();
                case ConnectionState.done:
                  return ListView.builder(
                      itemCount: snapshot.data!.length > 1 ? snapshot.data!.length : 1,
                      itemBuilder: (ctx, index) {
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }
                        if (snapshot.data!.isEmpty) {
                          return const Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: Center(child: Text('No profiles!')));
                        }
                        return ListTile(
                          leading: ProfilePhoto(
                              initials:
                                  '${snapshot.data![index].firstName[0]}${snapshot.data![index].lastName[0]}',
                              authId: snapshot.data![index].authId,
                              radius: 20),
                          title: Text(
                              '${snapshot.data![index].firstName} ${snapshot.data![index].lastName}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          trailing: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                                textStyle: Theme.of(context).textTheme.labelSmall),
                            onPressed: () => debugPrint('action pressed'),
                            child: const Text('Actions'),
                          ),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  VisitingProfilePage(authId: snapshot.data![index].authId))),
                        );
                      });
                default:
                  return const Center(child: Text('Something unaccounted for has occurred...'));
              }
            }));
  }
}
