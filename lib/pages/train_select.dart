import 'package:flutter/material.dart';
import 'package:trainbook/pages/coach_select.dart';
import 'package:trainbook/pages/ticket.dart';

class TrainSelectionPage extends StatefulWidget {
  final Ticket ticket;
  const TrainSelectionPage({super.key, required this.ticket});

  @override
  State<TrainSelectionPage> createState() => _TrainSelectionPageState();
}

class _TrainSelectionPageState extends State<TrainSelectionPage> {
  final List<String> _trains = ['Train A', 'Train B', 'Train C', 'Train D'];

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
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(_trains[index]),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        widget.ticket.train =  _trains[index];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoachSelectionPage(
                              ticket: widget.ticket,
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