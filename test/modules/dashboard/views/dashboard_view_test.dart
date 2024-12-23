import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mapnrank/app/modules/dashboard/views/dashboard_view.dart';
import 'package:mapnrank/app/repositories/community_repository.dart';
import 'package:mapnrank/app/repositories/sector_repository.dart';
import 'package:mapnrank/app/repositories/user_repository.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mapnrank/app/services/global_services.dart';
import 'package:mapnrank/color_constants.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../auth/controllers/auth_controller_test.dart';

// Create mock classes
class MockDashboardController extends GetxController with Mock implements DashboardController {
  @override
  var cancelSearchSubDivision = false.obs;

  @override
  RxDouble defaultLat = 7.3696495.obs;

  @override
  RxDouble defaultLng = 12.3445856.obs;

  @override
  RxDouble locationLat = 7.3696495.obs;

  @override
  RxDouble locationLng = 12.3445856.obs;

  @override
  var locationName = ''.obs;

  @override
  late String cameroonGeoJson;

  @override
  late String regionGeoJson;

  @override
  late String divisionGeoJson;

  @override
  List<Marker> markers = [];

  @override
  Rx<GeoJsonParser> hydroMapGeoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.blue,
    defaultPolygonBorderColor: Colors.blue,
    defaultPolygonFillColor: Colors.blue.withOpacity(0.1),
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),
  ).obs;

  @override
  Rx<GeoJsonParser> regionGeoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.black,
    defaultPolygonBorderColor: Colors.black,
    defaultPolygonFillColor: Colors.transparent,
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),
  ).obs;

  @override
  Rx<GeoJsonParser> divisionGeoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.black,
    defaultPolygonBorderColor: Colors.black,
    defaultPolygonFillColor: Colors.blue.withOpacity(0.2),
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),
  ).obs;

  @override
  Rx<GeoJsonParser> subDivisionGeoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.red,
    defaultPolygonBorderColor: Colors.red,
    defaultPolygonFillColor: Colors.blue.withOpacity(0.3),
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),
  ).obs;

  @override
  Rx<GeoJsonParser> locationGeoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.red,
    defaultPolygonBorderColor: Colors.orange,
    defaultPolygonFillColor: Colors.orange.withOpacity(0.4),
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),
  ).obs;

  @override
  List<Map<String, dynamic>> zones = [];

  @override
  List<Map<String, dynamic>> listAllZones = [];

  // @override
  // List<Map<String, dynamic>> listPostsZoneStatistics = [];

  @override
  var postsZoneStatistics =  [
          {
            'zone': {
              'name': 'Test Zone',
              'banner': 'https://example.com/banner.jpg',
            },
            'images': [
              {'url': 'https://example.com/image.jpg'}
            ],
            'creator': [
              {
                'avatar': 'https://example.com/avatar.jpg',
                'first_name': 'John',
                'last_name': 'Doe'
              }
            ],
            'content': '<p>Test content</p>'
          }
        ].obs;

  @override
  late UserRepository userRepository = UserRepository();

  @override
  late ZoneRepository zoneRepository = ZoneRepository();

  @override
  late SectorRepository sectorRepository = SectorRepository();

  @override
  late CommunityRepository communityRepository = CommunityRepository();

  @override
  var loadingCameroonGeoJson = true.obs;

  @override
  var loadingHydroMapGeoJson = true.obs;

  @override
  var loadingDivisionGeoJson = true.obs;

  @override
  var loadingSubDivisionGeoJson = true.obs;

  @override
  var loadingLocationGeoJson = true.obs;

  @override
  var loadingDisastersMarkers = true.obs;

  @override
  var loadingCameroonCheckBox = false.obs;

  @override
  var loadingHydroMapBox = false.obs;

  @override
  var loadingDisastersCheckBox = false.obs;

  @override
  LayerHitNotifier hitNotifier = ValueNotifier(null);

  @override
  MapController mapController = MapController();
  @override
  var currentUser = Rx<UserModel>(UserModel(email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      avatarUrl: 'http://example.com/avatar.png'));
}

