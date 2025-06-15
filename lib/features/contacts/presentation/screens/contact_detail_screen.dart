import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:contactsafe/features/contacts/presentation/screens/edit_contact_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;
  final bool isFavorite;

  const ContactDetailScreen({
    super.key,
    required this.contact,
    this.isFavorite = false,
  });

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  Contact? _detailedContact;
  int _filesCount = 0;
  int _notesCount = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _loadContactDetails(widget.contact.id);
    _loadCounts();
    _loadFavoriteStatus();
  }

  Future<void> _loadCounts() async {
    try {
      final filesSnapshot =
          await FirebaseFirestore.instance
              .collection('contact_files_metadata')
              .doc(widget.contact.id)
              .collection('files')
              .get();
      final notesSnapshot =
          await FirebaseFirestore.instance
              .collection('contact_notes')
              .doc(widget.contact.id)
              .collection('notes')
              .get();
      setState(() {
        _filesCount = filesSnapshot.size;
        _notesCount = notesSnapshot.size;
      });
    } catch (e) {
      setState(() {
        _filesCount = 0;
        _notesCount = 0;
      });
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList('favorite_contacts') ?? [];
    setState(() {
      _isFavorite = favIds.contains(widget.contact.id);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList('favorite_contacts') ?? [];
    if (favIds.contains(widget.contact.id)) {
      favIds.remove(widget.contact.id);
    } else {
      favIds.add(widget.contact.id);
    }
    await prefs.setStringList('favorite_contacts', favIds);
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<void> _loadContactDetails(String contactId) async {
    try {
      if (await FlutterContacts.requestPermission()) {
        Contact? fetchedContact = await FlutterContacts.getContact(
          contactId,
          withAccounts: true,
          withProperties: true,
          withPhoto: true,
        );
        setState(() {
          _detailedContact = fetchedContact ?? widget.contact;
        });
      } else {
        setState(() {
          _detailedContact = widget.contact;
        });
      }
    } catch (e) {
      setState(() {
        _detailedContact = widget.contact;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone call')),
        );
      }
    }
  }

  Future<void> _sendSms(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch messaging app')),
        );
      }
    }
  }

  Future<void> _sendEmail(String emailAddress) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {'subject': 'Regarding our contact', 'body': 'Hello,'},
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email app')),
        );
      }
    }
  }

  String generateVcf(Contact contact) {
    StringBuffer vcfContent = StringBuffer();

    vcfContent.writeln('BEGIN:VCARD');
    vcfContent.writeln('VERSION:3.0');

    String formattedName = '';
    if (contact.name.prefix.isNotEmpty) {
      formattedName += '${contact.name.prefix} ';
    }
    if (contact.name.first.isNotEmpty) {
      formattedName += '${contact.name.first} ';
    }
    if (contact.name.middle.isNotEmpty) {
      formattedName += '${contact.name.middle} ';
    }
    if (contact.name.last.isNotEmpty) {
      formattedName += contact.name.last;
    }
    formattedName = formattedName.trim();

    if (formattedName.isNotEmpty) {
      vcfContent.writeln('FN:$formattedName');
    }

    // Add organization to VCF if available
    if (contact.organizations.isNotEmpty) {
      vcfContent.writeln('ORG:${contact.organizations.first.company}');
    }

    for (var phone in contact.phones) {
      String typeLabel = _getPhoneLabelString(phone.label);
      vcfContent.writeln('TEL;TYPE=$typeLabel:${phone.number}');
    }

    for (var email in contact.emails) {
      String typeLabel = _getEmailLabelString(email.label);
      vcfContent.writeln('EMAIL;TYPE=$typeLabel:${email.address}');
    }

    for (var address in contact.addresses) {
      String typeLabel = _getAddressLabelString(address.label);
      vcfContent.writeln(
        'ADR;TYPE=$typeLabel:;;${address.street};${address.city};${address.postalCode};${address.country}',
      );
    }

    if (contact.photo != null && contact.photo!.isNotEmpty) {
      String base64Image = base64Encode(contact.photo!);
      vcfContent.writeln('PHOTO;ENCODING=BASE64;TYPE=JPEG:$base64Image');
    }

    vcfContent.writeln('END:VCARD');
    return vcfContent.toString();
  }

  Future<void> saveVcfFile(String vcfContent, String contactName) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          String fileName = '${contactName.replaceAll(' ', '_')}.vcf';
          File file = File('${directory.path}/$fileName');
          await file.writeAsString(vcfContent);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Contact exported to: ${file.path}')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error accessing storage.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving VCF file: $e')));
        }
      }
    } else if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied.')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Storage permission permanently denied. Please enable in settings.',
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
      default:
        return 'Address';
    }
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAvatar(Contact contact) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      child:
          contact.photo != null && contact.photo!.isNotEmpty
              ? ClipOval(
                child: Image.memory(
                  contact.photo!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
              : Center(
                child: Text(
                  contact.displayName.isNotEmpty
                      ? contact.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionItem(String title, int count, VoidCallback onTap) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCountBadge(count),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentContact = _detailedContact ?? widget.contact;

    // Determine what to display under the contact name
    String? subtitleText;
    if (currentContact.organizations.isNotEmpty &&
        currentContact.organizations.first.company.isNotEmpty) {
      subtitleText = currentContact.organizations.first.company;
    } else if (currentContact.phones.isNotEmpty) {
      subtitleText = currentContact.phones.first.number;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Navigator.pop(context),
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
          IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditContactScreen(contact: currentContact),
                ),
              ).then(
                (_) => {_loadContactDetails(currentContact.id), _loadCounts()},
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              _toggleFavorite();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${currentContact.displayName} favorite status toggled!',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                children: [
                  _buildAvatar(currentContact),
                  const SizedBox(height: 16),
                  Text(
                    currentContact.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (subtitleText != null && subtitleText.isNotEmpty)
                    Text(
                      subtitleText,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(Icons.call, 'Call', () {
                        if (currentContact.phones.isNotEmpty) {
                          _makePhoneCall(currentContact.phones.first.number);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No phone number available'),
                            ),
                          );
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Calling ${currentContact.displayName}',
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 16),
                      _buildActionButton(Icons.message, 'Message', () {
                        if (currentContact.phones.isNotEmpty) {
                          _sendSms(currentContact.phones.first.number);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No phone number available'),
                            ),
                          );
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Messaging ${currentContact.displayName}',
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 16),
                      _buildActionButton(Icons.email, 'Email', () {
                        if (currentContact.emails.isNotEmpty) {
                          _sendEmail(currentContact.emails.first.address);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No email address available'),
                            ),
                          );
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Emailing ${currentContact.displayName}',
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // Contact Details Section
            if (currentContact.phones.isNotEmpty ||
                currentContact.emails.isNotEmpty ||
                currentContact.addresses.isNotEmpty ||
                currentContact.organizations.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 8,
                        bottom: 4,
                      ),
                      child: Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    if (currentContact.phones.isNotEmpty)
                      ...currentContact.phones.map(
                        (phone) => _buildDetailItem(
                          _getPhoneLabelString(phone.label),
                          phone.number,
                        ),
                      ),
                    if (currentContact.emails.isNotEmpty)
                      ...currentContact.emails.map(
                        (email) => _buildDetailItem(
                          _getEmailLabelString(email.label),
                          email.address,
                        ),
                      ),
                    if (currentContact.addresses.isNotEmpty)
                      ...currentContact.addresses.map(
                        (address) => _buildDetailItem(
                          _getAddressLabelString(address.label),
                          '${address.street}, ${address.city}, ${address.postalCode}',
                        ),
                      ),
                  ],
                ),
              ),

            Container(
              margin: const EdgeInsets.only(
                top: 16,
                bottom: 24,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSectionItem('Files', _filesCount, () {
                    Navigator.pushNamed(
                      context,
                      '/contact_files',
                      arguments: currentContact,
                    ).then((_) => _loadCounts());
                  }),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildSectionItem('Notes', _notesCount, () {
                    Navigator.pushNamed(
                      context,
                      '/contact_notes',
                      arguments: currentContact,
                    ).then((_) => _loadCounts());
                  }),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildSectionItem('Export VCF', 0, () async {
                    if (_detailedContact != null) {
                      String vcfContent = generateVcf(_detailedContact!);
                      await saveVcfFile(
                        vcfContent,
                        _detailedContact!.displayName,
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
