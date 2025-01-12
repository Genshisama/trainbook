import 'package:flutter/material.dart';
import 'package:trainbook/pages/seat_select.dart';
import 'package:trainbook/ticket.dart';

class CoachSelectionPage extends StatefulWidget {
  final Ticket ticket;
  final String time;

  const CoachSelectionPage({super.key, required this.ticket, required this.time});

  @override
  State<CoachSelectionPage> createState() => _CoachSelectionPageState();
}

class _CoachSelectionPageState extends State<CoachSelectionPage> {
  final List<String> _coaches = ['Coach 1', 'Coach 2', 'Coach 3', 'Coach 4', 'Coach 5', 'Coach 6'];
  String? _selectedCoach;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Coach'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Train: ${widget.ticket.train}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Coach',
                border: OutlineInputBorder(),
              ),
              items: _coaches.map((coach) {
                return DropdownMenuItem(
                  value: coach,
                  child: Text(coach),
                );
              }).toList(),
              value: _selectedCoach,
              onChanged: (value) {
                setState(() {
                  _selectedCoach = value;
                });
              },
              validator: (value) => value == null ? 'Please select a coach' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedCoach == null
                  ? null
                  : () {
                      widget.ticket.coach = _selectedCoach ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeatSelectionPage(
                            ticket: widget.ticket,
                            time: widget.time
                          ),
                        ),
                      );
                    },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
