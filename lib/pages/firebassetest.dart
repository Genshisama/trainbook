import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';


/// Firebase Service Class
class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>?> fetchAllData() async {
    try {
      // Fetch all data from the Firebase Realtime Database
      final snapshot = await _dbRef.child('trains').get();

      if (snapshot.exists) {
        print("Data from Firebase: ${snapshot.value}");
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        print("No data available in the database.");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }
}

/// UI Page for Testing Firebase
class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({Key? key}) : super(key: key);

  @override
  _FirebaseTestPageState createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? _trainData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await _firebaseService.fetchAllData();
    setState(() {
      _trainData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Connection Test')),
      body: Center(
        child: _trainData == null
            ? const Text(
                'No data found or still loading...',
                style: TextStyle(fontSize: 16),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: _trainData!.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value.toString()),
                  );
                }).toList(),
              ),
      ),
    );
  }
}