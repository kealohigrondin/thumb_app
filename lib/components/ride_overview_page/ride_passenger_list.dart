import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/enums/ride_passenger_status.dart';
import 'package:thumb_app/data/types/ride_passenger_profile.dart';
import 'package:thumb_app/main.dart';

class RidePassengerList extends StatefulWidget {
  const RidePassengerList(
      {super.key, required this.passengerList, required this.driverUserId, required this.rideId});

  final List<RidePassengerProfile> passengerList;
  final String driverUserId;
  final String rideId;

  @override
  State<RidePassengerList> createState() => _RidePassengerListState();
}

class _RidePassengerListState extends State<RidePassengerList> {
  final String currentUserId = supabase.auth.currentUser!.id;

  void _updatePassengerStatus(RidePassengerStatus newStatus, String passengerUserId) async {
    try {
      // create row in ride_passenger table
      //don't need to pass in intial status or created_at since those are created on the db side
      await supabase
          .from('ride_passenger')
          .update({'status': newStatus.toShortString()})
          .eq('ride_id', widget.rideId)
          .eq('passenger_user_id', passengerUserId);
      if (mounted) {
        ShowSuccessSnackBar(context, 'Update saved!');
        // TODO: update UI to reflect new state of DB
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

  Widget _passengerStatusButton(RidePassengerProfile passenger) {
    if (passenger.status == RidePassengerStatus.requested) {
      return Row(
        children: [
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () =>
                  _updatePassengerStatus(RidePassengerStatus.denied, passenger.passengerUserId),
              child: const Text('Deny')),
          const SizedBox(width: 4),
          TextButton(
              onPressed: () =>
                  _updatePassengerStatus(RidePassengerStatus.confirmed, passenger.passengerUserId),
              child: const Text('Confirm')),
        ],
      );
    } else if (passenger.status == RidePassengerStatus.confirmed) {
      return TextButton(onPressed: null, child: Text(passenger.status.toShortString()));
    }
    return TextButton(onPressed: null, child: Text(passenger.status.toShortString()));
  }

  TextStyle _getPassengerNameTextStyle(RidePassengerStatus status) {
    if (status == RidePassengerStatus.cancelled || status == RidePassengerStatus.denied) {
      return const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough);
    }
    return const TextStyle();
  }

  Widget _driverPassengerView() {
    //view all passengers regardless of status
    return Column(
      children: widget.passengerList
          .map((passenger) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${passenger.firstName} ${passenger.lastName}',
                      style: _getPassengerNameTextStyle(passenger.status)),
                  _passengerStatusButton(passenger)
                ],
              ))
          .toList(),
    );
  }

  Widget _defaultPassengerView() {
    final viewablePassengerList = widget.passengerList
        .where((passenger) => passenger.status == RidePassengerStatus.confirmed)
        .toList();

    if (viewablePassengerList.isEmpty) {
      return const Text('No confirmed passengers!');
    }

    // TODO: add 'X passengers requested' in passenger list???
    return Column(
      children: viewablePassengerList
          .map((passenger) => Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(passenger.passengerUserId == currentUserId
                      ? '(You) ${passenger.firstName} ${passenger.lastName}'
                      : '${passenger.firstName} ${passenger.lastName}'),
                  Text(passenger.status != RidePassengerStatus.confirmed
                      ? ' (${passenger.status.toShortString()})'
                      : '')
                ],
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.passengerList.isEmpty) {
      return const Text('No passengers!');
    } else if (widget.driverUserId == currentUserId) {
      return _driverPassengerView();
    } else {
      return _defaultPassengerView();
    }
  }
}
