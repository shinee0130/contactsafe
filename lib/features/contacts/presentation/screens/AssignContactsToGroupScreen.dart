import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

// Global storage for contact groups and their assignments.
final List<String> globalGroups = [
  'Family',
  'Friends',
  'Work',
  'Emergency',
  'Not assigned',
];

final Map<String, List<String>> globalContactGroupsMap = {
  'Alice Smith': ['Family', 'Friends'],
  'Bob Johnson': ['Work'],
  'Charlie Brown': ['Friends', 'Not assigned'],
  'Diana Prince': ['Emergency'],
  'Eve Adams': ['Family', 'Work'],
  'Frank White': ['Not assigned'],
};

class AssignContactsToGroupScreen extends StatefulWidget {
  final String groupName;

  const AssignContactsToGroupScreen({super.key, required this.groupName});

  @override
  State<AssignContactsToGroupScreen> createState() =>
      _AssignContactsToGroupScreenState();
}

class _AssignContactsToGroupScreenState
    extends State<AssignContactsToGroupScreen> {
  List<Contact> _allContacts = [];
  List<Contact> _selectedContactsForGroup =
      []; // Contacts currently selected on this screen
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndPreselectContacts();
  }

  Future<void> _fetchAndPreselectContacts() async {
    setState(() {
      _isLoading = true;
    });

    if (await FlutterContacts.requestPermission()) {
      _allContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
      );

      // Sort contacts alphabetically
      _allContacts.sort((a, b) => a.displayName.compareTo(b.displayName));

      // Pre-select contacts already in this group (if any)
      _selectedContactsForGroup =
          _allContacts.where((contact) {
            final contactAssignedGroups =
                globalContactGroupsMap[contact.displayName] ?? [];
            return contactAssignedGroups.contains(widget.groupName);
          }).toList();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact permission denied')),
        );
      }
      _allContacts = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (_selectedContactsForGroup.contains(contact)) {
        _selectedContactsForGroup.remove(contact);
      } else {
        _selectedContactsForGroup.add(contact);
      }
    });
  }

  void _saveAssignments() {
    // --- THIS IS THE CRITICAL PART FOR PERSISTENCE ---
    // Update the globalContactGroupsMap based on current selections
    // In a real app, this would update your database/storage for contacts.

    // First, remove the group from any contact that was previously in it but is no longer selected
    for (final contact in _allContacts) {
      final contactDisplayName = contact.displayName;
      if (globalContactGroupsMap.containsKey(contactDisplayName)) {
        if (!_selectedContactsForGroup.contains(contact)) {
          // If contact is NOT selected for this group, ensure the group is removed
          globalContactGroupsMap[contactDisplayName]?.remove(widget.groupName);
        }
      }
    }

    // Now, add the group to all currently selected contacts
    for (final contact in _selectedContactsForGroup) {
      final contactDisplayName = contact.displayName;
      globalContactGroupsMap.putIfAbsent(
        contactDisplayName,
        () => [],
      ); // Ensure list exists
      if (!globalContactGroupsMap[contactDisplayName]!.contains(
        widget.groupName,
      )) {
        globalContactGroupsMap[contactDisplayName]!.add(widget.groupName);
      }
    }
    // -----------------------------------------------------

    // Optional: Print updated map for verification
    print('Updated Group Assignments for "${widget.groupName}":');
    globalContactGroupsMap.forEach((contactName, groups) {
      if (groups.contains(widget.groupName)) {
        print('- $contactName is now in "${widget.groupName}"');
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contacts assigned to "${widget.groupName}"')),
      );
      Navigator.pop(context); // Go back to ContactGroupsScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Assign to "${widget.groupName}"',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveAssignments,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _allContacts.isEmpty
              ? const Center(child: Text('No contacts found on your device.'))
              : ListView.builder(
                itemCount: _allContacts.length,
                itemBuilder: (context, index) {
                  final contact = _allContacts[index];
                  final isSelected = _selectedContactsForGroup.contains(
                    contact,
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 6.0,
                    ),
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      onTap: () => _toggleContactSelection(contact),
                      borderRadius: BorderRadius.circular(10.0),
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
                                value: isSelected,
                                onChanged: (bool? value) {
                                  _toggleContactSelection(contact);
                                },
                                activeColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  contact.thumbnail != null
                                      ? MemoryImage(contact.thumbnail!)
                                      : null,
                              backgroundColor: Colors.blue.withOpacity(0.7),
                              child:
                                  contact.thumbnail == null
                                      ? Text(
                                        contact.displayName.isNotEmpty
                                            ? contact.displayName[0]
                                                .toUpperCase()
                                            : '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      )
                                      : null, // Fallback color
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Text(
                                contact.displayName,
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.blue,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
