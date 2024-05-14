// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thumb_app/components/home_page/activity_card.dart';
import 'package:thumb_app/main.dart';

import '../../data/types/ride.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ignore: prefer_typing_uninitialized_variables
  List<Ride> activityData = [];

  Future<void> _getActivityData() async {
    final user = supabase.auth.currentUser!;
    print('UserID: ${user.id}');
    final result = await supabase.from('ride').select();
    setState(() {
      activityData = result.map((item) => Ride.fromJson(item)).toList();
    });
  }

  @override
  void initState() {
    print('init state');
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            onPressed: () => _getActivityData(),
            child: const Icon(Icons.refresh),
          ),
          body: Padding(
            padding: const EdgeInsets.all(4),
            child: ListView.builder(
              itemCount: activityData.length,
              itemBuilder: (ctx, index) => ActivityCard(ride: activityData[index])),
          )),
    );
  }
}
