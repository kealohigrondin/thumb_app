import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/ride_list.dart';
import 'package:thumb_app/services/supabase_service.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO: add chips for filters
    return const RideList(
        queryFn: SupabaseService.getRideSearchResults, isActivityRideList: false);
  }
}
