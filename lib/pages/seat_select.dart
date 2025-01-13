import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trainbook/pages/summary.dart';
import 'package:trainbook/ticket.dart';
import 'package:trainbook/user.dart';
import 'package:trainbook/utils.dart';

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
  String tripId = '';

  @override
  void initState() {
    super.initState();
    _initializeTrainData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = await User.getUserName();
    });
     _addSeatChangeListener();
  }

  Future<void> _initializeTrainData() async {
    tripId = '${processDate(widget.ticket.date1)}, ${widget.time}';
    final path = 'trains/${widget.ticket.train}/${widget.ticket.origin} - ${widget.ticket.destination}/$tripId';
    final snapshot = await _dbRef.child(path).get();

    if (!snapshot.exists) {
      await _dbRef.child(path).set({
        "trainNumber": widget.ticket.train,
        "departureTime": widget.ticket.date1,
        "arrivalTime": widget.ticket.date2,
        "price": widget.ticket.price,
        "coaches": {
          widget.ticket.coach: {"seats": {}},
        },
      });
    }
    _fetchSeatData();
  }

  Future<void> _fetchSeatData() async {
    final path =
        'trains/${widget.ticket.train}/${widget.ticket.origin} - ${widget.ticket.destination}/$tripId/coaches/${widget.ticket.coach}/seats';
    final snapshot = await _dbRef.child(path).get();

    if (snapshot.exists) {
      if (mounted) {
        setState(() {
          _seatStatus = Map<String, dynamic>.from(snapshot.value as Map);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _seatStatus = {};
        });
      }
    }
  }

  void _addSeatChangeListener() {
  final path =
      'trains/${widget.ticket.train}/${widget.ticket.origin} - ${widget.ticket.destination}/$tripId/coaches/${widget.ticket.coach}/seats';
  
  _dbRef.child(path).onValue.listen((event) {
    if (event.snapshot.value != null) {
      final updatedSeatStatus = Map<String, dynamic>.from(event.snapshot.value as Map);
      if (mounted) {
        setState(() {
          _seatStatus = updatedSeatStatus;
        });
      }
    }
  });
}

  Future<void> _selectSeat(String seatId) async {
    if (_selectedSeats.length >= widget.ticket.pax) return;
    final path =
        'trains/${widget.ticket.train}/${widget.ticket.origin} - ${widget.ticket.destination}/$tripId/coaches/${widget.ticket.coach}/seats/$seatId';

    await _dbRef.child(path).set({
      "status": "locked",
      "lockedBy": userId,
      "lockTimestamp": DateTime.now().toIso8601String(),
    });

    if (mounted) {
      setState(() {
        _seatStatus[seatId] = {
          "status": "locked",
          "lockedBy": userId,
          "lockTimestamp": DateTime.now().toIso8601String(),
        };
        _selectedSeats.add(seatId);
      });
    }
  }

  Future<void> _deselectSeat(String seatId) async {
    final path =
        'trains/${widget.ticket.train}/${widget.ticket.origin} - ${widget.ticket.destination}/$tripId/coaches/${widget.ticket.coach}/seats/$seatId';
    await _dbRef.child(path).remove();

    if (mounted) {
      setState(() {
        _seatStatus.remove(seatId);
        _selectedSeats.remove(seatId);
      });
    }
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
          '${widget.ticket.coach} \nSelected seats: ${_selectedSeats.join(', ')}',
          style: TextStyle(
            fontWeight: FontWeight.w500
          ),
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
                    time: widget.time,
                    tripId: tripId,), 
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
            Row(
              children: [
                Text(
                  'Train: ',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                ),
                Text(
                  widget.ticket.train,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Coach: ',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                ),
                Text(
                  widget.ticket.coach,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Select ${widget.ticket.pax} seats',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1, 
                ),
                itemCount: 25, 
                itemBuilder: (context, index) {
                  if (index % 5 == 2) {
                    return const SizedBox.shrink(); 
                  }

                  //create empty row to simulate aisle
                  final seatId = 'A${(index ~/ 5) * 4 + (index % 5 > 2 ? index % 5 - 1 : index % 5) + 1}';
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
            Row(
              children: [
                Container(
                  width: screenSize(context).width * 0.12,
                  height: screenSize(context).width * 0.12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 8,),
                Text(
                  'Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                ),)
              ],
            ),
            SizedBox(height: 16,),
            Row(
              children: [
                Container(
                  width: screenSize(context).width * 0.12,
                  height: screenSize(context).width * 0.12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 8,),
                Text(
                  'Taken',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                ),)
              ],
            ),
            SizedBox(
              height: screenSize(context).height * 0.1,
            )
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder( 
          borderRadius: BorderRadius.circular(15.0), 
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), 
        minimumSize: Size(screenSize(context).width * 0.9, 50),
        ), 
        onPressed: _selectedSeats.length < widget.ticket.pax ? null : _showConfirmationDialog,
        child: const Text('Proceed'),
      ),
    );
  }
}

