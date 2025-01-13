import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trainbook/pages/coach_select.dart';
import 'package:trainbook/ticket.dart';

class TrainSelectionPage extends StatefulWidget {
  final Ticket ticket;
  const TrainSelectionPage({super.key, required this.ticket});

  @override
  State<TrainSelectionPage> createState() => _TrainSelectionPageState();
}

class _TrainSelectionPageState extends State<TrainSelectionPage> {
  final List<String> _trains = ['Train A', 'Train B', 'Train C', 'Train D'];
  String departureDT = '';

  //generate dummy data for price
  double getPrice() {
    final random = Random();

    double price = widget.ticket.price;
    double differ = 0.90 + random.nextDouble() * 0.10;
    price *= differ;
    price = double.parse(price.toStringAsFixed(1));

    return price;
  }

  //generate dummy data for time
  String getTime(int index) {
    DateTime date = DateTime.parse(widget.ticket.date1);
    double duration = widget.ticket.duration; 

    List<int> hours = [8,12,18,22]; 
    List<int> minutes = [0,15,30,45]; 

    
    // final random = Random();
    
    // int randomHours = random.nextInt(24); 
    // int randomMinutes = random.nextInt(60); 
    
    DateTime departure = DateTime(date.year, date.month, date.day, hours[index], minutes[index]);

    departureDT = departure.toIso8601String();
    
    DateTime arrival = departure.add(Duration(hours: duration.toInt()));
    
    String formattedDeparture = '${departure.hour.toString().padLeft(2, '0')}:${departure.minute.toString().padLeft(2, '0')}';
    String formattedArrival = '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')}';
    
    return '$formattedDeparture - $formattedArrival';
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Train'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Trains:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _trains.length,
                itemBuilder: (context, index) {
                  double price = getPrice();
                  String time = getTime(index);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_trains[index]),
                          Text(time),
                        ],
                      ),
                      trailing: Text('RM ${price.toStringAsFixed(2)}'),
                      onTap: () {
                        widget.ticket.train =  _trains[index];
                        widget.ticket.price = price;
                        widget.ticket.date1 = departureDT;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoachSelectionPage(
                              ticket: widget.ticket,
                              time: time
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}