// ignore_for_file: non_constant_identifier_names

class RidePassengerProfile {
  String passengerUserId = '';
  String status = 'UNKNOWN';
  String firstName = '';
  String lastName = '';

  RidePassengerProfile.fromJson(Map<String, dynamic> data) {
    passengerUserId = data['passenger_user_id'];
    firstName = data['profile']['first_name'];
    lastName = data['profile']['last_name'];
    status = data['status'];
  }
}
