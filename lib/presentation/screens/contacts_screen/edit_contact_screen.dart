import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../common/theme/app_colors.dart';

class EditContactScreen extends StatefulWidget {
  final Contact contact;

  const EditContactScreen({super.key, required this.contact});

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  List<TextEditingController> _phoneControllers = [];
  List<TextEditingController> _emailControllers = [];
  List<TextEditingController> _websiteControllers = [];
  List<TextEditingController> _addressControllers = [];

  Contact get _updatedContact => Contact(
    id: widget.contact.id, // Keep the original ID for updating
    name: Name(
      first: _firstNameController.text.trim(),
      last: _lastNameController.text.trim(),
    ),
    // company: _companyController.text.trim(), // Still using the controller value
    phones: _phoneControllers.map((c) => Phone(c.text.trim())).toList(),
    emails: _emailControllers.map((c) => Email(c.text.trim())).toList(),
    websites: _websiteControllers.map((c) => Website(c.text.trim())).toList(),
    addresses:
        _addressControllers
            .map((c) => Address(c.text.trim()))
            .toList(), // Providing street
  );

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    _firstNameController.text = widget.contact.name.first ?? '';
    _lastNameController.text = widget.contact.name.last ?? '';
    // _companyController.text = widget.contact.company ?? ''; // Still using the controller
    _phoneControllers =
        widget.contact.phones
            .map((p) => TextEditingController(text: p.number))
            .toList();
    _emailControllers =
        widget.contact.emails
            .map((e) => TextEditingController(text: e.address ?? ''))
            .toList();
    _websiteControllers =
        widget.contact.websites
            .map((w) => TextEditingController(text: w.url ?? ''))
            .toList();
    _addressControllers =
        widget.contact.addresses
            .map((a) => TextEditingController(text: a.street ?? ''))
            .toList();
    if (_phoneControllers.isEmpty)
      _phoneControllers.add(TextEditingController());
    if (_emailControllers.isEmpty)
      _emailControllers.add(TextEditingController());
    if (_websiteControllers.isEmpty)
      _websiteControllers.add(TextEditingController());
    if (_addressControllers.isEmpty)
      _addressControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    for (final controller in _phoneControllers) {
      controller.dispose();
    }
    for (final controller in _emailControllers) {
      controller.dispose();
    }
    for (final controller in _websiteControllers) {
      controller.dispose();
    }
    for (final controller in _addressControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveContact() async {
    try {
      await FlutterContacts.updateContact(_updatedContact);
      Navigator.pop(context); // Go back to the contact detail screen
    } catch (e) {
      print('Error updating contact: $e');
      // Optionally show an error message to the user
    }
  }

  Future<void> _deleteContact() async {
    try {
      await FlutterContacts.deleteContact(widget.contact);
      Navigator.pop(context); // Go back
      Navigator.pop(context); // Go back to contacts screen
    } catch (e) {
      print('Error deleting contact: $e');
      // Optionally show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contact'),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back', style: TextStyle(color: AppColors.primary)),
        ),
        actions: [
          TextButton(
            onPressed: _saveContact,
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.blueGrey,
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Implement clear/change photo functionality
                  print('Clear photo');
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              labelText: 'First name',
              controller: _firstNameController,
            ),
            _buildTextField(
              labelText: 'Last name',
              controller: _lastNameController,
            ),
            _buildTextField(
              labelText: 'Company',
              controller: _companyController,
            ),
            const SizedBox(height: 20),
            _buildEditableTextFieldList(
              label: 'Phone',
              controllers: _phoneControllers,
              onAdd: () {
                setState(() {
                  _phoneControllers.add(TextEditingController());
                });
              },
            ),
            _buildEditableTextFieldList(
              label: 'Email',
              controllers: _emailControllers,
              onAdd: () {
                setState(() {
                  _emailControllers.add(TextEditingController());
                });
              },
            ),
            _buildEditableTextFieldList(
              label: 'Web site',
              controllers: _websiteControllers,
              onAdd: () {
                setState(() {
                  _websiteControllers.add(TextEditingController());
                });
              },
            ),
            _buildEditableTextFieldList(
              label: 'Address',
              controllers: _addressControllers,
              onAdd: () {
                setState(() {
                  _addressControllers.add(TextEditingController());
                });
              },
              maxLines: null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _deleteContact,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text(
                  'Delete contact',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: const InputDecoration(border: UnderlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTextFieldList({
    required String label,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        if (controllers.length > 1) {
                          controllers.removeAt(index);
                        } else if (controllers.length == 1) {
                          controllers[index].clear();
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: controllers[index],
                      decoration: InputDecoration(
                        labelText:
                            controllers.length > 1
                                ? '$label ${index + 1}'
                                : label,
                        border: const UnderlineInputBorder(),
                      ),
                      maxLines: maxLines,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
            label: Text(
              'Add $label',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
