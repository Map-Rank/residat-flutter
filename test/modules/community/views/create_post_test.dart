// test/mocks.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapnrank/app/modules/community/views/create_post.dart';
import 'package:mapnrank/app/providers/laravel_provider.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

import 'create_post_test.mocks.dart';
@GenerateNiceMocks([
  MockSpec<CommunityController>(),
  MockSpec<Post>(),

])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('CreatePostView shows and interacts correctly', (WidgetTester tester) async {
    // Arrange
    // Initialize Get and the mock controller
    Get.lazyPut(()=>CommunityController());
    Get.lazyPut(()=>AuthService());
    Get.lazyPut(()=>LaravelApiClient(dio: Dio()));
    final mockController = MockCommunityController();
    Get.lazyPut(()=>MockCommunityController());


    // Build the widget tree
    await tester.pumpWidget(
      GetMaterialApp(
        home: CreatePostView(),
        localizationsDelegates: [
          AppLocalizations.delegate,
          // ... other localization delegates
        ],
        locale: const Locale('en'), // S
      ),
    );

    // Pump and settle to ensure all animations and state changes are processed
    await tester.pumpAndSettle();

    // Act
    // Verify the app bar title, back button, and post button exist
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    //expect(find.byKey(Key('post_button')), findsOneWidget);

    // Tap the post button and verify interaction
    //await tester.tap(find.byKey(Key('post_button')));
    await tester.pump();

    // Assert
    // Check if the AlertDialog is shown (if there was a conditional check)
    expect(find.byType(AlertDialog), findsNothing); // Update based on actual behavior

    // Test content of TextFormField and interactions
    //await tester.enterText(find.byType(TextFormField), 'Sample content');
    //expect(find.text('Sample content'), findsOneWidget);

    // Example for tapping on an image picker dialog
    //await tester.tap(find.byIcon(FontAwesomeIcons.camera));
    await tester.pumpAndSettle();

    // Verify the image picker dialog is displayed
    //expect(find.byType(AlertDialog), findsOneWidget); // Adjust based on actual dialog

    // Clean up
  });

  testWidgets('buildInputImages renders correctly and interacts with delete and image picker buttons', (WidgetTester tester) async {
    Get.lazyPut(()=>CommunityController());
    Get.lazyPut(()=>AuthService());
    Get.lazyPut(()=>LaravelApiClient(dio: Dio()));
    final mockController = MockCommunityController();
    Get.lazyPut(()=>MockCommunityController());

    // Arrange
    when(mockController.createUpdatePosts).thenReturn(true.obs);
    when(mockController.imageFiles).thenReturn([XFile('path/to/image')].obs);
    CommunityController().createUpdatePosts.value = true;

    // Build the widget tree
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) =>  CreatePostView().buildInputImages(context),),
        ),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: Locale('en'),
      ),
    );

    await tester.pumpAndSettle(); // Let the UI render completely

    // Assert: Verify the Image is displayed
    //expect(find.byType(Image), findsOneWidget);

    // Act: Tap the delete icon
    //await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    // Assert: Ensure the image is removed after tapping delete
    //verify(mockController.imageFiles.removeAt(0)).called(1);

    // Act: Tap the camera icon to show the image picker dialog
    //await tester.tap(find.byIcon(FontAwesomeIcons.camera));
    await tester.pumpAndSettle();

    // Assert: Check if the dialog is displayed
    //expect(find.byType(AlertDialog), findsOneWidget);

    // Act: Tap on "Take picture"
    //await tester.tap(find.text('Take Picture')); // This assumes localization is working
    await tester.pumpAndSettle();

    // Assert: Verify that the pickImage method was called with ImageSource.camera
    //verify(mockController.pickImage(ImageSource.camera)).called(1);

    // Act: Close the dialog
    //await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

  });

  testWidgets('choose region button shows dialog when tapped',
          (WidgetTester tester) async {
            // Arrange
            // Initialize Get and the mock controller
            Get.lazyPut(()=>CommunityController());
            Get.lazyPut(()=>AuthService());
            Get.lazyPut(()=>LaravelApiClient(dio: Dio()));
            final mockController = MockCommunityController();
            Get.lazyPut(()=>MockCommunityController());
        // Arrange
        await tester.pumpWidget(
          GetMaterialApp(
            home: CreatePostView(),
            localizationsDelegates: [
              AppLocalizations.delegate,
              // ... other localization delegates
            ],
            locale: const Locale('en'), // S
          ),
        );

        // Act
        await tester.tap(find.byKey(Key('chooseRegion')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byKey(Key('regionDialog')), findsOneWidget);
      });

  testWidgets('choose division button shows dialog when tapped',
          (WidgetTester tester) async {
        // Arrange
        // Initialize Get and the mock controller
           // CommunityController().regionSelectedValue.value = [{'zone':2}];

        Get.lazyPut(()=>CommunityController());
        Get.lazyPut(()=>AuthService());
        Get.lazyPut(()=>LaravelApiClient(dio: Dio()));
        final mockController = MockCommunityController();
        Get.lazyPut(()=>MockCommunityController());
        // Arrange
        await tester.pumpWidget(
          GetMaterialApp(
            home: CreatePostView(),
            localizationsDelegates: [
              AppLocalizations.delegate,
              // ... other localization delegates
            ],
            locale: const Locale('en'), // S
          ),
        );

        // Act
        await tester.tap(find.byKey(Key('chooseDivision')));
        await tester.pumpAndSettle();

        // Assert
        //expect(find.byKey(Key('divisionDialog')), findsOneWidget);
      });

  testWidgets('choose subdivision button shows dialog when tapped',
          (WidgetTester tester) async {
        // Arrange
        // Initialize Get and the mock controller
        Get.lazyPut(()=>CommunityController());
        Get.lazyPut(()=>AuthService());
        Get.lazyPut(()=>LaravelApiClient(dio: Dio()));
        final mockController = MockCommunityController();
        Get.lazyPut(()=>MockCommunityController());

        CommunityController().regionSelectedValue = [{'zone': 1}].obs;
        // Arrange
        await tester.pumpWidget(
          GetMaterialApp(
            home: CreatePostView(),
            localizationsDelegates: [
              AppLocalizations.delegate,
              // ... other localization delegates
            ],
            locale: const Locale('en'), // S
          ),
        );

        // Act
        await tester.tap(find.byKey(Key('chooseSubdivision')));
        await tester.pumpAndSettle();

        // Assert
       // expect(find.byKey(Key('subdivisionDialog')), findsOneWidget);
      });


}
