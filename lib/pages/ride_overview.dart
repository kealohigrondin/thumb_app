import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';

import '../data/types/profile.dart';
import '../data/types/ride.dart';
import '../main.dart';

class RideOverview extends StatelessWidget {
  const RideOverview({super.key, required this.ride});

  final Ride ride;

  // Future<List<Profile>> _getPassengers() async {
  //   final List<Profile>> passengers = await supabase.from('ride_passenger')
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Expanded(
              child: ListView(children: [
                Text(ride.title!, style: Theme.of(context).textTheme.titleLarge),
                Text(DateFormat.MMMd().add_jm().format(ride.dateTime),
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(ride.description!,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(ride.departAddress!,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const Icon(Icons.arrow_downward),
                  Text(ride.arriveAddress!,
                      style: Theme.of(context).textTheme.bodyMedium),
                ]),
              ]),
            ),
              FilledButton(
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('join ride'))),
                  child: const Text('Request to Join'))
          ],
        ),
      )),
    );
  }
}
