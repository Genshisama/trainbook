import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trainbook/pages/ticket.dart';
import 'package:trainbook/pages/train_select.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<String> _locations = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Kuala Lumpur',
    'Labuan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Penang',
    'Perak',
    'Perlis',
    'Putrajaya',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
  ];

  Future<void> _selectDate(BuildContext context, String fieldName) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      _formKey.currentState?.fields[fieldName]?.didChange(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Booking Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            children: [
              FormBuilderDropdown<String>(
                name: 'origin',
                decoration: const InputDecoration(
                  labelText: 'Origin',
                  border: OutlineInputBorder(),
                ),
                items: _locations
                    .map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ))
                    .toList(),
                validator: (value) {
                  final destination = _formKey.currentState?.fields['destination']?.value;
                  if (value == null) {
                    return 'Please select an origin';
                  } else if (value == destination) {
                    return 'Origin and destination cannot be the same';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<String>(
                name: 'destination',
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  border: OutlineInputBorder(),
                ),
                items: _locations
                    .map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ))
                    .toList(),
                validator: (value) {
                  final origin = _formKey.currentState?.fields['origin']?.value;
                  if (value == null) {
                    return 'Please select a destination';
                  } else if (value == origin) {
                    return 'Origin and destination cannot be the same';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FormBuilderField<DateTime>(
                name: 'departureDate',
                validator: (value) => value == null ? 'Please select a departure date' : null,
                builder: (field) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Departure Date',
                      border: const OutlineInputBorder(),
                      errorText: field.errorText,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, 'departureDate'),
                      ),
                    ),
                    child: Text(
                      field.value != null
                          ? DateFormat('yyyy-MM-dd').format(field.value!)
                          : '',
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              FormBuilderField<DateTime>(
                name: 'returnDate',
                validator: (value) => value == null ? 'Please select a return date' : null,
                builder: (field) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Return Date',
                      border: const OutlineInputBorder(),
                      errorText: field.errorText,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, 'returnDate'),
                      ),
                    ),
                    child: Text(
                      field.value != null
                          ? DateFormat('yyyy-MM-dd').format(field.value!)
                          : '',
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'pax',
                decoration: const InputDecoration(
                  labelText: 'Number of Passengers',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of passengers';
                  } else if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if(_formKey.currentState != null){
                    if (_formKey.currentState!.saveAndValidate()) {
                      final formData = _formKey.currentState!.value;
                      
                      print(formData);

                      final ticket = Ticket.fromEmpty();
                      ticket.origin = formData['origin'];
                      ticket.destination = formData['destination'];
                      ticket.date1 = formData['departureDate'].toUtc().toIso8601String();
                      ticket.date2 = formData['returnDate'].toUtc().toIso8601String();
                      ticket.pax = int.parse(formData['pax']);
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrainSelectionPage(
                            ticket: ticket,
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
