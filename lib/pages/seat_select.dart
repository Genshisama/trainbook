import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SeatSelectionPage extends StatefulWidget {
  final String selectedTrain;
  final String selectedCoach;
  final String selectedDate;
  final int passengerCount;  // New field to hold the number of passengers

  const SeatSelectionPage({
    super.key,
    required this.selectedTrain,
    required this.selectedCoach,
    required this.selectedDate,
    required this.passengerCount, // Pass number of passengers
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic> _seatStatus = {};
  List<String> _selectedSeats = []; // List to hold selected seat IDs

  @override
  void initState() {
    super.initState();
    _initializeTrainData();
  }

  Future<void> _initializeTrainData() async {
    final path = 'trains/${widget.selectedTrain}';

    final snapshot = await _dbRef.child(path).get();

    if (!snapshot.exists) {
      // Create train data if it doesn't exist
      await _dbRef.child(path).set({
        "trainNumber": widget.selectedTrain,
        "departureTime": "${widget.selectedDate}T10:00:00",
        "arrivalTime": "${widget.selectedDate}T14:00:00",
        "coaches": {
          widget.selectedCoach: {
            "seats": {}, // Initialize empty seats structure
          }
        }
      });
    }

    // Fetch seat data after ensuring train data exists
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
    if (_selectedSeats.length >= widget.passengerCount) return; // Prevent selecting more than passenger count

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
      _selectedSeats.add(seatId); // Add to selected seats list
    });
  }

  Future<void> _deselectSeat(String seatId) async {
    final path = 'trains/${widget.selectedTrain}/coaches/${widget.selectedCoach}/seats/$seatId';

    // Remove the seat data from Firebase
    await _dbRef.child(path).remove();

    // Update local state
    setState(() {
      _seatStatus.remove(seatId);
      _selectedSeats.remove(seatId); // Remove from selected seats list
    });
  }

  bool _isSeatDisabled(String seatId, String currentUser) {
    if (!_seatStatus.containsKey(seatId)) return false;

    final seatData = _seatStatus[seatId];
    final status = seatData['status'];
    final lockedBy = seatData['lockedBy']; // Assuming the key is 'lockedBy'

    // Check if the seat is either locked or booked
    bool isLocked = status == 'locked' || status == 'booked';

    // Check if the seat is locked by the current user
    bool isLockedByCurrentUser = status == 'locked' && lockedBy == currentUser;

    return isLocked || isLockedByCurrentUser;
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
            Text(
              'Select up to ${widget.passengerCount} seats',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
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
                  bool isDisabled = _isSeatDisabled(seatId, 'currentUser');
                  bool isSelected = _selectedSeats.contains(seatId);

                  return GestureDetector(
                    onTap: () async {
                      if (isDisabled && !isSelected) return; // Do nothing for disabled seats

                      if (isSelected) {
                        // Deselect the seat if it's already selected
                        await _deselectSeat(seatId);
                      } else if (_selectedSeats.length < widget.passengerCount) {
                        // Select the seat if not already selected
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
    );
  }
}
