import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mapnrank/app/modules/global_widgets/circular_loading_widget.dart';

void main() {
  // group('CircularLoadingWidget', () {
  //   testWidgets('should display SpinKitThreeBounce initially', (WidgetTester tester) async {
  //     // Arrange
  //     await tester.pumpWidget(
  //       MaterialApp(
  //         home: Scaffold(
  //           body: CircularLoadingWidget(
  //             height: 100,
  //           ),
  //         ),
  //       ),
  //     );
  //
  //     // Assert
  //     expect(find.byType(SpinKitThreeBounce), findsOneWidget);
  //   });
  //
  //   testWidgets('should show completion text after animation', (WidgetTester tester) async {
  //     // Arrange
  //     const completeText = 'Completed!';
  //     await tester.pumpWidget(
  //       MaterialApp(
  //         home: Scaffold(
  //           body: CircularLoadingWidget(
  //             height: 100,
  //             onCompleteText: completeText,
  //           ),
  //         ),
  //       ),
  //     );
  //
  //     // Act - Wait for the timer to complete (10 seconds)
  //     await tester.pump(const Duration(seconds: 10));
  //     // Pump the animation
  //     await tester.pump(const Duration(milliseconds: 300));
  //
  //     // Assert
  //     expect(find.text(completeText), findsOneWidget);
  //     expect(find.byType(SpinKitThreeBounce), findsNothing);
  //   });
  //
  //   testWidgets('should call onComplete callback after timer', (WidgetTester tester) async {
  //     // Arrange
  //     bool onCompleteCalled = false;
  //     await tester.pumpWidget(
  //       MaterialApp(
  //         home: Scaffold(
  //           body: CircularLoadingWidget(
  //             height: 100,
  //             onComplete: (_) {
  //               onCompleteCalled = true;
  //             },
  //           ),
  //         ),
  //       ),
  //     );
  //
  //     // Act - Wait for the timer to complete
  //     await tester.pump(const Duration(seconds: 10));
  //     await tester.pump(const Duration(milliseconds: 300));
  //
  //     // Assert
  //     expect(onCompleteCalled, isTrue);
  //   });
  //
  //   testWidgets('should have correct height', (WidgetTester tester) async {
  //     // Arrange
  //     const double expectedHeight = 100.0;
  //     await tester.pumpWidget(
  //       MaterialApp(
  //         home: Scaffold(
  //           body: CircularLoadingWidget(
  //             height: expectedHeight,
  //           ),
  //         ),
  //       ),
  //     );
  //
  //     // Assert
  //     final SizedBox sizedBox = tester.widget(find.byType(SizedBox).first);
  //     expect(sizedBox.height, expectedHeight);
  //   });
  //
  //   testWidgets('should dispose properly', (WidgetTester tester) async {
  //     // Arrange
  //     await tester.pumpWidget(
  //       MaterialApp(
  //         home: Scaffold(
  //           body: CircularLoadingWidget(
  //             height: 100,
  //           ),
  //         ),
  //       ),
  //     );
  //
  //     // Act
  //     await tester.pumpWidget(const SizedBox());
  //
  //     // No need for explicit assertion as this test will fail if dispose causes any errors
  //   });
  // });
}