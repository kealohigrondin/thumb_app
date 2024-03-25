import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateProvider = StateProvider((ref) => DateTime.now());
final stepperCurrentPageProvider = StateProvider((ref) => 0);

class PublishRidePage extends ConsumerWidget {
  PublishRidePage({super.key});

  void _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        
        firstDate: DateTime.now(),
        lastDate: DateTime(
            DateTime.now().year + 1, DateTime.now().month, DateTime.now().day));
    if (pickedDate != null) {
      ref.read(selectedDateProvider.notifier).update((state) => pickedDate);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime selectedDate = ref.watch(selectedDateProvider);
    int currentStep = ref.watch(stepperCurrentPageProvider);

    return SafeArea(
        child: Stepper(
      currentStep: currentStep,
      steps: [
        Step(
            isActive: currentStep > 0,
            title: const Text('Ride Info'),
            content: Column(children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 3,
                maxLines: 5,
              ),
            ])),
        Step(
            isActive: currentStep > 1,
            title: const Text('Date & Time'),
            content: Column(
              children: [
                ElevatedButton(
                    onPressed: () => _selectDate(context, ref),
                    child: const Text('Select Date/Time')),
                Text(selectedDate.toLocal().toString())
              ],
            )),
        Step(
            isActive: currentStep > 2,
            title: const Text('Pickup'),
            content: Container(color: Colors.red)),
        Step(
            isActive: currentStep > 3,
            title: const Text('Dropoff'),
            content: Container(color: Colors.yellow)),
        Step(
            isActive: currentStep > 4,
            title: const Text('Passengers'),
            content: Container(color: Colors.yellow)),
      ],
      onStepContinue: () {
        if (currentStep < 4) {
          ref
              .read(stepperCurrentPageProvider.notifier)
              .update((state) => state += 1);
        } else {
          showDialog(
              context: context,
              builder: (context) =>
                  const AlertDialog(content: Text('end of stepper reached')));
        }
      },
      onStepCancel: () {
        if (currentStep > 0) {
          ref
              .read(stepperCurrentPageProvider.notifier)
              .update((state) => state -= 1);
        } else {
          showDialog(
              context: context,
              builder: (context) =>
                  const AlertDialog(content: Text('end of stepper reached')));
        }
      },
    ));
  }
}
