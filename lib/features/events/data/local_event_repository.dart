import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'models/event_model.dart';

class LocalEventRepository {
  Future<File> _getEventsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/events.json');
  }

  Future<List<AppEvent>> loadEvents() async {
    final file = await _getEventsFile();
    if (!await file.exists()) {
      return [];
    }
    final jsonString = await file.readAsString();
    if (jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> data = jsonDecode(jsonString);
    return data
        .map((e) => AppEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveEvents(List<AppEvent> events) async {
    final file = await _getEventsFile();
    final data = events.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> addEvent(AppEvent event) async {
    final events = await loadEvents();
    events.add(event);
    await saveEvents(events);
  }
}
