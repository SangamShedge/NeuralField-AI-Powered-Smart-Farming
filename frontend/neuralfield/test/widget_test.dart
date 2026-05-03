import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuralfield/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const NeuralFieldApp());
    expect(find.byType(Scaffold), findsOneWidget);
  });
}