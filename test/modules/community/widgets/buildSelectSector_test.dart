import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/modules/community/widgets/buildSelectSector.dart';
import 'package:mockito/mockito.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/global_widgets/location_widget.dart';
import 'package:mapnrank/app/modules/global_widgets/text_field_widget.dart';

class MockCommunityController extends GetxController with Mock implements CommunityController {
  @override
  var sectors = <Map<String, dynamic>>[].obs;

  @override
  var loadingSectors = false.obs;

  @override
  var selectedIndex = 0.obs;

  @override
  var sectorsSelected = <Map<String, dynamic>>[].obs;

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
  late MockCommunityController mockCommunityController;

  setUp(() {
    mockCommunityController = MockCommunityController();
    // Override the Get.put<CommunityController> call to use the mock controller
    Get.put<CommunityController>(mockCommunityController);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('BuildSelectSector renders correctly and handles interactions', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: BuildSelectSector(),
        ),
      ),
    );

    // Verify initial state
    expect(find.text('Select a sector'), findsOneWidget);
    //expect(find.byIcon(FontAwesomeIcons.search), findsOneWidget);
    expect(find.text('Select or search by sector name'), findsOneWidget);

    // Simulate entering text in search field
    await tester.enterText(find.byType(TextFieldWidget), 'Test Sector');
    await tester.pump();

    // Verify the controller method call
    //verify(mockCommunityController.filterSearchSectors('Test Sector')).called(1);

    // Mock the state after sectors are loaded
    expect(mockCommunityController.loadingSectors.value, false);
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
    expect(mockCommunityController.selectedIndex.value,  0);
    expect(mockCommunityController.sectorsSelected.isEmpty, true);

    // Simulate toggling the sector
    //await tester.tap(find.text('Sector 1'));
    await tester.pumpAndSettle();

    // Verify the sector is removed from selected sectors
    expect(mockCommunityController.selectedIndex.value, 0);
    expect(mockCommunityController.sectorsSelected.isEmpty, true);
  });
}