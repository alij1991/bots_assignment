// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bots_assignment/main.dart';

void main() {
  testWidgets('User Password Textfield Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    var login = find.text("Log in");
    expect(login, findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    expect(find.text('Password'), findsOneWidget);
    await tester.tap(login);
    await tester.pump();
    expect(find.text('Username or password is empty!'), findsWidgets);
  });
}
