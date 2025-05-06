import 'package:contactsafe/common/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ContactGroupsScreen extends StatefulWidget {
  const ContactGroupsScreen({super.key});

  @override
  State<ContactGroupsScreen> createState() => _ContactGroupsScreenState();
}

class _ContactGroupsScreenState extends State<ContactGroupsScreen> {
  bool _selectAll = false;
  final List<String> _groups = ['Not assigned'];
  final List<String> _selectedGroups = [];

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedGroups.addAll(_groups);
      } else {
        _selectedGroups.clear();
      }
    });
  }

  void _toggleGroupSelection(String groupName) {
    setState(() {
      if (_selectedGroups.contains(groupName)) {
        _selectedGroups.remove(groupName);
      } else {
        _selectedGroups.add(groupName);
      }
      _selectAll = _selectedGroups.length == _groups.length;
    });
  }

  void _addNewGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController newGroupController = TextEditingController();
        return AlertDialog(
          title: const Text('New Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ensure content fits
            children: [
              const Text('Do you want to add a new group?'),
              const SizedBox(height: 8.0),
              TextField(
                controller: newGroupController,
                decoration: const InputDecoration(hintText: 'Add name'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                _addNewGroupToList(
                  newGroupController.text.trim(),
                  shouldAddContacts: false,
                );
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ok & add contacts'),
              onPressed: () {
                _addNewGroupToList(
                  newGroupController.text.trim(),
                  shouldAddContacts: true,
                );
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewGroupToList(
    String newGroupName, {
    required bool shouldAddContacts,
  }) {
    if (newGroupName.isNotEmpty && !_groups.contains(newGroupName)) {
      setState(() {
        _groups.add(newGroupName);
      });
      if (shouldAddContacts) {
        // Navigate to the screen where the user can add contacts to this group
        print('Navigate to add contacts for group: $newGroupName');
        // Replace the print statement with your actual navigation logic
        // Example using Navigator.push:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => AddContactsToGroupScreen(groupName: newGroupName)),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Groups',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leadingWidth: 60.0,
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Done',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary, size: 30),
            onPressed: () => _addNewGroup(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Select all groups'),
            leading: Checkbox(
              value: _selectAll,
              onChanged: (bool? value) {
                if (value != null) {
                  _toggleSelectAll();
                }
              },
            ),
            onTap: _toggleSelectAll,
          ),
          const Divider(),
          ..._groups.map(
            (group) => ListTile(
              title: Text(group),
              leading: Checkbox(
                value: _selectedGroups.contains(group),
                onChanged: (bool? value) {
                  if (value != null) {
                    _toggleGroupSelection(group);
                  }
                },
              ),
              onTap: () => _toggleGroupSelection(group),
            ),
          ),
        ],
      ),
    );
  }
}
