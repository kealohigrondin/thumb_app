import 'package:flutter/material.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/services/supabase_service.dart';

class ProfileSearch extends SearchDelegate<Profile> {
  ProfileSearch(this.hintText);

  String hintText = 'Enter first/last name or email';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future:
          query == "" ? null : SupabaseService.getProfileSearchResults(query),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(hintText,
                  style: Theme.of(context).textTheme.labelMedium),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text(
                        '${snapshot.data![index].firstName} ${snapshot.data![index].lastName}'),
                    onTap: () {
                      close(context, snapshot.data![index]);
                    },
                  ),
                  itemCount: snapshot.data!.length,
                )
              : const Text('Loading...'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future:
          query == "" ? null : SupabaseService.getProfileSearchResults(query),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(hintText,
                  style: Theme.of(context).textTheme.labelMedium),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text(
                        '${snapshot.data![index].firstName} ${snapshot.data![index].lastName}'),
                    onTap: () {
                      close(context, snapshot.data![index]);
                    },
                  ),
                  itemCount: snapshot.data!.length,
                )
              : const Text('Loading...'),
    );
  }
}
