import 'package:contactsafe/l10n/app_localizations.dart';
import 'package:contactsafe/shared/widgets/navigation_item.dart';
import 'package:flutter/material.dart';

class SelectTabBarOrderScreen extends StatefulWidget {
  final List<NavigationItem> currentOrder;

  const SelectTabBarOrderScreen({super.key, required this.currentOrder});

  @override
  State<SelectTabBarOrderScreen> createState() =>
      _SelectTabBarOrderScreenState();
}

class _SelectTabBarOrderScreenState extends State<SelectTabBarOrderScreen> {
  late List<NavigationItem> _reorderableItems;

  @override
  void initState() {
    super.initState();
    _reorderableItems = List.from(widget.currentOrder); // Create a mutable copy
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final NavigationItem item = _reorderableItems.removeAt(oldIndex);
      _reorderableItems.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.select_tabbar_order_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Return the new order to the previous screen
              Navigator.pop(context, _reorderableItems);
            },
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: _reorderableItems.length,
        itemBuilder: (context, index) {
          final item = _reorderableItems[index];
          return Card(
            key: ValueKey(item.routeName), // Unique key for reordering
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(item.icon),
              title: Text(context.loc.item.label),
              trailing: const Icon(Icons.drag_handle), // Drag handle icon
            ),
          );
        },
        onReorder: _onReorder,
      ),
    );
  }
}
