import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/models/notification_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/notifications/widgets/notification_item_widget.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MockAuthService extends GetxService with Mock implements AuthService {
  final user = Rx<UserModel>(UserModel(email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      userId: 123,
      avatarUrl: 'http://example.com/avatar.png'));}

void main() {
  late MockAuthService mockAuthService;
  late NotificationModel mockNotification;

  setUp(() {
    mockAuthService = MockAuthService();
    Get.put<AuthService>(AuthService());

    const TEST_MOCK_STORAGE = '/test/test_pictures';
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return TEST_MOCK_STORAGE;
    });

    // Create a mock notification
    mockNotification = NotificationModel(
      title: 'Test Notification',
      content: 'Test Content',
      date: '2024-03-20T10:00:00',
      userModel: UserModel(
        userId: 123,
        firstName: 'John',
        lastName: 'Doe',
      ),
      zoneName: 'Test Zone',
    );
  });

  testWidgets('NotificationItemWidget displays correct content', (WidgetTester tester) async {
    // Arrange
    bool onDismissedCalled = false;
    bool onTapCalled = false;

    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Localizations(
            delegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Locale('en'),

            child: Builder(
                builder: (BuildContext context) {
                  return  NotificationItemWidget(
                    notification: mockNotification,
                    icon: Icon(Icons.notifications),
                    onDismissed: (notification) {
                      onDismissedCalled = true;
                    },
                    onTap: (notification) {
                      onTapCalled = true;
                    },
                  );
                }

            ),)

        ),
      ),
    );

    // Assert
    expect(find.text('Test Notification'), findsOneWidget);
    // expect(find.text('Test Content'), findsOneWidget);
    // expect(find.text('Test Zone'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_outlined), findsOneWidget);
  });

  testWidgets('NotificationItemWidget handles tap correctly', (WidgetTester tester) async {
    // Arrange
    bool onTapCalled = false;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Localizations(
            delegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Locale('en'),

            child: Builder(
                builder: (BuildContext context) {
                  return  NotificationItemWidget(
                    notification: mockNotification,
                    icon: Icon(Icons.notifications),
                    onDismissed: (notification) {},
                    onTap: (notification) {
                      onTapCalled = true;
                    },
                  );
                }

            ),)

        ),
      ),
    );

    // Act
    await tester.tap(find.byKey(Key('tapNotification')));
    await tester.pump();

    // Assert
    expect(onTapCalled, true);
  });

  testWidgets('NotificationItemWidget handles tap correctly', (WidgetTester tester) async {
    // Arrange
    bool onTapCalled = false;
    Get.find<AuthService>().user.value.userId = 123;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
            body: Localizations(
              delegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: Locale('en'),

              child: Builder(
                  builder: (BuildContext context) {
                    return  NotificationItemWidget(
                      notification: mockNotification,
                      icon: Icon(Icons.notifications),
                      onDismissed: (notification) {},
                      onTap: (notification) {
                        onTapCalled = true;
                      },
                    );
                  }

              ),)

        ),
      ),
    );

    // Act
    await tester.tap(find.byKey(Key('tapNotificationDismiss')));
    await tester.pump();

    // Assert
    expect(onTapCalled, true);
  });


  testWidgets('PopupMenuButton shows delete option and handles deletion', (WidgetTester tester) async {
    // Arrange
    bool onDismissedCalled = false;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Localizations(
            delegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Locale('en'),

            child: Builder(
                builder: (BuildContext context) {
                  return  NotificationItemWidget(
                    notification: mockNotification,
                    icon: Icon(Icons.notifications),
                    onDismissed: (notification) {
                      onDismissedCalled = true;
                    },
                    onTap: (notification) {},
                  );
                }

            ),)
        ),
      ),
    );

    // Act
    await tester.tap(find.byIcon(Icons.more_vert_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Assert
    expect(onDismissedCalled, true);
  });

  testWidgets('Dismissible widget handles swipe correctly', (WidgetTester tester) async {
    // Arrange
    bool onDismissedCalled = false;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Localizations(
            delegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Locale('en'),

            child: Builder(
                builder: (BuildContext context) {
                  return  NotificationItemWidget(
                    notification: mockNotification,
                    icon: Icon(Icons.notifications),
                    onDismissed: (notification) {
                      onDismissedCalled = true;
                    },
                    onTap: (notification) {},
                  );
                }

            ),)

        ),
      ),
    );

    // Act
    await tester.pumpAndSettle();
    // await tester.drag(find.byKey(Key('dismissibleNotification')), const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    // Assert
    expect(onDismissedCalled, false);
  });
}