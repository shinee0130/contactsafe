import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:contactsafe/models/contact_labels.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class EditContactScreen extends StatefulWidget {
  final Contact contact;

  const EditContactScreen({super.key, required this.contact});

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  Uint8List? _selectedPhoto;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  // Phone fields
  List<String> _phoneNumbers = [];
  List<PhoneLabel> _phoneLabels = [];

  // Email fields
  final List<TextEditingController> _emailControllers = [];
  final List<EmailLabel> _emailLabels = [];

  // Website fields
  final List<TextEditingController> _websiteControllers = [];

  // Address fields
  final List<TextEditingController> _addressControllers = [];
  final List<AddressLabel> _addressLabels = [];

  DateTime? _selectedBirthday;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    _selectedPhoto = widget.contact.avatar;
    _firstNameController.text = widget.contact.givenName ?? '';
    _lastNameController.text = widget.contact.familyName ?? '';
    _companyController.text = widget.contact.company ?? '';

    // Populate phones
    _phoneNumbers =
        (widget.contact.phones ?? []).map((p) => p.value ?? '').toList();
    _phoneLabels =
        (widget.contact.phones ?? [])
            .map((p) => PhoneLabelX.fromString(p.label))
            .toList();
    if (_phoneNumbers.isEmpty) {
      _phoneNumbers.add('');
      _phoneLabels.add(PhoneLabel.mobile);
    }

    // Populate emails
    _emailControllers.addAll(
      (widget.contact.emails ?? []).map(
        (e) => TextEditingController(text: e.value ?? ''),
      ),
    );
    _emailLabels.addAll(
      (widget.contact.emails ?? []).map((e) => EmailLabelX.fromString(e.label)),
    );
    if (_emailControllers.isEmpty) {
      _emailControllers.add(TextEditingController());
      _emailLabels.add(EmailLabel.home);
    }

    // Populate websites
    // contacts_service has no websites field; keep empty controllers

    // Populate addresses
    _addressControllers.addAll(
      (widget.contact.postalAddresses ?? []).map(
        (a) => TextEditingController(text: a.street ?? ''),
      ),
    );
    _addressLabels.addAll(
      (widget.contact.postalAddresses ?? []).map(
        (a) => AddressLabelX.fromString(a.label),
      ),
    );
    if (_addressControllers.isEmpty) {
      _addressControllers.add(TextEditingController());
      _addressLabels.add(AddressLabel.home);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
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
    // Filter out empty entries before saving
    final List<Item> phonesToSave = [];
    for (int i = 0; i < _phoneNumbers.length; i++) {
      if (_phoneNumbers[i].trim().isNotEmpty) {
        phonesToSave.add(
          Item(label: _phoneLabels[i].label, value: _phoneNumbers[i].trim()),
        );
      }
    }

    final List<Item> emailsToSave =
        _emailControllers
            .asMap()
            .entries
            .where((entry) => entry.value.text.trim().isNotEmpty)
            .map(
              (entry) => Item(
                label: _emailLabels[entry.key].label,
                value: entry.value.text.trim(),
              ),
            )
            .toList();

    final List<String> websitesToSave =
        _websiteControllers
            .where((c) => c.text.trim().isNotEmpty)
            .map((c) => c.text.trim())
            .toList();

    final List<PostalAddress> addressesToSave =
        _addressControllers
            .asMap()
            .entries
            .where((entry) => entry.value.text.trim().isNotEmpty)
            .map(
              (entry) => PostalAddress(
                label: _addressLabels[entry.key].label,
                street: entry.value.text.trim(),
              ),
            )
            .toList();

    // Update fields on the existing contact so that rawId and account
    // information are preserved during the update call.
    Contact updatedContact = Contact(
      givenName: _firstNameController.text.trim(),
      familyName: _lastNameController.text.trim(),
      company: _companyController.text.trim(),
      phones: phonesToSave,
      emails: emailsToSave,
      postalAddresses: addressesToSave,
      avatar: _selectedPhoto,
      birthday: _selectedBirthday,
    );

    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        await ContactsService.updateContact(updatedContact);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact updated successfully!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Contact permission denied. Cannot update contact.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error updating contact: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update contact: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteContact() async {
    try {
      await ContactsService.deleteContact(widget.contact);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete contact: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _changePhoto() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedPhoto = bytes;
        });
      }
    } else if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo library permission denied.')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Photo library permission permanently denied. Please enable in settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
    }
  }

  Widget _buildAvatar() {
    return Column(
      children: [
        GestureDetector(
          onTap: _changePhoto,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
            child:
                _selectedPhoto != null
                    ? ClipOval(
                      child: Image.memory(
                        _selectedPhoto!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                    : Icon(
                      Icons.person_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedPhoto != null ? 'Change picture' : 'Add picture',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              alignLabelWithHint: true,
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
                vertical: 16.0,
                horizontal: 16.0,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _getPhoneLabelString(PhoneLabel label) {
    switch (label) {
      case PhoneLabel.mobile:
        return 'Mobile';
      case PhoneLabel.home:
        return 'Home';
      case PhoneLabel.work:
        return 'Work';
      case PhoneLabel.pager:
        return 'Pager';
      case PhoneLabel.other:
        return 'Other';
      case PhoneLabel.custom:
        return 'Custom';
      default:
        return 'Phone';
    }
  }

  String _getEmailLabelString(EmailLabel label) {
    switch (label) {
      case EmailLabel.home:
        return 'Home';
      case EmailLabel.work:
        return 'Work';
      case EmailLabel.other:
        return 'Other';
      case EmailLabel.custom:
        return 'Custom';
      default:
        return 'Email';
    }
  }

  String _getAddressLabelString(AddressLabel label) {
    switch (label) {
      case AddressLabel.home:
        return 'Home';
      case AddressLabel.work:
        return 'Work';
      case AddressLabel.other:
        return 'Other';
      case AddressLabel.custom:
        return 'Custom';
      default:
        return 'Address';
    }
  }

  Widget _buildPhoneInputList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone (${_getPhoneLabelString(_phoneLabels[0])})',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _phoneNumbers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: IntlPhoneField(
                        initialValue: _phoneNumbers[index],
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
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
                            vertical: 16.0,
                            horizontal: 16.0,
                          ),
                        ),
                        initialCountryCode: 'US',
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                        onChanged: (phone) {
                          _phoneNumbers[index] = phone.number;
                        },
                        dropdownIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        dropdownTextStyle: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (_phoneNumbers.length > 1)
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            _phoneNumbers.removeAt(index);
                            _phoneLabels.removeAt(index);
                          });
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _phoneNumbers.add('');
                  _phoneLabels.add(PhoneLabel.other);
                });
              },
              icon: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              label: Text(
                'Add phone',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    bool isSpecial = false,
  }) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSpecial
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : bgColor,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBirthday() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedBirthday) {
      setState(() {
        _selectedBirthday = pickedDate;
      });
    }
  }

  Widget _buildEditableTextFieldList({
    required String label,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    int? maxLines,
    TextInputType keyboardType = TextInputType.text,
    List<dynamic>? labels,
    Function(int, dynamic)? onLabelChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label == 'Email' || label == 'Address'
                        ? '$label (${label == 'Email' ? _getEmailLabelString(_emailLabels[index]) : _getAddressLabelString(_addressLabels[index])})'
                        : label +
                            (controllers.length > 1 ? ' ${index + 1}' : ''),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: controllers[index],
                          keyboardType: keyboardType,
                          maxLines: maxLines,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            alignLabelWithHint: true,
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
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            if (controllers.length > 1) {
                              controllers[index].dispose();
                              controllers.removeAt(index);
                              if (labels != null && index < labels.length) {
                                labels.removeAt(index);
                              }
                            } else if (controllers.length == 1) {
                              controllers[index].clear();
                              if (labels != null && index < labels.length) {
                                if (label == 'Email')
                                  labels[index] = EmailLabel.other;
                                if (label == 'Address')
                                  labels[index] = AddressLabel.other;
                              }
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: TextButton.icon(
              onPressed: onAdd,
              icon: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              label: Text(
                'Add $label',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'contactSafe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saveContact,
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Edit contact',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 24),
            _buildAvatar(),
            const SizedBox(height: 24),

            // Main contact fields
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

            const SizedBox(height: 16),
            _buildPhoneInputList(),
            const SizedBox(height: 16),

            // Email section
            if (_emailControllers.every((c) => c.text.isEmpty))
              _buildAddButton(
                icon: Icons.email_outlined,
                text: 'Add email',
                onPressed: () {
                  setState(() {
                    _emailControllers.add(TextEditingController());
                    _emailLabels.add(EmailLabel.other);
                  });
                },
                isSpecial: true,
              ),
            if (_emailControllers.any((c) => c.text.isNotEmpty))
              _buildEditableTextFieldList(
                label: 'Email',
                controllers: _emailControllers,
                onAdd: () {
                  setState(() {
                    _emailControllers.add(TextEditingController());
                    _emailLabels.add(EmailLabel.other);
                  });
                },
                keyboardType: TextInputType.emailAddress,
                labels: _emailLabels,
                onLabelChanged: (index, newLabel) {
                  setState(() {
                    _emailLabels[index] = newLabel as EmailLabel;
                  });
                },
              ),
            const SizedBox(height: 8),

            // Birthday section
            if (_selectedBirthday == null)
              _buildAddButton(
                icon: Icons.cake_outlined,
                text: 'Add birthday',
                onPressed: _pickBirthday,
                isSpecial: true,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cake_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Birthday: ${MaterialLocalizations.of(context).formatFullDate(_selectedBirthday!)}',
                        style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedBirthday = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Address section
            if (_addressControllers.every((c) => c.text.isEmpty))
              _buildAddButton(
                icon: Icons.location_on_outlined,
                text: 'Add address',
                onPressed: () {
                  setState(() {
                    _addressControllers.add(TextEditingController());
                    _addressLabels.add(AddressLabel.other);
                  });
                },
                isSpecial: true,
              ),
            if (_addressControllers.any((c) => c.text.isNotEmpty))
              _buildEditableTextFieldList(
                label: 'Address',
                controllers: _addressControllers,
                onAdd: () {
                  setState(() {
                    _addressControllers.add(TextEditingController());
                    _addressLabels.add(AddressLabel.other);
                  });
                },
                maxLines: null,
                labels: _addressLabels,
                onLabelChanged: (index, newLabel) {
                  setState(() {
                    _addressLabels[index] = newLabel as AddressLabel;
                  });
                },
              ),
            const SizedBox(height: 24),

            // Delete contact button
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: _deleteContact,
                  child: const Text(
                    'Delete Contact',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
