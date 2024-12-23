import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapnrank/app/modules/global_widgets/tool_tip_widget.dart';

void main() {
  group('TooltipWidget', () {
    testWidgets('should render tooltip with correct text', (WidgetTester tester) async {
      const String testText = 'Test Tooltip';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TooltipWidget(text: testText),
          ),
        ),
      );

      // Verify text is displayed
      expect(find.text(testText), findsOneWidget);

      // Verify container properties
      final Container container = tester.widget<Container>(find.byType(Container));
      expect(container.decoration, isA<BoxDecoration>());

      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.border, isNotNull);
    });

    testWidgets('should have correct text style', (WidgetTester tester) async {
      const String testText = 'Test Tooltip';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TooltipWidget(text: testText),
          ),
        ),
      );

      final Text textWidget = tester.widget<Text>(find.text(testText));
      expect(textWidget.style?.color, equals(Colors.black));
      expect(textWidget.style?.fontSize, equals(14));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should contain CustomPaint widget for triangle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TooltipWidget(text: 'Test'),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsNWidgets(2));
    });
  });

  group('TooltipTrianglePainter', () {
    test('shouldRepaint returns false', () {
      final painter = TooltipTrianglePainter(
        fillColor: Colors.white,
        borderColor: Colors.white,
      );

      expect(painter.shouldRepaint(painter), isFalse);
    });

    testWidgets('paints triangle with correct colors', (WidgetTester tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              key: key,
              painter: TooltipTrianglePainter(
                fillColor: Colors.white,
                borderColor: Colors.white,
              ),
              size: const Size(24, 12),
            ),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
      // Note: Testing actual painting is limited in widget tests
      // For more detailed paint testing, you would need to use golden tests
    });
  });

  testWidgets('TooltipWidget layout structure', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TooltipWidget(text: 'Test'),
        ),
      ),
    );

    expect(find.byType(Stack), findsNWidgets(2));
    expect(find.byType(Container), findsOneWidget);
    expect(find.byType(Positioned), findsOneWidget);
    expect(find.byType(CustomPaint), findsNWidgets(2));
  });
}