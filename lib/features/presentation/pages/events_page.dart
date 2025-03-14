import 'package:contactsafe/features/presentation/widgets/nav_bar.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events')),
      body: Center(child: Text('Events Page')),
      bottomNavigationBar: NavBar(),
    );
  }
}
