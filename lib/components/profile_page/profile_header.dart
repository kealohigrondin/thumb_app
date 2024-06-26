import 'package:flutter/material.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/profile/profile_edit_page.dart';
import 'package:thumb_app/styles/button_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
      child: Column(children: [
        Row(children: [
          CircleAvatar(
              radius: 45,
              child: Text('${profile.firstName[0]}${profile.lastName[0]}',
                  style: const TextStyle(fontSize: 32))),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${profile.firstName} ${profile.lastName}',
                style: Theme.of(context).textTheme.titleMedium),
            Text(profile.email),
          ])
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
              child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(profile.bio),
          )),
          supabase.auth.currentUser!.id != profile.authId
              ? FilledButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add'),
                  onPressed: () => debugPrint('add friend clicked'),
                  style: squareSmallButton)
              : Container(),
        ])
      ]),
    );
  }
}
