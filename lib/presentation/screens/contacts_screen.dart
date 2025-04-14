import 'package:flutter/material.dart';
import 'package:contactsafe/common/widgets/header.dart';
import 'package:contactsafe/common/widgets/navigation.dart';

class ContactsFilteredScreen extends StatefulWidget {
  @override
  _ContactsFilteredScreenState createState() => _ContactsFilteredScreenState();
}

class _ContactsFilteredScreenState extends State<ContactsFilteredScreen> {
  TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
      print('Bottom navigation tapped: $index');
      // TODO: Implement navigation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ContactSafeHeader(
        titleText: 'ContactSafe',
        leading: TextButton(
          onPressed: () {
            // TODO: Implement navigation to groups screen
            print('Navigate to Groups');
          },
          child: Text('Groups', style: TextStyle(color: Colors.blue)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // TODO: Implement add new filter/group
              print('Add new filter/group');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              'ContactSafe - filtered',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
                print('Search query: $value');
              },
            ),
            SizedBox(height: 16),
            Text('Filtered Contacts will be displayed here'),
          ],
        ),
      ),
      bottomNavigationBar: ContactSafeNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavigationTap,
      ),
    );
  }
}
