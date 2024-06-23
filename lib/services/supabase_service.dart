import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/enums/ride_passenger_status.dart';
import 'package:thumb_app/data/types/passenger_profile.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/data/types/ride.dart';
import 'package:thumb_app/main.dart';

class SupabaseService {
  static int increment(int input) {
    return input + 1;
  }
  static void updatePassengerStatus(BuildContext context, String rideId,
      RidePassengerStatus newStatus, String passengerUserId) async {
    try {
      // create row in ride_passenger table
      //don't need to pass in intial status or created_at since those are created on the db side
      await supabase
          .from('ride_passenger')
          .update({'status': newStatus.toShortString()})
          .eq('ride_id', rideId)
          .eq('passenger_user_id', passengerUserId);
      debugPrint('updatePassengerStatus: Update saved!');
      // TODO: update UI to reflect new state of DB
    } catch (err) {
      if (context.mounted) {
        // TODO: implement new showSnackbar functionality
        //context.showErrorSnackBar(message: 'Unexpected error occurred ${err.toString()}', functionName: 'updatePassengerStatus');
        ShowErrorSnackBar(context, 'Unexpected error occurred.',
            'updatePassengerStatus(): ${err.toString()}');
      }
    }
    debugPrint('passenger status changed to $newStatus');
  }

  static Future<void> updateProfile(BuildContext context, String firstName,
      String lastName, String email, String phoneNumber, String bio) async {
    try {
      final authId = supabase.auth.currentUser!.id;
      final updates = {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': email.trim(),
        'phone_number': phoneNumber.trim(),
        'bio': bio.trim(),
      };
      await supabase.auth.updateUser(UserAttributes(
        data: updates,
      ));
      final profileUpdates = {'auth_id': authId, ...updates};
      await supabase
          .from('profile')
          .upsert(profileUpdates)
          .eq('auth_id', authId);
      if (context.mounted) {
        ShowSuccessSnackBar(context, 'Profile saved!');
        Navigator.of(context).pop();
      }
    } catch (err) {
      if (context.mounted) {
        ShowErrorSnackBar(context, 'Unexpected error occurred.',
            'updateProfile(): ${err.toString()}');
      }
    } finally {
      //close keyboard
      if (FocusManager.instance.primaryFocus != null) {
        FocusManager.instance.primaryFocus!.unfocus();
      }
      //unfocus all text fields
    }
  }

  static Future<List<Ride>> getSearchResults() async {
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
    } catch (err) {
      debugPrint('_getPassengers: ${err.toString()}');
      return [];
    }
  }

  static Future<List<Profile>> getFriends(String userId) async {
    try {
      var result = await supabase.from('friend')
      .select('profile(*)')
      .or('friend.user_id_1.$userId,friend.user_id_2.$userId');
       List<Profile> friendsList = result
          .where((element) => element['ride'] != null)
          .map((item) => Profile.fromJson(item['ride']))
          .toList();
      friendsList.sort((prof1, prof2) => '${prof1.firstName}${prof1.lastName}'.compareTo('${prof2.firstName}${prof2.lastName}'));
      return friendsList;
    } catch (err) {
      debugPrint('getRideHistory(): ${err.toString()}');
      return [];
    }
  }

  static Future<Profile> getProfile(String authId) async {
    try {
      final result = await supabase
          .from('profile')
          .select()
          .eq('auth_id', authId)
          .single();
      return Profile.fromJson(result);
    } catch (err) {
      debugPrint('getProfile(): ${err.toString()}');
    }
    return Profile();
  }

  // TODO: update to reflect rides only from self or friends
  static Future<List<Ride>> getActivityData() async {
    final result = await supabase
        .from('ride')
        .select()
        .lt('datetime', DateTime.now())
        .order('datetime',
            ascending: false); //get activity data in descending datetime
    return result.map((item) => Ride.fromJson(item)).toList();
  }

  static Future<List<Ride>> getRideHistory() async {
    if (supabase.auth.currentUser == null) {
      return [];
    }
    try {
      final passengerRides = await supabase
          .from('ride_passenger')
          .select('ride(*)')
          .eq('passenger_user_id', supabase.auth.currentUser!.id)
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
          .eq('driver_user_id', supabase.auth.currentUser!.id)
          .lte('datetime', DateTime.now());
      result.addAll(driverRides.map((item) => Ride.fromJson(item)));
      result.sort((ride1, ride2) => ride1.dateTime.compareTo(ride2.dateTime));
      return result;
    } catch (err) {
      debugPrint('getRideHistory(): ${err.toString()}');
      return [];
    }
  }

  static Future<List<Ride>> getRidesPlanned() async {
    if (supabase.auth.currentUser == null) {
      return [];
    }
    try {
      final passengerRides = await supabase
          .from('ride_passenger')
          .select('ride(*)')
          .eq('passenger_user_id', supabase.auth.currentUser!.id)
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
          .eq('driver_user_id', supabase.auth.currentUser!.id)
          .gte('datetime', DateTime.now());
      result.addAll(driverRides.map((item) => Ride.fromJson(item)));
      result.sort((ride1, ride2) => ride1.dateTime.compareTo(ride2.dateTime));
      return result;
    } catch (err) {
      debugPrint('getRidesPlanned(): ${err.toString()}');
      return [];
    }
  }
}
