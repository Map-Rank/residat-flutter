
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../color_constants.dart';
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
  var disaster;

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
  var loadingADisasterMarker = false.obs;

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
    communityRepository = CommunityRepository();

    var listZones = await getAllZonesFilterByName()??[];

    listAllZones = listZones.cast<Map<String, dynamic>>()??[];
    zones = listAllZones;

    var listPosts = await getPostsByZone("cameroon")??[];



    await getDisastersMarkers().then((_){
        loadingDisastersMarkers.value = true;
    });
    loadingDisastersCheckBox.value = true;

    await getCameroonGeoJson().then((_) {
        processData();
        loadingCameroonGeoJson.value = true;
      });
    loadingCameroonCheckBox.value = true;

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
    var result;
    try {
      if(zone == 'cameroon'){
         result = await communityRepository.getPostsByZone(1);
      }
      else{
        result = await communityRepository.getPostsByZone(zone[0]['id']);
      }

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
          markers.add(Marker(point: LatLng(disaster["latitude"], disaster["longitude"]), child: graphDropDown(Get.context!, disaster)));
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

  getADisasterMarker(int id) async {
    try {
      loadingADisasterMarker.value = true;
      var result = await zoneRepository.getADisasterMarker(id);
      disaster = result;
      print(disaster);

      loadingADisasterMarker.value = false;
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


  // coverage:ignore-start
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
  // coverage:ignore-end


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


  Widget  graphDropDown(BuildContext context, var disaster){
    return GestureDetector(
      onTap: () async {
        print('Disaster is : ${disaster}');
        getADisasterMarker(disaster['id']);
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            enableDrag: true,
            //showDragHandle: true,
            constraints: BoxConstraints(minHeight: 400),
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            //backgroundColor:Colors.transparent,
            builder: (context) =>
                DraggableScrollableSheet(
                  initialChildSize: 0.5, // Starts at 30% of screen height
                  minChildSize: 0.5, // Minimum 30% height
                  maxChildSize: 0.9, // Can expand up to 90% of screen
                  //expand: true,
                  builder: (context, scrollController) {
                    return Container(
                      //height: Get.height/1.65,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))

                      ),
                      child:
                      Obx(() => loadingADisasterMarker.value?
                      Center(
                        child: CircularProgressIndicator(
                          color: interfaceColor,
                        ),
                      ):
                      ListView(
                        controller: scrollController,
                        children:[

                          Divider(color: Colors.black, height: 4,thickness: 2,).paddingSymmetric(horizontal:Get.width/2.2, vertical: 20),

                          Align(
                            alignment: Alignment.center,
                              child: Text(disaster['locality'], style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, wordSpacing: 0.5),)).marginOnly(bottom: 40, top: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                            Container(
                              height: 20,
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black,  width: 2),
                                color: Colors.blueGrey.shade100
                              ),
                            ),
                              SizedBox(width: 20,),
                              Text('Water risk level', style: TextStyle(fontSize: 18, color: Colors.black54),)
                          ],).marginOnly(bottom: 10),

                          Container(
                            height: 300,
                            child:Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Stack(
                                children: [
                                  // Background Color Bands for Risk Levels
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue[200]!,
                                          Colors.blue[300]!,
                                          Colors.blue[100]!,
                                          Colors.orange[100]!,
                                          Colors.orange[200]!,
                                        ],
                                        stops: [0.1, 0.3, 0.5, 0.7, 1.0],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                  // Line Chart
                                  LineChart(
                                    LineChartData(
                                      titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              //reservedSize: 100,
                                              showTitles: false,
                                              interval: 1,
                                              getTitlesWidget: (value, meta) {
                                                switch (value.toInt()) {
                                                  case 0:
                                                    return Text('Very low');
                                                  case 1:
                                                    return Text('Low');
                                                  case 2:
                                                    return Text('Normal (dry season)');
                                                  case 3:
                                                    return Text('Normal (rainy season)');
                                                  case 4:
                                                    return Text('high');
                                                  default:
                                                    return Text('very high');
                                                }
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              getTitlesWidget: (value, meta) {
                                                switch (value.toInt()) {
                                                  case 0:
                                                    return Text('Feb 11');
                                                  case 1:
                                                    return Text('Feb 12');
                                                  case 2:
                                                    return Text('Feb 13');
                                                  case 3:
                                                    return Text('Feb 14');
                                                  case 4:
                                                    return Text('Feb 15');
                                                  default:
                                                    return Text('');
                                                }
                                              },
                                            ),
                                          ),
                                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))
                                      ),
                                      gridData: FlGridData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          isCurved: false,
                                          color: Colors.black,
                                          barWidth: 3,
                                          spots: [
                                            FlSpot(0, 3), // Feb 11
                                            FlSpot(1, 4), // Feb 12
                                            FlSpot(2, 1), // Feb 13
                                            FlSpot(3, 3), // Feb 14
                                            FlSpot(4, 5), // Feb 15
                                          ],
                                          belowBarData: BarAreaData(show: false),
                                        ),
                                      ],
                                      lineTouchData: LineTouchData(enabled: false),
                                      minY: 0,
                                      maxY: 5,
                                      borderData: FlBorderData(show: false),
                                      backgroundColor: Colors.transparent,
                                      extraLinesData: ExtraLinesData(
                                        verticalLines: [
                                          VerticalLine(
                                            x: 1,
                                            color: Colors.blue,
                                            strokeWidth: 2,
                                            dashArray: [5, 5],
                                          ),

                                        ],
                                        horizontalLines: [
                                          HorizontalLine(
                                            y: 2.5, // Middle Line
                                            color: Colors.green,
                                            strokeWidth: 2,
                                            //dashArray: [10, 5],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Label for Flood Risk
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'flood risk',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  // Label for Drought Risk
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'drought risk',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Checkbox(value: false, onChanged: (bool? value) {}),
                                Text('Current', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children: [
                                Checkbox(value: false, onChanged: (bool? value) {}),
                                Text('1 month ago', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children: [
                                Checkbox(value: false, onChanged: (bool? value) {}),
                                Text('1 year ago', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children: [
                                Checkbox(value: false, onChanged: (bool? value) {}),
                                Text(' 5 Years ago', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                          RichText(
                            text: TextSpan(
                              text: 'Current Water Level: ',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: 'High Water',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),

                          // Projection
                          Text(
                            'Projection:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),

                          // Description
                          RichText(
                            text: TextSpan(
                              text: 'Description: ',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: 'Area experiencing high riverine flood threat. Gauge levels very high with surface water bodies at maximum. Stable water availability for household and agriculture.',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),

                          // More Information Link
                          Text(
                            'For more information click here',
                            style: TextStyle(color: Colors.grey[700], decoration: TextDecoration.underline),
                          ),
                          SizedBox(height: 10),

                          // Simulation Button
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Text('similulation'),
                          ),
                    ])
                    )
                    );
                  },

        )


        );
      },
      child: Icon(Icons.notifications, color: Color(0xff0004fd),),
    );
  }


}












