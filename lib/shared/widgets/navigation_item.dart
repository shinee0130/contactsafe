import 'package:flutter/material.dart';

class NavigationItem {
  /// Localization key for this navigation label
  final String label;
  final String iconName; // icon-г нэрээр хадгална
  final String routeName;
  final int initialIndex;

  const NavigationItem({
    required this.label,
    required this.iconName,
    required this.routeName,
    required this.initialIndex,
  });

  // JSON руу хөрвүүлэх
  Map<String, dynamic> toJson() => {
    'label': label,
    'iconName': iconName,
    'routeName': routeName,
    'initialIndex': initialIndex,
  };

  // JSON-оос бүтээх
  factory NavigationItem.fromJson(Map<String, dynamic> json) => NavigationItem(
    label: json['label'],
    iconName: json['iconName'],
    routeName: json['routeName'],
    initialIndex: json['initialIndex'],
  );

  // Compile-time icon map
  static const Map<String, IconData> iconMap = {
    'person': Icons.person,
    'search': Icons.search,
    'event': Icons.event,
    'photo_library': Icons.photo_library,
    'settings': Icons.settings,
  };

  // Actual IconData-г авах
  IconData get icon => iconMap[iconName] ?? Icons.help_outline;

  // Default items
  static List<NavigationItem> defaultItems() {
    return const [
      NavigationItem(
        label: 'contacts',
        iconName: 'person',
        routeName: '/contacts',
        initialIndex: 0,
      ),
      NavigationItem(
        label: 'search',
        iconName: 'search',
        routeName: '/search',
        initialIndex: 1,
      ),
      NavigationItem(
        label: 'events',
        iconName: 'event',
        routeName: '/events',
        initialIndex: 2,
      ),
      NavigationItem(
        label: 'photos',
        iconName: 'photo_library',
        routeName: '/photos',
        initialIndex: 3,
      ),
      NavigationItem(
        label: 'settings',
        iconName: 'settings',
        routeName: '/settings',
        initialIndex: 4,
      ),
    ];
  }
}
