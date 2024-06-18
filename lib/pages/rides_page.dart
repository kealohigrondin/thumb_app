import 'package:flutter/material.dart';
import 'package:thumb_app/components/search_page/search_card.dart';
import 'package:thumb_app/data/enums/ride_passenger_status.dart';
import 'package:thumb_app/data/types/ride.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/publish_ride_page.dart';
import 'package:thumb_app/pages/loading_page.dart';
import 'package:thumb_app/services/supabase_service.dart';

class RidesPage extends StatefulWidget {
  const RidesPage({super.key});

  @override
  State<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends State<RidesPage> {
  late Future<List<Ride>> _rideHistoryList;
  late Future<List<Ride>> _ridePlannedList;

  Widget renderRideList(
      BuildContext context, AsyncSnapshot<List<Ride>> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return const LoadingPage();
      case ConnectionState.done:
        if (snapshot.hasError) {
          return ListView.builder(
              itemCount: 1,
              itemBuilder: (ctx, index) => Text(snapshot.error.toString()));
        }
        if (snapshot.data!.isEmpty) {
          return ListView.builder(
              itemCount: 1,
              itemBuilder: (ctx, index) => const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Center(child: Text('No rides!')),
                  ));
        }
        return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) =>
                SearchCard(ride: snapshot.data![index]));
      default:
        return const Center(
            child: Text('Something unaccounted for has occurred...'));
    }
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _rideHistoryList = SupabaseService.getRideHistory();
    });
  }

  Future<void> _refreshPlanned() async {
    setState(() {
      _ridePlannedList = SupabaseService.getRidesPlanned();
    });
  }

  @override
  void initState() {
    super.initState();
    _rideHistoryList = SupabaseService.getRideHistory();
    _ridePlannedList = SupabaseService.getRidesPlanned();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const TabBar(tabs: [
          Tab(icon: Icon(Icons.history)),
          Tab(icon: Icon(Icons.calendar_month))
        ]),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _refreshHistory,
              child: FutureBuilder(
                  future: _rideHistoryList,
                  builder: (BuildContext context,
                          AsyncSnapshot<List<Ride>> snapshot) =>
                      renderRideList(context, snapshot)),
            ),
            RefreshIndicator(
              onRefresh: _refreshPlanned,
              child: FutureBuilder(
                  future: _ridePlannedList,
                  builder: (BuildContext context,
                          AsyncSnapshot<List<Ride>> snapshot) =>
                      renderRideList(context, snapshot)),
            ),
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
