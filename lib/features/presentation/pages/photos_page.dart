import 'package:flutter/material.dart';
import '../widgets/header_bar.dart';

class PhotosScreen extends StatelessWidget {
  const PhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBar(
        title: "Photos",
        actions: [
          TextButton(
            onPressed: () {},
            child: Text("Edit", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Center(child: Text("No Photos Available")),
    );
  }
}
