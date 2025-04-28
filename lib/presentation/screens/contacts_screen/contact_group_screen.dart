import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart'; // Assuming you have this

class ContactGroupsScreen extends StatefulWidget {
  const ContactGroupsScreen({super.key});

  @override
  State<ContactGroupsScreen> createState() => _ContactGroupsScreenState();
}

class _ContactGroupsScreenState extends State<ContactGroupsScreen> {
  // TODO: Fetch and manage contact groups
  List<String> _groups = [
    'Select all groups',
    'Not assigned',
    'sss',
  ]; // Example data

  void _showNewGroupDialog(BuildContext context) {
    TextEditingController _newGroupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Do you want to add a new group?'),
              const SizedBox(height: 16),
              TextField(
                controller: _newGroupNameController,
                decoration: const InputDecoration(
                  hintText: 'Add name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newGroupName = _newGroupNameController.text.trim();
                if (newGroupName.isNotEmpty) {
                  // TODO: Implement group creation logic
                  print('Create group: $newGroupName');
                  setState(() {
                    _groups.add(newGroupName); // Update the local list
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                String newGroupName = _newGroupNameController.text.trim();
                if (newGroupName.isNotEmpty) {
                  // TODO: Implement group creation and navigate to add contacts
                  print('Create and add contacts to: $newGroupName');
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => AddContactsToGroupScreen(groupName: newGroupName)));
                  setState(() {
                    _groups.add(newGroupName); // Update the local list
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ok & add contacts'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Done', style: TextStyle(color: AppColors.primary)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showNewGroupDialog(context); // Show the dialog
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final groupName = _groups[index];
          return ListTile(
            title: Text(groupName),
            onTap: () {
              // TODO: Implement functionality for tapping on a group
              print('Tapped on group: $groupName');
              if (groupName == 'Select all groups') {
                // TODO: Implement select all groups logic
              } else if (groupName == 'Not assigned') {
                // TODO: Implement navigation to 'not assigned' contacts
              } else {
                // TODO: Implement navigation to group details or editing
              }
            },
          );
        },
      ),
    );
  }
}
