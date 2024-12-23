import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/community/widgets/buildSelectSector.dart';
import 'package:mapnrank/app/modules/community/widgets/buildSelectZone.dart';
import 'package:mapnrank/app/modules/global_widgets/location_widget.dart';
import 'package:mapnrank/app/modules/global_widgets/text_field_widget.dart';
import 'package:mapnrank/app/services/global_services.dart';
import '../../../../color_constants.dart';
import '../../../../common/ui.dart';
import '../../global_widgets/sector_item_widget.dart';
import '../../root/controllers/root_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreatePostView extends GetView<CommunityController> {
  const CreatePostView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.white),
          elevation: 0,
          // title:  Text(
          //   !controller.createUpdatePosts.value?'Create a Post'.tr:'Update a Post',
          //   style: Get.textTheme.headline6!.merge(const TextStyle(color: Colors.white)),
          // ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: interfaceColor),
            onPressed: () async => {
              if(controller.isRootFolder){
                await Get.find<RootController>().changePage(0),
                controller.postContentController.clear(),
                controller.emptyArrays(),
                controller.isRootFolder = false,
              }
              else{
                controller.emptyArrays(),
                Navigator.pop(context),
              }

              //Get.back()
            },
          ),
          actions: [
            SizedBox(
              //height: 80,
                child: Center(
                    child: InkWell(
                        onTap: () async{
                          print("Post is: ${controller.post.content}");
                          if(controller.post.content != null && controller.post.content != ''){
                            controller.createPosts.value = !controller.createPosts.value;
                            controller.updatePosts.value = !controller.updatePosts.value;
                            !controller.createUpdatePosts.value?
                            controller.createPosts.value?
                            await  controller.createPost(controller.post!):(){}
                                :controller.updatePosts.value?
                            await  controller.updatePost(controller.post!):(){};
                          }
                          else{
                            Get.showSnackbar(Ui.warningSnackBar(message: 'You cannot create a post without content'));
                          }

                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: interfaceColor,
                            ),

                            width: Get.width/3.5,
                            height: 40,
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            child: Center(
                                child: Obx(() =>  !controller.createUpdatePosts.value?!controller.createPosts.value ?
                                Text(AppLocalizations.of(context).post, style: Get.textTheme.bodyMedium!.merge(const TextStyle(color: Colors.white)))
                                    : const SizedBox(height: 20,
                                    child: SpinKitThreeBounce(color: Colors.white, size: 20)):
                                !controller.updatePosts.value?
                                Text(AppLocalizations.of(context).update, style: Get.textTheme.bodyMedium!.merge(const TextStyle(color: Colors.white)))
                                    : const SizedBox(height: 20,
                                    child: SpinKitThreeBounce(color: Colors.white, size: 20))

                                )
                            )
                        )
                    )
                )
            )
          ],
        ),
        body: Container(
          //padding: EdgeInsets.only(bottom: 80),
            decoration: const BoxDecoration(color: backgroundColor,
            ),
            child:  ListView(
              //padding: EdgeInsets.all(20),

              children: [

                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  padding: EdgeInsets.fromLTRB(10,0,10,40),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Card(
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            elevation: 0,
                            child: SizedBox(
                              height: Get.height*0.2,
                              child: TextFormField(
                                controller: controller.postContentController,
                                style: TextStyle(color: Colors.black, fontSize: 20),
                                cursorColor: Colors.black,
                                textInputAction:TextInputAction.done ,
                                maxLines: 20,
                                minLines: 2,
                                onChanged: (input) => controller.post!.content = input,
                                decoration: InputDecoration(
                                    border: InputBorder.none,

                                    hintText: '${AppLocalizations.of(context).share_your_thoughts}... ',

                                    hintStyle: TextStyle(fontSize: 28, color: Colors.grey.shade400)
                                ),

                              ),
                            )
                        ),
                        Obx(() => controller.imageFiles.length > 0 ?
                        buildInputImages(context)
                            :  GestureDetector(
                          onTap: (){ showDialog(
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
                              });},
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.camera, color: Colors.black,),
                              SizedBox(width: 10,),
                              Text(AppLocalizations.of(context).attach_images_optional, style:  Get.textTheme.bodyMedium?.merge(const TextStyle(color: Colors.black, fontSize: 16)))

                            ],
                          ),
                        ),),
                      ]
                  ).marginOnly(top: 20, bottom: 5),
                ),

                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  padding: EdgeInsets.fromLTRB(10,0,10,40),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).select_location_title,
                        style: Get.textTheme.bodyMedium?.merge(const TextStyle(color: Colors.black, fontSize: 18)),
                        textAlign: TextAlign.start,
                      ).marginOnly(bottom: 10,top: 20),
                      Text(AppLocalizations.of(context).select_zone_message,
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
                                  key: Key('regionDialog'),
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
                                  key: Key('divisionDialog'),
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
                                  key: Key('subdivisionDialog'),
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
                              key: Key('chooseSubdivision'),
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

                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  padding: EdgeInsets.fromLTRB(10,0,10,40),
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    children: [
                      Obx(() => Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context).choose_sector, style: Get.textTheme.bodyMedium?.merge(const TextStyle(color: Colors.black, fontSize: 18))).marginOnly(bottom: 10),
                            Text(AppLocalizations.of(context).select_your_sector_of_interest,
                              style: Get.textTheme.displayMedium!.merge(const TextStyle(color: Colors.black87, fontSize: 12)),
                              textAlign: TextAlign.start,
                            ).marginOnly(bottom: 20,),

                            GestureDetector(
                              onTap: (){
                                controller.filterBySector.value = false;
                                showDialog(context: context,
                                  builder: (context) => Dialog(
                                    insetPadding: EdgeInsets.all(20),
                                    child:  BuildSelectSector(),
                                  ),);
                              },
                              child: Container(
                                  width: Get.width,
                                  decoration: BoxDecoration(shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Get.theme.focusColor.withOpacity(0.5))),
                                  padding: EdgeInsets.all(20),
                                  child: controller.sectorsSelected.isNotEmpty?
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: Get.width*0.73,
                                        child: RichText(text: TextSpan(
                                            children:[
                                              for(var sector in controller.sectorsSelected)...[
                                                TextSpan(text: '${sector['name']}, ',style: Get.textTheme.headlineMedium, )
                                              ],


                                            ]
                                        )),
                                      ),
                                      FaIcon(FontAwesomeIcons.angleDown, size: 10,)

                                    ],
                                  ):
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(AppLocalizations.of(context).choose_sector, style: Get.theme.textTheme.headlineMedium!.merge(TextStyle(color: Colors.grey, fontSize: 18),)),
                                      FaIcon(FontAwesomeIcons.angleDown, size: 10,)
                                    ],
                                  ),

                              ),
                            ),
                          ]

                      ),).marginOnly(bottom: 20, top: 20),
                    ],
                  ),

                )




              ],
            )
        )
    );
  }




  Widget buildInputImages(BuildContext context){
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Obx(() =>
              controller.createUpdatePosts.value?
              SizedBox(
                height: Get.height/4,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.post.imagesUrl?.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      //onTap: onPictureTapped,
                      child: FadeInImage(
                        width: Get.width-50,
                        height: Get.height/4,
                        fit: BoxFit.cover,
                        image:  NetworkImage('${GlobalService().baseUrl}'
                            '${controller.post.imagesUrl![index]['url'].substring(1,controller.post.imagesUrl![index]['url'].length)}',
                            headers: GlobalService.getTokenHeaders()
                        ),
                        placeholder: const AssetImage(
                            "assets/images/loading.gif"),
                        imageErrorBuilder:
                            (context, error, stackTrace) {
                          return Image.asset(
                              "assets/images/loading.gif",
                              width: Get.width,
                              height: Get.height/4,
                              fit: BoxFit.fitWidth);
                        },
                      ).marginOnly(right: 10),
                    );

                  },
                ),
              )
                  :SizedBox()

              ),
              Obx(() =>  controller.imageFiles.length <= 0 ?
              SizedBox()
                  : SizedBox(
                height:Get.height/4,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index){
                      return Stack(
                        //mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                child: Image.file(
                                  controller.imageFiles[index],
                                  fit: BoxFit.cover,
                                  width: Get.width/2,
                                  height:Get.height/4,
                                ),
                              )
                          ),
                          Positioned(
                            top:0,
                            right:0,
                            child: Align(
                              //alignment: Alignment.centerRight,
                              child: IconButton(
                                  onPressed: (){
                                    controller.imageFiles.removeAt(index);
                                  },
                                  icon: const Icon(Icons.delete, color: inactive, size: 25, )
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index){
                      return const SizedBox(width: 8);
                    },
                    itemCount: controller.imageFiles.length),
              ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(onPressed: (){
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
          }, icon: Icon(FontAwesomeIcons.camera)),
        )
      ],
    )
     ;
  }

}
