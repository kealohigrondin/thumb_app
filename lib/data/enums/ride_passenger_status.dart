enum RidePassengerStatus {
  requested, confirmed, denied, cancelled, unknown
}
extension RideStatusExtension on RidePassengerStatus {
  String toShortString() {
    switch (this) {
      case RidePassengerStatus.requested:
        return 'Requested';
      case RidePassengerStatus.cancelled:
        return 'Cancelled';
      case RidePassengerStatus.denied:
        return 'Denied';
      case RidePassengerStatus.confirmed:
        return 'Confirmed';
      default:
        return 'Unknown';
    }
  }
}