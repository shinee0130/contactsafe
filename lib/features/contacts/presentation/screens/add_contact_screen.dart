import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // Import for phone number input
import '../../../../core/theme/app_colors.dart'; // Assuming this path is correct
import 'dart:typed_data';

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

  // For phone numbers, we'll manage a list of Phone objects (or just numbers)
  // The IntlPhoneField handles its own internal controller.
  List<String> _phoneNumbers = ['']; // Start with one empty phone field
  List<PhoneLabel> _phoneLabels = [PhoneLabel.mobile]; // Corresponding labels

  final List<TextEditingController> _emailControllers = [
    TextEditingController(),
  ];
  final List<EmailLabel> _emailLabels = [EmailLabel.home];

  // The image doesn't show websites, but we'll keep the functionality
  final List<TextEditingController> _websiteControllers = [
    TextEditingController(),
  ];

  final List<TextEditingController> _addressControllers = [
    TextEditingController(),
  ];
  final List<AddressLabel> _addressLabels = [AddressLabel.home];

  DateTime? _selectedBirthday;

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

    Contact newContact = Contact(
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
    );

    try {
      if (await FlutterContacts.requestPermission()) {
        await newContact.insert();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact saved successfully!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact permission denied. Cannot save contact.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        print('Error saving contact: $e');
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

  // New avatar style
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
              color: Colors.grey[200], // Light grey background
              border: Border.all(color: Colors.grey[300]!, width: 1),
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
                      Icons.add_a_photo_outlined, // Add photo icon
                      size: 48,
                      color: Colors.grey[600],
                    ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedPhoto != null
              ? 'Change picture'
              : 'Add picture', // Change text
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Custom TextField widget to match the UI
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
          floatingLabelBehavior:
              FloatingLabelBehavior.never, // Label stays as hint
          alignLabelWithHint: true, // Align label with hint
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ), // Highlight on focus
          ),
          filled: true,
          fillColor: Colors.white, // White background for text fields
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
        ),
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      ),
    );
  }

  // Helper functions to convert labels to strings
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

  // The new phone input with country code
  Widget _buildPhoneInputList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone (${_getPhoneLabelString(_phoneLabels[0])})', // Display current label
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                          // labelText: 'Phone Number', // No labelText, use hintText
                          hintText: 'Enter phone number', // Hint to match image
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 16.0,
                          ),
                        ),
                        initialCountryCode: 'US', // Default country code
                        onChanged: (phone) {
                          _phoneNumbers[index] = phone.number;
                        },
                        // Optionally, you can add dropdown for labels if you want to allow changing labels
                        // like 'Mobile', 'Work', 'Home'
                        dropdownIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                        dropdownTextStyle: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (_phoneNumbers.length >
                        1) // Only show remove button if more than one
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
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
            alignment: Alignment.centerLeft, // Align "Add phone" to left
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _phoneNumbers.add('');
                  _phoneLabels.add(PhoneLabel.other); // Add default label
                });
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.grey,
              ), // Grey icon
              label: const Text(
                'Add phone',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable button for "Add email", "Add birthday", "Add address"
  Widget _buildAddButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor =
        AppColors.primary, // Default to primary for consistency
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
    bool isSpecial = false, // For buttons like Email, Birthday, Address
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSpecial
                  ? Colors.blue[50]
                  : backgroundColor, // Light blue for these buttons
          foregroundColor:
              AppColors.textPrimary, // Darker text for light background
          elevation: 0, // No shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: Colors.blue[100]!,
              width: 1,
            ), // Light blue border
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          minimumSize: const Size(double.infinity, 50), // Full width
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.start, // Align icon and text to start
          children: [
            Icon(icon, color: AppColors.primary), // Primary color for icon
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ContactSafe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saveContact,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
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
                child: const Text(
                  'Create contact',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
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

            const SizedBox(height: 16), // Space before phone input
            // Phone input section (new style)
            _buildPhoneInputList(),
            const SizedBox(height: 16),

            // Dynamic "Add" buttons
            if (_emailControllers.every(
              (c) => c.text.isEmpty,
            )) // Show button if no email added
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
            if (_emailControllers.any(
              (c) => c.text.isNotEmpty,
            )) // Show list if emails exist
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

            if (_selectedBirthday == null) // Show button if no birthday added
              _buildAddButton(
                icon: Icons.cake_outlined,
                text: 'Add birthday',
                onPressed: _pickBirthday,
                isSpecial: true,
              )
            else // Show birthday text if picked
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_outlined, color: AppColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Birthday: ${MaterialLocalizations.of(context).formatFullDate(_selectedBirthday!)}',
                        style: const TextStyle(
                          fontSize: 17,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
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

            if (_addressControllers.every(
              (c) => c.text.isEmpty,
            )) // Show button if no address added
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
            if (_addressControllers.any(
              (c) => c.text.isNotEmpty,
            )) // Show list if addresses exist
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

            // You can keep websites if you want, but they are not in the sample image
            // _buildEditableTextFieldList(
            //   label: 'Website',
            //   controllers: _websiteControllers,
            //   onAdd: () {
            //     setState(() {
            //       _websiteControllers.add(TextEditingController());
            //     });
            //   },
            //   keyboardType: TextInputType.url,
            // ),
          ],
        ),
      ),
    );
  }

  // This _buildEditableTextFieldList is adapted from your previous response
  // It's used for Email and Address fields to maintain consistency
  Widget _buildEditableTextFieldList({
    required String label,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    int? maxLines,
    TextInputType keyboardType = TextInputType.text,
    List<dynamic>? labels,
    Function(int, dynamic)? onLabelChanged,
  }) {
    // Helper function to get the correct label string (already defined above)
    // Removed duplicate helper functions to keep code clean.
    // Ensure _getPhoneLabelString, _getEmailLabelString, _getAddressLabelString are defined once.

    // Dropdown for labels (similar to EditContactScreen)
    Widget _buildLabelDropdown(int index) {
      if (label == 'Email') {
        // Only for email and address in this context
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
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              dropdownColor: Colors.white,
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
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              dropdownColor: Colors.white,
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
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
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
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.grey,
              ), // Grey icon
              label: Text(
                'Add $label',
                style: const TextStyle(
                  color: Colors.grey,
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
