import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/ride_list.dart';
import 'package:thumb_app/pages/rides/publish_ride_page.dart';
import 'package:thumb_app/services/supabase_service.dart';

class RidesPage extends StatelessWidget {
  const RidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const TabBar(tabs: [
          Tab(icon: Icon(Icons.history)),
          Tab(icon: Icon(Icons.calendar_month))
        ]),
        body: const TabBarView(
          children: [
            RideList(
                queryFn: SupabaseService.getRideHistory,
                isActivityRideList: false),
            RideList(
                queryFn: SupabaseService.getRidesPlanned,
                isActivityRideList: false),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PublishRidePage()))),
      ),
    );
  }
}
