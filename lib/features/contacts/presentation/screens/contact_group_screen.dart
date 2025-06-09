import 'package:flutter/material.dart';
import 'AssignContactsToGroupScreen.dart';

class ContactGroupsScreen extends StatefulWidget {
  const ContactGroupsScreen({super.key});

  @override
  State<ContactGroupsScreen> createState() => _ContactGroupsScreenState();
}

class _ContactGroupsScreenState extends State<ContactGroupsScreen> {
  bool _selectAll = false;
  final List<String> _groups = [
    'Family',
    'Friends',
    'Work',
    'Emergency',
    'Not assigned',
  ];
  final List<String> _selectedGroups = [];

  @override
  void initState() {
    super.initState();
    if (_groups.contains('Not assigned') &&
        !_selectedGroups.contains('Not assigned')) {
      _selectedGroups.add('Not assigned');
    }
    _updateSelectAllStatus();
  }

  void _updateSelectAllStatus() {
    setState(() {
      _selectAll = _selectedGroups.length == _groups.length;
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedGroups.clear();
      if (_selectAll) {
        _selectedGroups.addAll(_groups);
      }
      _updateSelectAllStatus();
    });
  }

  void _toggleGroupSelection(String groupName) {
    setState(() {
      if (_selectedGroups.contains(groupName)) {
        _selectedGroups.remove(groupName);
      } else {
        _selectedGroups.add(groupName);
      }
      _updateSelectAllStatus();
    });
  }

  void _addNewGroup(BuildContext context) {
    TextEditingController newGroupController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'New Group',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the name for your new group:',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: newGroupController,
                decoration: InputDecoration(
                  hintText: 'Group name',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final String newGroupName = newGroupController.text.trim();
                if (newGroupName.isNotEmpty) {
                  // Option 1: Just add the group
                  _addNewGroupToList(
                    newGroupName,
                    shouldNavigateToAddContacts: false,
                  );
                }
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'OK', // Changed text from "Add Group" to "OK" for general add
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              // New button for "Ok & add contacts"
              onPressed: () {
                final String newGroupName = newGroupController.text.trim();
                if (newGroupName.isNotEmpty) {
                  _addNewGroupToList(
                    newGroupName,
                    shouldNavigateToAddContacts: true,
                  );
                }
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Ok & add contacts',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addNewGroupToList(
    String newGroupName, {
    required bool shouldNavigateToAddContacts,
  }) {
    if (newGroupName.isNotEmpty && !_groups.contains(newGroupName)) {
      setState(() {
        _groups.add(newGroupName);
        _selectedGroups.add(newGroupName); // Automatically select new group
        _updateSelectAllStatus();
      });

      if (shouldNavigateToAddContacts) {
        // Navigate to the contact selection screen for this new group
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    AssignContactsToGroupScreen(groupName: newGroupName),
          ),
        );
      }
    } else if (newGroupName.isNotEmpty && _groups.contains(newGroupName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group "$newGroupName" already exists.')),
      );
    }
  }

  // ... rest of your ContactGroupsScreen code remains the same ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Groups',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedGroups);
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        leadingWidth: 70.0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.blue, size: 28),
            onPressed: () => _addNewGroup(context),
            splashRadius: 24,
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surface,
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: _toggleSelectAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _selectAll,
                        onChanged: (bool? value) {
                          if (value != null) {
                            _toggleSelectAll();
                          }
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        'Select all groups',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ..._groups.map(
            (group) => Card(
              color: Theme.of(context).colorScheme.surface,
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: () => _toggleGroupSelection(group),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _selectedGroups.contains(group),
                          onChanged: (bool? value) {
                            if (value != null) {
                              _toggleGroupSelection(group);
                            }
                          },
                          activeColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          group,
                          style: TextStyle(
                            fontSize: 17.0,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight:
                                _selectedGroups.contains(group)
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
