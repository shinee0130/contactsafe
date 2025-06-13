import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/contact.dart';

class AppEvent {
  final String? id; // Firestore document ID
  final String title;
  final DateTime date;
  final String?
  location; // Stores either an address string or coordinates string
  final String? description;
  final List<String> participantContactIds; // Store only Contact IDs
  final String userId; // Owner of the event

  AppEvent({
    this.id,
    required this.title,
    required this.date,
    this.location,
    this.description,
    required this.participantContactIds,
    required this.userId,
  });

  // Factory constructor to create an AppEvent from a Firestore document
  factory AppEvent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return AppEvent(
      id: snapshot.id,
      title: data?['title'] ?? 'No Title', // Provide a default if null
      date: (data?['date'] as Timestamp).toDate(),
      location: data?['location'],
      description: data?['description'],
      participantContactIds: List<String>.from(
        data?['participantContactIds'] ?? [],
      ),
      userId: data?['userId'] ?? '',
    );
  }

  // Method to convert an AppEvent object to a Firestore-compatible Map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'location': location,
      'description': description,
      'participantContactIds': participantContactIds,
      'userId': userId,
    };
  }

  // Helper to map participant IDs to Contact objects
  // This will require the full list of all contacts fetched from the device
  List<Contact> getParticipants(List<Contact> allDeviceContacts) {
    return participantContactIds
        .map(
          (id) => allDeviceContacts.firstWhere(
            (contact) => contact.id == id,
            orElse:
                () =>
                    Contact(id: id, displayName: 'Unknown Contact'), // Fallback
          ),
        )
        .toList();
  }
}
