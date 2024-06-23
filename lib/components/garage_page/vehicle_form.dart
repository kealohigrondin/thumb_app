import 'package:flutter/material.dart';

class VehicleForm extends StatefulWidget {
  const VehicleForm({super.key});

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final List<DropdownMenuEntry> _stateList = const [
    DropdownMenuEntry(value: 'AL', label: 'Alabama'),
    DropdownMenuEntry(value: 'AK', label: 'Alaska'),
    DropdownMenuEntry(value: 'AZ', label: 'Arizona'),
    DropdownMenuEntry(value: 'AR', label: 'Arkansas'),
    DropdownMenuEntry(value: 'CA', label: 'California'),
    DropdownMenuEntry(value: 'CO', label: 'Colorado'),
    DropdownMenuEntry(value: 'CT', label: 'Connecticut'),
    DropdownMenuEntry(value: 'DE', label: 'Delaware'),
    DropdownMenuEntry(value: 'FL', label: 'Florida'),
    DropdownMenuEntry(value: 'GA', label: 'Georgia'),
    DropdownMenuEntry(value: 'HI', label: 'Hawaii'),
    DropdownMenuEntry(value: 'ID', label: 'Idaho'),
    DropdownMenuEntry(value: 'IL', label: 'Illinois'),
    DropdownMenuEntry(value: 'IN', label: 'Indiana'),
    DropdownMenuEntry(value: 'IA', label: 'Iowa'),
    DropdownMenuEntry(value: 'KS', label: 'Kansas'),
    DropdownMenuEntry(value: 'KY', label: 'Kentucky'),
    DropdownMenuEntry(value: 'LA', label: 'Louisiana'),
    DropdownMenuEntry(value: 'ME', label: 'Maine'),
    DropdownMenuEntry(value: 'MD', label: 'Maryland'),
    DropdownMenuEntry(value: 'MA', label: 'Massachusetts'),
    DropdownMenuEntry(value: 'MI', label: 'Michigan'),
    DropdownMenuEntry(value: 'MN', label: 'Minnesota'),
    DropdownMenuEntry(value: 'MS', label: 'Mississippi'),
    DropdownMenuEntry(value: 'MO', label: 'Missouri'),
    DropdownMenuEntry(value: 'MT', label: 'Montana'),
    DropdownMenuEntry(value: 'NE', label: 'Nebraska'),
    DropdownMenuEntry(value: 'NV', label: 'Nevada'),
    DropdownMenuEntry(value: 'NH', label: 'New Hampshire'),
    DropdownMenuEntry(value: 'NJ', label: 'New Jersey'),
    DropdownMenuEntry(value: 'NM', label: 'New Mexico'),
    DropdownMenuEntry(value: 'NY', label: 'New York'),
    DropdownMenuEntry(value: 'NC', label: 'North Carolina'),
    DropdownMenuEntry(value: 'ND', label: 'North Dakota'),
    DropdownMenuEntry(value: 'OH', label: 'Ohio'),
    DropdownMenuEntry(value: 'OK', label: 'Oklahoma'),
    DropdownMenuEntry(value: 'OR', label: 'Oregon'),
    DropdownMenuEntry(value: 'PA', label: 'Pennsylvania'),
    DropdownMenuEntry(value: 'RI', label: 'Rhode Island'),
    DropdownMenuEntry(value: 'SC', label: 'South Carolina'),
    DropdownMenuEntry(value: 'SD', label: 'South Dakota'),
    DropdownMenuEntry(value: 'TN', label: 'Tennessee'),
    DropdownMenuEntry(value: 'TX', label: 'Texas'),
    DropdownMenuEntry(value: 'UT', label: 'Utah'),
    DropdownMenuEntry(value: 'VT', label: 'Vermont'),
    DropdownMenuEntry(value: 'VA', label: 'Virginia'),
    DropdownMenuEntry(value: 'WA', label: 'Washington'),
    DropdownMenuEntry(value: 'WV', label: 'West Virginia'),
    DropdownMenuEntry(value: 'WI', label: 'Wisconsin'),
    DropdownMenuEntry(value: 'WY', label: 'Wyoming'),
  ];
  late final TextEditingController _makeController = TextEditingController();
  late final TextEditingController _modelController = TextEditingController();
  late final TextEditingController _yearController = TextEditingController();
  late final TextEditingController _licenseStateController =
      TextEditingController();
  late final TextEditingController _licenseNumberController =
      TextEditingController();
  late final TextEditingController _colorController = TextEditingController();

  Future<void> _save() async {
    debugPrint('save');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish a ride'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: ListView(children: [
              const SizedBox(height: 24),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _yearController,
                validator: (value) {
                  if (value == null ||
                      value == '' ||
                      int.tryParse(value) == null ||
                      int.parse(value) < 1950 ||
                      int.parse(value) > DateTime.now().year + 1) {
                    return 'Please enter a valid year.';
                  }
                  return null;
                },
                decoration: const InputDecoration.collapsed(hintText: 'Year*'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration.collapsed(
                    hintText: 'Make (Honda, Ford, etc.)'),
                validator: (value) {
                  if (value == null || value == '') {
                    return 'Please enter a valid make.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration.collapsed(
                    hintText: 'Model (Civic, F-150, etc.)'),
                validator: (value) {
                  if (value == null || value == '') {
                    return 'Please enter a valid model.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              Text('License Plate',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  DropdownMenu(
                    label: const Text('State'),
                    dropdownMenuEntries: _stateList,
                    controller: _licenseStateController,
                    initialSelection: 'OR',
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _licenseNumberController,
                      decoration:
                          const InputDecoration.collapsed(hintText: 'Plate #'),
                      validator: (value) {
                        if (value == null || value == '') {
                          return 'Please enter a valid model.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration.collapsed(
                    hintText: 'Color'),
                validator: (value) {
                  if (value == null || value == '') {
                    return 'Please enter a valid color.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 60),
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
