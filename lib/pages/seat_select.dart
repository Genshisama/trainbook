import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:trainbook/pages/summary.dart';
import 'package:trainbook/ticket.dart';
import 'package:trainbook/user.dart';

class SeatSelectionPage extends StatefulWidget {
  final Ticket ticket;
  final String time;

  const SeatSelectionPage({
    super.key,
    required this.ticket,
    required this.time
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String userId = '';
  Map<String, dynamic> _seatStatus = {};
  final List<String> _selectedSeats = [];

  @override
  void initState() {
    super.initState();
    _initializeTrainData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = await User.getUserName();
    });
  }

  Future<void> _initializeTrainData() async {
    final path = 'trains/${widget.ticket.train}';
    final snapshot = await _dbRef.child(path).get();

    if (!snapshot.exists) {
      await _dbRef.child(path).set({
        "trainNumber": widget.ticket.train,
        "departureTime": widget.ticket.date1,
        "arrivalTime": widget.ticket.date2,
        "coaches": {
          widget.ticket.coach: {"seats": {}},
        },
      });
    }
    _fetchSeatData();
  }

  Future<void> _fetchSeatData() async {
    final path =
        'trains/${widget.ticket.train}/coaches/${widget.ticket.coach}/seats';
    final snapshot = await _dbRef.child(path).get();

    if (snapshot.exists) {
      setState(() {
        _seatStatus = Map<String, dynamic>.from(snapshot.value as Map);
      });
    } else {
      setState(() {
        _seatStatus = {};
      });
    }
  }

  Future<void> _selectSeat(String seatId) async {
    if (_selectedSeats.length >= widget.ticket.pax) return;
    final path =
        'trains/${widget.ticket.train}/coaches/${widget.ticket.coach}/seats/$seatId';

    await _dbRef.child(path).set({
      "status": "locked",
      "lockedBy": userId,
      "lockTimestamp": DateTime.now().toIso8601String(),
    });

    setState(() {
      _seatStatus[seatId] = {
        "status": "locked",
        "lockedBy": userId,
        "lockTimestamp": DateTime.now().toIso8601String(),
      };
      _selectedSeats.add(seatId);
    });
  }

  Future<void> _deselectSeat(String seatId) async {
    final path =
        'trains/${widget.ticket.train}/coaches/${widget.ticket.coach}/seats/$seatId';
    await _dbRef.child(path).remove();

    setState(() {
      _seatStatus.remove(seatId);
      _selectedSeats.remove(seatId);
    });
  }

  bool _isSeatDisabled(String seatId, String currentUser) {
    if (!_seatStatus.containsKey(seatId)) return false;
    final seatData = _seatStatus[seatId];
    final status = seatData['status'];
    final lockedBy = seatData['lockedBy'];

    bool isBooked = status == 'booked';
    bool isLockedByOther = status == 'locked' && lockedBy != currentUser;

    return isBooked || isLockedByOther;
  }


  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Selection'),
        content: Text(
          'You have selected the following seats:\n${_selectedSeats.join(', ')}\nDo you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.ticket.seats = _selectedSeats;
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SummaryPage(
                    ticket: widget.ticket,
                    time: widget.time,), 
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Train: ${widget.ticket.train} \nCoach: ${widget.ticket.coach}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Select up to ${widget.ticket.pax} seats',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  final seatId = 'A${index + 1}';
                  bool isDisabled = _isSeatDisabled(seatId, userId);
                  bool isSelected = _selectedSeats.contains(seatId);

                  return GestureDetector(
                    onTap: () async {
                      if (isDisabled && !isSelected) return;

                      if (isSelected) {
                        await _deselectSeat(seatId);
                      } else if (_selectedSeats.length < widget.ticket.pax) {
                        await _selectSeat(seatId);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : (isDisabled ? Colors.grey : Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          seatId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedSeats.isEmpty ? null : _showConfirmationDialog,
        child: const Icon(Icons.check),
      ),
    );
  }
}

