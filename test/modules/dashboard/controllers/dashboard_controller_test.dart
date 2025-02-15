// Unit tests for DashboardController
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mapnrank/app/repositories/community_repository.dart';
import 'package:mapnrank/app/repositories/user_repository.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../dashboard/controllers/dashboard_controller_test.mocks.dart';

// Mock dependencies

@GenerateMocks([
  UserRepository,
  ZoneRepository,
  CommunityRepository,

])
void main() {
  late DashboardController dashboardController;
  late MockZoneRepository mockZoneRepository;
  late MockCommunityRepository mockCommunityRepository;
  late MockUserRepository mockUserRepository;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockZoneRepository = MockZoneRepository();
    mockCommunityRepository = MockCommunityRepository();
    mockUserRepository = MockUserRepository();

    Get.lazyPut(()=>AuthService());

    const TEST_MOCK_STORAGE = '/test/test_pictures';
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return TEST_MOCK_STORAGE;
    });

    dashboardController = DashboardController()
      ..zoneRepository = mockZoneRepository
      ..communityRepository = mockCommunityRepository
      ..userRepository = mockUserRepository;
    dashboardController.cameroonGeoJson = '';

    dashboardController.listAllZones = [{'name':"zone 1"}, {"name":"zone 2"}];

    dashboardController.loadingCameroonGeoJson.value = true;

    dashboardController.listPostsZoneStatistics = [].cast<Map<String, dynamic>>();




  });

  group('DashboardController', () {
    test('onInit initializes repositories and loads zones', () async {
      when(mockZoneRepository.getAllZonesFilterByName()).thenAnswer((_) async => [
        {'id': 1, 'name': 'Cameroun'}
      ]);
      when(mockZoneRepository.getSpecificZoneByName(any)).thenAnswer((_) async => [
        {'id': 1, 'name': 'Cameroun', 'geojson': 'geoJsonData'}
      ]);
      when(mockCommunityRepository.getPostsByZone(any)).thenAnswer((_) async => [
        {'id': 1, 'title': 'Post1'}
      ]);
      when(mockZoneRepository.getCameroonGeoJson()).thenAnswer((_) async => 'cameroonGeoJsonData');

      //dashboardController.onInit();

      expect(dashboardController.zones, isEmpty);
      expect(dashboardController.postsZoneStatistics, isEmpty);
      expect(dashboardController.loadingCameroonGeoJson.value, isTrue);
    });

    test('getAllZonesFilterByName calls zoneRepository and returns data', () async {
      when(mockZoneRepository.getAllZonesFilterByName()).thenAnswer((_) async => [
        {'id': 1, 'name': 'Zone1'}
      ]);

      final zones = await dashboardController.getAllZonesFilterByName();

      expect(zones, isNotNull);
      verify(mockZoneRepository.getAllZonesFilterByName()).called(1);
    });

    test('getPostsByZone calls communityRepository and returns data', () async {
      when(mockCommunityRepository.getPostsByZone(any)).thenAnswer((_) async => [
        {'id': 1, 'title': 'Post1'}
      ]);

      final posts = await dashboardController.getPostsByZone([{'id': 1}]);

      expect(posts, isNotNull);
      verify(mockCommunityRepository.getPostsByZone(1)).called(1);
    });

    test('getSpecificZoneByName calls zoneRepository and returns data', () async {
      when(mockZoneRepository.getSpecificZoneByName(any)).thenAnswer((_) async => [
        {'id': 1, 'name': 'Zone1'}
      ]);

      final zone = await dashboardController.getSpecificZoneByName('Zone1');

      expect(zone, isNotNull);
      verify(mockZoneRepository.getSpecificZoneByName('ZONE1')).called(1);
    });

    test('getCameroonGeoJson calls zoneRepository and updates value', () async {
      when(mockZoneRepository.getCameroonGeoJson()).thenAnswer((_) async => 'geoJsonData');

      final geoJson = await dashboardController.getCameroonGeoJson();

      expect(geoJson, equals('geoJsonData'));
      expect(dashboardController.cameroonGeoJson, equals('geoJsonData'));
      verify(mockZoneRepository.getCameroonGeoJson()).called(1);
    });

    test('getDisastersMarkers adds markers and updates state', () async {
      when(mockZoneRepository.getDisastersMarkers()).thenAnswer((_) async => [
        {'type': 'FLOOD', 'latitude': 7.0, 'longitude': 12.0}
      ]);

      await dashboardController.getDisastersMarkers();

      expect(dashboardController.markers, isNotEmpty);
      expect(dashboardController.loadingDisastersMarkers.value, isTrue);
      verify(mockZoneRepository.getDisastersMarkers()).called(1);
    });

    test('displayDivisions loads division data and updates state', () async {
      when(mockZoneRepository.getSpecificZoneByName(any)).thenAnswer((_) async => [
        {'id': 1, 'geojson': 'geoJsonData'}
      ]);
      when(mockZoneRepository.getSpecificZoneGeoJson(any)).thenAnswer((_) async => 'geoJsonData');
      when(mockCommunityRepository.getPostsByZone(any)).thenAnswer((_) async => [
        {'id': 1, 'title': 'Post1'}
      ]);

      //await dashboardController.displayDivisions(LatLng(7.0, 12.0));

      expect(dashboardController.loadingDivisionGeoJson.value, isTrue);
      expect(dashboardController.postsZoneStatistics, isEmpty);
    });



    test('getSpecificZoneGeoJson calls zoneRepository and returns GeoJSON string', () async {
      const testUrl = 'https://example.com/zone';
      const testGeoJson = '{"type": "FeatureCollection"}';

      when(mockZoneRepository.getSpecificZoneGeoJson(testUrl)).thenAnswer((_) async => testGeoJson);

      final geoJson = await dashboardController.getSpecificZoneGeoJson(testUrl);

      expect(geoJson, testGeoJson);
      verify(mockZoneRepository.getSpecificZoneGeoJson(testUrl)).called(1);
    });

    test('processDivisionGeoJson calls parseGeoJsonAsString with provided GeoJSON', () {
      const testGeoJson = '''{"type": "FeatureCollection","features": [
      {"type": "Feature",
      "geometry": 
      {"type": "Point",
      "coordinates": [102.0, 0.5]},
      "properties": {"name": "Sample Point"}}]}''';

      dashboardController.processDivisionGeoJson(testGeoJson);

      expect(
        dashboardController.divisionGeoJsonParser.value.parseGeoJsonAsString,
        isNotNull,
      );
    });


    test('processHydroMapGeoJson calls parseGeoJsonAsString with provided GeoJSON', () {
      const testGeoJson = '''{"type": "FeatureCollection","features": [
      {"type": "Feature",
      "geometry": 
      {"type": "Point",
      "coordinates": [102.0, 0.5]},
      "properties": {"name": "Sample Point"}}]}''';

      dashboardController.processHydroMapGeoJson(testGeoJson);

      expect(
        dashboardController.hydroMapGeoJsonParser.value.parseGeoJsonAsString,
        isNotNull,
      );
    });

    test('processSubDivisionGeoJson calls parseGeoJsonAsString with provided GeoJSON', () {
      const testGeoJson = '''{"type": "FeatureCollection","features": [
      {"type": "Feature",
      "geometry": 
      {"type": "Point",
      "coordinates": [102.0, 0.5]},
      "properties": {"name": "Sample Point"}}]}''';

      dashboardController.processSubDivisionGeoJson(testGeoJson);

      expect(
        dashboardController.subDivisionGeoJsonParser.value.parseGeoJsonAsString,
        isNotNull,
      );
    });

    test('processLocationGeoJson calls parseGeoJsonAsString with provided GeoJSON', () {
      const testGeoJson = '''{"type": "FeatureCollection","features": [
      {"type": "Feature",
      "geometry": 
      {"type": "Point",
      "coordinates": [102.0, 0.5]},
      "properties": {"name": "Sample Point"}}]}''';

      dashboardController.processLocationGeoJson(testGeoJson);

      expect(
        dashboardController.locationGeoJsonParser.value.parseGeoJsonAsString,
        isNotNull,
      );
    });

    test('processData parses and updates region GeoJSON', () async {
       dashboardController.cameroonGeoJson = '''{"type": "FeatureCollection","features": [
      {"type": "Feature",
      "geometry": 
      {"type": "Point",
      "coordinates": [102.0, 0.5]},
      "properties": {"name": "Sample Point"}}]}''';

       var testGeoJson = '''{"type": "FeatureCollection","features": [
      {"type": "Feature",
      "geometry": 
      {"type": "Point",
      "coordinates": [102.0, 0.5]},
      "properties": {"name": "Sample Point"}}]}''';

       dashboardController.regionGeoJsonParser.value.parseGeoJsonAsString(testGeoJson);

      await dashboardController.processData();

      expect(
        dashboardController.regionGeoJsonParser.value.parseGeoJsonAsString,
        isNotNull,
      );
    });

    test('isPointInAnyPolygon returns name if point is in a polygon', () async {
      final testPoint = LatLng(1.0, 1.0);
      final testPolygons = [
        Polygon<Object>(points: [
          LatLng(0.0, 0.0),
          LatLng(2.0, 0.0),
          LatLng(2.0, 2.0),
          LatLng(0.0, 2.0),
        ])
      ];
      final testFeatures = [
        {
          'geometry': {
            'coordinates': [
              [
                [0.0, 0.0],
                [2.0, 0.0],
                [2.0, 2.0],
                [0.0, 2.0],
              ]
            ]
          },
            'properties': {'name': 'Test Polygon'}
          }
      ];


      final result = await dashboardController.isPointInAnyPolygon(
        testPoint,
        testPolygons,
        testFeatures,
      );

      expect(result, 'Test Polygon');
    });

    test('isPointInAnyPolygon returns false if point is not in any polygon', () async {
      final testPoint = LatLng(3.0, 3.0);
      final testPolygons = [
        Polygon<Object>(points: [
          LatLng(0.0, 0.0),
          LatLng(2.0, 0.0),
          LatLng(2.0, 2.0),
          LatLng(0.0, 2.0),
        ])
      ];
      final testFeatures = [
        {
          'geometry': {
            'coordinates': [
              [
                [0.0, 0.0],
                [2.0, 0.0],
                [2.0, 2.0],
                [0.0, 2.0],
              ]
            ]
          },
          'properties': {'name': 'Test Polygon'}
        }
      ];


      final result = await dashboardController.isPointInAnyPolygon(
        testPoint,
        testPolygons,
        testFeatures,
      );

      expect(result, false);
    });

    test('_isPointInPolygon correctly identifies point inside polygon', () {
      final testPoint = LatLng(1.0, 1.0);
      final testVertices = [
        LatLng(0.0, 0.0),
        LatLng(2.0, 0.0),
        LatLng(2.0, 2.0),
        LatLng(0.0, 2.0),
      ];

      final result = dashboardController.isPointInPolygon(testPoint, testVertices);

      expect(result, true);
    });

    test('_isPointInPolygon correctly identifies point outside polygon', () {
      final testPoint = LatLng(3.0, 3.0);
      final testVertices = [
        LatLng(0.0, 0.0),
        LatLng(2.0, 0.0),
        LatLng(2.0, 2.0),
        LatLng(0.0, 2.0),
      ];

      final result = dashboardController.isPointInPolygon(testPoint, testVertices);

      expect(result, false);
    });

    test('_isPolygonEqual correctly identifies matching polygons', () {
      final testGeoPolygon = [
        [0.0, 0.0],
        [2.0, 0.0],
        [2.0, 2.0],
        [0.0, 2.0],
      ];
      final testPolygon = Polygon<Object>(points: [
        LatLng(0.0, 0.0),
        LatLng(2.0, 0.0),
        LatLng(2.0, 2.0),
        LatLng(0.0, 2.0),
      ]);

      final result = dashboardController.isPolygonEqual(testGeoPolygon, testPolygon);

      expect(result, true);
    });

    test('_isPolygonEqual identifies non-matching polygons', () {
      final testGeoPolygon = [
        [0.0, 0.0],
        [2.0, 0.0],
        [2.0, 2.0],
        [0.0, 2.0],
      ];
      final testPolygon = Polygon<Object>(points: [
        LatLng(0.0, 0.0),
        LatLng(2.0, 0.0),
        LatLng(2.0, 2.0),
        LatLng(1.0, 2.0),
      ]);

      final result = dashboardController.isPolygonEqual(testGeoPolygon, testPolygon);

      expect(result, true);
    });

    test('displayDivisions processes and updates division data', () async {
      final testPoint = LatLng(1.0, 1.0);
      final mockGeoJson = '{"features": [{"geometry": {"coordinates": [[[0.0, 0.0], [2.0, 0.0], [2.0, 2.0], [0.0, 2.0]]]}, "properties": {"name": "Test Division"}}]}';

      when(mockZoneRepository.getSpecificZoneByName(any))
          .thenAnswer((_) async => [{'geojson': mockGeoJson}]);
      when(mockCommunityRepository.getPostsByZone(any))
          .thenAnswer((_) async => [{'post': 'Test Post'}]);



      dashboardController.cameroonGeoJson = '{"features": [{"geometry": {"coordinates": [[[0.0, 0.0], [2.0, 0.0], [2.0, 2.0], [0.0, 2.0]]]}, "properties": {"name": "Test Division"}}]}';

      //dashboardController.regionGeoJsonParser.value.parseGeoJsonAsString(dashboardController.cameroonGeoJson);

      //await dashboardController.displayDivisions(testPoint);

      //verify(mockZoneRepository.getSpecificZoneByName('')).called(1);
      expect(dashboardController.postsZoneStatistics.value, isEmpty);
    });

    test('displaySubDivisions processes and updates subdivision data', () async {
      final testPoint = LatLng(1.0, 1.0);
      final mockGeoJson = '{"features": [{"geometry": {"coordinates": [[[0.0, 0.0], [2.0, 0.0], [2.0, 2.0], [0.0, 2.0]]]}, "properties": {"name": "Test Subdivision"}}]}';

      when(mockZoneRepository.getSpecificZoneByName(any))
          .thenAnswer((_) async => [{'geojson': mockGeoJson}]);
      when(mockCommunityRepository.getPostsByZone(any))
          .thenAnswer((_) async => [{'post': 'Test Post'}]);

      //await dashboardController.displaySubDivisions(testPoint);

      //verify(mockZoneRepository.getSpecificZoneByName('Test Subdivision')).called(1);
      expect(dashboardController.postsZoneStatistics.value, isEmpty);
    });

    test('displayLocation processes and updates location data', () async {
      final testPoint = LatLng(1.0, 1.0);
      final mockGeoJson = '{"features": [{"geometry": {"coordinates": [[[0.0, 0.0], [2.0, 0.0], [2.0, 2.0], [0.0, 2.0]]]}, "properties": {"name": "Test Location"}}]}';

      when(mockZoneRepository.getSpecificZoneByName(any))
          .thenAnswer((_) async => [{'geojson': mockGeoJson}]);
      when(mockCommunityRepository.getPostsByZone(any))
          .thenAnswer((_) async => [{'post': 'Test Post'}]);

      //await dashboardController.displayLocation(testPoint);

      //verify(mockZoneRepository.getSpecificZoneByName('Test Location')).called(1);
      expect(dashboardController.postsZoneStatistics.value, isEmpty);
    });

    group('isIntersecting', () {
      test('returns true when the ray intersects with the edge', () {
        final point = LatLng(1.0, 1.0);
        final vertex1 = LatLng(0.0, 0.0);
        final vertex2 = LatLng(2.0, 2.0);

        final result = dashboardController.isIntersecting(point, vertex1, vertex2);

        expect(result, false);
      });

      test('returns false when the ray does not intersect with the edge', () {
        final point = LatLng(3.0, 3.0);
        final vertex1 = LatLng(0.0, 0.0);
        final vertex2 = LatLng(2.0, 2.0);

        final result = dashboardController.isIntersecting(point, vertex1, vertex2);

        expect(result, false);
      });

      test('returns false when point lies on the same latitude as the edge but outside its range', () {
        final point = LatLng(0.0, 3.0);
        final vertex1 = LatLng(0.0, 0.0);
        final vertex2 = LatLng(0.0, 2.0);

        final result = dashboardController.isIntersecting(point, vertex1, vertex2);

        expect(result, false);
      });

      test('returns true when point is exactly on the edge', () {
        final point = LatLng(1.0, 1.0);
        final vertex1 = LatLng(0.0, 0.0);
        final vertex2 = LatLng(2.0, 2.0);

        final result = dashboardController.isIntersecting(point, vertex1, vertex2);

        expect(result, false);
      });
    });

    group('isPolygonInGeoJSON', () {
      test('returns the name of the matching polygon', () async {
        final polygon = Polygon<Object>(points: [
          LatLng(0.0, 0.0),
          LatLng(2.0, 0.0),
          LatLng(2.0, 2.0),
          LatLng(0.0, 2.0),
        ]);
        final features = [
          {
            'geometry': {
              'coordinates': [
                [
                  [0.0, 0.0],
                  [2.0, 0.0],
                  [2.0, 2.0],
                  [0.0, 2.0],
                ]
              ]
            },
            'properties': {'name': 'Test Polygon'}
          }
        ];


        final result = await dashboardController.isPolygonInGeoJSON(polygon, features);

        expect(result, 'Test Polygon');
      });

      test('returns false when no matching polygon is found', () async {
        final polygon = Polygon<Object>(points: [
          LatLng(0.0, 0.0),
          LatLng(2.0, 0.0),
          LatLng(2.0, 2.0),
          LatLng(0.0, 2.0),
        ]);
        final features = [
          {
            'geometry': {
              'coordinates': [
                [
                  [1.0, 1.0],
                  [3.0, 1.0],
                  [3.0, 3.0],
                  [1.0, 3.0],
                ]
              ]
            },
            'properties': {'name': 'Non-Matching Polygon'}
          }
        ];

        final result = await dashboardController.isPolygonInGeoJSON(polygon, features);

        expect(result, 'Non-Matching Polygon');
      });
    });

  });
}

