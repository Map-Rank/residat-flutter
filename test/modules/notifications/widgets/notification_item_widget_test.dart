
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mapnrank/app/models/notification_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/notifications/widgets/notification_item_widget.dart';
import 'package:mapnrank/app/services/auth_service.dart';

import 'package:mockito/annotations.dart';

@GenerateMocks([AuthService])

void main() {
  //late MockAuthService mockAuthService;

  setUp(() {
    //mockAuthService = MockAuthService();
    Get.put<AuthService>(AuthService());
  });

  tearDown(() {
    Get.reset();
  });

  // testWidgets('renders NotificationItemWidget correctly', (WidgetTester tester) async {
  //   final notification = NotificationModel(
  //     title: 'Test Notification',
  //     content: '<p>Test Content</p>',
  //     date: DateTime.now().toIso8601String(),
  //     userModel: UserModel(userId: 1, firstName: 'John', lastName: 'Doe'),
  //     zoneName: 'Zone A',
  //   );
  //
  //   //when(mockAuthService.user).thenReturn(UserModel(userId: 1).obs);
  //
  //   bool wasDismissed = false;
  //   bool wasTapped = false;
  //
  //   await tester.pumpWidget(
  //     GetMaterialApp(
  //       home: Scaffold(
  //         body: NotificationItemWidget(
  //           notification: notification,
  //           icon: Icon(Icons.notifications),
  //           onDismissed: (notif) {
  //             wasDismissed = true;
  //           },
  //           onTap: (notif) {
  //             wasTapped = true;
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   // Verify the widget renders correctly
  //   expect(find.text('Test Notification'), findsOneWidget);
  //   expect(find.text('Test Content'), findsNothing); // Trimmed by ReadMoreText
  //
  //   // Simulate tap on the widget
  //   await tester.tap(find.byType(GestureDetector));
  //   await tester.pumpAndSettle();
  //   expect(wasTapped, isTrue);
  //
  //   // Simulate dismissing the widget
  //   await tester.drag(find.byType(Dismissible), Offset(-500, 0));
  //   await tester.pumpAndSettle();
  //   expect(wasDismissed, isTrue);
  // });
  //
  // testWidgets('handles ReadMoreText content properly', (WidgetTester tester) async {
  //   final notification = NotificationModel(
  //     title: 'Expandable Notification',
  //     content: '<p>Line 1</p><p>Line 2</p>',
  //     date: DateTime.now().toIso8601String(),
  //     userModel: UserModel(userId: 1, firstName: 'Jane', lastName: 'Smith'),
  //     zoneName: 'Zone B',
  //   );
  //
  //   //when(mockAuthService.user).thenReturn(UserModel(userId: 1).obs);
  //
  //   await tester.pumpWidget(
  //     GetMaterialApp(
  //       home: Scaffold(
  //         body: NotificationItemWidget(
  //           notification: notification,
  //           icon: Icon(Icons.notifications),
  //           onDismissed: (_) {},
  //           onTap: (_) {},
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   // Verify content is transformed correctly
  //   expect(find.text('Line 1'), findsOneWidget);
  //   expect(find.text('Line 2'), findsNothing); // Initially hidden
  // });
}
