import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Custom Model for Contact File Metadata (NO CHANGES HERE) ---
class ContactFile {
  final String id;
  final String name;
  final int size;
  final String downloadUrl;
  final DateTime uploadDate;
  final String storagePath;
  final String uid;
  final String contactId;

  ContactFile({
    required this.id,
    required this.name,
    required this.size,
    required this.downloadUrl,
    required this.uploadDate,
    required this.storagePath,
    required this.uid,
    required this.contactId,
  });

  factory ContactFile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ContactFile(
      id: doc.id,
      name: data['name'] ?? 'Unknown File',
      size: data['size'] ?? 0,
      downloadUrl: data['downloadUrl'] ?? '',
      uploadDate: (data['uploadDate'] as Timestamp).toDate(),
      storagePath: data['storagePath'] ?? '',
      uid: data['uid'] ?? '',
      contactId: data['contactId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'size': size,
      'downloadUrl': downloadUrl,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'storagePath': storagePath,
      'uid': uid,
      'contactId': contactId,
    };
  }
}

// Add copyWith to ContactFile for easy ID update after Firestore add (NO CHANGES HERE)
extension ContactFileExtension on ContactFile {
  ContactFile copyWith({
    String? id,
    String? name,
    int? size,
    String? downloadUrl,
    DateTime? uploadDate,
    String? storagePath,
    String? uid,
    String? contactId,
  }) {
    return ContactFile(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      uploadDate: uploadDate ?? this.uploadDate,
      storagePath: storagePath ?? this.storagePath,
      uid: uid ?? this.uid,
      contactId: contactId ?? this.contactId,
    );
  }
}
// ----------------------------------------------

class ContactFilesScreen extends StatefulWidget {
  final Contact contact;

  const ContactFilesScreen({super.key, required this.contact});

  @override
  State<ContactFilesScreen> createState() => _ContactFilesScreenState();
}

