import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/events/controllers/events_controller.dart';
import 'package:mapnrank/app/modules/global_widgets/location_widget.dart';
import 'package:mapnrank/app/modules/global_widgets/text_field_widget.dart';
import 'package:mapnrank/common/ui.dart';
import '../../../../color_constants.dart';
import '../../../services/global_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BuildSelectZone extends GetView<CommunityController> {
  BuildSelectZone({Key? key,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    Get.lazyPut(()=>EventsController());
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(AppLocalizations.of(context).select_a_region),
            GestureDetector(
              onTap: (){
                showDialog(context: context,
                  builder:  (context) => Dialog(
                    key: Key('regionDialog'),
                      insetPadding: EdgeInsets.all(20),
                      child:  ListView(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        children: [
                          Text(AppLocalizations.of(context).choose_your_region,
                            style: Get.textTheme.bodyMedium?.merge(const TextStyle(color: labelColor)),
                            textAlign: TextAlign.start,
                          ),

                          Obx(() =>
                              Column(
                                children: [
                                  TextFieldWidget(
                                    readOnly: false,
                                    keyboardType: TextInputType.text,
                                    validator: (input) => input!.isEmpty ? AppLocalizations.of(context).required_field : null,
                                    //onChanged: (input) => controller.selectUser.value = input,
                                    //labelText: "Research receiver".tr,
                                    iconData: FontAwesomeIcons.search,
                                    style: const TextStyle(color: labelColor),
                                    hintText: AppLocalizations.of(context).search_region_name,
                                    onChanged: (value)=>{
                                      controller.filterSearchRegions(value)
                                    },
                                    errorText: '', suffixIcon: const Icon(null), suffix: const Icon(null),
                                  ),
                                  controller.loadingRegions.value ?
                                  Column(
                                    children: [
                                      for(var i=0; i < 4; i++)...[
                                        Container(
                                            width: Get.width,
                                            height: 60,
                                            margin: const EdgeInsets.all(5),
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              child: Image.asset(
                                                'assets/images/loading.gif',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 40,
                                              ),
                                            ))
                                      ]
                                    ],
                                  ) :
                                  Container(
                                      margin: const EdgeInsetsDirectional.only(end: 10, start: 10),
                                      // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                                        ],
                                      ),

                                      child: ListView.builder(
                                        //physics: AlwaysScrollableScrollPhysics(),
                                          itemCount: controller.regions.length,
                                          shrinkWrap: true,
                                          primary: false,
                                          itemBuilder: (context, index) {

                                            return GestureDetector(
                                              // coverage:ignore-start
                                                onTap: () async {
                                                  controller.regionSelected.value = !controller.regionSelected.value;
                                                  controller.regionSelectedIndex.value = index;
                                                  if(controller.regionSelectedValue.contains(controller.regions[index]) ){
                                                    if(controller.noFilter.value){
                                                      controller.regionSelectedValue.remove(controller.regions[index]);
                                                      controller.chooseARegion.value = false;
                                                      controller.regionSelectedValue.clear();


                                                    }
                                                    else{
                                                      controller.regionSelectedValue.remove(controller.regions[index]);
                                                      controller.regionSelectedValue.clear();
                                                      controller.filterSearchPostsByZone(controller.regions[index]['id']);
                                                      controller.chooseARegion.value = false;
                                                      controller.loadingPosts.value = true;
                                                      controller.listAllPosts = await controller.getAllPosts(0);
                                                      controller.allPosts.value = controller.listAllPosts;

                                                    }

                                                  }
                                                  else{

                                                    if(controller.noFilter.value){
                                                      controller.regionSelectedValue.clear();
                                                      controller.post?.zonePostId = controller.regions[index]['id'];
                                                      controller.regionSelectedValue.add(controller.regions[index]);

                                                    }
                                                    else{
                                                      controller.regionSelectedValue.clear();
                                                      controller.post?.zonePostId = controller.regions[index]['id'];
                                                      controller.regionSelectedValue.add(controller.regions[index]);
                                                      controller.filterSearchPostsByZone(controller.regions[index]['id']);
                                                      //controller.filterSearchPostsByRegionZone(controller.regions[index]['id'].toString());
                                                      //controller.post?.sectors?.remove(controller.sectors[index]['id']);
                                                    }



                                                  }

                                                  controller.divisionsSet = await controller.getAllDivisions(index);
                                                  controller.listDivisions.value =  controller.divisionsSet['data'];
                                                  controller.loadingDivisions.value = ! controller.divisionsSet['status'];
                                                  controller.divisions.value =  controller.listDivisions;

                                                  Navigator.of(context).pop();


                                                },
                                                // coverage:ignore-end
                                                child: Obx(() => LocationWidget(
                                                  regionName: controller.regions[index]['name'],
                                                  selected: controller.regionSelectedIndex.value == index && controller.regionSelectedValue.contains(controller.regions[index]) ? true  : false ,
                                                ))
                                            );
                                          })
                                  )
                                ],
                              ),
                          ).marginOnly(bottom: 20),
                        ],
                      )
                  )
                  ,);
              },
              child: Container(
                key: Key('chooseRegion'),
                decoration: BoxDecoration(shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Get.theme.focusColor.withOpacity(0.5))),
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(() => controller.regionSelectedValue.isNotEmpty?
                    Text(controller.regionSelectedValue[0]['name'], style: Get.textTheme.headlineMedium,)
                        :Text(AppLocalizations.of(context).choose_your_region, style: Get.theme.textTheme.headlineMedium!.merge(TextStyle(color: Colors.grey, fontSize: 18),)),
                    ),
                    FaIcon(FontAwesomeIcons.angleDown, size: 10,)
                  ],
                ),
              ),

            ),
          ],
        ).marginOnly(bottom: 20, top: 20, left: 10, right: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).select_a_division),
            GestureDetector(
              onTap: (){
                controller.chooseADivision.value = true;
                if(controller.regionSelectedValue.isEmpty) {
                  Get.showSnackbar(Ui.warningSnackBar(message: AppLocalizations.of(context).select_region_first));
                }
                else{
                  showDialog(context: context, builder: (context) => Dialog(
                    key: Key('divisionDialog'),
                    insetPadding: EdgeInsets.all(20),
                    child: ListView(
                      padding: EdgeInsets.all(20),
                      children: [
                        Text(AppLocalizations.of(context).choose_your_subdivision,
                          style: Get.textTheme.bodyMedium?.merge(const TextStyle(color: labelColor)),
                          textAlign: TextAlign.start,
                        ),

                        Obx(() =>
                            Column(
                              children: [
                                TextFieldWidget(
                                  readOnly: false,
                                  keyboardType: TextInputType.text,
                                  validator: (input) => input!.isEmpty ? AppLocalizations.of(context).required_field : null,
                                  //onChanged: (input) => controller.selectUser.value = input,
                                  //labelText: "Research receiver".tr,
                                  iconData: FontAwesomeIcons.search,
                                  style: const TextStyle(color: labelColor),
                                  hintText: AppLocalizations.of(context).search_division_name,
                                  onChanged: (value)=>{
                                    controller.filterSearchDivisions(value)
                                  },
                                  errorText: '', suffixIcon: const Icon(null), suffix: const Icon(null),
                                ),
                                controller.loadingDivisions.value ?
                                Column(
                                  children: [
                                    for(var i=0; i < 4; i++)...[
                                      Container(
                                          width: Get.width,
                                          height: 60,
                                          margin: const EdgeInsets.all(5),
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            child: Image.asset(
                                              'assets/images/loading.gif',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 40,
                                            ),
                                          ))
                                    ]
                                  ],
                                ) :
                                Container(
                                    margin: const EdgeInsetsDirectional.only(end: 10, start: 10, bottom: 10),
                                    // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                                      ],
                                    ),

                                    child: ListView.builder(
                                      //physics: AlwaysScrollableScrollPhysics(),
                                        itemCount: controller.divisions.length,
                                        shrinkWrap: true,
                                        primary: false,
                                        itemBuilder: (context, index) {

                                          return GestureDetector(
                                            // coverage:ignore-start
                                              onTap: () async{
                                                controller.divisionSelected.value = !controller.divisionSelected.value;
                                                controller.divisionSelectedIndex.value = index;
                                                if(controller.divisionSelectedValue.contains(controller.divisions[index]) ){
                                                  if(controller.noFilter.value){
                                                    controller.divisionSelectedValue.remove(controller.divisions[index]);
                                                    controller.divisionSelectedValue.clear();
                                                    controller.chooseADivision.value = false;

                                                  }
                                                  else{
                                                    controller.divisionSelectedValue.remove(controller.divisions[index]);
                                                    controller.divisionSelectedValue.clear();
                                                    controller.chooseADivision.value = false;
                                                    //controller.post?.sectors?.remove(controller.sectors[index]['id']);
                                                    //controller.filterSearchPostsByDivisionZone(controller.divisions[index]['id'].toString());
                                                    await controller.filterSearchPostsByZone(controller.regionSelectedValue[0]['id']);

                                                  }


                                                }
                                                else{

                                                  if(controller.noFilter.value){
                                                    controller.divisionSelectedValue.clear();
                                                    controller.post?.zonePostId = controller.divisions[index]['id'];
                                                    controller.divisionSelectedValue.add(controller.divisions[index]);
                                                  }
                                                  else{
                                                    controller.divisionSelectedValue.clear();
                                                    controller.divisionSelectedValue.add(controller.divisions[index]);
                                                    await controller.filterSearchPostsByZone(controller.divisions[index]['id']);
                                                    //controller.filterSearchPostsByDivisionZone(controller.divisions[index]['id'].toString());
                                                  }
                                                }





                                                controller.subdivisionsSet = await controller.getAllSubdivisions(index);
                                                controller.listSubdivisions.value = controller.subdivisionsSet['data'];
                                                controller.loadingSubdivisions.value = !controller.subdivisionsSet['status'];
                                                controller.subdivisions.value = controller.listSubdivisions;

                                                Navigator.of(context).pop();
                                                //print(controller.subdivisionSelectedValue[0]['id'].toString());

                                              },
                                              // coverage:ignore-end
                                              child: Obx(() => LocationWidget(
                                                regionName: controller.divisions[index]['name'],
                                                selected: controller.divisionSelectedIndex.value == index && controller.divisionSelectedValue.contains(controller.divisions[index]) ? true  : false ,
                                              ))
                                          );
                                        })
                                )
                              ],
                            ),
                        ).marginOnly(bottom: 20),
                      ],
                    ) ,
                  ),);
                }
              },
              child:  Container(
                key: Key('chooseDivision'),
                decoration: BoxDecoration(shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Get.theme.focusColor.withOpacity(0.5))),
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(() => controller.divisionSelectedValue.isNotEmpty?
                    Text(controller.divisionSelectedValue[0]['name'], style: Get.textTheme.headlineMedium,):
                    Text(AppLocalizations.of(context).choose_your_division, style: Get.theme.textTheme.headlineMedium!.merge(TextStyle(color: Colors.grey, fontSize: 18),))),

                    FaIcon(FontAwesomeIcons.angleDown, size: 10,)
                  ],
                ),
              ),
            ),
          ],
        ).marginOnly(bottom: 20, left: 10, right: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).select_a_subdivision),
            GestureDetector(
              onTap: (){
                controller.chooseASubDivision.value = true;
                if(controller.regionSelectedValue.isEmpty) {
                  Get.showSnackbar(Ui.warningSnackBar(message: AppLocalizations.of(context).select_region_division_first));
                }
                else if(controller.divisionSelectedValue.isEmpty) {
                  Get.showSnackbar(Ui.warningSnackBar(message: AppLocalizations.of(context).select_division_first));
                }
                else{
                  showDialog(context: context, builder: (context) => Dialog(
                    key: Key('subdivisionDialog'),
                    insetPadding: EdgeInsets.all(20),
                    child: ListView(
                      padding: EdgeInsets.all(20),
                      children: [
                        Text(AppLocalizations.of(context).choose_your_subdivision,
                          style: Get.textTheme.bodyMedium?.merge(const TextStyle(color: labelColor)),
                          textAlign: TextAlign.start,
                        ),
                        Obx(() =>
                            Column(
                              children: [
                                TextFieldWidget(
                                  readOnly: false,
                                  keyboardType: TextInputType.text,
                                  validator: (input) => input!.isEmpty ? AppLocalizations.of(context).required_field : null,
                                  //onChanged: (input) => controller.selectUser.value = input,
                                  //labelText: "Research receiver".tr,
                                  iconData: FontAwesomeIcons.search,
                                  style: const TextStyle(color: labelColor),
                                  hintText: AppLocalizations.of(context).search_subdivision_name,
                                  onChanged: (value)=>{
                                    controller.filterSearchSubdivisions(value)
                                  },
                                  errorText: '', suffixIcon: const Icon(null), suffix: const Icon(null),
                                ),
                                controller.loadingSubdivisions.value  ?
                                Column(
                                  children: [
                                    for(var i=0; i < 4; i++)...[
                                      Container(
                                          width: Get.width,
                                          height: 60,
                                          margin: const EdgeInsets.all(5),
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            child: Image.asset(
                                              'assets/images/loading.gif',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 40,
                                            ),
                                          ))
                                    ]
                                  ],
                                ) :
                                Container(
                                    margin: const EdgeInsetsDirectional.only(end: 10, start: 10, bottom: 10),
                                    // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                                      ],
                                    ),

                                    child: ListView.builder(
                                      //physics: AlwaysScrollableScrollPhysics(),
                                        itemCount: controller.subdivisions.length,
                                        shrinkWrap: true,
                                        primary: false,
                                        itemBuilder: (context, index) {

                                          return GestureDetector(
                                              onTap: () async {
                                                // coverage:ignore-start
                                                controller.subdivisionSelected.value = !controller.subdivisionSelected.value;
                                                controller.subdivisionSelectedIndex.value = index;

                                                if(controller.subdivisionSelectedValue.contains(controller.subdivisions[index]) ){



                                                  if(controller.noFilter.value){
                                                    controller.subdivisionSelectedValue.clear();
                                                    controller.subdivisionSelectedValue.remove(controller.subdivisions[index]);
                                                    controller.chooseASubDivision.value = false;
                                                  }
                                                  else{
                                                    controller.subdivisionSelectedValue.clear();
                                                    controller.subdivisionSelectedValue.remove(controller.subdivisions[index]);
                                                    controller.chooseASubDivision.value = false;
                                                    await controller.filterSearchPostsByZone(controller.divisionSelectedValue[0]['id']);
                                                    //controller.filterSearchPostsBySubdivisionZone(controller.subdivisions[index]['id'].toString());

                                                  }
                                                }
                                                else{
                                                  if(controller.noFilter.value){
                                                    controller.subdivisionSelectedValue.clear();
                                                    controller.subdivisionSelectedValue.add(controller.subdivisions[index]);
                                                    controller.post?.zonePostId = controller.subdivisions[index]['id'];
                                                  }
                                                  else{
                                                    controller.subdivisionSelectedValue.clear();
                                                    controller.subdivisionSelectedValue.add(controller.subdivisions[index]);
                                                    //controller.post?.zonePostId = controller.subdivisions[index]['id'];
                                                    //controller.filterSearchPostsBySubdivisionZone(controller.subdivisions[index]['id'].toString());
                                                    await controller.filterSearchPostsByZone(controller.subdivisions[index]['id']);
                                                  }


                                                }

                                                Navigator.of(context).pop();


                                                print(controller.subdivisions);
                                                // coverage:ignore-end

                                              },
                                              child: Obx(() => LocationWidget(
                                                key: Key('tapSubdivision'),
                                                regionName: controller.subdivisions[index]['name'],
                                                selected: controller.subdivisionSelectedIndex.value == index && controller.subdivisionSelectedValue.contains(controller.subdivisions[index]) ? true  : false ,
                                              ))
                                          );
                                        })
                                )
                              ],
                            ),
                        ).marginOnly(bottom: 20),
                      ],
                    ),
                  ),);
                }
              },
              child:Container(
                key: Key('chooseSubdivision'),
                decoration: BoxDecoration(shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Get.theme.focusColor.withOpacity(0.5))),
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(() => controller.subdivisionSelectedValue.isEmpty?
                    Text(AppLocalizations.of(context).choose_your_subdivision, style: Get.theme.textTheme.headlineMedium!.merge(TextStyle(color: Colors.grey, fontSize: 18))):
                    Text(controller.subdivisionSelectedValue[0]['name'], style: Get.theme.textTheme.headlineMedium,),)
                    ,
                    FaIcon(FontAwesomeIcons.angleDown, size: 10,)
                  ],
                ),
              ),
            ),
          ],
        ).marginOnly(bottom: 20, left: 10, right: 10),


      ],
    );
  }
}