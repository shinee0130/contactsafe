import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class ContactFilesScreen extends StatefulWidget {
  final Contact contact;

  const ContactFilesScreen({super.key, required this.contact});

  @override
  State<ContactFilesScreen> createState() => _ContactFilesScreenState();
}

class _ContactFilesScreenState extends State<ContactFilesScreen> {
  List<PlatformFile> _files = [];
  bool _editMode = false;
  List<int> _selectedIndices = [];
  FileSortOption _sortOption = FileSortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    // Load dummy data for demonstration
    _loadDummyFiles();
  }

  void _loadDummyFiles() {
    // In a real app, you would load files from storage
    setState(() {
      _files = [
        PlatformFile(
          name: "Contract.pdf",
          size: 2400000,
          path: null,
          bytes: null,
        ),
        PlatformFile(
          name: "Profile.jpg",
          size: 1200000,
          path: null,
          bytes: null,
        ),
        PlatformFile(
          name: "Meeting Notes.docx",
          size: 350000,
          path: null,
          bytes: null,
        ),
      ];
    });
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'txt',
      ],
    );

    if (result != null) {
      setState(() {
        _files.addAll(result.files);
        _sortFiles();
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
      if (!_editMode) _selectedIndices.clear();
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _deleteSelected() {
    setState(() {
      _selectedIndices.sort((a, b) => b.compareTo(a));
      for (var index in _selectedIndices) {
        _files.removeAt(index);
      }
      _selectedIndices.clear();
      _editMode = false;
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
          // Using modification date for sorting
          break;
        case FileSortOption.dateDesc:
          // Using modification date for sorting
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
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
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
          _editMode
              ? TextButton(
                onPressed: _deleteSelected,
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : TextButton(
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
            onPressed: _pickFiles,
          ),
        ],
      ),
      body:
          _files.isEmpty
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
                    Text(
                      'Tap the + button to add files',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  final isSelected = _selectedIndices.contains(index);

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
                            file.extension,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getFileIcon(file.extension),
                          color: _getFileIconColor(file.extension),
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
                        '${_formatFileSize(file.size)} • ${DateFormat('MMM d, y').format(DateTime.now())}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing:
                          _editMode
                              ? Checkbox(
                                value: isSelected,
                                onChanged: (value) => _toggleSelection(index),
                                activeColor: Colors.blue,
                              )
                              : IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  // Show file options menu
                                },
                              ),
                      onTap: () {
                        if (_editMode) {
                          _toggleSelection(index);
                        } else {
                          // Open file preview
                        }
                      },
                      onLongPress: () {
                        if (!_editMode) {
                          setState(() {
                            _editMode = true;
                            _selectedIndices.add(index);
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
