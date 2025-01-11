import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:trainbook/pages/ticket.dart';

class SummaryPage extends StatefulWidget {
  final Ticket ticket;

  const SummaryPage({super.key, required this.ticket});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  handlePaymentCompletion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment completed successfully!')),
    );
  }

  changeSeatStatus() async {
    for(String seat in widget.ticket.seats){
      final path =
        'trains/${widget.ticket.train}/coaches/${widget.ticket.coach}/seats/$seat/status';

      await _dbRef.child(path).set("booked");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.ticket.seats.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Seat: ${widget.ticket.seats[index]}'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentPage(),
                ),
              ).then((_) {
                handlePaymentCompletion();
                changeSeatStatus();
              });
            },
            child: const Text('Pay Now'),
          ),
        ],
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
