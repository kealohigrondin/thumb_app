import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thumb_app/components/ride_overview_page/ride_driver_details.dart';
import 'package:thumb_app/components/shared/center_progress_indicator.dart';
import 'package:thumb_app/components/ride_overview_page/ride_passenger_list.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/enums/ride_passenger_status.dart';
import 'package:thumb_app/data/types/passenger_profile.dart';
import 'package:thumb_app/pages/chat/chat_page.dart';
import 'package:thumb_app/services/supabase_service.dart';

import '../../data/types/ride.dart';
import '../../main.dart';

class RideOverview extends StatefulWidget {
  const RideOverview({super.key, required this.ride});

  final Ride ride;
  final double horizontalPadding = 12;

  @override
  State<RideOverview> createState() => _RideOverviewState();
}

class _RideOverviewState extends State<RideOverview> {
  late Future<List<PassengerProfile>> _passengerList;

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

  void _updatePassengerStatus(String rideId, RidePassengerStatus status, String passengerUserId) {
    try {
      SupabaseService.updatePassengerStatus(rideId, status, passengerUserId);
      ShowSuccessSnackBar(context, 'Passenger Status updated (pull to refresh)');
    } catch (err) {
      ShowErrorSnackBar(context, 'Error updating passenger status. Try again later.', err.toString());
    }
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
      SupabaseService.upsertPassenger(values);
      // TODO: notify driver that a passenger request was made
      if (mounted) {
        Navigator.of(context).pop();
        ShowSuccessSnackBar(context, widget.ride.enableInstantBook ? 'Ride Joined!' : 'Ride Requested!');
        _refresh();
      }
    } catch (error) {
      if (mounted) {
        ShowErrorSnackBar(context, 'Error requesting ride! Try again later.', error.toString());
      }
    }
  }

  Widget _displayActionButtons(bool isCurrentUserConfirmedPassenger, int confirmedPassengerCount) {
    final currentUserId = supabase.auth.currentUser!.id;
    if (widget.ride.dateTime.compareTo(DateTime.now()) < 0) {
      return const OutlinedButton(onPressed: null, child: Text('Ride has completed'));
    } else if (currentUserId == widget.ride.driverUserId) {
      return const TextButton(onPressed: null, child: Text('You are driver'));
    } else if (isCurrentUserConfirmedPassenger) {
      return OutlinedButton(
          style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error)), // Border color

          onPressed: () => _updatePassengerStatus(widget.ride.id!, RidePassengerStatus.cancelled, currentUserId),
          child: const Text('Cancel Ride'));
    } else if (confirmedPassengerCount == widget.ride.availableSeats) {
      //no seats left
      return const FilledButton(onPressed: null, child: Text('No available seats'));
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
      _passengerList = SupabaseService.getPassengers(widget.ride.id!);
    });
  }

  @override
  void initState() {
    super.initState();
    _passengerList = SupabaseService.getPassengers(widget.ride.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Ride Overview'), actions: [
          if (true) // TODO: restrict chat button to driver and passengers
            IconButton(
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatPage(rideId: widget.ride.id!))),
                icon: const Icon(Icons.chat, size: 25))
        ]),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder(
            future: _passengerList,
            builder: (BuildContext context, AsyncSnapshot<List<PassengerProfile>> snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else if (snapshot.hasData) {
                final bool isCurrentUserConfirmedPassenger = snapshot.data!
                    .where((element) =>
                        element.passengerUserId == supabase.auth.currentUser!.id && element.status == RidePassengerStatus.confirmed)
                    .isNotEmpty;
                return SafeArea(
                    child: Column(
                  children: [
                    Expanded(
                      child: ListView(children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(widget.horizontalPadding, widget.horizontalPadding, 18, 0),
                          child: Text(widget.ride.title!, style: Theme.of(context).textTheme.titleLarge),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: widget.horizontalPadding),
                          child: Text(DateFormat.MMMd().add_jm().format(widget.ride.dateTime),
                              style: Theme.of(context).textTheme.labelLarge),
                        ),
                        const SizedBox(height: 8),
                        if (widget.ride.description!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: widget.horizontalPadding),
                            child: Text(widget.ride.description!),
                          )
                        else
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: widget.horizontalPadding),
                            child: Text(
                              'No description',
                              style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic),
                            ),
                          ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: widget.horizontalPadding),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(widget.ride.departAddress!),
                            const Icon(Icons.arrow_downward),
                            Text(widget.ride.arriveAddress!),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: widget.horizontalPadding),
                          child: Row(
                            children: [
                              Text('Passengers', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(width: 4),
                              Text(
                                  '(${widget.ride.availableSeats! - snapshot.data!.length} ${widget.ride.availableSeats! - snapshot.data!.length == 1 ? 'open seat' : 'open seats'})',
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        RidePassengerList(
                          passengerList: snapshot.data!,
                          driverUserId: widget.ride.driverUserId!,
                          rideId: widget.ride.id!,
                        ),
                        const SizedBox(height: 24),
                        if (widget.ride.driverUserId != supabase.auth.currentUser!.id)
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: widget.horizontalPadding),
                              child: Text('Driver', style: Theme.of(context).textTheme.titleMedium),
                            ),
                            RideDriverDetails(driverUserId: widget.ride.driverUserId!),
                            const SizedBox(height: 24),
                          ]),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: widget.horizontalPadding),
                          child: Text('Vehicle', style: Theme.of(context).textTheme.titleMedium),
                        ),
                      ]),
                    ),
                    _displayActionButtons(isCurrentUserConfirmedPassenger, snapshot.data!.length)
                  ],
                ));
              } else {
                return const CenterProgressIndicator();
              }
            },
          ),
        ));
  }
}
