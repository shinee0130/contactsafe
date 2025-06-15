import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      Directory baseDir;
      if (Platform.isAndroid) {
        baseDir = (await getExternalStorageDirectory())!;
      } else {
        baseDir = await getApplicationDocumentsDirectory();
      }

      final photosDir = Directory('${baseDir.path}/photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
      final files = photosDir.listSync();
      _photos =
          files
              .whereType<File>()
              .where(
                (f) => imageExtensions.any(
                  (ext) => f.path.toLowerCase().endsWith(ext),
                ),
              )
              .toList();

      _sortPhotos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load photos: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
      if (!_editMode) {
        _selectedIndices.clear();
      }
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

  Future<void> _copySelectedPhotos() async {
    final dir = await getApplicationDocumentsDirectory();
    final copyDir = Directory('${dir.path}/photos_copied');
    if (!await copyDir.exists()) {
      await copyDir.create(recursive: true);
    }
    for (var index in _selectedIndices) {
      final file = _photos[index];
      await file.copy('${copyDir.path}/${file.path.split('/').last}');
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied ${_selectedIndices.length} photo(s)')),
      );
    }
  }

  Future<void> _cutSelectedPhotos() async {
    final dir = await getApplicationDocumentsDirectory();
    final cutDir = Directory('${dir.path}/photos_cut');
    if (!await cutDir.exists()) {
      await cutDir.create(recursive: true);
    }
    for (var index in _selectedIndices) {
      final file = _photos[index];
      final newPath = '${cutDir.path}/${file.path.split('/').last}';
      await file.rename(newPath);
      _photos[index] = File(newPath);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Moved ${_selectedIndices.length} photo(s)')),
      );
    }
    setState(() {});
  }

  Future<void> _shareSelectedPhotos() async {
    final files = _selectedIndices.map((i) => XFile(_photos[i].path)).toList();
    if (files.isNotEmpty) {
      await Share.shareXFiles(files);
    }
  }

  Future<void> _archiveSelectedPhotos() async {
    final dir = await getApplicationDocumentsDirectory();
    final archiveDir = Directory('${dir.path}/photos_archive');
    if (!await archiveDir.exists()) {
      await archiveDir.create(recursive: true);
    }
    for (var index in _selectedIndices) {
      final file = _photos[index];
      final newPath = '${archiveDir.path}/${file.path.split('/').last}';
      await file.rename(newPath);
      _photos[index] = File(newPath);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archived ${_selectedIndices.length} photo(s)')),
      );
    }
    setState(() {});
  }

  void _deleteSelectedPhotos() {
    _selectedIndices.sort((a, b) => b.compareTo(a));
    for (var index in _selectedIndices) {
      final file = _photos[index];
      if (file.existsSync()) {
        file.deleteSync();
      }
      _photos.removeAt(index);
    }
    setState(() {
      _selectedIndices.clear();
      _editMode = false;
    });
  }

  void _openPhotoViewer(File photo) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(child: Image.file(photo)),
            ),
          ),
    );
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
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sort Photos By',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ...SortOption.values.map(
                  (option) => ListTile(
                    title: Text(
                      _getSortOptionName(option),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing:
                        _sortOption == option
                            ? Icon(Icons.check, color: Colors.blue)
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'contactSafe',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 5.0),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
        actions: [
          _editMode && _selectedIndices.isNotEmpty
              ? TextButton(
                onPressed: _deleteSelectedPhotos,
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : TextButton(
                onPressed: _toggleEditMode,
                child: Text(
                  _editMode ? 'Cancel' : 'Edit',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
          IconButton(
            icon: Icon(
              _editMode ? Icons.done : Icons.swap_vert,
              color: Colors.blue,
              size: 30,
            ),
            onPressed: _editMode ? _toggleEditMode : _showSortOptions,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photos',
              style: TextStyle(
                fontSize: 31.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _photos.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No photos yet',
                              style: TextStyle(
                                fontSize: 18,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add image files to the app documents folder to view them',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
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
                                _openPhotoViewer(_photos[index]);
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
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
            if (_editMode && _selectedIndices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copySelectedPhotos,
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_cut),
                      onPressed: _cutSelectedPhotos,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _shareSelectedPhotos,
                    ),
                    IconButton(
                      icon: const Icon(Icons.archive),
                      onPressed: _archiveSelectedPhotos,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _deleteSelectedPhotos,
                    ),
                  ],
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
