import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:trainbook/pages/home.dart';
import 'package:trainbook/ticket.dart';
import 'package:trainbook/utils.dart';

class SummaryPage extends StatefulWidget {
  final Ticket ticket;
  final String time;

  const SummaryPage({super.key, required this.ticket, required this.time});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<String> times = [];
  String date = '';

  handlePaymentCompletion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment completed successfully!')),
    );
  }

  Future<void> changeSeatStatus() async {
    for(String seat in widget.ticket.seats){
      final path =
        'trains/${widget.ticket.train}/coaches/${widget.ticket.coach}/seats/$seat/status';

      await _dbRef.child(path).set("booked");
    }
  }

  String formatDuration(double duration) {
    int hours = duration.toInt(); 
    int minutes = ((duration - hours) * 60).toInt(); 

    String formattedDuration = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    return formattedDuration;
  }

  @override
  void initState() {
    super.initState();

    times = processTime(widget.time);
    date = processDate(widget.ticket.date1);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: widget.ticket.seats.length,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         title: Text('Seat: ${widget.ticket.seats[index]}'),
            //       );
            //     },
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.ticket.origin,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(
                    Icons.linear_scale_outlined,
                    size: 30,),
                ),
                Text(
                  widget.ticket.destination,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),),
              ],
            ),
            SizedBox(height: 16,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${times[0]} - ${times[1]}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),),
                  Text(
                    'Duration: ${formatDuration(widget.ticket.duration)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                    ),),
                  SizedBox(height: 16,),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500
                    ),),
                  SizedBox(height: 16,),
                  Text(
                    widget.ticket.train,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400
                    ),),
                  Text(
                    widget.ticket.coach,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500
                    ),),
                  SizedBox(height: 16,),
                  Row(
                    children: [
                      Text(
                        'Seat No',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400
                        ),),
                      SizedBox(width: 16,),
                      Text(
                        widget.ticket.seats.join(', '),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),),
                    ],
                  ),
                  SizedBox(height: 16,),
                  Row(
                    children: [
                      Text(
                        'Fare',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400
                        ),),
                      SizedBox(width: 16,),
                      Text(
                        'RM ${widget.ticket.price}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Row(
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400
                        ),),
                      SizedBox(width: 16,),
                      Text(
                        'RM ${widget.ticket.price * widget.ticket.pax}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),),
                    ],
                  ),
                ],
              ),
            ),            
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentPage(),
            ),
          ).then((_) {
            handlePaymentCompletion();
            changeSeatStatus().then((_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
                (Route<dynamic> route) => false,
              );
            });
          });
        },

        child: const Text('Pay Now'),
      ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); 
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Processing Payment')),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
