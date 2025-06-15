import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'note_detail_screen.dart';

class ContactNotesScreen extends StatefulWidget {
  final Contact contact;

  const ContactNotesScreen({super.key, required this.contact});

  @override
  State<ContactNotesScreen> createState() => _ContactNotesScreenState();
}

class _ContactNotesScreenState extends State<ContactNotesScreen> {
  List<ContactNote> _notes = [];
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();
  int _editingIndex = -1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<ContactNote> _contactNotesCollection() {
    return _firestore
        .collection('contact_notes')
        .doc(widget.contact.id)
        .collection('notes')
        .withConverter<ContactNote>(
          fromFirestore: (snapshot, _) => ContactNote.fromFirestore(snapshot),
          toFirestore: (note, _) => note.toFirestore(),
        );
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      final query = await _contactNotesCollection().get();
      setState(() {
        _notes = query.docs.map((d) => d.data()).toList();
      });
    } catch (e) {
      _showSnackBar('Failed to load notes: ${e.toString()}');
    }
  }

  Future<void> _addOrUpdateNote() async {
    if (_noteController.text.trim().isEmpty) {
      return;
    }

    if (_editingIndex >= 0) {
      final note = _notes[_editingIndex].copyWith(
        content: _noteController.text,
        updatedAt: DateTime.now(),
      );
      try {
        await _contactNotesCollection().doc(note.id).update(note.toFirestore());
        setState(() {
          _notes[_editingIndex] = note;
          _editingIndex = -1;
        });
      } catch (e) {
        _showSnackBar('Failed to update note: ${e.toString()}');
      }
    } else {
      final newNote = ContactNote(
        id: '',
        content: _noteController.text,
        createdAt: DateTime.now(),
      );
      try {
        final doc = await _contactNotesCollection().add(newNote);
        setState(() {
          _notes.insert(0, newNote.copyWith(id: doc.id));
        });
      } catch (e) {
        _showSnackBar('Failed to add note: ${e.toString()}');
      }
    }
    _noteController.clear();
    _noteFocusNode.unfocus();
  }

  Future<void> _viewNote(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: _notes[index])),
    );
    if (result == 'delete') {
      _deleteNote(index);
    } else if (result is String) {
      // Edited content returned
      setState(() {
        _editingIndex = index;
        _noteController.text = result;
      });
      _showNoteDialog();
    }
  }

  Future<void> _deleteNote(int index) async {
    try {
      await _contactNotesCollection().doc(_notes[index].id).delete();
      setState(() {
        _notes.removeAt(index);
        if (_editingIndex == index) {
          _editingIndex = -1;
          _noteController.clear();
          _noteFocusNode.unfocus();
        }
      });
    } catch (e) {
      _showSnackBar('Failed to delete note: ${e.toString()}');
    }
  }

  void _showNoteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editingIndex >= 0 ? 'Edit Note' : 'Add New Note',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    focusNode: _noteFocusNode,
                    maxLines: 8,
                    minLines: 3,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Write your note here...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await _addOrUpdateNote();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
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
    return Scaffold(
      appBar: AppBar(
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 30, color: Colors.blue),
            onPressed: () {
              _noteController.clear();
              _editingIndex = -1;
              _showNoteDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${widget.contact.displayName} - Notes',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child:
                _notes.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_add,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No notes yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first note',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return _buildNoteCard(note, index);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(ContactNote note, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _viewNote(index),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.content, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, y • h:mm a').format(note.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (note.updatedAt != null)
                    Text(
                      'Edited',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              if (_editingIndex == index)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNote(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class ContactNote {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ContactNote({
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory ContactNote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContactNote(
      id: doc.id,
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  ContactNote copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactNote(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
