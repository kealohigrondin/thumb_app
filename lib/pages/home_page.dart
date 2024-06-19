import 'package:flutter/material.dart';
import 'package:thumb_app/components/home_page/activity_card.dart';
import 'package:thumb_app/pages/loading_page.dart';
import 'package:thumb_app/services/supabase_service.dart';

import '../data/types/ride.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Ride>> _rideList;

  @override
  void initState() {
    super.initState();
    _rideList = SupabaseService.getActivityData();
  }

  Future<void> _refresh() async {
    final result = SupabaseService.getActivityData();
    setState(() {
      _rideList = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder(
          future: _rideList,
          builder: (BuildContext context, AsyncSnapshot<List<Ride>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const LoadingPage();
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return ListView.builder(
                      itemCount: 1, itemBuilder: (ctx, index) => Text(snapshot.error.toString()));
                }
                if (snapshot.data!.isEmpty) {
                  return ListView.builder(
                      itemCount: 1,
                      itemBuilder: (ctx, index) => const Padding(
                            padding: EdgeInsets.only(top: 32),
                            child: Center(child: Text('No Activity!')),
                          ));
                }
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (ctx, index) => ActivityCard(ride: snapshot.data![index]));
              default:
                return const Center(child: Text('Something unaccounted for has occurred...'));
            }
          }),
    );
  }
}
