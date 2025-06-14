import 'dart:io';

import 'package:contactsafe/features/events/data/local_event_repository.dart';
import 'package:contactsafe/features/events/data/models/event_model.dart';
import 'package:contactsafe/features/events/presentation/screens/events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });
  });

  tearDown(() async {
    channel.setMockMethodCallHandler(null);
    await tempDir.delete(recursive: true);
  });

  testWidgets('Events screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: EventsScreen()));
    expect(find.text('Events'), findsOneWidget);
  });

  test('LocalEventRepository saves and loads events', () async {
    final repo = LocalEventRepository();
    final event = AppEvent(
      title: 'Test',
      date: DateTime(2024, 1, 1),
      location: 'here',
      description: 'desc',
      participantContactIds: const [],
      userId: '1',
    );

    await repo.saveEvents([event]);
    final events = await repo.loadEvents();

    expect(events.length, 1);
    expect(events.first.title, 'Test');
  });
}
