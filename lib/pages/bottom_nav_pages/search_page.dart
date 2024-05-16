// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:thumb_app/components/home_page/activity_card.dart';
import 'package:thumb_app/components/search_page/search_card.dart';
import 'package:thumb_app/main.dart';

import '../../data/types/ride.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<List<Ride>> _getSearchResults() async {
    final user = supabase.auth.currentUser!;
    final result = await supabase
        .from('ride')
        .select()
        .not('driver_user_id', 'eq', user.id);
    return result.map((item) => Ride.fromJson(item)).toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getSearchResults(),
        builder: (BuildContext context, AsyncSnapshot<List<Ride>> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (ctx, index) =>
                    SearchCard(ride: snapshot.data![index]));
          } else {
            return const Text('loading');
          }
        });
  }
}
