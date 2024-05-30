import 'package:flutter/material.dart';
import 'package:thumb_app/pages/bottom_nav_pages/publish_ride_page.dart';
import 'package:thumb_app/pages/loading_screen.dart';

import '../../components/search_page/search_card.dart';
import '../../data/types/ride.dart';
import '../../main.dart';

class RidesPage extends StatelessWidget {
  const RidesPage({super.key});

  Future<List<Ride>> _getRideHistory() async {
    if (supabase.auth.currentUser == null) {
      return [];
    }
    final result = await supabase
        .from('ride')
        .select()
        .eq('driver_user_id', supabase.auth.currentUser!.id)
        .lte('datetime', DateTime.now());
    return result.map((item) => Ride.fromJson(item)).toList();
  }

  Future<List<Ride>> _getRidesPlanned() async {
    if (supabase.auth.currentUser == null) {
      return [];
    }
    final result = await supabase
        .from('ride')
        .select()
        .eq('driver_user_id', supabase.auth.currentUser!.id)
        .gte('datetime', DateTime.now());
    return result.map((item) => Ride.fromJson(item)).toList();
  }

  Widget renderRideList(BuildContext context, AsyncSnapshot<List<Ride>> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return const LoadingScreen();
      case ConnectionState.done:
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No rides!'));
        }
        return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) => SearchCard(ride: snapshot.data![index]));
      default:
        return const Center(child: Text('Something unaccounted for has occurred...'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
          child: Scaffold(
        appBar: const TabBar(
            tabs: [Tab(icon: Icon(Icons.history)), Tab(icon: Icon(Icons.calendar_month))]),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: TabBarView(
            children: [
              FutureBuilder(
                  future: _getRideHistory(),
                  builder: (BuildContext context, AsyncSnapshot<List<Ride>> snapshot) =>
                      renderRideList(context, snapshot)),
              FutureBuilder(
                  future: _getRidesPlanned(),
                  builder: (BuildContext context, AsyncSnapshot<List<Ride>> snapshot) =>
                      renderRideList(context, snapshot))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => const PublishRidePage()))),
      )),
    );
  }
}
