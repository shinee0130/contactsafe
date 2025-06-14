import 'package:contactsafe/utils/color_extensions.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
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

  ContactFile({
    required this.id,
    required this.name,
    required this.size,
    required this.downloadUrl,
    required this.uploadDate,
    required this.storagePath,
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
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'size': size,
      'downloadUrl': downloadUrl,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'storagePath': storagePath,
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
  }) {
    return ContactFile(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      uploadDate: uploadDate ?? this.uploadDate,
      storagePath: storagePath ?? this.storagePath,
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
    debugPrint('Loading files for contact ID: ${widget.contact.id}');
    _loadFiles();
  }

  CollectionReference<ContactFile> _contactFilesCollection() {
    // Ensure widget.contact.id is not null or empty
    if (widget.contact.id == null || widget.contact.id.isEmpty) {
      throw Exception(
        "Contact ID is null or empty, cannot access Firestore collection.",
      );
    }
    return _firestore
        .collection('contact_files_metadata')
        .doc(widget.contact.id)
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
      setState(() {
        _files = querySnapshot.docs.map((doc) => doc.data()).toList();
        _sortFiles();
      });
    } catch (e) {
      debugPrint('Error loading files: $e');
      _showSnackBar('Failed to load files: ${e.toString()}'); // Show full error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _isLoading = true; // Start loading for the entire upload process
      });

      int successfulUploads = 0;
      int failedUploads = 0;

      // START OF THE MISSING 'TRY' BLOCK
      try {
        for (PlatformFile platformFile in result.files) {
          if (platformFile.bytes == null) {
            _showSnackBar(
              'Skipping ${platformFile.name}: File bytes not available. Try another file type or read method.',
            );
            failedUploads++;
            continue;
          }

          try {
            final fileName = platformFile.name;
            final storagePath = 'contact_files/${widget.contact.id}/$fileName';
            final ref = _storage.ref().child(storagePath);

            // 1. Upload file to Firebase Storage
            debugPrint('Attempting to upload ${fileName} to Storage...');
            await ref.putData(platformFile.bytes!);
            final downloadUrl = await ref.getDownloadURL();
            debugPrint(
              'Successfully uploaded ${fileName} to Storage. Download URL: $downloadUrl',
            );

            // 2. Save metadata to Firestore
            debugPrint(
              'Attempting to save metadata for ${fileName} to Firestore...',
            );
            final newFile = ContactFile(
              id: '', // Will be set by Firestore after doc.add
              name: fileName,
              size: platformFile.size,
              downloadUrl: downloadUrl,
              uploadDate: DateTime.now(),
              storagePath: storagePath,
            );

            // Add document to Firestore and get its ID
            final docRef = await _contactFilesCollection().add(newFile);
            debugPrint(
              'Successfully saved metadata for ${fileName} to Firestore. Doc ID: ${docRef.id}',
            );

            // 3. Update local state ONLY AFTER BOTH OPERATIONS SUCCEED
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
            // Important: If a file fails, we don't want it in the local list
          }
        } // End of for loop

        // Final summary message
        String summaryMessage = '';
        if (successfulUploads > 0) {
          summaryMessage += '$successfulUploads file(s) uploaded successfully.';
        }
        if (failedUploads > 0) {
          if (summaryMessage.isNotEmpty) {
            summaryMessage += '\n';
          }
          summaryMessage += '$failedUploads file(s) failed to upload.';
        }
        if (summaryMessage.isEmpty) {
          summaryMessage = 'No files selected or processed.';
        }
        _showSnackBar(summaryMessage);

        // Reload files after all attempts, to ensure consistency
        _loadFiles(); // Re-fetch the true state from Firestore
      } catch (e) {
        // <--- Corresponding catch block for the outer try
        debugPrint('Overall error during file picking or processing: $e');
        _showSnackBar(
          'An overall error occurred during file picking or processing: ${e.toString()}',
        );
      } finally {
        // <--- This 'finally' now has a 'try' block
        setState(() {
          _isLoading = false; // End loading regardless of success/failure
        });
      }
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
      setState(() {
        _files.removeWhere((f) => f.id == file.id);
      });
      _showSnackBar('File deleted');
    } catch (e) {
      _showSnackBar('Failed to delete file: ${e.toString()}');
    } finally {
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
      await SharePlus.instance
          .share(files: [XFile(tempFile.path)], text: file.name);
    } catch (e) {
      _showSnackBar('Failed to share file: ${e.toString()}');
    }
  }

  Future<void> _openFile(ContactFile file) async {
    final uri = Uri.parse(file.downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not open file');
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
                          ? const Icon(Icons.check, color: Colors.blue)
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
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
        return Colors.blue;
      case 'png':
        return Colors.blue;
      case 'doc':
      case 'docx':
        return Colors.blue.shade800;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'txt':
        return Colors.grey;
      default:
        return Colors.blue;
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert, size: 30, color: Colors.blue),
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
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.add, size: 30, color: Colors.blue),
            onPressed: _isLoading ? null : _pickAndUploadFiles,
          ),
        ],
      ),
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
                    color: isSelected ? Colors.blue[50] : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getFileIconColor(
                            file.name.split('.').last,
                          ).withValues(alpha: (0.2 * 255).round()),
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
                                activeColor: Colors.blue,
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
