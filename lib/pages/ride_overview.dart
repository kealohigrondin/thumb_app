import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thumb_app/components/shared/center_progress_indicator.dart';
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
      ShowErrorSnackBar(
          context, 'Error requesting ride! Try again later.', error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getPassengers(),
      builder: (BuildContext context,
          AsyncSnapshot<List<RidePassengerProfile>> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(children: [
                      Text(widget.ride.title!,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(
                          DateFormat.MMMd()
                              .add_jm()
                              .format(widget.ride.dateTime),
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Text(widget.ride.description!,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.ride.departAddress!,
                                style: Theme.of(context).textTheme.bodyMedium),
                            const Icon(Icons.arrow_downward),
                            Text(widget.ride.arriveAddress!,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ]),
                      const SizedBox(height: 24),
                      snapshot.data!.isNotEmpty
                          ? Column(
                              children: snapshot.data!
                                  .map((passenger) => Text(
                                      '${passenger.firstName} ${passenger.lastName} --- ${passenger.status}'))
                                  .toList(),
                            )
                          : const Text('No passengers!'),
                      const SizedBox(height: 24),
                      const Text('driver details'),
                      const SizedBox(height: 24),
                      const Text('car details'),
                    ]),
                  ),
                  FilledButton(
                      onPressed: _handleRequestToJoin,
                      child: const Text('Request to Join'))
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
