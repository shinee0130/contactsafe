import 'package:flutter/material.dart';

import 'contact_notes_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final ContactNote note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => Navigator.pop(context, 'delete'),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pop(context, note.content),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          note.content,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
