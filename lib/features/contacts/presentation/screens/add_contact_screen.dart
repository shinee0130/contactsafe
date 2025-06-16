import 'dart:io';

import 'package:contactsafe/l10n/app_localizations.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          .collection('user_contacts')
          .doc(FirebaseAuth.instance.currentUser!.uid)
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
        debugPrint('Error saving contact to device or Firestore: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save contact: $e')));
      }
    }
  }

  Future<bool> requestPhotoPermission(BuildContext context) async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      int sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      if (sdkInt >= 33) {
        // Android 13+
        status = await Permission.photos.request();
      } else {
        // Android 12- (хуучин хувилбар)
        status = await Permission.storage.request();
      }
    } else if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      // Бусад платформд зөвшөөрөл шаардахгүй
      return true;
    }

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo library permission denied.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
      return false;
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Photo library permission permanently denied. Please enable in settings.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
      return false;
    }
    return false;
  }

  Future<void> _changePhoto() async {
    final granted = await requestPhotoPermission(context);
    if (!granted) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedPhoto = bytes;
      });
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedPhoto != null
              ? context.loc.translate('changePicture')
              : context.loc.translate('addPicture'),
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
              fontSize: 12.0,
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
                          hintText: context.loc.translate('enterPhoneNumber'),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ), // Grey icon
              label: Text(
                context.loc.translate('addPhone'),
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
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
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
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

            // ---- EMAIL SECTION ----
            if (_emailControllers.isEmpty)
              _buildAddButton(
                icon: Icons.email_outlined,
                text: context.loc.translate('addEmail'),
                onPressed: () {
                  setState(() {
                    _emailControllers.add(TextEditingController());
                    _emailLabels.add(EmailLabel.other);
                  });
                },
                isSpecial: true,
              ),
            if (_emailControllers.isNotEmpty)
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

            // ---- BIRTHDAY SECTION ----
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
                        ).colorScheme.onSurface.withOpacity(0.5),
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

            // ---- ADDRESS SECTION ----
            if (_addressControllers.isEmpty)
              _buildAddButton(
                icon: Icons.location_on_outlined,
                text: context.loc.translate('addAddress'),
                onPressed: () {
                  setState(() {
                    _addressControllers.add(TextEditingController());
                    _addressLabels.add(AddressLabel.other);
                  });
                },
                isSpecial: true,
              ),
            if (_addressControllers.isNotEmpty)
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
        return DropdownButtonHideUnderline(
          child: DropdownButton<EmailLabel>(
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
                EmailLabel.values.map((value) {
                  return DropdownMenuItem<EmailLabel>(
                    value: value,
                    child: Text(
                      _getEmailLabelString(value),
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                }).toList(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
            ),
            dropdownColor: Theme.of(context).colorScheme.surface,
          ),
        );
      } else if (label == 'Address') {
        return DropdownButtonHideUnderline(
          child: DropdownButton<AddressLabel>(
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
                AddressLabel.values.map((value) {
                  return DropdownMenuItem<AddressLabel>(
                    value: value,
                    child: Text(
                      _getAddressLabelString(value),
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                }).toList(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
            ),
            dropdownColor: Theme.of(context).colorScheme.surface,
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
              padding: const EdgeInsets.only(left: 0, right: 0, bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Dropdown (label)
                  Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 8),
                    child: _buildLabelDropdown(index),
                  ),
                  // Textfield (email or address)
                  Expanded(
                    child: TextField(
                      controller: controllers[index],
                      keyboardType: keyboardType,
                      maxLines: maxLines ?? 1,
                      decoration: InputDecoration(
                        hintText:
                            label == 'Email'
                                ? context.loc.translate('exampleEmail')
                                : context.loc.translate('enterAddress'),
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
                          horizontal: 14.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // Remove icon
                  Padding(
                    padding: const EdgeInsets.only(left: 6, right: 3),
                    child: ClipOval(
                      child: Material(
                        color: Colors.grey.shade200,
                        child: InkWell(
                          onTap: () {
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
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 0.0, bottom: 16.0),
            child: TextButton.icon(
              onPressed: onAdd,
              icon: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              label: Text(
                'Add $label',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
