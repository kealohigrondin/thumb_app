import 'package:flutter/material.dart';

class PublishRidePage extends StatelessWidget {
  PublishRidePage({super.key});

  final steps = [
    Step(
        title: const Text('Driver Details'),
        content: Container(color: Colors.red)),
    Step(
        title: const Text('Car'),
        content: Container(color: Colors.blue)),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Stepper(steps: steps));
  }
}
