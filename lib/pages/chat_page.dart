import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key, this.rideId = ''});

  String rideId;

  // TODO: create chat_list_page to show a list of chats before this page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
        ),
        body: Center(
            child: Column(
          children: [
            const Text('chats here'),
            Text(rideId),
          ],
        )));
  }
}
