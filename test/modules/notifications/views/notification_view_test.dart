import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/models/notification_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/global_widgets/circular_loading_widget.dart';
import 'package:mapnrank/app/modules/profile/views/profile_view.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mapnrank/app/modules/notifications/views/notification_view.dart';
import 'package:mapnrank/app/modules/notifications/controllers/notification_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Create mock controller
class MockNotificationController extends GetxController with Mock implements NotificationController {
  @override
  var currentUser = Rx<UserModel>(UserModel(email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      avatarUrl: 'http://example.com/avatar.png')); // Add your User model
  final loadingNotifications = false.obs;
  final notifications = [].obs;
  final isMyCreatedNotification = false.obs;
  final createdNotifications = [].obs;
  final receivedNotifications = [].obs;

  @override
  Future<void> refreshNotification() async {
    // Mock implementation
  }

}

void main() {
  late MockNotificationController controller;

  setUp(() {
    controller = MockNotificationController();
    Get.put<NotificationController>(controller);
    Get.lazyPut(()=>AuthService());
    Get.find<AuthService>().user.value.userId = 1;

    const TEST_MOCK_STORAGE = '/test/test_pictures';
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return TEST_MOCK_STORAGE;
    });
    //Get.lazyPut(()=>AuthService());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('NotificationView should render correctly for regular users', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      GetMaterialApp(
        home:Localizations(
          delegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Locale('en'),

          child: Builder(
              builder: (BuildContext context) {
                return NotificationView();
              }

          ),),
      ),
    );

    // Assert
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.text('Important messages'), findsOneWidget);
  });

  testWidgets('NotificationView should render correctly for council users', (WidgetTester tester) async {
    // Arrange
    controller.currentUser.value = UserModel(type: 'COUNCIL', avatarUrl: "https://images.cm"); // Add your User model

    await tester.pumpWidget(
      GetMaterialApp(
        home: Localizations(
          delegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Locale('en'),

          child: Builder(
              builder: (BuildContext context) {
                return NotificationView();
              }

          ),)
        ,
      ),
    );

    // Assert
    expect(find.text('Send mass message'), findsOneWidget);
    expect(find.text('Recently sent'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
  });

  testWidgets('NotificationView should render correctly for non council users', (WidgetTester tester) async {
    // Arrange
    controller.currentUser.value = UserModel(type: 'OTHER', avatarUrl: "https://images.cm");
    controller.loadingNotifications.value = false;
    controller.notifications.value = [NotificationModel(
      zoneId: '1',
      zoneName: 'Garoua',
      content: 'Sample notification',
      notificationId: 1,
      bannerUrl: "https://images.cm",
        date: '2012-12-10',
      userModel:UserModel(email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          avatarUrl: 'http://example.com/avatar.png') ,
      title: 'notification title'
    ),
      NotificationModel(
          zoneId: '1',
          zoneName: 'Garoua',
          content: 'Sample notification',
          notificationId: 1,
        bannerUrl: "https://images.cm",
        date: '2012-12-10',
        userModel:UserModel(email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            avatarUrl: 'http://example.com/avatar.png') ,
          title: 'notification title',
      )];

    await tester.pumpWidget(
      GetMaterialApp(
        home: Localizations(
          delegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Locale('en'),

          child: Builder(
              builder: (BuildContext context) {
                return NotificationView();
              }

          ),)
        ,
      ),
    );

    // Assert
    expect(find.text('Important messages'), findsOneWidget);
    expect(controller.notifications.length, 2);


  });

  testWidgets('NotificationView should render correctly for council users for their created notifications', (WidgetTester tester) async {
    // Arrange
    controller.currentUser.value = UserModel(type: 'COUNCIL', avatarUrl: "https://images.cm");
    controller.loadingNotifications.value = false;
    controller.notifications.value = [NotificationModel(
        zoneId: '1',
        zoneName: 'Garoua',
        content: 'Sample notification',
        notificationId: 1,
        bannerUrl: "https://images.cm",
        date: '2012-12-10',
        userModel:UserModel(email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            avatarUrl: 'http://example.com/avatar.png') ,
        title: 'notification title'
    ),
      NotificationModel(
        zoneId: '1',
        zoneName: 'Garoua',
        content: 'Sample notification',
        notificationId: 1,
        bannerUrl: "https://images.cm",
        date: '2012-12-10',
        userModel:UserModel(email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            avatarUrl: 'http://example.com/avatar.png') ,
        title: 'notification title',
      )];

    controller.createdNotifications.value = [NotificationModel(
        zoneId: '1',
        zoneName: 'Garoua',
        content: 'Sample notification',
        notificationId: 1,
        bannerUrl: "https://images.cm",
        date: '2012-12-10',
        userModel:UserModel(email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            avatarUrl: 'http://example.com/avatar.png') ,
        title: 'notification title'
    ),
      ];

    controller.isMyCreatedNotification.value = true;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Localizations(
          delegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Locale('en'),

          child: Builder(
              builder: (BuildContext context) {
                return NotificationView();
              }

          ),)
        ,
      ),
    );

    // Assert
    expect(controller.createdNotifications.length, 1);


  });

  testWidgets('NotificationView should render correctly for council users for the notifications they received', (WidgetTester tester) async {
    // Arrange
    controller.currentUser.value = UserModel(type: 'COUNCIL', avatarUrl: "https://images.cm");
    controller.loadingNotifications.value = false;
    controller.notifications.value = [NotificationModel(
        zoneId: '1',
        zoneName: 'Garoua',
        content: 'Sample notification',
        notificationId: 1,
        bannerUrl: "https://images.cm",
        date: '2012-12-10',
        userModel:UserModel(email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            avatarUrl: 'http://example.com/avatar.png') ,
        title: 'notification title'
    ),
      NotificationModel(
        zoneId: '1',
        zoneName: 'Garoua',
        content: 'Sample notification',
        notificationId: 1,
        bannerUrl: "https://images.cm",
        date: '2012-12-10',
        userModel:UserModel(email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            avatarUrl: 'http://example.com/avatar.png') ,
        title: 'notification title',
      )];

    controller.receivedNotifications.value = [NotificationModel(
        zoneId: '1',
        zoneName: 'Garoua',
        content: 'Sample notification',
        notificationId: 1,
        bannerUrl: "https://images.cm",
        date: '2012-12-10',
        userModel:UserModel(email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            avatarUrl: 'http://example.com/avatar.png') ,
        title: 'notification title'
    ),
    ];

    controller.isMyCreatedNotification.value = false;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Localizations(
          delegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Locale('en'),

          child: Builder(
              builder: (BuildContext context) {
                return NotificationView();
              }

          ),)
        ,
      ),
    );

    // Assert
    expect(controller.receivedNotifications.length, 1);


  });


  testWidgets('Should toggle between Recently sent and Inbox for council users', (WidgetTester tester) async {
    // Arrange
    controller.currentUser.value = UserModel(type: 'COUNCIL', avatarUrl: "https://images.cm"); // Add your User model

    await tester.pumpWidget(
      GetMaterialApp(
        home: Localizations(
          delegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Locale('en'),

          child: Builder(
              builder: (BuildContext context) {
                return NotificationView();
              }

          ),),
      ),
    );

    // Act
    await tester.tap(find.text('Inbox'));
    await tester.pump();

    // Assert
    expect(controller.isMyCreatedNotification.value, true);

    // Act
    await tester.tap(find.text('Recently sent'));
    await tester.pump();

    // Assert
    expect(controller.isMyCreatedNotification.value, false);
  });



  testWidgets('Should refresh notifications when pulling to refresh', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      GetMaterialApp(
        home: Localizations(
          delegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Locale('en'),

          child: Builder(
              builder: (BuildContext context) {
                return NotificationView();
              }

          ),),
      ),
    );

    // Act
    await tester.fling(
      find.byKey(Key('listView')),
      const Offset(0.0, 300.0),
      1000.0,
    );
    await tester.pump();

    // Verify
    //verify(controller.refreshNotification()).called(1);
  });

}
