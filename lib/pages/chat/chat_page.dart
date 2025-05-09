import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thumb_app/data/types/ride.dart';
import 'package:thumb_app/pages/rides/ride_overview.dart';
import 'package:thumb_app/services/supabase_service.dart';
import 'package:timeago/timeago.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thumb_app/main.dart';
import 'package:thumb_app/utils/utils.dart';
import 'package:thumb_app/data/types/message.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/components/shared/loading_page.dart';
import 'package:thumb_app/components/shared/profile_photo.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.ride});

  final Ride ride;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final Stream<List<Message>> _messagesStream;
  final Map<String, Profile> _profileCache = {};

  @override
  void initState() {
    _messagesStream = supabase
        .from('chat')
        .stream(primaryKey: ['id'])
        .eq('ride_id', widget.ride.id!)
        .order('created_at')
        .map((maps) => maps
            .map((map) => Message.fromJson(map: map, myUserId: supabase.auth.currentUser!.id))
            .toList());
    super.initState();
  }

  Future<void> _loadProfileCache(String profileId) async {
    if (_profileCache[profileId] != null) {
      return;
    }
    final profile = await SupabaseService.getProfile(profileId);
    setState(() {
      _profileCache[profileId] = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: FittedBox(fit: BoxFit.fitWidth, child: Text(widget.ride.title!)),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => RideOverview(ride: widget.ride))),
              icon: const Icon(Icons.info_outline))
        ],
      ),
      body: StreamBuilder<List<Message>>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!;
            return Column(children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(child: Text('Start your conversation now :)'))
                    : ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          _loadProfileCache(message.userId);
                          return _ChatBubble(
                            message: message,
                            profile: _profileCache[message.userId],
                          );
                        }),
              ),
              _MessageBar(rideId: widget.ride.id!)
            ]);
          } else {
            return const LoadingPage();
          }
        },
      ),
    );
  }
}

/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  const _MessageBar({required this.rideId});

  final String rideId;

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _submitMessage(),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    try {
      await supabase
          .from('chat')
          .insert({'user_id': myUserId, 'content': text, 'ride_id': widget.rideId});
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showErrorSnackBar(
            message: error.toString(), functionName: 'chat_page._submitMessage()');
      }
    } catch (_) {
      if (mounted) {
        context.showErrorSnackBar(
            message: 'Unexpected error occurred', functionName: 'chat_page._submitMessage()');
      }
    }
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.profile,
  });

  final Message message;
  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!message.isMine && profile != null)
        ProfilePhoto(
            initials: '${profile?.firstName[0]}${profile?.lastName[0]}',
            authId: profile!.authId,
            radius: 24),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: message.isMine ? Theme.of(context).primaryColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content,
              style: TextStyle(
                  color: message.isMine ? Theme.of(context).colorScheme.onPrimary : Colors.black)),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.createdAt, locale: 'en_short')),
      const SizedBox(width: 60),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}
