// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:thumb_app/components/search_page/search_card.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/loading_page.dart';

import '../../data/types/ride.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Ride>> _rideList;

  Future<List<Ride>> _getSearchResults() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }
    // TODO: hide rides that currentUser is passenger on from the user
    final result = await supabase
        .from('ride')
        .select('*, ride_passenger(passenger_user_id)')
        .gte('datetime', DateTime.now())
        .not('driver_user_id', 'eq', user.id)
        .order('datetime', ascending: true);
    return result.map((item) => Ride.fromJson(item)).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _rideList = _getSearchResults();
    });
  }

  @override
  void initState() {
    super.initState();
    _rideList = _getSearchResults();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Testing will require two devices publishing or an admin making new rides
    //TODO: add chips for filters
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder(
          future: _rideList,
          builder: (BuildContext context, AsyncSnapshot<List<Ride>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const LoadingPage();
              case ConnectionState.done:
                return ListView.builder(
                    itemCount: snapshot.data!.length > 1 ? snapshot.data!.length : 1,
                    itemBuilder: (ctx, index) {
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                      if (snapshot.data!.isEmpty) {
                        const Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Center(child: Text('No results!')),
                        );
                      }
                      return SearchCard(ride: snapshot.data![index]);
                    });

              default:
                return ListView.builder(
                    itemCount: 1,
                    itemBuilder: (ctx, builder) =>
                        const Center(child: Text('Something unaccounted for has occurred...')));
            }
          }),
    );
  }
}
