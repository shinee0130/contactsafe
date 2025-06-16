import 'package:flutter/material.dart';
import 'contact_notes_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final ContactNote note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        title: Text(
          'Note', // i18n: noteDetailTitle
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
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
            icon: Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete note', // i18n: deleteNote
            onPressed: () => Navigator.pop(context, 'delete'),
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Edit note', // i18n: editNote
            onPressed: () => Navigator.pop(context, note.content),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              note.content,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ),
      ),
    );
  }
}
