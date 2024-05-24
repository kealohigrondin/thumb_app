// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:thumb_app/components/search_page/search_card.dart';
import 'package:thumb_app/main.dart';

import '../../data/types/ride.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  Future<List<Ride>> _getSearchResults() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }
    final result = await supabase.from('ride').select().not('driver_user_id', 'eq', user.id);
    return result.map((item) => Ride.fromJson(item)).toList();
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
                itemBuilder: (ctx, index) => SearchCard(ride: snapshot.data![index]));
          } else {
            return const Text('loading');
          }
        });
  }
}
