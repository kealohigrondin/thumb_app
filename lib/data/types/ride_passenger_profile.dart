// ignore_for_file: non_constant_identifier_names

import 'package:thumb_app/data/enums/ride_passenger_status.dart';

class RidePassengerProfile {
  String passengerUserId = '';
  RidePassengerStatus status = RidePassengerStatus.unknown;
  String firstName = '';
  String lastName = '';

  RidePassengerProfile.fromJson(Map<String, dynamic> data) {
    passengerUserId = data['passenger_user_id'];
    firstName = data['profile']['first_name'];
    lastName = data['profile']['last_name'];
    switch ((data['status'] as String).toUpperCase()) {
      case 'REQUESTED':
        status = RidePassengerStatus.requested;
        break;
      case 'CANCELLED':
        status = RidePassengerStatus.cancelled;
        break;
      case 'DENIED':
        status = RidePassengerStatus.denied;
        break;
      case 'CONFIRMED':
        status = RidePassengerStatus.confirmed;
        break;
      default:
        status = RidePassengerStatus.unknown;
    }
  }
}
