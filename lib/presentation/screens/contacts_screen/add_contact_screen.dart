import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../common/theme/app_colors.dart';
import 'dart:typed_data'; // Import for Uint8List

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  Uint8List? _selectedPhoto;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final List<TextEditingController> _phoneControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _emailControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _websiteControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _addressControllers = [
    TextEditingController(),
  ];

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
      organizations: [Organization(company: company)],
      phones: phones,
      emails: emails,
      websites: websites,
      addresses: addresses,
      photo: _selectedPhoto,
    );

    try {
      await FlutterContacts.insertContact(newContact);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      print('Error saving contact: $e');
    }
  }

  Future<void> _changePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedPhoto = bytes;
      });
    }
  }

  void _clearPhoto() {
    setState(() {
      _selectedPhoto = null;
    });
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        _selectedPhoto != null
            ? CircleAvatar(
              radius: 75,
              backgroundImage: MemoryImage(_selectedPhoto!),
            )
            : const CircleAvatar(
              radius: 75,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person_outline, size: 75, color: Colors.white),
            ),
        GestureDetector(
          onTap: _changePhoto,
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () {
            Navigator.pop(context);
          },
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
            const Text(
              'Create contact',
              style: TextStyle(fontSize: 31.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Center(child: _buildAvatar()),
            Center(
              child: TextButton(
                onPressed: _clearPhoto,
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              hintText: 'Firstname',
              labelText: 'First name',
              controller: _firstNameController,
            ),
            _buildTextField(
              hintText: 'Firstname',
              labelText: 'Last name',
              controller: _lastNameController,
            ),
            _buildTextField(
              hintText: 'Firstname',
              labelText: 'Company',
              controller: _companyController,
            ),
            const SizedBox(height: 16),
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
    required String hintText,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              labelText: labelText,
              border: const OutlineInputBorder(),
            ),
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
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildTextField(
                labelText:
                    controllers.length > 1 ? '$label ${index + 1}' : label,
                hintText: 'Enter $label',
                controller: controllers[index],
              ),
            );
          },
        ),
      ],
    );
  }
}
