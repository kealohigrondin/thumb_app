import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thumb_app/utils/utils.dart';

import '../../data/types/ride.dart';
import 'user_icon_button.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 0, 4),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Padding(
                //   padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
                //   child: FaIcon(
                //     FontAwesomeIcons.globe,
                //     color: Theme.of(context).colorScheme.onPrimaryContainer,
                //     size: 12,
                //   ),
                // ),
                Text(getTimeFromRide(ride.dateTime),
                    style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
            child: Text(
              ride.title ?? 'Title',
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 2,
            ),
          ),
          ride.description!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 16),
                  child: Text(ride.description!,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.labelMedium),
                )
              : const SizedBox(height: 4),
          Divider(
            height: 2,
            thickness: 1,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
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
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                        onPressed: () async {
                          debugPrint('liked');
                        },
                        icon: Icon(
                          Icons.favorite_sharp,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 25,
                        )),
                    IconButton(
                      // borderColor: Colors.transparent,
                      // borderRadius: 20,
                      // borderWidth: 0,
                      // buttonSize: 40,
                      // fillColor: Colors.transparent,
                      icon: Icon(
                        Icons.comment_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 24,
                      ),
                      onPressed: () {
                        // ignore: avoid_print
                        debugPrint('IconButton pressed ...');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
