import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contactsafe/core/theme/app_colors.dart';
import 'package:contactsafe/shared/widgets/navigation_bar.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  int _currentIndex = 3;
  List<File> _photos = [];
  bool _isLoading = false;
  bool _editMode = false;
  List<int> _selectedIndices = [];
  SortOption _sortOption = SortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    // _loadPhotos();
  }

  // Future<void> _loadPhotos() async {
  //   setState(() => _isLoading = true);
  //   // TODO: Replace with actual photo loading logic from storage
  //   await Future.delayed(const Duration(seconds: 1)); // Simulate loading
  //   setState(() => _isLoading = false);
  // }

  Future<void> _uploadPhotos() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _photos.addAll(pickedFiles.map((file) => File(file.path)));
          _sortPhotos();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo library permission denied')),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
      if (!_editMode) _selectedIndices.clear();
    });
  }

  void _togglePhotoSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _deleteSelectedPhotos() {
    setState(() {
      _selectedIndices.sort((a, b) => b.compareTo(a));
      for (var index in _selectedIndices) {
        _photos.removeAt(index);
      }
      _selectedIndices.clear();
      _editMode = false;
    });
  }

  void _sortPhotos() {
    setState(() {
      switch (_sortOption) {
        case SortOption.nameAsc:
          _photos.sort(
            (a, b) => a.path.split('/').last.compareTo(b.path.split('/').last),
          );
          break;
        case SortOption.nameDesc:
          _photos.sort(
            (a, b) => b.path.split('/').last.compareTo(a.path.split('/').last),
          );
          break;
        case SortOption.dateAsc:
          _photos.sort(
            (a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()),
          );
          break;
        case SortOption.dateDesc:
          _photos.sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
          );
          break;
        case SortOption.sizeAsc:
          _photos.sort((a, b) => a.lengthSync().compareTo(b.lengthSync()));
          break;
        case SortOption.sizeDesc:
          _photos.sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));
          break;
      }
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sort Photos By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...SortOption.values.map(
                  (option) => ListTile(
                    title: Text(_getSortOptionName(option)),
                    trailing:
                        _sortOption == option
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                    onTap: () {
                      setState(() => _sortOption = option);
                      _sortPhotos();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String _getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.nameDesc:
        return 'Name (Z-A)';
      case SortOption.dateAsc:
        return 'Date (Oldest first)';
      case SortOption.dateDesc:
        return 'Date (Newest first)';
      case SortOption.sizeAsc:
        return 'Size (Smallest first)';
      case SortOption.sizeDesc:
        return 'Size (Largest first)';
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
        actions: [
          _editMode && _selectedIndices.isNotEmpty
              ? TextButton(
                onPressed: _deleteSelectedPhotos,
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : TextButton(
                onPressed: _toggleEditMode,
                child: Text(
                  _editMode ? 'Cancel' : 'Edit',
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
          IconButton(
            icon: Icon(
              _editMode ? Icons.done : Icons.swap_vert,
              color: AppColors.primary,
              size: 30,
            ),
            onPressed: _editMode ? _toggleEditMode : _showSortOptions,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadPhotos,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Photos',
              style: TextStyle(fontSize: 31.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _photos.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No photos yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap the + button to add photos',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (_editMode) {
                                _togglePhotoSelection(index);
                              } else {
                                // TODO: Implement photo viewer
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
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(_photos[index], fit: BoxFit.cover),
                                if (_editMode)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Checkbox(
                                      value: _selectedIndices.contains(index),
                                      onChanged:
                                          (value) =>
                                              _togglePhotoSelection(index),
                                      fillColor: MaterialStateProperty.all(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ContactSafeNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/contacts');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/events');
              break;
            case 3:
              // Already on photos screen
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}

enum SortOption { nameAsc, nameDesc, dateAsc, dateDesc, sizeAsc, sizeDesc }
