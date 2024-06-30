import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/ride_list.dart';
import 'package:thumb_app/services/supabase_service.dart';

class RideHistoryPage extends StatelessWidget {
  const RideHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
      ),
      body: const RideList(
          queryFn: SupabaseService.getRideHistory, isActivityRideList: false),
    );
  }
}
