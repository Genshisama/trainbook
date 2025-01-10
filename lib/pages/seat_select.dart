import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SeatSelectionPage extends StatefulWidget {
  final String selectedTrain;
  final String selectedCoach; 
  final String selectedDate; 

  const SeatSelectionPage({
    super.key,
    required this.selectedTrain,
    required this.selectedCoach,
    required this.selectedDate,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic> _seatStatus = {}; 
  String? _selectedSeat;

  @override
  void initState() {
    super.initState();
    _fetchSeatData();
  }

  Future<void> _fetchSeatData() async {
    final path = 'trains/${widget.selectedTrain}/coaches/${widget.selectedCoach}/seats';
    final snapshot = await _dbRef.child(path).get();

    if (snapshot.exists) {
      // Load existing seat data
      setState(() {
        _seatStatus = Map<String, dynamic>.from(snapshot.value as Map);
      });
    } else {
      // No data exists, keep empty seatStatus map
      setState(() {
        _seatStatus = {};
      });
    }
  }

  Future<void> _selectSeat(String seatId) async {
    final path = 'trains/${widget.selectedTrain}/coaches/${widget.selectedCoach}/seats/$seatId';
    final userId = "currentUser"; // Replace with your actual user ID logic

    // Update Firebase with the new seat selection
    await _dbRef.child(path).set({
      "status": "locked",
      "lockedBy": userId,
      "lockTimestamp": DateTime.now().toIso8601String(),
    });

    // Update local state
    setState(() {
      _seatStatus[seatId] = {
        "status": "locked",
        "lockedBy": userId,
        "lockTimestamp": DateTime.now().toIso8601String(),
      };
      _selectedSeat = seatId;
    });
  }

  bool _isSeatDisabled(String seatId) {
    if (!_seatStatus.containsKey(seatId)) return false;

    final seatData = _seatStatus[seatId];
    return seatData['status'] == 'locked' || seatData['status'] == 'booked';
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
              'Train: ${widget.selectedTrain}, Coach: ${widget.selectedCoach}, Date: ${widget.selectedDate}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Number of seats per row
                  childAspectRatio: 1,
                ),
                itemCount: 20, // Display 20 seats for the example
                itemBuilder: (context, index) {
                  final seatId = 'A${index + 1}'; // Seat IDs: A1, A2, etc.
                  final isDisabled = _isSeatDisabled(seatId);

                  return GestureDetector(
                    onTap: isDisabled
                        ? null
                        : () async {
                            await _selectSeat(seatId);
                          },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedSeat == seatId
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
    );
  }
}
