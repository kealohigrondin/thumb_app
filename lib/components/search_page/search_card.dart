import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/ride_overview.dart';
import 'package:thumb_app/utils/utils.dart';

import '../../data/types/ride.dart';
import '../home_page/user_icon_button.dart';

class SearchCard extends StatelessWidget {
  const SearchCard({super.key, required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => RideOverview(ride: ride))),
      child: Card(
        color: supabase.auth.currentUser!.id == ride.driverUserId ? Colors.amber[100] : null,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(DateFormat.MMMd().add_jm().format(ride.dateTime),
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ride.title ?? 'Title', style: Theme.of(context).textTheme.labelLarge),
                  Text(formatDoubleToCurrency(ride.passengerCost!),
                      style: Theme.of(context).textTheme.labelLarge)
                ],
              ),
              Text(ride.departAddress!,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              const Icon(Icons.arrow_downward),
              const SizedBox(height: 4),
              Text(ride.arriveAddress!,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              Divider(
                height: 2,
                thickness: 1,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          UserIconButton(
                              imagePath:
                                  'https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dXNlcnxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60'),
                          UserIconButton(
                              imagePath:
                                  'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxNXx8cHJvZmlsZXxlbnwwfHx8fDE2OTE0NDY5MzJ8MA&ixlib=rb-4.0.3&q=80&w=400'),
                          UserIconButton(
                              imagePath:
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D')
                        ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
