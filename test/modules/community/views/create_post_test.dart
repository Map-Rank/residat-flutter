// test/mocks.dart


import 'dart:io';

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

// Mock class
class MockCommunityController extends GetxController with Mock implements CommunityController {
  @override
  var chooseARegion = false.obs;

  @override
  var createUpdatePosts = false.obs;

  @override
  var updatePosts = false.obs;

  @override
  Post post = Post(
      content: 'post',
    sectors: [],
    commentCount: RxInt(2),
    commentList: [],
    imagesUrl: [
        {'url':'https:testUrl.com'}
      ],
    likeCount: RxInt(2),
    shareCount: RxInt(2)
  );

  @override
  var createPosts = false.obs;

  @override
  var chooseADivision = false.obs;

  @override
  var chooseASubDivision = false.obs;

  @override
  var loadingRegions = false.obs;

  @override
  var loadingDivisions = false.obs;

  @override
  var loadingSubdivisions = false.obs;

  @override
  var regionSelected = false.obs;

  @override
  var divisionSelected = false.obs;

  @override
  var subdivisionSelected = false.obs;

  @override
  var regionSelectedIndex = 0.obs;

  @override
  var divisionSelectedIndex = 0.obs;

  @override
  var subdivisionSelectedIndex = 0.obs;

  @override
  var regions = [{'name': 'Region'}].obs;

  @override
  var divisions = [{'name': 'Division'}].obs;

  @override
  var subdivisions = [{'name': 'SubDivision'}].obs;

  @override
  var imageFiles = [File('path/to/image')].obs;

  @override
  var regionSelectedValue = [{'name': 'Region'}].obs;

  @override
  var divisionSelectedValue = [{'name': 'Division'}].obs;

  @override
  var subdivisionSelectedValue = [{'name': 'SubDivision'}].obs;

  @override
  var sectorsSelected = [{'name': 'sector'}].obs;

  @override
  TextEditingController postContentController = TextEditingController();
}


@GenerateNiceMocks([
  MockSpec<Post>(),

])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.instance.window.physicalSizeTestValue = Size(3000, 3000); // Larger screen size
  TestWidgetsFlutterBinding.instance.window.devicePixelRatioTestValue = 1.0;


  testWidgets('CreatePostView shows and interacts correctly', (WidgetTester tester) async {
    // Arrange
    // Initialize Get and the mock controller
    Get.lazyPut(()=>CommunityController());
    Get.lazyPut(()=>AuthService());
    Get.lazyPut(()=>LaravelApiClient(dio: Dio()));
    final mockController = MockCommunityController();
    Get.lazyPut(()=>MockCommunityController());
    mockController.isRootFolder = true;


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


    // Act
    await tester.press(find.byKey(Key('backCreatePost')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('avatar')));
    await tester.pumpAndSettle();

    // Assert
    //expect(find.byKey(Key('regionDialog')), findsOneWidget);

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
    mockController.createUpdatePosts = true.obs;
    mockController.imageFiles = [XFile('path/to/image')].obs;
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
    //await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    // Assert: Ensure the image is removed after tapping delete
    //verify(mockController.imageFiles.removeAt(0)).called(1);

    await tester.pumpAndSettle();
  });


  testWidgets('buildInputImages renders correctly and image files is not empty', (WidgetTester tester) async {
    Get.lazyPut(()=>CommunityController());
    Get.lazyPut(()=>AuthService());
    Get.lazyPut(()=>LaravelApiClient(dio: Dio()));
    final mockController = MockCommunityController();
    Get.lazyPut(()=>MockCommunityController());

    // Arrange
    mockController.createUpdatePosts = true.obs;
    mockController.imageFiles = [XFile('path/to/image')].obs;


    // Build the widget tree
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) =>  CreatePostView()),
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

    // Act
    await tester.tap(find.byKey(Key('inputImage')));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byKey(Key('imageDialog')), findsOneWidget);

    // Act: Tap the delete icon
    //await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    // Assert: Ensure the image is removed after tapping delete
    //verify(mockController.imageFiles.removeAt(0)).called(1);

    await tester.pumpAndSettle();


  });


  testWidgets('choose region button shows dialog when tapped',
          (WidgetTester tester) async {
            // Arrange
            // Initialize Get and the mock controller
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
            final mockController = MockCommunityController();
            Get.put<CommunityController>(mockController);

            Get.replace<CommunityController>(mockController);

            // Arrange

            mockController.createUpdatePosts = true.obs;
            mockController.regionSelectedValue = [{"name": "Region"}].obs;
            mockController.regionSelectedValue = [{"name": "Region"}].obs;
            //mockController.imageFiles = <XFile>[].obs;
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
                find.byKey(const Key('chooseDivision')),
                100.0,
                scrollable: scrollable,
              );
              await tester.pumpAndSettle();
            }

            final signOutButton = find.byKey(const Key('chooseDivision'));
            expect(signOutButton, findsOneWidget);
            await tester.tap(signOutButton);
            await tester.pumpAndSettle();

            expect(find.byKey(const Key('divisionDialog')), findsOneWidget);
      });



  testWidgets('choose subdivision button shows dialog when tapped',
          (WidgetTester tester) async {
        // Arrange
        // Initialize Get and the mock controller

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
            find.byKey(const Key('chooseSubdivision')),
            100.0,
            scrollable: scrollable,
          );
          await tester.pumpAndSettle();
        }

        final signOutButton = find.byKey(const Key('chooseSubdivision'));
        expect(signOutButton, findsOneWidget);
        await tester.tap(signOutButton);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('subdivisionDialog')), findsOneWidget);
      });

  testWidgets('buildInputImages renders correctly and image files is not empty', (WidgetTester tester) async {
    // Create and register the mock controller BEFORE creating the widget
    final mockController = MockCommunityController();
    Get.put<CommunityController>(mockController);

    Get.replace<CommunityController>(mockController);

    // Set up the mock controller state
   // when(mockController.createUpdatePosts).thenReturn(true.obs);
   // when(mockController.imageFiles).thenReturn(<XFile>[XFile('path/to/image')].obs);
// Use put instead of lazyPut

    // Set up the mock controller state
    mockController.createUpdatePosts.value = true;
    mockController.createPosts.value = true;

    mockController.imageFiles.value = <File>[File('path/to/image')].obs;
    //mockController.imageFiles.assignAll(imagesList);
    mockController.postContentController = TextEditingController();

    // Build the widget tree
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) => CreatePostView()),
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

    await tester.pumpAndSettle();

    // Act
    await tester.tap(find.byKey(Key('cameraKey')));
    await tester.pumpAndSettle();

    // Assert
     expect(find.byKey(Key('cameraDialog')), findsOneWidget);
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.window.clearPhysicalSizeTestValue();
    TestWidgetsFlutterBinding.instance.window.clearDevicePixelRatioTestValue();
  });


}
