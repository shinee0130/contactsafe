import 'package:flutter/material.dart';
import '../widgets/header_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBar(title: "Settings"),
      body: ListView(
        children: [
          ListTile(
            title: Text("Privacy"),
            subtitle: Text("Open in 'Settings' app"),
          ),
          Divider(),
          ListTile(title: Text("Version")),
          ListTile(title: Text("Imprint")),
          ListTile(title: Text("Privacy")),
          SwitchListTile(
            title: Text("Sort by first name"),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text("Last name first"),
            value: false,
            onChanged: (value) {},
          ),
          Divider(),
          ListTile(
            title: Text(
              "Import contacts",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          Divider(),
          ListTile(
            title: Text("Create backup", style: TextStyle(color: Colors.blue)),
          ),
          ListTile(
            title: Text(
              "Restore from backup",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          ListTile(
            title: Text(
              "Backup in iCloud",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          ListTile(
            title: Text(
              "Restore from iCloud",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          Divider(),
          SwitchListTile(
            title: Text("Use password"),
            value: false,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text("Use FaceID"),
            value: true,
            onChanged: (value) {},
          ),
          ListTile(
            title: Text(
              "Change password",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
