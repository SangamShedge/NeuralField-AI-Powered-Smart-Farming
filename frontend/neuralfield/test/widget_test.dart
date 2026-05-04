import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:NeuralField/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const NeuralFieldApp(isLoggedIn: false,));
    expect(find.byType(Scaffold), findsOneWidget);
  });
}