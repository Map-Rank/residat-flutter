import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/modules/community/widgets/buildSelectZone.dart';
import 'package:mapnrank/app/providers/laravel_provider.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/events/controllers/events_controller.dart';
import 'package:mapnrank/app/modules/global_widgets/location_widget.dart';
import 'package:mapnrank/app/modules/global_widgets/text_field_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


// Mock class
class MockCommunityController extends GetxController with Mock implements CommunityController {
  @override
  var chooseARegion = false.obs;

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
  var regions = [].obs;

  @override
  var divisions = [].obs;

  @override
  var subdivisions = [].obs;

  @override
  var regionSelectedValue = [{'name': 'Region'}].obs;

  @override
  var divisionSelectedValue = [{'name': 'Division'}].obs;

  @override
  var subdivisionSelectedValue = [{'name': 'SubDivision'}].obs;
}

void main() {
  late MockCommunityController mockCommunityController;

  setUp(() {
    mockCommunityController = MockCommunityController();
    Get.put<CommunityController>(mockCommunityController);
    Get.lazyPut(() => EventsController());
  });

  testWidgets('BuildSelectZone renders correctly and handles interactions', (WidgetTester tester) async {
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
                    return BuildSelectZone();
                  }

              ),),
        ),
      ),
    );

    mockCommunityController.regions.value = [
      {'name': 'Region 1', 'id': 1}
    ];

    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    // Verify the controller state change for division selection
   // expect(mockCommunityController.chooseADivision.value, true);

    // Simulate division selection
    mockCommunityController.divisions.value = [
      {'name': 'Division 1', 'id': 1}
    ];


    await tester.pumpAndSettle();

    // Verify the controller state change for subdivision selection
    //expect(mockCommunityController.chooseASubDivision.value, true);

    // Simulate subdivision selection
    mockCommunityController.subdivisions.value = [
      {'name': 'Sub-Division 1', 'id': 1}
    ];

  });

  testWidgets('BuildSelectZone renders correctly and handles interactions', (WidgetTester tester) async {

    mockCommunityController.loadingRegions.value = true;

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
                  return BuildSelectZone();
                }

            ),),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

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
            home: BuildSelectZone(),
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
            home: BuildSelectZone(),
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
        CommunityController().subdivisions = [{'zone': 1}].obs;
        // Arrange
        await tester.pumpWidget(
          GetMaterialApp(
            home: BuildSelectZone(),
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
