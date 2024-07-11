import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thumb_app/data/enums/ride_passenger_status.dart';
import 'package:thumb_app/data/types/passenger_profile.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/data/types/ride.dart';
import 'package:thumb_app/main.dart';

class SupabaseService {
  static int increment(int input) {
    return input + 1;
  }

  static Future<void> upsertPassenger(dynamic values) async {
    try {
      await supabase.from('ride_passenger').upsert(values);
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<void> follow(String authIdToFollow) async {
    try {
      // TODO: set status to 'requested' once push notifications are added
      final authId = supabase.auth.currentUser!.id;
      await supabase.from('follower').insert(
          {'follower_user_id': authId, 'target_user_id': authIdToFollow, 'status': 'CONFIRMED'});
    } on PostgrestException catch (error) {
      //can also capture stacktrace with second argument after 'error'
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<void> unfollow(String authIdToUnfollow, String followerUserId) async {
    try {
      await supabase
          .from('follower')
          .delete()
          .eq('follower_user_id', followerUserId)
          .eq('target_user_id', authIdToUnfollow);
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static void removeFollower(String authIdToRemove) async {
    try {
      final authId = supabase.auth.currentUser!.id;
      await supabase
          .from('follower')
          .delete()
          .eq('follower_user_id', authIdToRemove)
          .eq('target_user_id', authId);
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static void updatePassengerStatus(
      String rideId, RidePassengerStatus newStatus, String passengerUserId) async {
    try {
      // create row in ride_passenger table
      //don't need to pass in intial status or created_at since those are created on the db side
      await supabase
          .from('ride_passenger')
          .update({'status': newStatus.toShortString()})
          .eq('ride_id', rideId)
          .eq('passenger_user_id', passengerUserId);
      debugPrint('updatePassengerStatus: Update saved!');
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<void> updateProfile(
      String firstName, String lastName, String email, String phoneNumber, String bio) async {
    try {
      final authId = supabase.auth.currentUser!.id;
      final updates = {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': email.trim(),
        'phone_number': phoneNumber.trim(),
        'bio': bio.trim(),
      };
      //update auth
      await supabase.auth.updateUser(UserAttributes(
        data: updates,
      ));
      //update profile table
      final profileUpdates = {'auth_id': authId, ...updates};
      await supabase.from('profile').upsert(profileUpdates).eq('auth_id', authId);
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<List<Ride>> getRideSearchResults() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return [];
      }
      // TODO: hide rides that currentUser is passenger on from the user
      final result = await supabase
          .from('ride')
          .select('*, ride_passenger(passenger_user_id)')
          .gte('datetime', DateTime.now())
          .not('driver_user_id', 'eq', user.id)
          .order('datetime', ascending: true);

      return result.map((item) => Ride.fromJson(item)).toList();
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<List<Profile>> getProfileSearchResults(String searchTerm) async {
    try {
      final result = await supabase
          .from('profile')
          .select()
          .neq('auth_id', supabase.auth.currentUser!.id)
          .or('first_name.ilike.%$searchTerm%,last_name.ilike.%$searchTerm%,email.ilike.%$searchTerm%');
      return result.map((item) => Profile.fromJson(item)).toList();
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<List<PassengerProfile>> getPassengers(String rideId) async {
    try {
      var result = await supabase
          .from('ride_passenger')
          .select('passenger_user_id, status, profile(first_name, last_name)')
          .eq('ride_id', rideId);
      List<PassengerProfile> ridePassengerProfile =
          result.map((item) => PassengerProfile.fromJson(item)).toList();
      return ridePassengerProfile;
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<Profile> getProfile(String authId) async {
    try {
      final result = await supabase.from('profile').select().eq('auth_id', authId).single();
      return Profile.fromJson(result);
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<List<Ride>> getActivityData() async {
    final followingProfiles = await getProfilesFollowed(supabase.auth.currentUser!.id);
    final followingAuthIds = followingProfiles.map((item) => item.authId);
    final searchAuthIds = [...followingAuthIds, supabase.auth.currentUser!.id];

    try {
      final passengerResults = await supabase
          .from('ride_passenger')
          .select('ride(*)')
          .inFilter('passenger_user_id', searchAuthIds)
          .inFilter('status', [
        RidePassengerStatus.confirmed.toShortString(),
        RidePassengerStatus.requested.toShortString()
      ]).lte('ride.datetime', DateTime.now());

      List<Ride> result = passengerResults
          .where((element) => element['ride'] != null)
          .map((item) => Ride.fromJson(item['ride']))
          .toList();

      final driverResults = await supabase
          .from('ride')
          .select()
          .lt('datetime', DateTime.now())
          .inFilter('driver_user_id', searchAuthIds)
          .order('datetime', ascending: false); //get activity data in descending datetime

      result.addAll(driverResults.map((item) => Ride.fromJson(item)));
      result.sort((ride1, ride2) => ride2.dateTime.compareTo(ride1.dateTime)); //sort by date
      final noDupes = result.distinct((ride) => ride.id!);
      return noDupes.toList();
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<List<Ride>> getRideHistory(String authId) async {
    try {
      final passengerRides = await supabase
          .from('ride_passenger')
          .select('ride(*)')
          .eq('passenger_user_id', authId)
          .inFilter('status', [
        RidePassengerStatus.confirmed.toShortString(),
        RidePassengerStatus.requested.toShortString()
      ]).lte('ride.datetime', DateTime.now());
      List<Ride> result = passengerRides
          .where((element) => element['ride'] != null)
          .map((item) => Ride.fromJson(item['ride']))
          .toList();
      final driverRides = await supabase
          .from('ride')
          .select()
          .eq('driver_user_id', authId)
          .lte('datetime', DateTime.now());
      result.addAll(driverRides.map((item) => Ride.fromJson(item)));
      result.sort((ride1, ride2) => ride1.dateTime.compareTo(ride2.dateTime));
      return result;
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<List<Ride>> getRidesPlanned(String authId) async {
    try {
      final passengerRides = await supabase
          .from('ride_passenger')
          .select('ride(*)')
          .eq('passenger_user_id', authId)
          .inFilter('status', [
        RidePassengerStatus.confirmed.toShortString(),
        RidePassengerStatus.requested.toShortString()
      ]).gte('ride.datetime', DateTime.now());
      List<Ride> result = passengerRides
          .where((element) => element['ride'] != null)
          .map((item) => Ride.fromJson(item['ride']))
          .toList();
      final driverRides = await supabase
          .from('ride')
          .select()
          .eq('driver_user_id', authId)
          .gte('datetime', DateTime.now());
      result.addAll(driverRides.map((item) => Ride.fromJson(item)));
      result.sort((ride1, ride2) => ride1.dateTime.compareTo(ride2.dateTime));
      return result;
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<List<Profile>> getProfilesFollowed(String authId) async {
    try {
      var result = await supabase
          .from('follower')
          .select('profile!follower_target_user_id_fkey(*)')
          .eq('status', 'CONFIRMED')
          .eq('follower_user_id', authId);
      List<Profile> friendsList = result
          .where((element) => element['profile'] != null)
          .map((item) => Profile.fromJson(item['profile']))
          .toList();
      friendsList.sort((prof1, prof2) =>
          '${prof1.firstName}${prof1.lastName}'.compareTo('${prof2.firstName}${prof2.lastName}'));
      return friendsList;
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<List<Profile>> getFollowerProfiles(String authId) async {
    try {
      var result = await supabase
          .from('follower')
          .select('profile!follower_follower_user_id_fkey(*)')
          .eq('status', 'CONFIRMED')
          .eq('target_user_id', authId);
      List<Profile> friendsList = result
          .where((element) => element['profile'] != null)
          .map((item) => Profile.fromJson(item['profile']))
          .toList();
      friendsList.sort((prof1, prof2) =>
          '${prof1.firstName}${prof1.lastName}'.compareTo('${prof2.firstName}${prof2.lastName}'));
      return friendsList;
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<bool> isFollowing(String targetUserId, String currentUserId) async {
    try {
      List<Profile> followedProfiles = await getProfilesFollowed(currentUserId);
      Profile targetProfileFound = followedProfiles
          .firstWhere((element) => element.authId == targetUserId, orElse: () => Profile());
      return targetProfileFound.authId == targetUserId;
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }

  static Future<List<Ride>> getRidesWithChats(String authId) async {
    try {
      //1. get rides for user
      final passengerRides = await supabase
          .from('ride_passenger')
          .select('ride(*)')
          .eq('passenger_user_id', authId)
          .inFilter('status', [
        RidePassengerStatus.confirmed.toShortString(),
        RidePassengerStatus.requested.toShortString()
      ]);

      List<Ride> allRides = passengerRides
          .where((data) => data['ride'] != null)
          .map((item) => Ride.fromJson(item['ride']))
          .toList();
      final driverRides = await supabase.from('ride').select().eq('driver_user_id', authId);

      allRides.addAll(driverRides.map((item) => Ride.fromJson(item)));
      allRides.sort((ride1, ride2) => ride1.dateTime.compareTo(ride2.dateTime));

      // get list of rideIDs from ridelist that are in chat table
      final rideIDsWithChats = await supabase
          .from('chat')
          .select('ride_id')
          .inFilter('ride_id', allRides.map((ride) => ride.id!).toList());

      List<String> distinctRideIds =
          rideIDsWithChats.map((element) => element['ride_id'].toString()).distinct().toList();

      // filter ridelist by rideIDs found in chat table
      return allRides.where((ride) => distinctRideIds.contains(ride.id)).toList();
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      rethrow;
    }
  }
}
