import 'package:flutter/material.dart';
import '../../common/widgets/navigation_bar.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  int _currentIndex = 3; // To highlight the current tab

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      print('Bottom navigation tapped: $index');
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/contacts');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/search');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/events');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/photos');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/settings');
          break;
      }
    });
  }

  void _editPhotos() {
    // TODO: Implement edit photos functionality
    print('Edit photos');
  }

  void _uploadPhotos() {
    // TODO: Implement upload photos functionality
    print('Upload photos');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'ContactSafe',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
        actions: [
          TextButton(onPressed: _editPhotos, child: const Text('Edit')),
          IconButton(
            icon: const Icon(Icons.upload_file), // Example upload icon
            onPressed: _uploadPhotos,
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Photos will be displayed here',
        ), // Replace with your photos grid
      ),
      bottomNavigationBar: ContactSafeNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavigationTap,
      ),
    );
  }
}
