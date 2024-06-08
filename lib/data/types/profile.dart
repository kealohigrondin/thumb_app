class Profile {
  String authId = '';
  DateTime createdAt = DateTime.fromMicrosecondsSinceEpoch(0);
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String email = '';

   Profile.fromJson(Map<String, dynamic> data) {
    authId = data['auth_id'];
    createdAt = DateTime.parse(data['created_at']);
    firstName = data['first_name'] ?? '';
    lastName = data['last_name'] ?? '';
    phoneNumber = data['phone_number'] ?? '';
    email = data['email'] ?? '';
  }

  Profile();
}