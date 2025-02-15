import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mapnrank/app/modules/profile/controllers/profile_controller.dart';
import 'package:mapnrank/app/modules/auth/controllers/auth_controller.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/events/controllers/events_controller.dart';
import 'package:mapnrank/app/routes/app_routes.dart';
import 'package:mapnrank/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'profile_view_test.mocks.dart'; // Import the generated mocks file
import 'package:mapnrank/app/modules/profile/views/profile_view.dart';

// Generate the necessary mocks
@GenerateNiceMocks([
  MockSpec<ProfileController>(),
  MockSpec<AuthController>(),
  MockSpec<CommunityController>(),
  MockSpec<EventsController>(),

])
void main() {
  late MockProfileController mockProfileController;
  late MockAuthController mockAuthController;
  late MockCommunityController mockCommunityController;
  late MockEventsController mockEventsController;
  late ProfileController profileController;
  late CommunityController communityController;


  setUp(() {
    Get.testMode = true;
    Get.lazyPut(()=>ProfileController());
    Get.lazyPut(()=>AuthService());
    Get.lazyPut(()=>CommunityController());
    Get.lazyPut(()=>AuthController());
    Get.lazyPut(()=>EventsController());
    Get.lazyPut(()=>MockAuthController());
    mockProfileController = MockProfileController();
    mockAuthController = MockAuthController();
    mockCommunityController = MockCommunityController();
    mockEventsController = MockEventsController();
    profileController = ProfileController();
    const TEST_MOCK_STORAGE = '/test/test_pictures';
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return TEST_MOCK_STORAGE;
    });
    communityController = CommunityController();

    profileController.currentUser.value = UserModel(userId: 1,
      firstName: 'John',
      phoneNumber: '777777777',
      gender: 'Male',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      avatarUrl: null,
      birthdate: '1994-02-02',
      myPosts: ['Post1', 'Post2'], // Example post identifiers
      myEvents: ['Event1', 'Event2'], );

  });

  testWidgets('ProfileView displays correctly with avatar url being null', (WidgetTester tester) async {
    // Arrange

    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        home: ProfileView(),
        localizationsDelegates: [
          AppLocalizations.delegate,
          // ... other localization delegates
        ],
        locale: const Locale('en'), // Set locale to 'en'
      ),
    );

    // await tester.scrollUntilVisible(
    //   find.byKey(Key('signoutkey')), // The key for the target widget
    //   100.0, // Scroll increment
    //   //scrollable: find.byKey(Key('listView')),
    //   scrollable: find.ancestor(
    //     of: find.byKey(Key('signoutkey')),
    //     matching: find.byType(Scrollable),
    //   ),
    // );

    // Act

    // Assert
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsAtLeast(1));
  });

  testWidgets('Log out of the application action',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: ProfileView(),
            localizationsDelegates: [
              AppLocalizations.delegate,
            ],
            locale: const Locale('en'),
          ),
        );

        // Give more time for the widget to settle
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // First find any Scrollable widgets
        final scrollables = find.byType(Scrollable);
        expect(scrollables, findsWidgets, reason: 'No scrollable widgets found');

        // Find all possible scrollable containers
        final listViews = find.byType(ListView);
        final singleChildScrollViews = find.byType(SingleChildScrollView);

        print('Found ${listViews.evaluate().length} ListViews');
        print('Found ${singleChildScrollViews.evaluate().length} SingleChildScrollViews');

        // Try scrolling the first available scrollable
        final scrollable = find.byType(Scrollable).first;

        // Perform multiple small scrolls to ensure we cover the entire content
        for (var i = 0; i < 3; i++) {
          await tester.scrollUntilVisible(
            find.byKey(const Key('logOutKey')),
            100.0,
            scrollable: scrollable,
          );
          await tester.pumpAndSettle();
        }

        final signOutButton = find.byKey(const Key('logOutKey'));
        expect(signOutButton, findsOneWidget);
        await tester.tap(signOutButton);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('logout_app')), findsOneWidget);
      });

  testWidgets('Delete account from the application action',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: ProfileView(),
            localizationsDelegates: [
              AppLocalizations.delegate,
            ],
            locale: const Locale('en'),
          ),
        );

        // Give more time for the widget to settle
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // First find any Scrollable widgets
        final scrollables = find.byType(Scrollable);
        expect(scrollables, findsWidgets, reason: 'No scrollable widgets found');

        // Find all possible scrollable containers
        final listViews = find.byType(ListView);
        final singleChildScrollViews = find.byType(SingleChildScrollView);

        print('Found ${listViews.evaluate().length} ListViews');
        print('Found ${singleChildScrollViews.evaluate().length} SingleChildScrollViews');

        // Try scrolling the first available scrollable
        final scrollable = find.byType(Scrollable).first;

        // Perform multiple small scrolls to ensure we cover the entire content
        for (var i = 0; i < 3; i++) {
          await tester.scrollUntilVisible(
            find.byKey(const Key('deleteAccountKey')),
            100.0,
            scrollable: scrollable,
          );
          await tester.pumpAndSettle();
        }

        final signOutButton = find.byKey(const Key('deleteAccountKey'));
        expect(signOutButton, findsOneWidget);
        await tester.tap(signOutButton);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('deleteAccountDialog')), findsOneWidget);
      });

  testWidgets('ProfileView displays correctly with avatar url being non null', (WidgetTester tester) async {
    // Arrange
    profileController.currentUser.value = UserModel(userId: 1,
      firstName: 'John',
      phoneNumber: '777777777',
      gender: 'Male',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      avatarUrl: 'https://www.residat.com/media/avatar/shofolafelix@gmail.com/avatar_66de4efe34fbc.jpg',
      myPosts: ['Post1', 'Post2'], // Example post identifiers
      myEvents: ['Event1', 'Event2'], );

    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        home: ProfileView(),
        localizationsDelegates: [
          AppLocalizations.delegate,
          // ... other localization delegates
        ],
        locale: const Locale('en'), // Set locale to 'en'
      ),
    );

    // Assert
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsAtLeast(1));
  });

  testWidgets('ProfileView displays correctly with loadProfileImage at true', (WidgetTester tester) async {
    // Arrange
    profileController.loadProfileImage.value = true;
    profileController.profileImage.value = File('test/test_pictures/filter.png');

    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        home: ProfileView(),
        localizationsDelegates: [
          AppLocalizations.delegate,
          // ... other localization delegates
        ],
        locale: const Locale('en'), // Set locale to 'en'
      ),
    );

    // Assert
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsAtLeast(1));
  });

  // testWidgets('Tapping the signout button shows confirmation dialog', (WidgetTester tester) async {
  //   // Arrange: Set up a basic MaterialApp with ProfileView and localization
  //   await tester.pumpWidget(
  //     GetMaterialApp(
  //       home: Scaffold(
  //         body: Localizations(
  //           delegates: [
  //             AppLocalizations.delegate,
  //             GlobalMaterialLocalizations.delegate,
  //             GlobalWidgetsLocalizations.delegate,
  //             GlobalCupertinoLocalizations.delegate,
  //           ],
  //           locale: const Locale('en'), // Set locale to 'en'
  //           child: ProfileView(),
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   // Wait for the widget tree to build
  //   await tester.pumpAndSettle();
  //
  //   //debugDumpApp();
  //
  //   // Act: Tap on the 'signout' button
  //   final signOutButton = find.byKey(Key('signoutkey'));
  //   expect(signOutButton, findsOneWidget); // Ensure button is present
  //   await tester.tap(signOutButton); // Tap the signout button
  //   await tester.pumpAndSettle(); // Wait for the dialog to appear
  //
  //   // Assert: Check if the confirmation dialog is displayed
  //   expect(find.byType(AlertDialog), findsOneWidget); // Check if AlertDialog is displayed
  //   expect(find.byKey(Key('logout_app')), findsOneWidget); // Check for logout_app key
  //   expect(find.text('Log out'), findsOneWidget); // Verify dialog title (localization dependent)
  //   expect(find.text('Are you sure you want to sign out?'), findsOneWidget); // Check the confirmation text (adjust based on localization)
  //   expect(find.text('Exit'), findsOneWidget); // Verify presence of exit button
  //   expect(find.text('Cancel'), findsOneWidget); // Verify presence of cancel button
  // });
  //
  // testWidgets('Signout dialog shows loading spinner when AuthController is loading', (WidgetTester tester) async {
  //   // Arrange: Set loading value to true in AuthController
  //   when(mockAuthController.loading).thenReturn(RxBool(true));
  //
  //   await tester.pumpWidget(
  //     GetMaterialApp(
  //       home: Scaffold(
  //         body: Localizations(
  //           delegates: [
  //             AppLocalizations.delegate,
  //             GlobalMaterialLocalizations.delegate,
  //             GlobalWidgetsLocalizations.delegate,
  //             GlobalCupertinoLocalizations.delegate,
  //           ],
  //           locale: const Locale('en'),
  //           child: ProfileView(),
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   // Act: Tap on the 'signout' button
  //   final signOutButton = find.byKey(Key('signout'));
  //   await tester.tap(signOutButton);
  //   await tester.pumpAndSettle(); // Wait for dialog to appear
  //
  //   // Assert: Check for loading spinner in the dialog
  //   expect(find.byType(AlertDialog), findsOneWidget); // Check if the dialog is shown
  //   expect(find.byType(SpinKitThreeBounce), findsOneWidget); // Check if the spinner is shown
  // });
  //
  // testWidgets('Cancel button in the signout dialog dismisses the dialog', (WidgetTester tester) async {
  //   // Arrange: Render the ProfileView with the signout button
  //   await tester.pumpWidget(
  //     GetMaterialApp(
  //       home: Scaffold(
  //         body: Localizations(
  //           delegates: [
  //             AppLocalizations.delegate,
  //             GlobalMaterialLocalizations.delegate,
  //             GlobalWidgetsLocalizations.delegate,
  //             GlobalCupertinoLocalizations.delegate,
  //           ],
  //           locale: const Locale('en'),
  //           child: ProfileView(),
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   // Act: Tap on the 'signout' button
  //   await tester.tap(find.byKey(Key('signout')));
  //   await tester.pumpAndSettle(); // Wait for the dialog to appear
  //
  //   // Act: Tap the cancel button
  //   final cancelButton = find.text('Cancel');
  //   await tester.tap(cancelButton);
  //   await tester.pumpAndSettle(); // Wait for the dialog to disappear
  //
  //   // Assert: Ensure the dialog is dismissed
  //   expect(find.byType(AlertDialog), findsNothing); // Dialog should not be present anymore
  // });

}