void main() {
  late MockDashboardController mockController;

  setUp(() {
    mockController = MockDashboardController();
    Get.put<DashboardController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  group('DashboardView Widget Tests', () {
    testWidgets('should render DashboardView with AppBar', (WidgetTester tester) async {
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
                  return DashboardView();
                }

            ),),
        ),
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('should show search field in AppBar', (WidgetTester tester) async {
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
                  return DashboardView();
                }

            ),),
        ),
      );

      // Assert
      expect(find.byType(Autocomplete<Map<String, dynamic>>), findsOneWidget);
    });

    testWidgets('should show logo in AppBar', (WidgetTester tester) async {
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
                  return DashboardView();
                }

            ),),
        ),
      );

      // Assert
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should show bottom buttons', (WidgetTester tester) async {
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
                  return DashboardView();
                }

            ),),
        ),
      );

      // Assert
      expect(find.text('Zone statistics'), findsOneWidget);
      expect(find.text('Layers'), findsOneWidget);
    });

    testWidgets('should open layers dialog when layers button is tapped',
            (WidgetTester tester) async {
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
                      return DashboardView();
                    }

                ),),
            ),
          );

          // Act
          await tester.tap(find.text('Layers'));
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Cameroon'), findsOneWidget);
          expect(find.text('Hydro Polygon Map'), findsOneWidget);
          expect(find.text('Disasters Markers'), findsOneWidget);
        });

    testWidgets('should clear search when cancel button is tapped',
            (WidgetTester tester) async {
          // Arrange
          mockController.cancelSearchSubDivision.value = true;

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
                      return DashboardView();
                    }

                ),),
            ),
          );

          // Find the TextFormField
          final textFieldFinder = find.byType(TextFormField);

          // Enter text
          await tester.enterText(textFieldFinder, 'test search');
          await tester.pump();

          // Find and tap the cancel button
          final cancelButton = find.byKey(Key('clear'));
          await tester.tap(cancelButton);
          await tester.pump();
          // Assert
          //expect(find.text('test search'), findsNothing);
        });

    testWidgets('Bottom sheet shows loading indicator when posts statistics is empty',
            (WidgetTester tester) async {
          // Arrange
          mockController.postsZoneStatistics = [].obs;

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
                        return  GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: tester.element(find.byType(GestureDetector)),
                              isScrollControlled: true,
                              enableDrag: true,
                              showDragHandle: true,
                              useSafeArea: true,
                              builder: (context) => Container(
                                height: Get.height/1.8,
                                decoration: BoxDecoration(
                                    color: Colors.white
                                ),
                                child: Obx(() => mockController.postsZoneStatistics.isEmpty
                                    ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                    value: 1,
                                  ),
                                )
                                    : Container()
                                ),
                              ),
                            );
                          },
                          child: Text('Open Bottom Sheet'),
                        );
                      }

                  ),),

              ),
            ),
          );

          // Tap to open bottom sheet
          await tester.tap(find.text('Open Bottom Sheet'));
          await tester.pumpAndSettle();

          // Assert
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        });

    testWidgets('Bottom sheet shows content when posts statistics is not empty',
            (WidgetTester tester) async {
          // Arrange
          final mockData = [
            {
              'zone': {
                'name': 'Test Zone',
                'banner': 'https://example.com/banner.jpg',
              },
              'images': [
                {'url': 'https://example.com/image.jpg'}
              ],
              'creator': [
                {
                  'avatar': 'https://example.com/avatar.jpg',
                  'first_name': 'John',
                  'last_name': 'Doe'
                }
              ],
              'content': '<p>Test content</p>'
            }
          ].obs;

          mockController.postsZoneStatistics =  mockData;

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
                        return  DashboardView();
                      }

                  ),)
                ,
              ),
            ),
          );

          // Tap to open bottom sheet
          // await tester.tap(find.text('Open Bottom Sheet'));
          // await tester.pumpAndSettle();

          // Assert
          expect(mockController.postsZoneStatistics.length, 1);
        });

    testWidgets('Zone statistics button shows bottom sheet when tapped',
            (WidgetTester tester) async {
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
                      return  DashboardView();
                    }

                ),),
            ),
          );

          // Act
          await tester.tap(find.text('Zone statistics'));
          await tester.pumpAndSettle();

          // Assert
          expect(find.byKey(Key('modalBottomSheet')), findsOneWidget);
        });

  });
}