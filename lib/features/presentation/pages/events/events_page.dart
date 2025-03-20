import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBar(
        title: "Events",
        actions: [
          IconButton(
            onPressed: () {},
            color: Colors.blue,
            icon: Icon(Icons.sync),
          ),
          IconButton(
            onPressed: () {},
            color: Colors.blue,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
