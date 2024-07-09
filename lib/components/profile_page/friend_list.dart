import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/profile_photo.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/components/shared/loading_page.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/profile/visiting_profile_page.dart';
import 'package:thumb_app/services/supabase_service.dart';
import 'package:thumb_app/styles/button_styles.dart';

class FriendList extends StatefulWidget {
  const FriendList({super.key, required this.queryFn, required this.type});

  final Future<List<Profile>> Function() queryFn;
  final String type;

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  late Future<List<Profile>> _profileList;

  void _unfollow(String authIdToUnfollow) async {
    try {
      await SupabaseService.unfollow(
          authIdToUnfollow, supabase.auth.currentUser!.id);
      if (mounted) {
        ShowSuccessSnackBar(context, 'Account unfollowed.');
      }
    } catch (err) {
      debugPrint(err.toString());
      if (mounted) {
        ShowErrorSnackBar(
            context,
            'Error unfollowing account. Try again later.',
            'friends_list.unfollow(): ${err.toString()}');
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }
  }

  void _removeFollower(String authIdToRemove) {
    try {
      SupabaseService.removeFollower(authIdToRemove);
      if (mounted) {
        ShowSuccessSnackBar(context, 'Account removed from followers.');
      }
    } catch (err) {
      debugPrint(err.toString());
      if (mounted) {
        ShowErrorSnackBar(
            context,
            'Error removing follower account. Try again later.',
            'friends_list.removeFollower(): ${err.toString()}');
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }
  }

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

  void _openUnfollowDialog(BuildContext context, Profile acctToUnfollow) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unfollow ${acctToUnfollow.firstName}?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
            'Unfollowing ${acctToUnfollow.firstName} ${acctToUnfollow.lastName} will result in their public rides not showing up in your activity feed.',
            style: Theme.of(context).textTheme.bodySmall),
        actions: <Widget>[
          TextButton(
            style: squareSmallButton,
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            style: squareSmallButton,
            child: const Text('Unfollow'),
            onPressed: () => _unfollow(acctToUnfollow.authId),
          ),
        ],
      ),
    );
  }

  void _openRemoveFollowerDialog(BuildContext context, Profile acctToRemove) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove ${acctToRemove.firstName} as follower?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
            'Removing ${acctToRemove.firstName} ${acctToRemove.lastName} as a follower will result in this user not seeing your public rides in their activity feed.',
            style: Theme.of(context).textTheme.bodySmall),
        actions: <Widget>[
          TextButton(
            style: squareSmallButton,
            child: const Text('Keep'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            style: squareSmallButton,
            child: const Text('Remove'),
            onPressed: () => _removeFollower(acctToRemove.authId),
          ),
        ],
      ),
    );
  }

  void _handleActionClick(Profile acctToAction) {
    debugPrint(widget.type);
    showModalBottomSheet(
        showDragHandle: true,
        constraints: const BoxConstraints(maxWidth: 640),
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          widget.type == 'FOLLOWING'
                              ? 'Follow Options'
                              : 'Follower Options',
                          style: Theme.of(context).textTheme.titleMedium),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close))
                    ],
                  ),
                ),
                const Divider(),
                if (widget.type == 'FOLLOWING')
                  ListTile(
                    title: Text('Unfollow',
                        style: Theme.of(context).textTheme.bodyMedium),
                    onTap: () => _openUnfollowDialog(context, acctToAction),
                  ),
                if (widget.type == 'FOLLOWERS')
                  ListTile(
                    title: Text('Remove follower',
                        style: Theme.of(context).textTheme.bodyMedium),
                    onTap: () =>
                        _openRemoveFollowerDialog(context, acctToAction),
                  ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refreshHistory,
        child: FutureBuilder(
            future: _profileList,
            builder:
                (BuildContext context, AsyncSnapshot<List<Profile>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const LoadingPage();
                case ConnectionState.done:
                  return ListView.builder(
                      itemCount:
                          snapshot.data!.length > 1 ? snapshot.data!.length : 1,
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
                              onPressed: () =>
                                  _handleActionClick(snapshot.data![index]),
                              style: squareSmallButton,
                              child: const Text('Actions')),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => VisitingProfilePage(
                                      authId: snapshot.data![index].authId))),
                        );
                      });
                default:
                  return const Center(
                      child: Text('Something unaccounted for has occurred...'));
              }
            }));
  }
}
