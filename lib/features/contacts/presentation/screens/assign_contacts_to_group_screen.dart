import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

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

    final status = await Permission.contacts.request();
    if (status.isGranted) {
      _allContacts = await ContactsService.getContacts(
        withThumbnails: false,
      ).then((c) => c.toList());

      // Sort contacts alphabetically
      _allContacts.sort(
        (a, b) => (a.displayName ?? '').compareTo(b.displayName ?? ''),
      );

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
      if (contactDisplayName == null || contactDisplayName.isEmpty) {
        // null эсвэл хоосон нэртэй контакт skip хийх
        continue;
      }
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
    debugPrint('Updated Group Assignments for "${widget.groupName}":');
    globalContactGroupsMap.forEach((contactName, groups) {
      if (groups.contains(widget.groupName)) {
        debugPrint('- $contactName is now in "${widget.groupName}"');
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
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveAssignments,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
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
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  (contact.avatar != null &&
                                          contact.avatar!.isNotEmpty)
                                      ? MemoryImage(contact.avatar!)
                                      : null,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                              child:
                                  (contact.avatar == null ||
                                          contact.avatar!.isEmpty)
                                      ? Text(
                                        (contact.displayName ?? '').isNotEmpty
                                            ? contact.displayName![0]
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
                                contact.displayName ?? '',
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Theme.of(context).colorScheme.primary,
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