class _ContactFilesScreenState extends State<ContactFilesScreen> {
  List<ContactFile> _files = [];
  bool _editMode = false;
  List<String> _selectedFileIds = [];
  FileSortOption _sortOption = FileSortOption.dateDesc;
  bool _isLoading = false;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Log the contact ID to ensure it's valid
    debugPrint('Loading files for contact ID: ${widget.contact.identifier}');
    _loadFiles();
  }

  CollectionReference<ContactFile> _contactFilesCollection() {
    final contactId = widget.contact.identifier ?? '';
    if (contactId.isEmpty) {
      throw Exception(
        "Contact ID is empty, cannot access Firestore collection.",
      );
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _firestore
        .collection('user_files')
        .doc(uid)
        .collection('contacts')
        .doc(contactId)
        .collection('files')
        .withConverter<ContactFile>(
          fromFirestore: (snapshot, _) => ContactFile.fromFirestore(snapshot),
          toFirestore: (file, _) => file.toFirestore(),
        );
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final querySnapshot = await _contactFilesCollection().get();
      if (!mounted) return;
      setState(() {
        _files = querySnapshot.docs.map((doc) => doc.data()).toList();
        _sortFiles();
      });
    } catch (e) {
      debugPrint('Error loading files: $e');
      _showSnackBar('Failed to load files: ${e.toString()}'); // Show full error
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }
      var status = await Permission.manageExternalStorage.request();
      // Зарим төхөөрөмж дээр тусгай тохиргоогоор өгөх шаардлагатай
      if (status.isPermanentlyDenied) {
        // Settings рүү автоматаар оруулах код дээрээ байгаа
        return false;
      }
      return status.isGranted;
    } else if (Platform.isIOS) {
      // Зураг/файл авах бол photos permission шаардлагатай
      var status = await Permission.photos.request();
      return status.isGranted;
    }
    return false;
  }

  Future<void> _pickAndUploadFiles() async {
    // Permission шалгах
    if (!await _requestStoragePermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Storage permission denied. Please enable in settings.',
          ),
          action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
        ),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true, // Заавал!
      type: FileType.any,
    );

    if (result == null) return; // No file picked

    setState(() {
      _isLoading = true;
    });

    int successfulUploads = 0;
    int failedUploads = 0;

    try {
      for (PlatformFile platformFile in result.files) {
        Uint8List? fileBytes;
        if (platformFile.bytes != null) {
          fileBytes = platformFile.bytes;
        } else if (platformFile.path != null) {
          fileBytes = await File(platformFile.path!).readAsBytes();
        } else {
          _showSnackBar('Cannot read file: ${platformFile.name}');
          continue;
        }

        try {
          final fileName = platformFile.name;
          final uid = FirebaseAuth.instance.currentUser!.uid;
          final storagePath =
              'user_files/$uid/${widget.contact.identifier}/$fileName';
          final ref = _storage.ref().child(storagePath);

          // 1. Upload file to Firebase Storage
          await ref.putData(fileBytes!);
          final downloadUrl = await ref.getDownloadURL();

          // 2. Save metadata to Firestore
          final newFile = ContactFile(
            id: '', // Will be set by Firestore after doc.add
            name: fileName,
            size: platformFile.size,
            downloadUrl: downloadUrl,
            uploadDate: DateTime.now(),
            storagePath: storagePath,
            uid: uid,
            contactId: widget.contact.identifier ?? '',
          );

          // Add document to Firestore and get its ID
          final docRef = await _contactFilesCollection().add(newFile);

          // 3. Update local state
          setState(() {
            _files.add(newFile.copyWith(id: docRef.id));
            _sortFiles();
          });
          successfulUploads++;
        } catch (e) {
          debugPrint(
            'Error uploading or saving metadata for ${platformFile.name}: $e',
          );
          _showSnackBar(
            'Failed to upload ${platformFile.name}: ${e.toString()}',
          );
          failedUploads++;
        }
      }
      // Summary message
      String summaryMessage = '';
      if (successfulUploads > 0) {
        summaryMessage += '$successfulUploads file(s) uploaded successfully.';
      }
      if (failedUploads > 0) {
        if (summaryMessage.isNotEmpty) summaryMessage += '\n';
        summaryMessage += '$failedUploads file(s) failed to upload.';
      }
      if (summaryMessage.isEmpty)
        summaryMessage = 'No files selected or processed.';
      _showSnackBar(summaryMessage);

      // Reload files after all attempts, to ensure consistency
      _loadFiles(); // Re-fetch the true state from Firestore
    } catch (e) {
      debugPrint('Overall error during file picking or processing: $e');
      _showSnackBar(
        'An error occurred during file picking or processing: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSelectedFiles() async {
    if (_selectedFileIds.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final deleteFutures =
          _selectedFileIds.map((fileId) async {
            final fileToDelete = _files.firstWhere(
              (file) => file.id == fileId,
              orElse:
                  () =>
                      throw Exception(
                        'File not found locally for ID: $fileId',
                      ), // More robust error
            );
            debugPrint(
              'Attempting to delete ${fileToDelete.name} from Storage and Firestore...',
            );
            // Delete from Firebase Storage
            await _storage.ref().child(fileToDelete.storagePath).delete();
            // Delete metadata from Firestore
            await _contactFilesCollection().doc(fileId).delete();
            debugPrint('Successfully deleted ${fileToDelete.name}.');
          }).toList();

      await Future.wait(deleteFutures);

      if (!mounted) return;
      setState(() {
        _files.removeWhere((file) => _selectedFileIds.contains(file.id));
        _selectedFileIds.clear();
        _editMode = false;
      });
      _showSnackBar('Selected files deleted successfully!');
    } catch (e) {
      debugPrint('Error deleting files: $e');
      _showSnackBar('Failed to delete selected files: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFile(ContactFile file) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _storage.ref().child(file.storagePath).delete();
      await _contactFilesCollection().doc(file.id).delete();
      if (!mounted) return;
      setState(() {
        _files.removeWhere((f) => f.id == file.id);
      });
      _showSnackBar('File deleted');
    } catch (e) {
      _showSnackBar('Failed to delete file: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _renameFile(ContactFile file) async {
    final controller = TextEditingController(text: file.name);
    final newName = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Rename File'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Enter new name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (newName != null && newName.isNotEmpty && newName != file.name) {
      try {
        await _contactFilesCollection().doc(file.id).update({'name': newName});
        if (!mounted) return;
        setState(() {
          final index = _files.indexWhere((f) => f.id == file.id);
          if (index != -1) {
            _files[index] = _files[index].copyWith(name: newName);
            _sortFiles();
          }
        });
      } catch (e) {
        _showSnackBar('Failed to rename file: ${e.toString()}');
      }
    }
  }

  Future<void> _shareFile(ContactFile file) async {
    try {
      final data = await _storage.ref().child(file.storagePath).getData();
      if (data == null) {
        _showSnackBar('Unable to retrieve file data');
        return;
      }
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${file.name}');
      await tempFile.writeAsBytes(data);
      await Share.shareXFiles([XFile(tempFile.path)], text: file.name);
    } catch (e) {
      _showSnackBar('Failed to share file: ${e.toString()}');
    }
  }

  Future<void> _openFile(ContactFile file) async {
    try {
      // 1. Файл татаж авах
      final data = await _storage.ref().child(file.storagePath).getData();
      if (data == null) {
        _showSnackBar('Could not download file data');
        return;
      }

      // 2. Түр хадгалах
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${file.name}');
      await tempFile.writeAsBytes(data);

      // 3. File type шалгаж зураг бол харуулах, бусад бол нээх
      if ([
        "jpg",
        "jpeg",
        "png",
        "gif",
      ].any((ext) => file.name.toLowerCase().endsWith(ext))) {
        // App дотор preview dialog-оор харуулах (таны photos screen шиг)
        showDialog(
          context: context,
          builder:
              (_) => Dialog(
                backgroundColor: Colors.black,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: InteractiveViewer(child: Image.file(tempFile)),
                ),
              ),
        );
      } else {
        // Бусад файл (pdf, doc гэх мэт) -> open with external app
        final uri = Uri.file(tempFile.path);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar('Could not open file');
        }
      }
    } catch (e) {
      _showSnackBar('Failed to open file: $e');
    }
  }

  void _showFileOptions(ContactFile file) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.drive_file_rename_outline),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(context);
                  _renameFile(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  _shareFile(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteFile(file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- UI and Helper Functions (mostly retained, minor tweaks) ---

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
      if (!_editMode) {
        _selectedFileIds.clear();
      }
    });
  }

  void _toggleSelection(String fileId) {
    setState(() {
      if (_selectedFileIds.contains(fileId)) {
        _selectedFileIds.remove(fileId);
      } else {
        _selectedFileIds.add(fileId);
      }
    });
  }

  void _sortFiles() {
    setState(() {
      switch (_sortOption) {
        case FileSortOption.nameAsc:
          _files.sort((a, b) => a.name.compareTo(b.name));
          break;
        case FileSortOption.nameDesc:
          _files.sort((a, b) => b.name.compareTo(a.name));
          break;
        case FileSortOption.dateAsc:
          _files.sort((a, b) => a.uploadDate.compareTo(b.uploadDate));
          break;
        case FileSortOption.dateDesc:
          _files.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
          break;
        case FileSortOption.sizeAsc:
          _files.sort((a, b) => a.size.compareTo(b.size));
          break;
        case FileSortOption.sizeDesc:
          _files.sort((a, b) => b.size.compareTo(a.size));
          break;
      }
    });
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort Files By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...FileSortOption.values.map(
                (option) => ListTile(
                  title: Text(_getSortOptionName(option)),
                  trailing:
                      _sortOption == option
                          ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                          : null,
                  onTap: () {
                    setState(() {
                      _sortOption = option;
                      _sortFiles();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSortOptionName(FileSortOption option) {
    switch (option) {
      case FileSortOption.nameAsc:
        return 'Name (A-Z)';
      case FileSortOption.nameDesc:
        return 'Name (Z-A)';
      case FileSortOption.dateAsc:
        return 'Date (Oldest first)';
      case FileSortOption.dateDesc:
        return 'Date (Newest first)';
      case FileSortOption.sizeAsc:
        return 'Size (Smallest first)';
      case FileSortOption.sizeDesc:
        return 'Size (Largest first)';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1048576) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_fields;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(String? extension) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return colorScheme.error;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return colorScheme.primary;
      case 'doc':
      case 'docx':
        return colorScheme.primary;
      case 'xls':
      case 'xlsx':
        return colorScheme.secondary;
      case 'txt':
        return colorScheme.outline;
      default:
        return colorScheme.primary;
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'contactSafe',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.swap_vert,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _showSortDialog,
          ),
          if (_editMode)
            TextButton(
              onPressed:
                  _selectedFileIds.isNotEmpty ? _deleteSelectedFiles : null,
              child: Text(
                'Delete (${_selectedFileIds.length})',
                style: TextStyle(
                  color: _selectedFileIds.isNotEmpty ? Colors.red : Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _toggleEditMode,
              child: Text(
                'Edit',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.add,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _isLoading ? null : _pickAndUploadFiles,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _files.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'No files available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the + button to add files',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  final isSelected = _selectedFileIds.contains(file.id);

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    color:
                        isSelected
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1)
                            : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[300]!,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getFileIcon(file.name.split('.').last),
                          color: _getFileIconColor(file.name.split('.').last),
                          size: 28,
                        ),
                      ),
                      title: Text(
                        file.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${_formatFileSize(file.size)} • ${DateFormat('MMM d, y').format(file.uploadDate)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing:
                          _editMode
                              ? Checkbox(
                                value: isSelected,
                                onChanged: (value) => _toggleSelection(file.id),
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                              )
                              : IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.grey,
                                ),
                                onPressed: () => _showFileOptions(file),
                              ),
                      onTap: () {
                        if (_editMode) {
                          _toggleSelection(file.id);
                        } else {
                          _openFile(file);
                        }
                      },
                      onLongPress: () {
                        if (!_editMode) {
                          setState(() {
                            _editMode = true;
                            _selectedFileIds.add(file.id);
                          });
                        }
                      },
                    ),
                  );
                },
              ),
    );
  }
}

enum FileSortOption { nameAsc, nameDesc, dateAsc, dateDesc, sizeAsc, sizeDesc }
