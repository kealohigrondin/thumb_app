import 'package:flutter/material.dart';
import '../../services/place_service.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch(this.sessionToken, this.hintText) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  late final String sessionToken;
  String hintText = 'Enter place or address';
  late PlaceApiProvider apiClient;

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
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(hintText, style: Theme.of(context).textTheme.labelMedium),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text(snapshot.data![index].description,
                        style: Theme.of(context).textTheme.bodyMedium),
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
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(hintText, style: Theme.of(context).textTheme.labelMedium),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text(snapshot.data![index].description,
                        style: Theme.of(context).textTheme.bodyMedium),
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
