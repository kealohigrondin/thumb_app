// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:thumb_app/components/home_page/activity_card.dart';
import 'package:thumb_app/main.dart';

import '../../data/types/ride.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<List<Ride>> _getActivityData() async {
    final user = supabase.auth.currentUser!;
    print('UserID: ${user.id}');
    final result = await supabase.from('ride').select();
    return result.map((item) => Ride.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getActivityData(),
        builder: (BuildContext context, AsyncSnapshot<List<Ride>> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (ctx, index) =>
                    ActivityCard(ride: snapshot.data![index]));
          } else {
            return const Text('loading');
          }
        });
  }
}
