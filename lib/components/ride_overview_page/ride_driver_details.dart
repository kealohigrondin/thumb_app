import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/center_progress_indicator.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/pages/profile/visiting_profile_page.dart';
import 'package:thumb_app/services/supabase_service.dart';

class RideDriverDetails extends StatefulWidget {
  const RideDriverDetails({super.key, required this.driverUserId});
  final String driverUserId;

  @override
  State<RideDriverDetails> createState() => _RideDriverDetailsState();
}

class _RideDriverDetailsState extends State<RideDriverDetails> {
  late final Future<Profile> _driverProfile;

  @override
  void initState() {
    super.initState();
    _driverProfile = SupabaseService.getProfile(widget.driverUserId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _driverProfile,
        builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
          if (snapshot.hasError) {
            ShowErrorSnackBar(context, snapshot.error.toString());
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return ListTile(
              title: Row(children: [
                CircleAvatar(
                  child: Text(
                      '${snapshot.data!.firstName[0]}${snapshot.data!.lastName[0]}'),
                ),
                const SizedBox(width: 4),
                Text(
                    '${snapshot.data!.firstName} ${snapshot.data!.lastName}'),
              ]),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => VisitingProfilePage(
                        authId: snapshot.data!.authId,
                      ))),
            );
          } else {
            return const CenterProgressIndicator();
          }
        });
  }
}
