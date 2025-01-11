import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  final List<String> selectedSeats;

  const SummaryPage({super.key, required this.selectedSeats});

  @override
  Widget build(BuildContext context) {
    void handlePaymentCompletion() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed successfully!')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: selectedSeats.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Seat: ${selectedSeats[index]}'),
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
                // Invoke callback when PaymentPage is popped
                handlePaymentCompletion();
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
