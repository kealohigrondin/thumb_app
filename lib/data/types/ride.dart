class Ride {
  String? id;
  String? arriveAddress;
  int? availableSeats;
  DateTime? createdAt = DateTime.now();
  DateTime dateTime = DateTime.now();
  String? departAddress;
  String? description;
  String? driverUserId;
  bool enableInstantBook = false;
  int? likeCount;
  double? passengerCost;
  String? title;

  Ride.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    arriveAddress = data['arrive_address'];
    createdAt =
        data['created_at'] != null ? DateTime.parse(data['created_at']) : null;
    dateTime = DateTime.parse(data['datetime']);
    departAddress = data['depart_address'];
    enableInstantBook = data['enable_instant_book'];
    likeCount = data['like_count'];
    passengerCost = double.tryParse(data['passenger_cost'].toString());
    title = data['title'];
    driverUserId = data['driver_user_id'];
    availableSeats = data['available_seats'];
    description = data['description'];
  }
  Ride();
}