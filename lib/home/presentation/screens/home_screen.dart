import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              "$_counter",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              child: Text("Increment"),
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_counter);
              },
              child: Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}

// Stateful Widget
