import 'dart:convert';
import 'dart:io';
import 'package:contactsafe/presentation/screens/contacts_screen/edit_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../common/theme/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _loadContactDetails(widget.contact.id);
  }

  Future<void> _loadContactDetails(String contactId) async {
    try {
      if (await FlutterContacts.requestPermission()) {
        Contact? fetchedContact = await FlutterContacts.getContact(
          contactId,
          withAccounts: true,
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
      print('Error loading contact details with accounts: $e');
      setState(() {
        _detailedContact = widget.contact;
      });
    }
  }

  String generateVcf(Contact contact) {
    StringBuffer vcfContent = StringBuffer();

    vcfContent.writeln('BEGIN:VCARD');
    vcfContent.writeln('VERSION:3.0');

    String formattedName = '';
    if (contact.name?.prefix != null && contact.name!.prefix!.isNotEmpty) {
      formattedName += '${contact.name!.prefix} ';
    }
    if (contact.name?.first != null && contact.name!.first!.isNotEmpty) {
      formattedName += '${contact.name!.first} ';
    }
    if (contact.name?.middle != null && contact.name!.middle!.isNotEmpty) {
      formattedName += '${contact.name!.middle} ';
    }
    if (contact.name?.last != null && contact.name!.last!.isNotEmpty) {
      formattedName += contact.name!.last!;
    }
    formattedName = formattedName.trim();

    if (formattedName.isNotEmpty) {
      vcfContent.writeln('FN:$formattedName');
    }

    if (contact.name?.last != null ||
        contact.name?.first != null ||
        contact.name?.middle != null ||
        contact.name?.prefix != null ||
        contact.name?.suffix != null) {
      vcfContent.writeln(
        'N:${contact.name?.last ?? ''};${contact.name?.first ?? ''};${contact.name?.middle ?? ''};${contact.name?.prefix ?? ''};${contact.name?.suffix ?? ''}',
      );
    }

    for (var phone in contact.phones) {
      String typeLabel = '';
      switch (phone) {}
      vcfContent.writeln('TEL;TYPE=$typeLabel:${phone.number}');
    }

    for (var email in contact.emails) {
      String typeLabel = '';
      switch (email) {}
      vcfContent.writeln('EMAIL;TYPE=$typeLabel:${email.address}');
    }

    for (var address in contact.addresses) {
      String typeLabel = '';
      switch (address) {}
      vcfContent.writeln(
        'ADR;TYPE=$typeLabel:;;${address.street ?? ''};${address.city ?? ''};${address ?? ''};${address.postalCode ?? ''};${address.country ?? ''}',
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
          print('VCF file saved to: ${file.path}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('VCF file saved to: ${file.path}')),
          );
        } else {
          print('Error: Could not access storage directory.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error accessing storage.')),
          );
        }
      } catch (e) {
        print('Error saving VCF file: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving VCF file: $e')));
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied.')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Storage permission permanently denied. Please enable in settings.',
          ),
          action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
        ),
      );
    }
  }

  Widget _buildAvatar(Contact contact) {
    if (contact.photo != null && contact.photo!.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: MemoryImage(contact.photo!),
      );
    } else {
      return const Icon(
        Icons.person_outline,
        size: 100,
        color: Colors.blueGrey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentContact = _detailedContact ?? widget.contact;

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
            onPressed: () {
              Navigator.pushNamed(context, '/groups');
            },
            child: const Text(
              'Group',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditContactScreen(contact: currentContact),
                ),
              );
            },
            child: const Text(
              'Edit',
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
              'Contact Details',
              style: TextStyle(fontSize: 31.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Center(child: _buildAvatar(currentContact)),
            const SizedBox(height: 16),
            Center(
              child: Text(
                currentContact.displayName,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            if (currentContact.phones.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mobile',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      currentContact.phones.first.number,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            ListTile(
              title: const Text('Files'),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('0', style: TextStyle(fontSize: 20)),
                  Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/contact_files',
                  arguments: currentContact,
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Notes'),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('0', style: TextStyle(fontSize: 20)),
                  Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/contact_notes',
                  arguments: currentContact,
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Create VCF'),
              onTap: () async {
                if (_detailedContact != null) {
                  String vcfContent = generateVcf(_detailedContact!);
                  await saveVcfFile(vcfContent, _detailedContact!.displayName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact details are still loading.'),
                    ),
                  );
                }
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
