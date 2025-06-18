import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';

class AppEvent {
  final String? id; // Firestore document ID
  final String title;
  final DateTime date;
  final String?
  location; // Stores either an address string or coordinates string
  final String? description;
  final List<String> participantContactIds; // Store only Contact IDs
  final String userId; // Owner of the event (unused for local storage)

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

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    return AppEvent(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'No Title',
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String?,
      description: json['description'] as String?,
      participantContactIds: List<String>.from(
        json['participantContactIds'] ?? const [],
      ),
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
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
            (contact) => contact.identifier == id,
            orElse: () {
              final c = Contact(givenName: 'Unknown Contact');
              c.identifier = id;
              return c;
            },
          ),
        )
        .toList();
  }
}
