import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/modules/community/widgets/comment_widget.dart';
 // Adjust the import path based on your project structure

void main() {
  testWidgets('CommentWidget displays correctly', (WidgetTester tester) async {
    // Mock data
    const String user = 'John Doe';
    const String comment = 'This is a comment';
    const String imageUrl = 'https://example.com/avatar.jpg';

    // Build the widget and trigger a frame
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: CommentWidget(
            user: user,
            comment: comment,
            userAvatar: SizedBox(),
          ),
        ),
      ),
    );

    // Verify the presence of key widgets and properties
    expect(find.byType(Row), findsWidgets);
    //expect(find.byType(ClipOval), findsOneWidget);
    //expect(find.byType(FadeInImage), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(2)); // One for user, one for comment

    // Verify user text
    expect(find.text(user), findsOneWidget);

    // Verify comment text
    expect(find.text(comment), findsOneWidget);

    // Verify image loading and error handling
    // final imageWidget = tester.widget<FadeInImage>(find.byType(FadeInImage));
    // expect(imageWidget.placeholder, isA<AssetImage>());
    // expect(imageWidget.image, isA<NetworkImage>());
  });
}
