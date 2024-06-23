import 'package:flutter/material.dart';
import 'package:thumb_app/components/home_page/activity_card.dart';
import 'package:thumb_app/components/search_page/search_card.dart';
import 'package:thumb_app/data/types/ride.dart';
import 'package:thumb_app/components/shared/loading_page.dart';

class RideList extends StatefulWidget {
  const RideList(
      {super.key, required this.queryFn, required this.isActivityRideList});

  final Future<List<Ride>> Function() queryFn;
  final bool isActivityRideList;

  @override
  State<RideList> createState() => _RideListState();
}

class _RideListState extends State<RideList> {
  late Future<List<Ride>> _rideHistoryList;

  @override
  void initState() {
    super.initState();
    _rideHistoryList = widget.queryFn();
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _rideHistoryList = widget.queryFn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refreshHistory,
        child: FutureBuilder(
            future: _rideHistoryList,
            builder:
                (BuildContext context, AsyncSnapshot<List<Ride>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const LoadingPage();
                case ConnectionState.done:
                  return ListView.builder(
                      itemCount:
                          snapshot.data!.length > 1 ? snapshot.data!.length : 1,
                      itemBuilder: (ctx, index) {
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }
                        if (snapshot.data!.isEmpty) {
                          return const Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: Center(child: Text('No rides!')));
                        }
                        return widget.isActivityRideList
                            ? ActivityCard(ride: snapshot.data![index])
                            : SearchCard(ride: snapshot.data![index]);
                      });
                default:
                  return const Center(
                      child: Text('Something unaccounted for has occurred...'));
              }
            }));
  }
}
