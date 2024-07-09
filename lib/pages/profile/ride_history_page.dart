import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/ride_list.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/services/supabase_service.dart';

class RideHistoryPage extends StatelessWidget {
  const RideHistoryPage({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History ${profile.email}'),
      ),
      body: RideList(
          queryFn: () => SupabaseService.getRideHistory(profile.authId),
          isActivityRideList: false),
    );
  }
}
