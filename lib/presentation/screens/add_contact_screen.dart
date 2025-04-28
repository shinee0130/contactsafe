import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../common/theme/app_colors.dart'; // Assuming you have this

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  List<TextEditingController> _phoneControllers = [TextEditingController()];
  List<TextEditingController> _emailControllers = [TextEditingController()];
  List<TextEditingController> _websiteControllers = [TextEditingController()];
  List<TextEditingController> _addressControllers = [TextEditingController()];

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
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String company = _companyController.text.trim();

    List<Phone> phones =
        _phoneControllers.map((c) => Phone(c.text.trim())).toList();
    List<Email> emails =
        _emailControllers.map((c) => Email(c.text.trim())).toList();
    List<Website> websites =
        _websiteControllers.map((c) => Website(c.text.trim())).toList();
    List<Address> addresses =
        _addressControllers.map((c) => Address(c.text.trim())).toList();

    Contact newContact = Contact(
      name: Name(first: firstName, last: lastName),
      phones: phones,
      emails: emails,
      websites: websites,
      addresses: addresses,
    );

    try {
      await FlutterContacts.insertContact(newContact);
      Navigator.pop(context);
    } catch (e) {
      print('Error saving contact: $e');
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
              'ContactSafe',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 100,
                  color: Colors.blueGrey,
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement clear/change photo functionality
                    print('Clear/Change photo');
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(),
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
            const SizedBox(),
            _buildAddableSection(
              label: 'Phone',
              controllers: _phoneControllers,
              onAdd: () {
                setState(() {
                  _phoneControllers.add(TextEditingController());
                });
              },
            ),
            _buildAddableSection(
              label: 'Email',
              controllers: _emailControllers,
              onAdd: () {
                setState(() {
                  _emailControllers.add(TextEditingController());
                });
              },
            ),
            _buildAddableSection(
              label: 'Web site',
              controllers: _websiteControllers,
              onAdd: () {
                setState(() {
                  _websiteControllers.add(TextEditingController());
                });
              },
            ),
            _buildAddableSection(
              label: 'Address',
              controllers: _addressControllers,
              onAdd: () {
                setState(() {
                  _addressControllers.add(TextEditingController());
                });
              },
              maxLines: null,
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
      padding: const EdgeInsets.symmetric(vertical: 0),
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
          const SizedBox(height: 0),
          TextField(
            controller: controller,
            decoration: const InputDecoration(border: UnderlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildAddableSection({
    required String label,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
            label: Text(
              'Add $label',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: TextField(
                controller: controllers[index],
                decoration: InputDecoration(
                  labelText:
                      controllers.length > 1 ? '$label ${index + 1}' : label,
                  border: const UnderlineInputBorder(),
                ),
                maxLines: maxLines,
              ),
            );
          },
        ),
        const SizedBox(height: 0),
      ],
    );
  }
}
