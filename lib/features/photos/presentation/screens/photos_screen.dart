import 'package:contactsafe/l10n/app_localizations.dart';
import 'package:contactsafe/l10n/context_loc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:contactsafe/shared/widgets/navigation_bar.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final List<String> _photoUrls = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var user = FirebaseAuth.instance.currentUser;
      user ??= (await FirebaseAuth.instance.signInAnonymously()).user;
      final uid = user!.uid;
      final ref = FirebaseStorage.instance.ref().child('user_files/$uid/');
      final urls = await _listImageUrls(ref);

      if (mounted) {
        setState(() {
          _photoUrls
            ..clear()
            ..addAll(urls);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load photos';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<String>> _listImageUrls(Reference ref) async {
    const imageExts = ['.jpg', '.jpeg', '.png', '.gif'];
    final result = await ref.listAll();
    final urls = <String>[];

    for (final item in result.items) {
      final name = item.name.toLowerCase();
      if (imageExts.any((e) => name.endsWith(e))) {
        urls.add(await item.getDownloadURL());
      }
    }

    for (final prefix in result.prefixes) {
      urls.addAll(await _listImageUrls(prefix));
    }

    return urls;
  }

  void _openPreview(String url) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(child: Image.network(url)),
            ),
          ),
    );
  }

  Widget _buildBody() {
    Widget child;
    if (_isLoading) {
      child = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      child = Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    } else if (_photoUrls.isEmpty) {
      child = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                context.loc.noPhotos,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      child = GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _photoUrls.length,
        itemBuilder: (context, index) {
          final url = _photoUrls[index];
          return GestureDetector(
            onTap: () => _openPreview(url),
            child: Image.network(url, fit: BoxFit.cover),
          );
        },
      );
    }

    return RefreshIndicator(onRefresh: _loadPhotos, child: child);
  }

  void _onNavTap(int index) {
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
            const SizedBox(width: 10),
            Text(
              context.loc.appTitle,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 5),
            Image.asset('assets/contactsafe_logo.png', height: 26),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.loc.photos,
              style: const TextStyle(
                fontSize: 31.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: ContactSafeNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
