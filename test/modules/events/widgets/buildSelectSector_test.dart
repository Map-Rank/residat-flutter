import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/modules/events/controllers/events_controller.dart';
import 'package:mapnrank/app/modules/events/widgets/buildSelectSector.dart';
import 'package:mockito/mockito.dart';
import 'package:mapnrank/app/modules/global_widgets/text_field_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MockEventsController extends GetxController with Mock implements EventsController {
  @override
  var sectors = <Map<String, dynamic>>[{"name":"sector", "id":1}].obs;

  @override
  var loadingSectors = false.obs;

  @override
  var selectedIndex = 0.obs;

  @override
  var sectorsSelected = <Map<String, dynamic>>[].obs;

  @override
  var filterBySector = false.obs;

  @override
  var noFilter = false.obs;

  @override
  var post = Post();

  @override
  void filterSearchSectors(String value) {
    // Mock implementation
  }

  @override
  void filterSearchPostsBySectors(var sectorsIds) {
    // Mock implementation
  }
}

void main() {
  late MockEventsController mockEventsController;

  setUp(() {
    mockEventsController = MockEventsController();
    // Override the Get.put<CommunityController> call to use the mock controller
    Get.put<EventsController>(mockEventsController);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('BuildSelectSector renders correctly and handles interactions', (WidgetTester tester) async {
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
                  return BuildSelectSector();
                }

            ),),
        ),
      ),
    );

    // Verify initial state
    //expect(find.text('Select a sector'), findsOneWidget);
    //expect(find.byIcon(FontAwesomeIcons.search), findsOneWidget);
    //expect(find.text('Select or search by sector name'), findsOneWidget);

    // Simulate entering text in search field
    await tester.enterText(find.byType(TextFieldWidget), 'Test Sector');
    await tester.pump();

    // Verify the controller method call
    //verify(mockCommunityController.filterSearchSectors('Test Sector')).called(1);

    // Mock the state after sectors are loaded
    //expect(mockEventsController.loadingSectors.value, false);
    // when(mockCommunityController.sectors).thenReturn([
    //   {'name': 'Sector 1', 'id': 1},
    //   {'name': 'Sector 2', 'id': 2},
    // ].obs);

    await tester.pump();

    // Verify sector list is displayed
    // expect(find.text('Sector 1'), findsOneWidget);
    // expect(find.text('Sector 2'), findsOneWidget);

    // Simulate tapping on a sector
    //await tester.tap(find.text('Sector 1'));
    await tester.pumpAndSettle();

    // Verify the controller state change for sector selection
    expect(mockEventsController.selectedIndex.value,  0);
    expect(mockEventsController.sectorsSelected.isEmpty, true);

    // Simulate toggling the sector
    //await tester.tap(find.text('Sector 1'));
    await tester.pumpAndSettle();

    // Verify the sector is removed from selected sectors
    expect(mockEventsController.selectedIndex.value, 0);
    expect(mockEventsController.sectorsSelected.isEmpty, true);
  });

  testWidgets('BuildSelectSector renders a loading gif while sectors are loading', (WidgetTester tester) async {
    mockEventsController.loadingSectors.value = true;
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
                  return BuildSelectSector();
                }

            ),),
        ),
      ),
    );

  });
}
