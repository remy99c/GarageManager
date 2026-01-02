import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:garage_master/main.dart';

void main() {
  testWidgets('GarageMaster app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const GarageMasterApp());

    expect(find.text('GarageMaster'), findsOneWidget);
  });
}
