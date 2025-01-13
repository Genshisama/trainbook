import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trainbook/ticket.dart';
import 'package:trainbook/pages/train_select.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:trainbook/user.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String userName = '';
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

  double getAvgCost() {
    final random = Random();
    double price = random.nextDouble() * 256;

    price = double.parse(price.toStringAsFixed(2));
    return price;
  }

  Future<void> getUserName() async {
    userName = await User.getUserName();

    if (userName.isEmpty) {
      showNameDialog();
    } else {
      setState(() {});
    }
  }

  Future<void> showNameDialog() async {
    TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Your Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Your Name'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String enteredName = nameController.text.trim();
                if (enteredName.isNotEmpty) {
                  if(userName.isNotEmpty){
                    await User.removeUserName();
                  }
                  await User.saveUserName(enteredName);
                  setState(() {
                    userName = enteredName; 
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name cannot be empty!')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    getUserName();
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
              Container(
                padding: EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hi, $userName',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500
                        ),
                    ),
                    IconButton(
                      onPressed: (){
                        showNameDialog();
                      }, 
                      icon: Icon(Icons.edit))
                  ],
                ),
              ),
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
                // validator: (value) => value == null ? 'Please select a return date' : null,
                builder: (field) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Return Date (Optional)',
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
                      
                      final ticket = Ticket.fromEmpty();
                      ticket.origin = formData['origin'];
                      ticket.destination = formData['destination'];
                      ticket.date1 = formData['departureDate'].toUtc().toIso8601String();
                      ticket.date2 = formData['returnDate']?.toUtc().toIso8601String();
                      ticket.pax = int.parse(formData['pax']);
                      final random = Random();
                      ticket.duration = 2;
                      ticket.userName = userName;
                      ticket.price = getAvgCost();
                      
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
