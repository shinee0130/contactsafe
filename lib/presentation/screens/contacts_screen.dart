import 'package:flutter/material.dart';
import 'package:contactsafe/common/widgets/header.dart';
import 'package:contactsafe/common/widgets/navigation.dart';
import 'package:contactsafe/common/theme/app_colors.dart';
import 'package:contactsafe/common/theme/app_styles.dart';

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

  void _navigateToGroups() {
    print('Navigate to Groups screen');
    // TODO: Implement navigation to the groups screen
  }

  void _addNewFilter() {
    print('Add new filter/group');
    // TODO: Implement add new filter/group functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ContactSafeHeader(
        titleText: 'ContactSafe',
        onGroupsPressed: _navigateToGroups,
        onAddPressed: _addNewFilter,
        logo: Image.asset(
          'assets/contactsafe_logo.png', // Adjust as needed
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ContactSafe - filtered', style: AppStyles.headlineMedium),
            SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
                print('Search query: $value');
              },
            ),
            SizedBox(height: 24),
            Text(
              'Filtered Contacts will be displayed here',
              style: AppStyles.bodyMedium,
            ),
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
