import 'package:flutter/material.dart';

class SearchProfilePage extends StatelessWidget {
  const SearchProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Search Profiles')),
        body: const Center(child: Text('search profiles')));
  }
}
