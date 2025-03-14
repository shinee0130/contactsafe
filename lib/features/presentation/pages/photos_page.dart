import 'package:contactsafe/features/presentation/widgets/nav_bar.dart';
import 'package:flutter/material.dart';

class PhotosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photos')),
      body: Center(child: Text('Photos Page')),
      bottomNavigationBar: NavBar(),
    );
  }
}
