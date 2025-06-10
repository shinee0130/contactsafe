import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart'; // <<< ADD THIS IMPORT

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

  List<String> _phoneNumbers = [''];
  List<PhoneLabel> _phoneLabels = [PhoneLabel.mobile];

  final List<TextEditingController> _emailControllers = [
    TextEditingController(),
  ];
  final List<EmailLabel> _emailLabels = [EmailLabel.home];

  final List<TextEditingController> _websiteControllers = [
    TextEditingController(),
  ];

  final List<TextEditingController> _addressControllers = [
    TextEditingController(),
  ];
  final List<AddressLabel> _addressLabels = [AddressLabel.home];

  DateTime? _selectedBirthday;

  // Firestore instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // <<< ADD THIS LINE

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
    // --- Data preparation for flutter_contacts (existing logic) ---
    final List<Phone> phonesToSave = [];
    for (int i = 0; i < _phoneNumbers.length; i++) {
      if (_phoneNumbers[i].trim().isNotEmpty) {
        phonesToSave.add(
          Phone(_phoneNumbers[i].trim(), label: _phoneLabels[i]),
        );
      }
    }

    final List<Email> emailsToSave =
        _emailControllers
            .asMap()
            .entries
            .where((entry) => entry.value.text.trim().isNotEmpty)
            .map(
              (entry) => Email(
                entry.value.text.trim(),
                label: _emailLabels[entry.key],
              ),
            )
            .toList();

    final List<Website> websitesToSave =
        _websiteControllers
            .where((c) => c.text.trim().isNotEmpty)
            .map((c) => Website(c.text.trim()))
            .toList();

    final List<Address> addressesToSave =
        _addressControllers
            .asMap()
            .entries
            .where((entry) => entry.value.text.trim().isNotEmpty)
            .map(
              (entry) => Address(
                entry.value.text.trim(),
                label: _addressLabels[entry.key],
              ),
            )
            .toList();

    // Create a Contact object for saving to device (if needed)
    Contact newDeviceContact = Contact(
      name: Name(
        first: _firstNameController.text.trim(),
        last: _lastNameController.text.trim(),
      ),
      organizations:
          _companyController.text.trim().isNotEmpty
              ? [Organization(company: _companyController.text.trim())]
              : [],
      phones: phonesToSave,
      emails: emailsToSave,
      websites: websitesToSave,
      addresses: addressesToSave,
      photo: _selectedPhoto,
      // You can add birthday here too if FlutterContacts supports it
      // birthday: _selectedBirthday, // Check flutter_contacts docs for exact usage
    );

    // --- Prepare data for Firestore ---
    Map<String, dynamic> firestoreContactData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'company': _companyController.text.trim(),
      'phones':
          phonesToSave
              .map((p) => {'number': p.number, 'label': p.label.toString()})
              .toList(),
      'emails':
          emailsToSave
              .map((e) => {'address': e.address, 'label': e.label.toString()})
              .toList(),
      'websites': websitesToSave.map((w) => w.url).toList(),
      'addresses':
          addressesToSave
              .map((a) => {'address': a.address, 'label': a.label.toString()})
              .toList(),
      'birthday':
          _selectedBirthday != null
              ? Timestamp.fromDate(_selectedBirthday!)
              : null, // Store as Firestore Timestamp
      // For photo, you would typically upload it to Firebase Storage and save the URL here.
      // For now, we'll just acknowledge it.
      'photoUrl':
          null, // We'll add Firebase Storage logic for photos later if needed
      'createdAt': FieldValue.serverTimestamp(), // Timestamp of creation
    };

    try {
      // 1. Save to device contacts (optional, based on your app's needs)
      if (await FlutterContacts.requestPermission()) {
        await newDeviceContact.insert();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact saved to device!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Contact permission denied. Cannot save to device.',
              ),
            ),
          );
        }
      }

      // 2. Save to Cloud Firestore
      await _firestore
          .collection('contacts')
          .add(firestoreContactData); // <<< SAVE TO FIRESTORE
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact saved to Cloud Firestore!')),
        );
        Navigator.pop(context, true); // Pop back after successful save
      }
    } catch (e) {
      if (mounted) {
        print('Error saving contact to device or Firestore: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save contact: $e')));
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
                      Icons.add_a_photo_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedPhoto != null ? 'Change picture' : 'Add picture',
          style: TextStyle(
            color: Colors.blue,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                          labelText: 'Phone Number',
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ), // Grey icon
              label: Text(
                'Add phone',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSpecial
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.blue, width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ContactSafe',
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
                color: Colors.blue,
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
                  'Create contact',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Divider(),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
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
          ],
        ),
      ),
    );
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
    Widget _buildLabelDropdown(int index) {
      if (label == 'Email') {
        return Expanded(
          flex: 2,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<EmailLabel>(
              isExpanded: true,
              value:
                  labels != null && index < labels.length
                      ? labels[index] as EmailLabel
                      : EmailLabel.other,
              onChanged: (EmailLabel? newValue) {
                if (newValue != null && onLabelChanged != null) {
                  onLabelChanged(index, newValue);
                }
              },
              items:
                  EmailLabel.values.map<DropdownMenuItem<EmailLabel>>((
                    EmailLabel value,
                  ) {
                    return DropdownMenuItem<EmailLabel>(
                      value: value,
                      child: Text(_getEmailLabelString(value)),
                    );
                  }).toList(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        );
      } else if (label == 'Address') {
        return Expanded(
          flex: 2,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AddressLabel>(
              isExpanded: true,
              value:
                  labels != null && index < labels.length
                      ? labels[index] as AddressLabel
                      : AddressLabel.other,
              onChanged: (AddressLabel? newValue) {
                if (newValue != null && onLabelChanged != null) {
                  onLabelChanged(index, newValue);
                }
              },
              items:
                  AddressLabel.values.map<DropdownMenuItem<AddressLabel>>((
                    AddressLabel value,
                  ) {
                    return DropdownMenuItem<AddressLabel>(
                      value: value,
                      child: Text(_getAddressLabelString(value)),
                    );
                  }).toList(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (labels != null &&
                      (label == 'Email' || label == 'Address'))
                    _buildLabelDropdown(index),
                  if (labels != null &&
                      (label == 'Email' || label == 'Address'))
                    const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: controllers[index],
                      keyboardType: keyboardType,
                      maxLines: maxLines,
                      decoration: InputDecoration(
                        labelText:
                            (labels != null &&
                                    (label == 'Email' || label == 'Address'))
                                ? null
                                : (controllers.length > 1
                                    ? '$label ${index + 1}'
                                    : label),
                        floatingLabelBehavior:
                            FloatingLabelBehavior.never, // Label stays as hint
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ), // Grey icon
              label: Text(
                'Add $label',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
