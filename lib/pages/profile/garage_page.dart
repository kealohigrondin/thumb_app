import 'package:flutter/material.dart';
import 'package:thumb_app/components/garage_page/vehicle_list.dart';

class GaragePage extends StatelessWidget {
  const GaragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Garage'),
        ),
        body: const VehicleList());
  }
}
