import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vegobolt/Pages/Maintenance.dart';

void main() {
  testWidgets('Displays canceled item in history', (WidgetTester tester) async {
    final canceledItem = {
      'id': 'abc123',
      'title': 'Pump replacement',
      'machineId': 'VB-999',
      'location': 'Barangay 171',
      'priority': 'Low',
      'priorityColor': Colors.orange,
      'scheduledDate': DateTime.now(),
      'status': 'Canceled',
      'resolvedDate': DateTime.now().toIso8601String(),
    };

    await tester.pumpWidget(MaterialApp(home: MaintenancePage(initialHistoryItems: [canceledItem])));
    await tester.pumpAndSettle();

    // Ensure history tab is visible
    expect(find.text('History'), findsOneWidget);

    // Switch to History tab
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    // The canceled status label should be shown
    expect(find.text('Canceled'), findsOneWidget);
    // Title and machine id should be present
    expect(find.text('Pump replacement'), findsOneWidget);
    expect(find.textContaining('VB-999'), findsOneWidget);
  });
}
