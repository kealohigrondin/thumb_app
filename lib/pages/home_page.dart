import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/ride_list.dart';
import 'package:thumb_app/services/supabase_service.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

   @override
  Widget build(BuildContext context) {
    return const RideList(queryFn: SupabaseService.getActivityData, isActivityRideList: true);
  }
}
