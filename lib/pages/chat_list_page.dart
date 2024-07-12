import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thumb_app/components/shared/loading_page.dart';
import 'package:thumb_app/data/types/ride.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/chat/chat_page.dart';
import 'package:thumb_app/services/supabase_service.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late Future<List<Ride>> _ridesWithChats;

  @override
  void initState() {
    super.initState();
    _ridesWithChats = SupabaseService.getRidesWithChats(supabase.auth.currentUser!.id);
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _ridesWithChats = SupabaseService.getRidesWithChats(supabase.auth.currentUser!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refreshHistory,
        child: FutureBuilder(
            future: _ridesWithChats,
            builder: (BuildContext context, AsyncSnapshot<List<Ride>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const LoadingPage();
                case ConnectionState.done:
                  return ListView.builder(
                      itemCount: snapshot.data!.length > 1 ? snapshot.data!.length : 1,
                      itemBuilder: (ctx, index) {
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }
                        if (snapshot.data!.isEmpty) {
                          return const Padding(
                              padding: EdgeInsets.fromLTRB(12, 32, 12, 12),
                              child: Text(
                                  'No rides with messages sent! To get your messages to show up here, send one from the ride overview page'));
                        }
                        return ListTile(
                          title: Text(
                            '(${DateFormat.Md().format(snapshot.data![index].dateTime)}) ${snapshot.data![index].title!}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChatPage(ride: snapshot.data![index]))),
                        );
                      });
                default:
                  return const Center(child: Text('Something unaccounted for has occurred...'));
              }
            }));
  }
}
