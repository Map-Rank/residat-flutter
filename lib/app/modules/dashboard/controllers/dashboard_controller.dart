
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../common/ui.dart';
import '../../../models/user_model.dart';
import '../../../repositories/community_repository.dart';
import '../../../repositories/sector_repository.dart';
import '../../../repositories/user_repository.dart';
import '../../../repositories/zone_repository.dart';
import '../../../services/auth_service.dart';
import 'package:latlong2/latlong.dart';

class DashboardController extends GetxController {
  final Rx<UserModel> currentUser = Get
      .find<AuthService>()
      .user;
  var cancelSearchSubDivision = false.obs;
  RxDouble defaultLat = 7.3696495.obs;
  RxDouble defaultLng = 12.3445856.obs;

  RxDouble locationLat = 7.3696495.obs;
  RxDouble locationLng = 12.3445856.obs;
  var  locationName = ''.obs;
  late String cameroonGeoJson;
  late String regionGeoJson;
  late String divisionGeoJson;
  List<Marker> markers = [];

  Rx<GeoJsonParser> hydroMapGeoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.blue,
    defaultPolygonBorderColor: Colors.blue,
    defaultPolygonFillColor: Colors.blue.withOpacity(0.1),
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),
  ).obs;

  Rx<GeoJsonParser> regionGeoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.black,
    defaultPolygonBorderColor: Colors.black,
    defaultPolygonFillColor: Colors.transparent,
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),
  ).obs;

  Rx<GeoJsonParser> divisionGeoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.black,
    defaultPolygonBorderColor: Colors.black,
    defaultPolygonFillColor: Colors.blue.withOpacity(0.2),
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),
  ).obs;

  Rx<GeoJsonParser> subDivisionGeoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.red,
    defaultPolygonBorderColor: Colors.red,
    defaultPolygonFillColor: Colors.blue.withOpacity(0.3),
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),

  ).obs;

  Rx<GeoJsonParser> locationGeoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.red,
    defaultPolygonBorderColor: Colors.orange,
    defaultPolygonFillColor: Colors.orange.withOpacity(0.4),
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),

  ).obs;

  List<Map<String, dynamic>> zones = [];
  List<Map<String, dynamic>> listAllZones = [];

  List<Map<String, dynamic>> listPostsZoneStatistics = [];
  var  postsZoneStatistics = [].obs;

  late UserRepository userRepository;

  late ZoneRepository zoneRepository;

  late SectorRepository sectorRepository;

  late CommunityRepository communityRepository;

  var loadingCameroonGeoJson = true.obs;
  var loadingHydroMapGeoJson = true.obs;
  var loadingDivisionGeoJson = true.obs;
  var loadingSubDivisionGeoJson = true.obs;
  var loadingLocationGeoJson = true.obs;
  var loadingDisastersMarkers = true.obs;

  var loadingCameroonCheckBox = false.obs;
  var loadingHydroMapBox = false.obs;
  var loadingDisastersCheckBox = false.obs;


  LayerHitNotifier hitNotifier = ValueNotifier(null);


  MapController mapController = MapController();

  DashboardController() {

  }

  @override
  void onInit() async {
    userRepository = UserRepository();
    zoneRepository = ZoneRepository();
    sectorRepository = SectorRepository();
    communityRepository = CommunityRepository();

    var listZones = await getAllZonesFilterByName()??[];

    listAllZones = listZones.cast<Map<String, dynamic>>()??[];
    zones = listAllZones;

    var zone = await getSpecificZoneByName("Cameroun");
    var listPosts = await getPostsByZone(zone)??[];

    loadingCameroonCheckBox.value = true;
    await getCameroonGeoJson().then((_) {
        processData();
        loadingCameroonGeoJson.value = true;
      });

    listPostsZoneStatistics = listPosts.cast<Map<String, dynamic>>()??[];
    postsZoneStatistics.value = listPostsZoneStatistics;
    print('PostZone Statistics: $postsZoneStatistics');
    super.onInit();
  }

  Future refreshDashboard({bool showMessage = false}) async {

  }

  getAllZonesFilterByName() async {
    try {
      var result = await zoneRepository.getAllZonesFilterByName();
      print('List of all Zones is: $result');
      return result;
    }
    catch (e) {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
  }

  getPostsByZone(var zone) async {
    try {
      var result = await communityRepository.getPostsByZone(zone[0]['id']);
      return result;
    }
    catch (e) {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
  }
  getSpecificZoneByName(String name) async {
    var zone_name = name;
    locationName.value = name;
    try {
      // if(name.contains("-") && name != 'FAR-NORTH'){
      //   zone_name = name.replaceAll("-", " ");
      // }
      // if(name.contains("-") && name != 'FAR-NORTH'){
      //   zone_name = name.replaceAll("-", " ");
      // }

      var result = await zoneRepository.getSpecificZoneByName(zone_name.toUpperCase());
      return result;
    }
    catch (e) {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
  }

  getDisastersMarkers() async {
    try {
      var result = await zoneRepository.getDisastersMarkers();
      for(var disaster in result){
        if(disaster["type"].toUpperCase()  == "FLOOD"){
          markers.add(Marker(point: LatLng(disaster["latitude"], disaster["longitude"]), child: Icon(Icons.notifications, color: Colors.red,)));
        }

      }
      loadingDisastersMarkers.value = true;
    }
    catch (e) {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
        loadingDisastersMarkers.value = true;
      }
    }
  }


  getCameroonGeoJson() async {
    try {
      loadingCameroonGeoJson.value = false;
      var result = await zoneRepository.getCameroonGeoJson();
      cameroonGeoJson = '''${result}''';

      return cameroonGeoJson;
    }
    catch (e) {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
  }

  getSpecificZoneGeoJson(String url) async {
    try {
      var result = await zoneRepository.getSpecificZoneGeoJson(url)??'';
      var geoJson = '''${result}''';

      return geoJson;
    }
    catch (e) {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
  }

  processDivisionGeoJson(String geoJson){
    divisionGeoJsonParser.value.parseGeoJsonAsString(geoJson);
  }

  processHydroMapGeoJson(String geoJson){
    hydroMapGeoJsonParser.value.parseGeoJsonAsString(geoJson);
  }

  processSubDivisionGeoJson(String geoJson){
    subDivisionGeoJsonParser.value.parseGeoJsonAsString(geoJson);
  }

  processLocationGeoJson(String geoJson){
    locationGeoJsonParser.value.parseGeoJsonAsString(geoJson);
  }

  Future<void> processData() async {
    // parse a small test geoJson
    // normally one would use http to access geojson on web and this is
    // the reason why this function is async.
    regionGeoJsonParser.value.parseGeoJsonAsString(cameroonGeoJson);
  }


  displayDivisions(LatLng point) async {
    print(jsonDecode(cameroonGeoJson)["features"]);
    var name = await isPointInAnyPolygon(point, regionGeoJsonParser.value.polygons, jsonDecode(cameroonGeoJson)["features"]);
    print('Name is: $name');
    var zone = await getSpecificZoneByName(name.toString())??[{'geojson':''}];
    getSpecificZoneGeoJson(zone[0]['geojson']).then((data) {
      regionGeoJson = data??'';
      processDivisionGeoJson(data??'');
      loadingDivisionGeoJson.value = true;
    });

    var listPosts = await getPostsByZone(zone);

    listPostsZoneStatistics = listPosts??[].cast<Map<String, dynamic>>();
    postsZoneStatistics.value = listPostsZoneStatistics;


  }

  displaySubDivisions(LatLng point) async {
    var name = await isPointInAnyPolygon(point, divisionGeoJsonParser.value.polygons, jsonDecode(regionGeoJson)["features"]);
    print('Name is again: $name');
    var zone = await getSpecificZoneByName(name);
    print('zone: $zone');
    if(!zone.isEmpty){
      getSpecificZoneGeoJson(zone[0]['geojson']).then((data) {
        divisionGeoJson = data;
        processSubDivisionGeoJson(data);
        loadingSubDivisionGeoJson.value = true;
      });
    }
    else{
      loadingSubDivisionGeoJson.value = true;
    }
    var listPosts = await getPostsByZone(zone);

    listPostsZoneStatistics = listPosts.cast<Map<String, dynamic>>();
    postsZoneStatistics.value = listPostsZoneStatistics;



  }

  displayLocation(LatLng point) async {
    var name = await isPointInAnyPolygon(point, subDivisionGeoJsonParser.value.polygons, jsonDecode(divisionGeoJson)["features"]);
    print('Name is again: $name');
    var zone = await getSpecificZoneByName(name);
    print('zone: $zone');
    if(!zone.isEmpty){
      getSpecificZoneGeoJson(zone[0]['geojson']).then((data) {
        processLocationGeoJson(data);
        loadingLocationGeoJson.value = true;
      });
    }
    else{
      loadingLocationGeoJson.value = true;
    }
    var listPosts = await getPostsByZone(zone);

    listPostsZoneStatistics = listPosts.cast<Map<String, dynamic>>();
    postsZoneStatistics.value = listPostsZoneStatistics;



  }


   isPointInAnyPolygon(LatLng point, List<Polygon<Object>> polygons, var features) async {
    for (Polygon<Object> polygon in polygons) {
      if (isPointInPolygon(point, polygon.points)) {
        var name = await isPolygonInGeoJSON(polygon,features);
        return name;
      }
    }
    return false;
  }

  bool isPointInPolygon(LatLng point, List<LatLng> vertices) {
    int intersections = 0;
    int vertexCount = vertices.length;

    for (int i = 0; i < vertexCount; i++) {
      LatLng vertex1 = vertices[i];
      LatLng vertex2 = vertices[(i + 1) % vertexCount];

      if (isIntersecting(point, vertex1, vertex2)) {
        intersections++;
      }
    }

    // If the number of intersections is odd, the point is inside the polygon.
    return (intersections % 2) != 0;
  }

  bool isIntersecting(LatLng point, LatLng vertex1, LatLng vertex2) {
    // Check if the ray intersects with the polygon edge.
    bool isIntersecting = ((vertex1.latitude > point.latitude) != (vertex2.latitude > point.latitude)) &&
        (point.longitude < (vertex2.longitude - vertex1.longitude) * (point.latitude - vertex1.latitude) /
            (vertex2.latitude - vertex1.latitude) +
            vertex1.longitude);

    return isIntersecting;
  }


// Function to check if a Polygon matches any polygon in a GeoJSON
   isPolygonInGeoJSON(Polygon<Object> polygon,  var features) async {
    for (var feature in features) {
      //for (var geoPolygon in feature['geometry']['coordinates'][0]) {
        if (isPolygonEqual(feature['geometry']['coordinates'][0], polygon)) {
          var name = feature['properties']['name'];

          return name; // Polygon matches one in GeoJSON
        }
     // }

    }
    return false;
  }

// Helper function to check if two polygons are equal
  bool isPolygonEqual(var geoPolygon, Polygon<Object> polygon) {

    final geoPoints = geoPolygon;

    if (geoPoints.length != polygon.points.length) return false;
    for (int i = 0; i < geoPoints.length; i++) {
      if (geoPoints[i][0] != polygon.points[i].latitude ||
          geoPoints[i][1] != polygon.points[i].longitude) {

      }
    }

    return true;
  }



}










