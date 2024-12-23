import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mapnrank/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mapnrank/app/modules/global_widgets/block_button_widget.dart';
import 'package:mapnrank/app/modules/global_widgets/tool_tip_widget.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mapnrank/app/services/global_services.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../color_constants.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../root/controllers/root_controller.dart';

import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar:
      AppBar(
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.white),
        backgroundColor: Colors.white,
        leadingWidth: 0,
        //toolbarHeight: controller.filterByLocation.value || controller.filterBySector.value?590:190,
        leading: Icon(null),
        centerTitle: true,
        title: Container(
          //margin: EdgeInsets.only(bottom: 20),
            color: Colors.white,
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    Scaffold.of(context).openDrawer();
                  },
                  child: Image.asset(
                      "assets/images/logo.png",
                      width: Get.width/6,
                      height: Get.width/6,
                      fit: BoxFit.fitWidth),
                ).marginOnly(left: 10),
                Container(
                  height: 40,
                  width: Get.width/1.6,
                  decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10)

                  ),
                  child: Autocomplete<Map<String, dynamic>>(
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        onFieldSubmitted: (value) => onFieldSubmitted(),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: AppLocalizations.of(context).search_subdivision,
                            hintStyle: TextStyle(fontSize: 14),
                            prefixIcon: Icon(
                              FontAwesomeIcons.search,
                              color: Colors.grey,
                              size: 15,
                            ),
                            suffixIcon: Obx(() =>
                            controller.cancelSearchSubDivision.value?
                            GestureDetector(
                                onTap: () async {
                                  textEditingController.clear();
                                  controller.mapController.move(
                                      LatLng(controller.defaultLat.value,
                                          controller.defaultLng.value), 6);
                                },
                                child: Icon(FontAwesomeIcons.multiply, color: Colors.grey.shade600, key: Key('clear'),
                                  size: 15,)):Icon(null),
                            )
                        ),
                        onChanged:(value){
                          if(value.length> 0){
                            controller.cancelSearchSubDivision.value = true;
                          }
                          else{
                            controller.cancelSearchSubDivision.value = false;
                          }


                        },
                      );
                    },
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Map<String, dynamic>>.empty();
                      } else {
                        // Replace this with your dynamic list
                        List<Map<String, dynamic>> dynamicList = controller.zones;

                        // Filter the list based on the search query
                        return dynamicList.where((item) {
                          String name = item['name'].toLowerCase();
                          return name.contains(textEditingValue.text.toLowerCase());
                        });
                      }
                    },
                    displayStringForOption: (Map<String, dynamic> option) {
                      // This defines what will be shown in the field when the user selects an option
                      return option['name'];
                    },
                    onSelected: (Map<String, dynamic> selection) async {
                      print('Selection is: $selection');
                      // Handle the selected dynamic object
                      //print('Selected: ${selection['name']}');
                      //controller.noFilter.value = false;
                      //await controller.filterSearchPostsByZone(selection['id']);
                    },
                    optionsViewBuilder: (context, Function(Map<String, dynamic>) onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                title: Text(option['name']),
                                onTap: () {
                                  onSelected(option);
                                  controller.mapController.move(
                                      LatLng(option['latitude'] as double,
                                          option['longitude'] as double), 8);
                                  print(controller.defaultLat.value);
                                  print(controller.defaultLng.value);
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  )


                  ,

                ),
                ClipOval(
                    child: GestureDetector(
                      onTap: () async {
                        //await Get.find<RootController>().changePage(0);
                        Get.lazyPut<ProfileController>(
                              () => ProfileController(),
                        );
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProfileView(), ));

                      },
                      child: FadeInImage(
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                        image:  NetworkImage(controller.currentUser.value!.avatarUrl!, headers: GlobalService.getTokenHeaders()),
                        placeholder: const AssetImage(
                            "assets/images/loading.gif"),
                        imageErrorBuilder:
                            (context, error, stackTrace) {
                          return Image.asset(
                              "assets/images/user_admin.png",
                              width: 40,
                              height: 40,
                              fit: BoxFit.fitWidth);
                        },
                      ),
                    )
                ).marginOnly(right: 10),
              ],
            )
        ),
      ),
      body: Obx(() => Stack(
        children: [
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: LatLng(controller.defaultLat.value, controller.defaultLng.value), // Center the map over London
              initialZoom: 6,
              interactionOptions: const InteractionOptions(
                enableMultiFingerGestureRace: true,
                flags: InteractiveFlag.doubleTapDragZoom |
                InteractiveFlag.doubleTapZoom |
                InteractiveFlag.drag |
                InteractiveFlag.flingAnimation |
                InteractiveFlag.pinchZoom |
                InteractiveFlag.scrollWheelZoom,
              ),



            ),
            children: [
              TileLayer( // Display map tiles from any source
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                userAgentPackageName: 'com.example.app',
                // And many more recommended properties!
              ),
              Obx(() => !controller.loadingCameroonGeoJson.value
                  ? const Center(child: CircularProgressIndicator())
                  : MouseRegion(
                hitTestBehavior: HitTestBehavior.deferToChild,
                cursor: SystemMouseCursors.click, // Use a special cursor to indicate interactivity
                child: GestureDetector(
                    onTap: () async {
                      controller.divisionGeoJsonParser.value.polygons.clear();
                      controller.loadingDivisionGeoJson.value = false;
                      controller.mapController.move(controller.hitNotifier.value!.coordinate, 8);
                      controller.displayDivisions(controller.hitNotifier.value!.coordinate);
                      controller.locationLat.value = controller.hitNotifier.value!.coordinate.latitude;
                      controller.locationLng.value = controller.hitNotifier.value!.coordinate.longitude;
                    },
                    // And/or any other gesture callback
                    child: PolygonLayer(
                      hitNotifier:controller.hitNotifier,
                      polygons: controller.regionGeoJsonParser.value.polygons,
                    )
                ),
              ),),

              Obx(() => controller.defaultLng!=controller.locationLng && controller.defaultLat!=controller.locationLat?MarkerLayer(
                  markers: [Marker(
                      point: LatLng(controller.locationLat.value,
                        controller.locationLng.value,
                      ),
                      width: Get.width/3,
                      child: Obx(() => TooltipWidget(text: controller.locationName.value),),
                      height:40
                  )]):SizedBox(),),


              Obx(() => !controller.loadingHydroMapGeoJson.value
                  ? const Center(child: CircularProgressIndicator())
                  : MouseRegion(
                hitTestBehavior: HitTestBehavior.deferToChild,
                cursor: SystemMouseCursors.click, // Use a special cursor to indicate interactivity
                child: GestureDetector(
                    onTap: () async {
                      controller.mapController.move(controller.hitNotifier.value!.coordinate, 8);
                    },
                    // And/or any other gesture callback
                    child: PolygonLayer(
                      hitNotifier:controller.hitNotifier,
                      polygons: controller.hydroMapGeoJsonParser.value.polygons,
                    )
                ),
              ),),

              Obx(() => !controller.loadingDivisionGeoJson.value
                  ? const Center(child: CircularProgressIndicator())
                  : MouseRegion(
                hitTestBehavior: HitTestBehavior.deferToChild,
                cursor: SystemMouseCursors.click, // Use a special cursor to indicate interactivity
                child:GestureDetector(
                  onTap: () async {

                    controller.locationGeoJsonParser.value.polygons.clear();
                    controller.subDivisionGeoJsonParser.value.polygons.clear();


                    controller.loadingSubDivisionGeoJson.value = false;
                    controller.mapController.move(controller.hitNotifier.value!.coordinate, 9);
                    controller.displaySubDivisions(controller.hitNotifier.value!.coordinate);

                    controller.locationLat.value = controller.hitNotifier.value!.coordinate.latitude;
                    controller.locationLng.value = controller.hitNotifier.value!.coordinate.longitude;

                  },
                  // And/or any other gesture callback
                  child: PolygonLayer(
                    hitNotifier:controller.hitNotifier,
                    polygons: controller.divisionGeoJsonParser.value.polygons,
                  ),
                ),
              ),),


              Obx(() => !controller.loadingSubDivisionGeoJson.value
                  ? const Center(child: CircularProgressIndicator())
                  : MouseRegion(
                hitTestBehavior: HitTestBehavior.deferToChild,
                cursor: SystemMouseCursors.click, // Use a special cursor to indicate interactivity
                child: GestureDetector(
                    onTap: () async {
                      controller.locationGeoJsonParser.value.polygons.clear();



                      controller.loadingLocationGeoJson.value = false;
                      controller.mapController.move(controller.hitNotifier.value!.coordinate, 10);
                      controller.displayLocation(controller.hitNotifier.value!.coordinate);
                      controller.locationLat.value = controller.hitNotifier.value!.coordinate.latitude;
                      controller.locationLng.value = controller.hitNotifier.value!.coordinate.longitude;
                    },
                    // And/or any other gesture callback
                    child: PolygonLayer(
                      hitNotifier:controller.hitNotifier,
                      polygons: controller.subDivisionGeoJsonParser.value.polygons,
                    )
                ),
              ),),

              Obx(() => !controller.loadingLocationGeoJson.value
                  ? const Center(child: CircularProgressIndicator())
                  : MouseRegion(
                hitTestBehavior: HitTestBehavior.deferToChild,
                cursor: SystemMouseCursors.click, // Use a special cursor to indicate interactivity
                child: GestureDetector(
                    onTap: () async {
                      // controller.loadingSubDivisionGeoJson.value = false;
                      // controller.mapController.move(controller.hitNotifier.value!.coordinate, 8);
                      // controller.displaySubDivisions(controller.hitNotifier.value!.coordinate);
                    },
                    // And/or any other gesture callback
                    child: PolygonLayer(
                      hitNotifier:controller.hitNotifier,
                      polygons: controller.locationGeoJsonParser.value.polygons,
                    )
                ),
              ),),



              Obx(() => !controller.loadingDisastersMarkers.value
                  ? const Center(child: CircularProgressIndicator())
                  : MouseRegion(
                hitTestBehavior: HitTestBehavior.deferToChild,
                cursor: SystemMouseCursors.click, // Use a special cursor to indicate interactivity
                child: GestureDetector(
                    onTap: () async {
                      //Nothing to add concerning disasters markers yet

                    },
                    // And/or any other gesture callback
                    child: MarkerLayer(markers: controller.markers )

                ),
              ),),


              RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirments
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
                  ),
                  // Also add images...
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            child: Row(
              children: [
                GestureDetector(
                  key: Key('modalBottomSheet'),
                  onTap: (){
                    showModalBottomSheet(
                      context: context,
                        isScrollControlled: true,
                        enableDrag: true,
                        showDragHandle: true,
                        useSafeArea: true,
                        //backgroundColor:Colors.transparent,
                        builder: (context) => Container(
                          height: Get.height/1.65,
                          decoration: BoxDecoration(
                            color: Colors.white
                          ),
                          child: Obx(() => controller.postsZoneStatistics.isEmpty?
                          Center(
                            child: CircularProgressIndicator(
                              color: interfaceColor,
                              value: 1,
                            ),
                          ):
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(20),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                      ),
                                      child:FadeInImage(
                                        width: Get.width,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        image: NetworkImage('${controller.postsZoneStatistics[0]['zone']['banner']}',
                                            headers: GlobalService.getTokenHeaders()
                                        ),
                                        placeholder: const AssetImage(
                                          "assets/images/loading.gif",
                                        ),
                                        imageErrorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                              "assets/images/loading.gif",
                                              width: Get.width,
                                              height: 120,
                                              fit: BoxFit.fitWidth);
                                        },
                                      ) ,
                                    ),
                                    Positioned(
                                        bottom: 20,
                                        left: 10,
                                        child: Text(controller.postsZoneStatistics[0]['zone']['name'], style: TextStyle(fontSize: 16),)
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(bottom: 20,left: 20, top: 20),
                                margin: EdgeInsets.only(left: 20),
                                height:Get.height/3,
                                decoration: BoxDecoration(
                                    color: backgroundColor
                                ),
                                child: Obx(() => ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.postsZoneStatistics.length,
                                  itemBuilder: (context, index) =>
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: Stack(
                                            children: [
                                              FadeInImage(
                                                width: Get.width,
                                                height: 200,
                                                fit: BoxFit.cover,
                                                image: NetworkImage('${controller.postsZoneStatistics[index]['images'][0]['url']}',
                                                    headers: GlobalService.getTokenHeaders()
                                                ),
                                                placeholder: const AssetImage(
                                                  "assets/images/loading.gif",),
                                                imageErrorBuilder:
                                                    (context, error, stackTrace) {
                                                  return Image.asset(
                                                      "assets/images/loading.gif",
                                                      width: Get.width,
                                                      height: 200,
                                                      fit: BoxFit.fitHeight);
                                                },
                                              ),
                                              Positioned(
                                                  top: Get.height/6,
                                                  child: Container(
                                                    width: Get.width,
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                      color: Colors.white,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            ClipOval(
                                                                child: FadeInImage(
                                                                  width: 40,
                                                                  height: 40,
                                                                  fit: BoxFit.cover,
                                                                  image:  NetworkImage(controller.postsZoneStatistics[index]['creator'][0]['avatar'], headers: GlobalService.getTokenHeaders()),
                                                                  placeholder: const AssetImage(
                                                                      "assets/images/loading.gif"),
                                                                  imageErrorBuilder:
                                                                      (context, error, stackTrace) {
                                                                    return Image.asset(
                                                                        "assets/images/loading.gif",
                                                                        width: 40,
                                                                        height: 40,
                                                                        fit: BoxFit.cover);
                                                                  },
                                                                )
                                                            ),
                                                            const SizedBox(width: 5,),
                                                            Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('${controller.postsZoneStatistics[index]['creator'][0]['first_name'][0].toUpperCase()}${controller.postsZoneStatistics[index]['creator'][0]['first_name'].substring(1).toLowerCase()} ${controller.postsZoneStatistics[index]['creator'][0]['last_name'][0].toUpperCase()}${controller.postsZoneStatistics[index]['creator'][0]['last_name'].substring(1).toLowerCase()}',
                                                                    //overflow:TextOverflow.ellipsis ,
                                                                    style: Get.textTheme.titleSmall),
                                                                Container(
                                                                    padding: EdgeInsets.all(5),
                                                                    decoration: BoxDecoration(
                                                                        color: secondaryColor,
                                                                        borderRadius: BorderRadius.circular(10)
                                                                    ),
                                                                    child: Text('RECENT', style: TextStyle(color: Colors.white),)

                                                                )
                                                              ],
                                                            )


                                                          ],


                                                        ).marginOnly(bottom: 10),

                                                        Text(controller.postsZoneStatistics[index]['content'].replaceAllMapped(RegExp(r'<p>|<\/p>'), (match) {
                                                          return match.group(0) == '</p>' ? '\n' : ''; // Replace </p> with \n and remove <p>
                                                        })
                                                            .replaceAll(RegExp(r'^\s*\n', multiLine: false), ''), overflow: TextOverflow.ellipsis,),

                                                      ],
                                                    ),

                                                  ))
                                            ],
                                          )
                                      ).marginOnly(right: 20),),),
                              ),

                            ],
                          ),)
                        ),
                    );

                  },
                  child: Container(
                    width: Get.width/3,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: interfaceColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Zone statistics', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
                  ),
                ).marginSymmetric(vertical: 10, horizontal: 10),
                GestureDetector(
                  onTap: (){
                    showDialog(context: context,
                      builder: (context) => Dialog(
                        shape: Border.symmetric(vertical: BorderSide.none, horizontal: BorderSide.none),
                       backgroundColor: Colors.white,
                        insetPadding: EdgeInsets.fromLTRB(10, (Get.height/2),10, Get.height/6),
                        child:  Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Layers"),
                            Row(
                              children: [
                               Obx(() =>  Checkbox(value: controller.loadingCameroonCheckBox.value,
                                 onChanged: (value) {
                                   controller.loadingCameroonCheckBox.value = value!;
                                   if(controller.loadingCameroonCheckBox.value){
                                     controller.getCameroonGeoJson().then((_) {
                                       controller.processData();
                                       controller.loadingCameroonGeoJson.value = true;
                                     });
                                   }
                                   else{
                                     controller.loadingCameroonGeoJson.value = false;
                                     controller.loadingDivisionGeoJson.value = false;
                                     controller.loadingSubDivisionGeoJson.value = false;
                                     controller.loadingLocationGeoJson.value = false;
                                     controller.regionGeoJsonParser.value.polygons.clear();
                                     controller.divisionGeoJsonParser.value.polygons.clear();
                                     controller.subDivisionGeoJsonParser.value.polygons.clear();
                                     controller.locationGeoJsonParser.value.polygons.clear();
                                     controller.loadingCameroonGeoJson.value = true;
                                     controller.loadingDivisionGeoJson.value = true;
                                     controller.loadingSubDivisionGeoJson.value = true;
                                     controller.loadingLocationGeoJson.value = true;
                                     controller.mapController.move(LatLng(controller.defaultLat.value, controller.defaultLng.value), 6);
                                   }

                                 },
                               ),),
                                Text('Cameroon'),
                              ],
                            ),

                            Row(
                              children: [
                                Obx(() => Checkbox(value: controller.loadingHydroMapBox.value,
                                  onChanged: (value) {
                                    controller.loadingHydroMapBox.value = value!;
                                    if(controller.loadingHydroMapBox.value){
                                      controller.loadingHydroMapGeoJson.value = false;
                                      controller.getSpecificZoneGeoJson(GlobalService.hydroMapUrl).then((data) {
                                        controller.processHydroMapGeoJson(jsonDecode(data));
                                        controller.loadingHydroMapGeoJson.value = true;
                                      });
                                    }
                                    else{
                                      controller.loadingHydroMapGeoJson.value = false;
                                      controller.hydroMapGeoJsonParser.value.polygons.clear();
                                      controller.loadingHydroMapGeoJson.value = true;
                                    }

                                  },
                                ),),
                                Text('Hydro Polygon Map'),
                              ],
                            ),

                            Row(
                              children: [
                                Obx(() => Checkbox(value: controller.loadingDisastersCheckBox.value,
                                  onChanged: (value) {
                                    controller.loadingDisastersCheckBox.value = value!;
                                  if(controller.loadingDisastersCheckBox.value){
                                    controller.loadingDisastersMarkers.value = false;
                                    controller.getDisastersMarkers();
                                  }
                                  else{
                                    controller.loadingDisastersMarkers.value = false;
                                    controller.markers.clear();
                                    controller.loadingDisastersMarkers.value = true;
                                  }

                                  },
                                ),),
                                Text('Disasters Markers'),
                              ],
                            ),

                          ],
                        ).paddingAll(10) ,
                      ).marginOnly(left: Get.width/2.8, ),
                    );

                  },
                  child: Container(
                    width: Get.width/3,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: interfaceColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Layers', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
                  ),
                )

              ],
            ),
          )

        ],
      ),),
      //     controller: controller.webViewController)

    );
  }
}

