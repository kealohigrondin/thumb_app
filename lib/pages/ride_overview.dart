import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thumb_app/components/shared/center_progress_indicator.dart';
import 'package:thumb_app/components/ride_overview_page/ride_passenger_list.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/enums/ride_passenger_status.dart';
import 'package:thumb_app/data/types/passenger_profile.dart';

import '../data/types/ride.dart';
import '../main.dart';

class RideOverview extends StatefulWidget {
  const RideOverview({super.key, required this.ride});

  final Ride ride;

  @override
  State<RideOverview> createState() => _RideOverviewState();
}

class _RideOverviewState extends State<RideOverview> {
  late Future<List<PassengerProfile>> _passengerList;

  Future<List<PassengerProfile>> _getPassengers() async {
    try {
      var result = await supabase
          .from('ride_passenger')
          .select('passenger_user_id, status, profile(first_name, last_name)')
          .eq('ride_id', widget.ride.id!);
      List<PassengerProfile> ridePassengerProfile =
          result.map((item) => PassengerProfile.fromJson(item)).toList();
      return ridePassengerProfile;
    } catch (err) {
      debugPrint(err.toString());
      return [];
    }
  }

  void _showInstantBookWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm instant booking?', style: Theme.of(context).textTheme.titleMedium),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            FilledButton(onPressed: _handleRequestToJoin, child: const Text('Confirm'))
          ],
        );
      },
    );
  }

  void _handleRequestToJoin() async {
    debugPrint('handle request to join ride');

    try {
      dynamic values = {
        'ride_id': widget.ride.id!,
        'passenger_user_id': supabase.auth.currentUser!.id,
        'requestor_user_id': supabase.auth.currentUser!.id,
      };
      if (widget.ride.enableInstantBook) {
        values = {...values, 'status': RidePassengerStatus.confirmed.toShortString()};
      }
      await supabase.from('ride_passenger').upsert(values);
      // TODO: notify driver that a passenger request was made
      if (mounted) {
        Navigator.of(context).pop();
        ShowSuccessSnackBar(
            context, widget.ride.enableInstantBook ? 'Ride Joined!' : 'Ride Requested!');
        _refresh();
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      ShowErrorSnackBar(context, 'Error requesting ride! Try again later.', error.toString());
    }
  }

  void _updatePassengerStatus(RidePassengerStatus newStatus, String passengerUserId) async {
    try {
      // create row in ride_passenger table
      //don't need to pass in intial status or created_at since those are created on the db side
      await supabase
          .from('ride_passenger')
          .update({'status': newStatus.toShortString()})
          .eq('ride_id', widget.ride.id!)
          .eq('passenger_user_id', passengerUserId);
      if (mounted) {
        ShowSuccessSnackBar(context, 'Update saved!');
        _refresh();
      }
    } catch (error) {
      ShowErrorSnackBar(
          // ignore: use_build_context_synchronously
          context,
          'Error updating ride! Try again later.',
          error.toString());
    }
    debugPrint('passenger status changed to $newStatus');
  }

  Widget _displayActionButtons(bool isCurrentUserConfirmedPassenger) {
    final currentUserId = supabase.auth.currentUser!.id;
    if (currentUserId == widget.ride.driverUserId) {
      return const TextButton(onPressed: null, child: Text('You are driver'));
    } else if (isCurrentUserConfirmedPassenger) {
      return OutlinedButton(
          style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error)), // Border color

          onPressed: () => _updatePassengerStatus(RidePassengerStatus.cancelled, currentUserId),
          child: const Text('Cancel Ride'));
    }
    return FilledButton(
        onPressed: () {
          if (widget.ride.enableInstantBook) {
            return _showInstantBookWarningDialog();
          }
          _handleRequestToJoin();
        },
        child: Text(widget.ride.enableInstantBook ? 'Instant Book' : 'Request to Join'));
  }

  Future<void> _refresh() async {
    setState(() {
      _passengerList = _getPassengers();
    });
  }

  @override
  void initState() {
    super.initState();
    _passengerList = _getPassengers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ride Overview'),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder(
            future: _passengerList,
            builder: (BuildContext context, AsyncSnapshot<List<PassengerProfile>> snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else if (snapshot.hasData) {
                return SafeArea(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(children: [
                          Text(widget.ride.title!, style: Theme.of(context).textTheme.titleLarge),
                          Text(DateFormat.MMMd().add_jm().format(widget.ride.dateTime),
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          Text(widget.ride.description!),
                          const SizedBox(height: 24),
                          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(widget.ride.departAddress!),
                            const Icon(Icons.arrow_downward),
                            Text(widget.ride.arriveAddress!),
                          ]),
                          const SizedBox(height: 24),
                          Text('Passengers', style: Theme.of(context).textTheme.titleMedium),
                          RidePassengerList(
                            passengerList: snapshot.data!,
                            driverUserId: widget.ride.driverUserId!,
                            rideId: widget.ride.id!,
                          ),
                          const SizedBox(height: 24),
                          //TODO: Hide driver section if currentUser is driver
                          Text('Driver', style: Theme.of(context).textTheme.titleMedium),
                          Text(widget.ride.driverUserId!),
                          const SizedBox(height: 24),
                          Text('Vehicle', style: Theme.of(context).textTheme.titleMedium),
                        ]),
                      ),
                      _displayActionButtons(snapshot.data!
                          .where((element) =>
                              element.passengerUserId == supabase.auth.currentUser!.id &&
                              element.status == RidePassengerStatus.confirmed)
                          .isNotEmpty)
                    ],
                  ),
                ));
              } else {
                return const CenterProgressIndicator();
              }
            },
          ),
        ));
  }
}
