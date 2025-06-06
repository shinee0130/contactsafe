import 'package:flutter/material.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final String routeName;
  final int initialIndex; // To map back to original indices for navigation

  NavigationItem({
    required this.label,
    required this.icon,
    required this.routeName,
    required this.initialIndex,
  });

  // Convert to JSON for saving
  Map<String, dynamic> toJson() => {
    'label': label,
    'iconCodePoint': icon.codePoint,
    'fontFamily': icon.fontFamily,
    'fontPackage': icon.fontPackage,
    'routeName': routeName,
    'initialIndex': initialIndex,
  };

  // Create from JSON for loading
  factory NavigationItem.fromJson(Map<String, dynamic> json) => NavigationItem(
    label: json['label'],
    icon: IconData(
      json['iconCodePoint'],
      fontFamily: json['fontFamily'],
      fontPackage: json['fontPackage'],
    ),
    routeName: json['routeName'],
    initialIndex: json['initialIndex'],
  );

  // Helper to get all default items (this list will be reordered)
  static List<NavigationItem> defaultItems() {
    return [
      NavigationItem(
        label: 'Contacts',
        icon: Icons.person,
        routeName: '/contacts',
        initialIndex: 0,
      ),
      NavigationItem(
        label: 'Search',
        icon: Icons.search,
        routeName: '/search',
        initialIndex: 1,
      ),
      NavigationItem(
        label: 'Events',
        icon: Icons.event,
        routeName: '/events',
        initialIndex: 2,
      ),
      NavigationItem(
        label: 'Photos',
        icon: Icons.photo_library,
        routeName: '/photos',
        initialIndex: 3,
      ),
      NavigationItem(
        label: 'Settings',
        icon: Icons.settings,
        routeName: '/settings',
        initialIndex: 4,
      ),
    ];
  }
}
