import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/events/controllers/events_controller.dart';
import 'package:mapnrank/app/modules/events/widgets/buildSelectSector.dart';
import 'package:mapnrank/app/modules/events/widgets/buildSelectZone.dart';
import 'package:mapnrank/app/modules/global_widgets/text_field_widget.dart';
import 'package:mapnrank/app/services/global_services.dart';
import '../../../../color_constants.dart';
import '../../../../common/ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../global_widgets/location_widget.dart';
import '../controllers/notification_controller.dart';

class InstitutionCreateMessage extends GetView<NotificationController> {
  const InstitutionCreateMessage({super.key});


  @override
  Widget build(BuildContext context) {
    Get.lazyPut(()=>CommunityController());
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.white),
          //title: Text('Create Mass Message'),

          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: interfaceColor),
            onPressed: () => {
              Navigator.pop(context),
              //Get.back()
            },
          ),
          actions: [
            Center(
                child: InkWell(
                    onTap: () async{
                          if(controller.notification.zoneId != null){

                            await controller.createNotifications(controller.notification);

                          }
                          else{
                            Get.showSnackbar(Ui.warningSnackBar(message: 'You cannot create an event without specifying a zone'));
                          }



                    },
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: interfaceColor,
                        ),

                        width: Get.width/1.8,
                        height: 50,
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: Center(
                            child: Obx(() =>  !controller.createNotification.value ?
                            Text(AppLocalizations.of(context).create_mass_message, style: Get.textTheme.bodyMedium!.merge(const TextStyle(color: Colors.white)))
                                : const SizedBox(height: 20, child: SpinKitThreeBounce(color: Colors.white, size: 20))

                            )
                        )
                    )
                )
            )
          ],
        ),
        body: Container(
            decoration: const BoxDecoration(color: backgroundColor,),
            padding: EdgeInsets.symmetric(horizontal: 10),

            //margin: EdgeInsets.only(bottom: 80),
            child:  ListView(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            buildInputImages(context),
                            Text(AppLocalizations.of(context).notification_title, style:Get.textTheme.labelMedium).marginOnly(left: 10),
                            Card(
                                elevation: 0,
                                child: SizedBox(
                                  height: Get.height*0.08,
                                  child: TextFormField(
                                    style: Get.textTheme.headlineMedium,
                                    cursorColor: Colors.black,
                                    textInputAction:TextInputAction.done ,
                                    maxLines: 4,
                                    minLines: 2,
                                    onChanged: (input) => controller.notification.title = input,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid, color: Get.theme.focusColor.withOpacity(0.5) ), borderRadius: BorderRadius.circular(10),),
                                      focusedBorder: OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid, color: Get.theme.focusColor.withOpacity(0.5)), borderRadius: BorderRadius.circular(10)),
                                      enabledBorder: OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid,color: Get.theme.focusColor.withOpacity(0.5) ), borderRadius: BorderRadius.circular(10)),
                                      hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                                      //filled: true,
                                      prefixIcon: const Icon(Icons.description),
                                      hintText: AppLocalizations.of(context).enter_notification_title,
                                      //hintStyle: TextStyle(fontSize: 28, color: Colors.grey.shade400)
                                    ),

                                  ),
                                )
                            )
                          ]
                      ).marginOnly(top: 20, bottom: 5),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(AppLocalizations.of(context).notification_content, style:Get.textTheme.labelMedium).marginOnly(left: 10),
                            Card(
                                elevation: 0,
                                child: SizedBox(
                                  height: Get.height*0.13,
                                  child: TextFormField(
                                    style: Get.textTheme.headlineMedium,
                                    cursorColor: Colors.black,
                                    textInputAction:TextInputAction.done ,
                                    textAlign: TextAlign.justify,
                                    maxLines: 20,
                                    minLines: 2,
                                    onChanged: (input) => controller.notification.content = input,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid, color: Get.theme.focusColor.withOpacity(0.5) ), borderRadius: BorderRadius.circular(10),),
                                      focusedBorder: OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid, color: Get.theme.focusColor.withOpacity(0.5)), borderRadius: BorderRadius.circular(10)),
                                      enabledBorder: OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid,color: Get.theme.focusColor.withOpacity(0.5) ), borderRadius: BorderRadius.circular(10)),
                                      hintStyle: TextStyle(color: Colors.grey, fontSize: 18,),
                                      //filled: true,
                                      prefixIcon: const Icon(Icons.description, ),
                                      hintText: AppLocalizations.of(context).enter_notification_content,
                                      //hintStyle: TextStyle(fontSize: 28, color: Colors.grey.shade400)
                                    ),

                                  ),
                                )
                            )
                          ]
                      ).marginOnly(top: 20),

                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  padding: EdgeInsets.fromLTRB(10,0,10,40),
                  margin: EdgeInsets.fromLTRB(0, 10, 0,10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).select_location_title,
                        style: Get.textTheme.bodyMedium?.merge(const TextStyle(color: Colors.black, fontSize: 18)),
                        textAlign: TextAlign.start,
                      ).marginOnly(bottom: 10,top: 20),
                      Text(AppLocalizations.of(context).select_notification_location_description,
                        style: Get.textTheme.displayMedium!.merge(const TextStyle(color: Colors.black87, fontSize: 12)),
                        textAlign: TextAlign.start,
                      ).marginOnly(bottom: 20,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text(AppLocalizations.of(context).select_a_region),
                          GestureDetector(
                            onTap: (){
                              showDialog(context: context,
                                builder:  (context) => Dialog(
                                    insetPadding: EdgeInsets.all(20),
                                    child:  ListView(
                                      padding: EdgeInsets.all(20),
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(AppLocalizations.of(context).choose_your_region,
                                              style: Get.textTheme.bodyMedium?.merge(const TextStyle(color: labelColor)),
                                              textAlign: TextAlign.start,
                                            ),
                                            TextButton(onPressed: (){
                                              Navigator.of(context).pop();
                                            }, child: Text('${AppLocalizations.of(context).ok}/${AppLocalizations.of(context).cancel}'))
                                          ],
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
                                                    margin: const EdgeInsetsDirectional.only(end: 10, start: 10, top: 10, bottom: 10),
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
                                                                if(controller.regionSelectedValue.contains(controller.regions[index])){
                                                                    controller.regionSelectedValue.remove(controller.regions[index]);
                                                                    controller.chooseARegion.value = false;
                                                                    controller.regionSelectedValue.clear();

                                                                }
                                                                else{

                                                                    controller.regionSelectedValue.clear();
                                                                    controller.notification.zoneId = controller.regions[index]['id'].toString();
                                                                    controller.regionSelectedValue.add(controller.regions[index]);


                                                                }

                                                                controller.divisionsSet = await controller.getAllDivisions(index);
                                                                controller.listDivisions.value =  controller.divisionsSet['data'];
                                                                controller.loadingDivisions.value = ! controller.divisionsSet['status'];
                                                                controller.divisions.value =  controller.listDivisions;


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
                              decoration: BoxDecoration(shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Get.theme.focusColor.withOpacity(0.5))),
                              padding: EdgeInsets.all(20),
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
                      ).marginOnly(bottom: 20),
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
                                  insetPadding: EdgeInsets.all(20),
                                  child: ListView(
                                    padding: EdgeInsets.all(20),
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(AppLocalizations.of(context).choose_your_subdivision,
                                            style: Get.textTheme.bodyMedium?.merge(const TextStyle(color: labelColor)),
                                            textAlign: TextAlign.start,
                                          ),
                                          TextButton(onPressed: (){
                                            Navigator.of(context).pop();
                                          }, child: Text('${AppLocalizations.of(context).ok}/${AppLocalizations.of(context).cancel}'))
                                        ],
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
                                                  margin: const EdgeInsetsDirectional.only(end: 10, start: 10, top: 10, bottom: 10),
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
                                                                  controller.divisionSelectedValue.remove(controller.divisions[index]);
                                                                  controller.divisionSelectedValue.clear();
                                                                  controller.chooseADivision.value = false;

                                                              }
                                                              else{
                                                                  controller.divisionSelectedValue.clear();
                                                                  controller.notification.zoneId = controller.divisions[index]['id'].toString();
                                                                  controller.divisionSelectedValue.add(controller.divisions[index]);

                                                              }





                                                              controller.subdivisionsSet = await controller.getAllSubdivisions(index);
                                                              controller.listSubdivisions.value = controller.subdivisionsSet['data'];
                                                              controller.loadingSubdivisions.value = !controller.subdivisionsSet['status'];
                                                              controller.subdivisions.value = controller.listSubdivisions;
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
                              decoration: BoxDecoration(shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Get.theme.focusColor.withOpacity(0.5))),
                              padding: EdgeInsets.all(20),
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
                      ).marginOnly(bottom: 20),
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
                                  insetPadding: EdgeInsets.all(20),
                                  child: ListView(
                                    padding: EdgeInsets.all(20),
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(AppLocalizations.of(context).choose_your_subdivision,
                                            style: Get.textTheme.bodyMedium?.merge(const TextStyle(color: labelColor)),
                                            textAlign: TextAlign.start,
                                          ),
                                          TextButton(onPressed: (){
                                            Navigator.of(context).pop();
                                          }, child: Text('${AppLocalizations.of(context).ok}/${AppLocalizations.of(context).cancel}'))
                                        ],
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
                                                  margin: const EdgeInsetsDirectional.only(end: 10, start: 10, top: 10, bottom: 10),
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
                                                              controller.subdivisionSelected.value = !controller.subdivisionSelected.value;
                                                              controller.subdivisionSelectedIndex.value = index;

                                                              if(controller.subdivisionSelectedValue.contains(controller.subdivisions[index]) ){

                                                                  controller.subdivisionSelectedValue.clear();
                                                                  controller.subdivisionSelectedValue.remove(controller.subdivisions[index]);
                                                                  controller.chooseASubDivision.value = false;


                                                              }
                                                              else{
                                                                  controller.subdivisionSelectedValue.clear();
                                                                  controller.subdivisionSelectedValue.add(controller.subdivisions[index]);
                                                                  controller.notification.zoneId = controller.subdivisions[index]['id'].toString();


                                                              }



                                                              print(controller.subdivisions);

                                                              //controller.currentUser.value.zoneId = controller.subdivisionSelectedValue[0]['id'].toString();


                                                              //print(controller.subdivisionSelected);

                                                            },
                                                            child: Obx(() => LocationWidget(
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
                              decoration: BoxDecoration(shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Get.theme.focusColor.withOpacity(0.5))),
                              padding: EdgeInsets.all(20),
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
                      ).marginOnly(bottom: 20),
                    ],
                  ),
                ),

              ],
            ).paddingOnly(bottom: 20)
        )
    );
  }



  Widget buildInputImages(BuildContext context){
    return Container(
      decoration: const BoxDecoration(
        color: backgroundColor,
      ),
      //padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Obx(() => Stack(children: [
            controller.imageFiles.length <= 0 ?Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                width: double.infinity,
                height: 140,
                child: Image.asset(
                  'assets/images/loading.gif',
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
            ):
            Obx(() => ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Image.file(
                controller.imageFiles[0],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 140,
              ),
            ),),
            Positioned(
                right: 20,
                top: 10,
                child: GestureDetector(
                    onTap: (){
                      controller.imageFiles.clear();
                      showDialog(
                          context: Get.context!,
                          builder: (_){
                            return AlertDialog(
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                              ),
                              content: Container(
                                  height: 140,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                      children: [
                                        ListTile(
                                          onTap: ()async{
                                            await controller.pickImage(ImageSource.camera);
                                            Navigator.pop(Get.context!);
                                          },
                                          leading: const Icon(FontAwesomeIcons.camera),
                                          title: Text(AppLocalizations.of(context).take_picture, style: Get.textTheme.headlineMedium!.merge(const TextStyle(fontSize: 15))),
                                        ),
                                        ListTile(
                                          onTap: ()async{
                                            await controller.pickImage(ImageSource.gallery);
                                            Navigator.pop(Get.context!);
                                          },
                                          leading: const Icon(FontAwesomeIcons.image),
                                          title: Text(AppLocalizations.of(context).upload_image, style: Get.textTheme.headlineMedium!.merge(const TextStyle(fontSize: 15))),
                                        )
                                      ]
                                  )
                              ),
                              actions: [
                                TextButton(
                                    onPressed: ()=> Navigator.pop(context),
                                    child: Text(AppLocalizations.of(context).cancel, style: Get.textTheme.headlineMedium!.merge(const TextStyle(color: inactive)),))
                              ],
                            );
                          });

                    },
                    child: FaIcon(FontAwesomeIcons.edit, color: interfaceColor,))),
            controller.imageFiles.length <= 0 ?Align(
              alignment: Alignment.bottomCenter,
              child: Text(AppLocalizations.of(context).upload_event_banner),
            ).paddingOnly(top: 20):SizedBox()

          ]),),

        ],
      ),
    );
  }

  Widget buildLoader() {
    return Container(
        width: 100,
        height: Get.height/4,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Image.asset(
            'assets/img/loading.gif',
            fit: BoxFit.cover,
            width: double.infinity,
            height: Get.height/4,
          ),
        ));
  }

}
