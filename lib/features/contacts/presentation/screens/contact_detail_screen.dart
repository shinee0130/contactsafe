import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:contactsafe/models/contact_labels.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    _loadContactDetails(widget.contact.identifier ?? '');
    _loadCounts();
    _loadFavoriteStatus();
  }

  Future<void> _loadCounts() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final contactId = widget.contact.identifier ?? '';
      if (userId == null || contactId.isEmpty) {
        setState(() {
          _filesCount = 0;
          _notesCount = 0;
        });
        return;
      }
      final filesSnapshot =
          await FirebaseFirestore.instance
              .collection('user_files')
              .doc(userId)
              .collection('contacts')
              .doc(contactId)
              .collection('files')
              .get();
      final notesSnapshot =
          await FirebaseFirestore.instance
              .collection('user_notes')
              .doc(userId)
              .collection('contacts')
              .doc(contactId)
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
      _isFavorite = favIds.contains(widget.contact.identifier);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList('favorite_contacts') ?? [];
    final contactId = widget.contact.identifier ?? '';
    if (favIds.contains(contactId)) {
      favIds.remove(contactId);
    } else {
      favIds.add(contactId);
    }
    await prefs.setStringList('favorite_contacts', favIds);
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<void> _loadContactDetails(String contactId) async {
    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        final contacts = await FlutterContactsService.getContacts(
          withThumbnails: false,
        );
        final fetchedContact = contacts.firstWhere(
          (c) => c.identifier == contactId,
          orElse: () => widget.contact,
        );
        setState(() {
          _detailedContact = fetchedContact;
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

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available')),
      );
      return;
    }
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

  Future<void> _sendSms(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available')),
      );
      return;
    }
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

  Future<void> _sendEmail(String? emailAddress) async {
    if (emailAddress == null || emailAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email address available')),
      );
      return;
    }
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
    if ((contact.prefix ?? '').isNotEmpty) {
      formattedName += '${contact.prefix} ';
    }
    if ((contact.givenName ?? '').isNotEmpty) {
      formattedName += '${contact.givenName} ';
    }
    if ((contact.middleName ?? '').isNotEmpty) {
      formattedName += '${contact.middleName} ';
    }
    if ((contact.familyName ?? '').isNotEmpty) {
      formattedName += contact.familyName!;
    }
    formattedName = formattedName.trim();

    if (formattedName.isNotEmpty) {
      vcfContent.writeln('FN:$formattedName');
    }

    // Add organization to VCF if available
    if ((contact.company ?? '').isNotEmpty) {
      vcfContent.writeln('ORG:${contact.company}');
    }

    for (var phone in (contact.phones ?? [])) {
      String typeLabel = _getPhoneLabelString(
        PhoneLabelX.fromString(phone.label),
      );
      vcfContent.writeln('TEL;TYPE=$typeLabel:${phone.value ?? ''}');
    }

    for (var email in (contact.emails ?? [])) {
      String typeLabel = _getEmailLabelString(
        EmailLabelX.fromString(email.label),
      );
      vcfContent.writeln('EMAIL;TYPE=$typeLabel:${email.value ?? ''}');
    }

    for (var address in (contact.postalAddresses ?? [])) {
      String typeLabel = _getAddressLabelString(
        AddressLabelX.fromString(address.label),
      );
      vcfContent.writeln(
        'ADR;TYPE=$typeLabel:;;${address.street ?? ''};${address.city ?? ''};${address.postcode ?? ''};${address.country ?? ''}',
      );
    }

    if (contact.avatar != null && contact.avatar!.isNotEmpty) {
      String base64Image = base64Encode(contact.avatar!);
      vcfContent.writeln('PHOTO;ENCODING=BASE64;TYPE=JPEG:$base64Image');
    }

    vcfContent.writeln('END:VCARD');
    return vcfContent.toString();
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) return true;

      final photos = await Permission.photos.request();
      final videos = await Permission.videos.request();
      if (photos.isGranted || videos.isGranted) return true;

      final storage = await Permission.storage.request();
      return storage.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return false;
  }

  Future<void> saveVcfFile(String vcfContent, String contactName) async {
    bool hasPermission = await requestStoragePermission();
    if (hasPermission) {
      try {
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          String fileName =
              '${(contactName.isNotEmpty ? contactName : "Contact").replaceAll(' ', '_')}.vcf';
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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Storage permission denied. Please enable in settings.',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withOpacity(0.09)
                : Colors.black.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAvatar(Contact contact) {
    String initials = '?';
    final name = contact.displayName ?? '';
    if (name.isNotEmpty) {
      initials = name[0].toUpperCase();
    }
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child:
          contact.avatar != null && contact.avatar!.isNotEmpty
              ? ClipOval(
                child: Image.memory(
                  contact.avatar!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
              : Center(
                child: Text(
                  initials,
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
                if (Theme.of(context).brightness == Brightness.light)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                if (Theme.of(context).brightness == Brightness.dark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
    if ((currentContact.company ?? '').isNotEmpty) {
      subtitleText = currentContact.company;
    } else if ((currentContact.phones?.isNotEmpty ?? false)) {
      subtitleText = currentContact.phones!.first.value ?? '';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
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
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditContactScreen(contact: currentContact),
                ),
              ).then(
                (_) => {
                  _loadContactDetails(currentContact.identifier ?? ''),
                  _loadCounts(),
                },
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
                    '${currentContact.displayName ?? 'Contact'} favorite status toggled!',
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
                    currentContact.displayName ?? 'No name',
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
                        final phone =
                            (currentContact.phones?.isNotEmpty ?? false)
                                ? currentContact.phones!.first.value
                                : null;
                        _makePhoneCall(phone);
                      }),
                      const SizedBox(width: 16),
                      _buildActionButton(Icons.message, 'Message', () {
                        final phone =
                            (currentContact.phones?.isNotEmpty ?? false)
                                ? currentContact.phones!.first.value
                                : null;
                        _sendSms(phone);
                      }),
                      const SizedBox(width: 16),
                      _buildActionButton(Icons.email, 'Email', () {
                        final email =
                            (currentContact.emails?.isNotEmpty ?? false)
                                ? currentContact.emails!.first.value
                                : null;
                        _sendEmail(email);
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // Contact Details Section
            if ((currentContact.phones?.isNotEmpty ?? false) ||
                (currentContact.emails?.isNotEmpty ?? false) ||
                (currentContact.postalAddresses?.isNotEmpty ?? false) ||
                ((currentContact.company ?? '').isNotEmpty))
              Container(
                margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (Theme.of(context).brightness == Brightness.light)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    if (Theme.of(context).brightness == Brightness.dark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
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
                    if ((currentContact.phones?.isNotEmpty ?? false))
                      ...currentContact.phones!.map(
                        (phone) => _buildDetailItem(
                          _getPhoneLabelString(
                            PhoneLabelX.fromString(phone.label),
                          ),
                          phone.value ?? '',
                        ),
                      ),
                    if ((currentContact.emails?.isNotEmpty ?? false))
                      ...currentContact.emails!.map(
                        (email) => _buildDetailItem(
                          _getEmailLabelString(
                            EmailLabelX.fromString(email.label),
                          ),
                          email.value ?? '',
                        ),
                      ),
                    if ((currentContact.postalAddresses?.isNotEmpty ?? false))
                      ...currentContact.postalAddresses!.map(
                        (address) => _buildDetailItem(
                          _getAddressLabelString(
                            AddressLabelX.fromString(address.label),
                          ),
                          '${address.street ?? ''}, ${address.city ?? ''}, ${address.postcode ?? ''}',
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
                  if (Theme.of(context).brightness == Brightness.light)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  if (Theme.of(context).brightness == Brightness.dark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
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
                        _detailedContact!.displayName ?? 'Contact',
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
