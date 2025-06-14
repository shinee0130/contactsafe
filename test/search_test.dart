import 'package:contactsafe/features/search/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Search screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
    expect(find.text('Search'), findsOneWidget);
  });
}
