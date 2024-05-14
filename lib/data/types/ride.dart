class Ride {
  String? id;
  String? arriveAddress;
  DateTime? createdAt;
  DateTime? dateTime;
  String? departAddress;
  bool? enableInstantBooking;
  int? likeCount;
  double? passengerCost;
  String? title;
  String? driverUserId;
  int? availableSeats;
  String? description;

  Ride.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    arriveAddress = data['arrive_address'];
    createdAt = data['created_at'] != null ? DateTime.parse(data['created_at']) : null;
    dateTime = data['datetime'] != null ? DateTime.parse(data['datetime']) : null;
    departAddress = data['depart_address'];
    enableInstantBooking = data['enableInstantBooking'];
    likeCount = data['like_count'];
    passengerCost = data['passenger_cost'];
    title = data['title'];
    driverUserId = data['driver_user_id'];
    availableSeats = data['available_seats'];
    description = data['description'];
  }
}