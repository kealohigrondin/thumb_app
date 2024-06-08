import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thumb_app/components/shared/center_progress_indicator.dart';
import 'package:thumb_app/components/ride_overview_page/ride_passenger_list.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/types/ride_passenger_profile.dart';

import '../data/types/ride.dart';
import '../main.dart';

class RideOverview extends StatefulWidget {
  const RideOverview({super.key, required this.ride});

  final Ride ride;

  @override
  State<RideOverview> createState() => _RideOverviewState();
}

class _RideOverviewState extends State<RideOverview> {
  Future<List<RidePassengerProfile>> _getPassengers() async {
    try {
      var result = await supabase
          .from('ride_passenger')
          .select('passenger_user_id, status, profile(first_name, last_name)')
          .eq('ride_id', widget.ride.id!);
      List<RidePassengerProfile> ridePassengerProfile =
          result.map((item) => RidePassengerProfile.fromJson(item)).toList();
      return ridePassengerProfile;
    } catch (err) {
      debugPrint(err.toString());
      return [];
    }
  }

  void _handleRequestToJoin() async {
    debugPrint('handle request to join ride');
    if (widget.ride.enableInstantBook) {
      //TODO: if check for instantbook and show a modal to confirm
    }
    // TODO: disable request button if the current user is already requested and show a 'cancel' button in it's place
    try {
      // create row in ride_passenger table
      //don't need to pass in intial status or created_at since those are created on the db side
      final values = {
        'ride_id': widget.ride.id!,
        'passenger_user_id': supabase.auth.currentUser!.id,
        'requestor_user_id': supabase.auth.currentUser!.id,
      };
      await supabase.from('ride_passenger').upsert(values);
      // TODO: notify driver that a passenger request was made
      if (mounted) {
        Navigator.of(context).pop();
        ShowSuccessSnackBar(context, 'Ride Requested!');
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      ShowErrorSnackBar(context, 'Error requesting ride! Try again later.', error.toString());
    }
  }

  Widget _displayActionButtons(bool isCurrentUserConfirmedPassenger) {
    final currentUserId = supabase.auth.currentUser!.id;
    //TODO: handle driver view
    // if currentUser is passenger and requested, add a 'cancel' button and disable 'book' button or don't show
    // default to show only book button
    // do we show a 'message driver' button here? (maybe stretch)
    //if current user is driver
    //if current user is passenger and confirmed, show cancel button
    //else show book button
    if (currentUserId == widget.ride.driverUserId) {
      return const Text('You are driver');
    } else if (isCurrentUserConfirmedPassenger) {
      // TODO: use passenger_service???
      //return OutlinedButton(onPressed: onPressed, child: child)
    }
    return FilledButton(
        onPressed: () {
          //TODO: handle no seats available, rider already requested or confirmed, etc.
          _handleRequestToJoin();
        },
        child: Text(widget.ride.enableInstantBook ? 'Instant Book' : 'Request to Join'));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getPassengers(),
      builder: (BuildContext context, AsyncSnapshot<List<RidePassengerProfile>> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Text('Ride Overview')],
              ),
            ),
            body: SafeArea(
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
                      // could also update the appbar header to say 'Your Ride' or something if its the driver or a confirmed passenger
                      Text('Driver', style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.ride.driverUserId!),
                      const SizedBox(height: 24),
                      Text('Vehicle', style: Theme.of(context).textTheme.titleMedium),
                    ]),
                  ),
                  _displayActionButtons(snapshot.data!
                      .where(
                          (passenger) => passenger.passengerUserId == supabase.auth.currentUser!.id)
                      .isNotEmpty)
                ],
              ),
            )),
          );
        } else {
          return const CenterProgressIndicator();
        }
      },
    );
  }
}
