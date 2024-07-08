import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/profile_photo.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/enums/ride_passenger_status.dart';
import 'package:thumb_app/data/types/passenger_profile.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/profile/visiting_profile_page.dart';
import 'package:thumb_app/services/supabase_service.dart';

class RidePassengerList extends StatefulWidget {
  const RidePassengerList(
      {super.key,
      required this.passengerList,
      required this.driverUserId,
      required this.rideId});

  final List<PassengerProfile> passengerList;
  final String driverUserId;
  final String rideId;

  @override
  State<RidePassengerList> createState() => _RidePassengerListState();
}

class _RidePassengerListState extends State<RidePassengerList> {
  final String currentUserId = supabase.auth.currentUser!.id;

  void _updatePassengerStatus(
      String rideId, RidePassengerStatus status, String passengerUserId) {
    try {
      SupabaseService.updatePassengerStatus(rideId, status, passengerUserId);
      ShowSuccessSnackBar(context, 'Passenger Status updated');
    } catch (err) {
      ShowErrorSnackBar(context,
          'Error updating passenger status. Try again later.', err.toString());
    }
  }

  Widget _passengerStatusButton(PassengerProfile passenger) {
    if (passenger.status == RidePassengerStatus.requested) {
      return Row(
        children: [
          TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => _updatePassengerStatus(widget.rideId,
                  RidePassengerStatus.denied, passenger.passengerUserId),
              child: const Text('Deny')),
          const SizedBox(width: 4),
          TextButton(
              onPressed: () => _updatePassengerStatus(widget.rideId,
                  RidePassengerStatus.confirmed, passenger.passengerUserId),
              child: const Text('Confirm')),
        ],
      );
    }
    return Text('(${passenger.status.toShortString()})');
  }

  TextStyle _getPassengerNameTextStyle(RidePassengerStatus status) {
    if (status == RidePassengerStatus.cancelled ||
        status == RidePassengerStatus.denied) {
      return const TextStyle(
          color: Colors.grey, decoration: TextDecoration.lineThrough);
    }
    return Theme.of(context).textTheme.bodyMedium!;
  }

  Widget _driverPassengerView() {
    //view all passengers regardless of status
    return Column(
      children: widget.passengerList
          .map((passenger) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: ListTile(
                  leading: ProfilePhoto(
                      initials:
                          '${passenger.firstName[0]}${passenger.lastName[0]}',
                      authId: passenger.passengerUserId,
                      radius: 20),
                  title: Text('${passenger.firstName} ${passenger.lastName}',
                      style: _getPassengerNameTextStyle(passenger.status)),
                  trailing: _passengerStatusButton(passenger),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => VisitingProfilePage(
                          authId: passenger.passengerUserId))),
                ),
              ))
          .toList(),
    );
  }

  Widget _defaultPassengerView() {
    final viewablePassengerList = widget.passengerList
        .where((passenger) => passenger.status == RidePassengerStatus.confirmed)
        .toList();

    if (viewablePassengerList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Text('No confirmed passengers!'),
      );
    }

    // TODO: add 'X passengers requested' in passenger list?
    return Column(
      children: viewablePassengerList
          .map((passenger) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: ListTile(
                  leading: ProfilePhoto(
                      initials:
                          '${passenger.firstName[0]}${passenger.lastName[0]}',
                      authId: passenger.passengerUserId,
                      radius: 20),
                  title: Text(
                      passenger.passengerUserId == currentUserId
                          ? '(You) ${passenger.firstName} ${passenger.lastName}'
                          : '${passenger.firstName} ${passenger.lastName}',
                      style: Theme.of(context).textTheme.bodyMedium),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => VisitingProfilePage(
                          authId: passenger.passengerUserId))),
                ),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.passengerList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('No passengers!'),
      );
    } else if (widget.driverUserId == currentUserId) {
      return _driverPassengerView();
    } else {
      return _defaultPassengerView();
    }
  }
}
