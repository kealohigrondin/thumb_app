enum RidePassengerStatus { requested, confirmed, denied, cancelled, unknown }

extension RideStatusExtension on RidePassengerStatus {
  String toShortString() {
    switch (this) {
      case RidePassengerStatus.requested:
        return 'REQUESTED';
      case RidePassengerStatus.cancelled:
        return 'CANCELLED';
      case RidePassengerStatus.denied:
        return 'DENIED';
      case RidePassengerStatus.confirmed:
        return 'CONFIRMED';
      default:
        return 'UNKNOWN';
    }
  }
}
