import 'package:flutter/material.dart';
import 'package:thumb_app/components/garage_page/vehicle_form.dart';
import 'package:thumb_app/components/garage_page/vehicle_list.dart';

class GaragePage extends StatelessWidget {
  const GaragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Garage'),
          actions: [IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const VehicleForm())),
              icon: const Icon(Icons.add))]
        ),
        body: const VehicleList());
  }
}
