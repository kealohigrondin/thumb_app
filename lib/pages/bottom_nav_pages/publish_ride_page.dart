import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/services/place_service.dart';
import 'package:uuid/uuid.dart';

import 'package:thumb_app/main.dart';

import '../../components/publish_page/address_search.dart';

final titleProvider = StateProvider((ref) => '');
final selectedDateProvider = StateProvider((ref) => DateTime.now());
final selectedTimeProvider = StateProvider((ref) => TimeOfDay.now());
final enableQuickBookProvider = StateProvider((ref) => false);

class PublishRidePage extends StatefulWidget {
  const PublishRidePage({super.key});

  @override
  State<PublishRidePage> createState() => _PublishRidePageState();
}

class _PublishRidePageState extends State<PublishRidePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _pickupAddressController = TextEditingController();
  late final TextEditingController _dropoffAddressController = TextEditingController();
  late final TextEditingController _seatsController = TextEditingController();
  late final TextEditingController _costController = TextEditingController();

  var enableInstantBook = false;
  var selectedDate = DateTime.now();

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year, DateTime.now().month + 4, DateTime.now().day));
    if (pickedDate != null) {
      setState(() {
        selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
            selectedDate.hour, selectedDate.minute);
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null) {
      setState(() {
        selectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
            pickedTime.hour, pickedTime.minute);
      });
    }
  }

  Future<void> _save() async {
    try {
      await supabase.from('ride').insert({
        'arrive_address': _dropoffAddressController.text,
        'available_seats': _seatsController.text,
        'created_at': DateTime.now().toString(),
        'datetime': selectedDate.toString(),
        'depart_address': _pickupAddressController.text,
        'description': _descriptionController.text,
        'enable_instant_book': enableInstantBook,
        'like_count': 0,
        'passenger_cost': _costController.text,
        'title': _titleController.text,
        'driver_user_id': supabase.auth.currentUser!.id,
      });
      if (mounted) {
        Navigator.of(context).pop();
        ShowSuccessSnackBar(context, 'Ride published!');
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      ShowErrorSnackBar(context, 'Error saving ride data! Try again later.', error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: ListView(children: [
              TextFormField(
                  controller: _pickupAddressController,
                  onTap: () async {
                    final sessionToken = const Uuid().v4();
                    final Suggestion? result = await showSearch(
                        context: context,
                        delegate: AddressSearch(sessionToken, 'Enter pickup address'));
                    if (result != null) {
                      setState(() {
                        _pickupAddressController.text = result.description;
                      });
                    }
                  },
                  decoration: const InputDecoration.collapsed(hintText: 'Pickup address*')),
              const SizedBox(height: 20),
              TextFormField(
                  controller: _dropoffAddressController,
                  onTap: () async {
                    final sessionToken = const Uuid().v4();
                    final Suggestion? result = await showSearch(
                        context: context,
                        delegate: AddressSearch(sessionToken, 'Enter dropoff address'));
                    if (result != null) {
                      setState(() {
                        _dropoffAddressController.text = result.description;
                      });
                    }
                  },
                  decoration: const InputDecoration.collapsed(hintText: 'Dropoff address*')),
              const Divider(
                height: 68,
                thickness: 2,
                indent: 48,
                endIndent: 48,
              ),
              TextFormField(
                controller: _titleController,
                validator: (value) {
                  if (value == null || value == '') {
                    return 'Please enter a title.';
                  }
                  return null;
                },
                decoration: const InputDecoration.collapsed(hintText: 'Add a title*'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration.collapsed(hintText: 'Add a description'),
                minLines: 1,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(DateFormat.yMMMEd().format(selectedDate))),
                ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: Text(DateFormat.jm().format(selectedDate))),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enable instant book?',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Switch(
                      value: enableInstantBook,
                      onChanged: (value) => setState(() {
                            enableInstantBook = value;
                          }))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Seats*',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(
                    width: 40,
                    child: TextFormField(
                      controller: _seatsController,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null) {
                          return 'Enter a valid number';
                        }
                        var amount = num.tryParse(value);
                        if (amount == null || amount < 1) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Passenger Cost*',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(
                    width: 40,
                    child: TextFormField(
                      controller: _costController,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[.0-9]"))
                      ],
                      validator: (value) {
                        if (value == null) {
                          return 'Enter a valid number';
                        }
                        var amount = num.tryParse(value);
                        if (amount == null || amount < 0) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _save();
                    } else {
                      return;
                    }
                  },
                  child: const Text('Save')),
            ]),
          ),
        ),
      ),
    );
  }
}
