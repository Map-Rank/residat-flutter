import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/global_widgets/location_widget.dart';
import 'package:mapnrank/app/modules/global_widgets/text_field_widget.dart';
import 'package:mapnrank/color_constants.dart';

class BuildSelectSector extends GetView<CommunityController> {
  BuildSelectSector({Key? key,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        Text('Select a sector',
          style: Get.textTheme.bodyText2?.merge(const TextStyle(color: labelColor)),
          textAlign: TextAlign.start,
        ),
        Obx(() =>
            Column(
              children: [
                TextFieldWidget(
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  validator: (input) => input!.isEmpty ? 'Required field' : null,
                  iconData: FontAwesomeIcons.search,
                  style: const TextStyle(color: labelColor),
                  hintText: 'Select or search by sector name',
                  onChanged: (value)=>{
                    controller.filterSearchSectors(value)
                  },
                  errorText: '', suffixIcon: const Icon(null), suffix: const Icon(null),
                ),
                controller.loadingSectors.value ?
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
                        itemCount:controller.sectors.length,
                        shrinkWrap: true,
                        primary: false,
                        itemBuilder: (context, index) {

                          return GestureDetector(
                              onTap: () async {


                                controller.selectedIndex. value = index;
                                if(controller.sectorsSelected.contains(controller.sectors[index]) ){
                                  if(controller.noFilter.value){
                                    controller.sectorsSelected.remove(controller.sectors[index]);
                                    controller.post?.sectors?.remove(controller.sectors[index]['id']);
                                  }
                                  else{
                                    controller.sectorsSelected.remove(controller.sectors[index]);
                                    //controller.post?.sectors?.remove(controller.sectors[index]['id']);
                                    controller.filterSearchPostsBySectors(controller.sectors[index]['id'].toString());
                                  }

                                }
                                else{
                                  if(controller.noFilter.value){
                                    controller.sectorsSelected.add(controller.sectors[index]);
                                    controller.post?.sectors?.add(controller.sectors[index]['id']);
                                  }
                                  else{
                                    controller.sectorsSelected.add(controller.sectors[index]);
                                    controller.filterSearchPostsBySectors(controller.sectors[index]['id'].toString());
                                  }


                                }



                              },
                              child: Obx(() => LocationWidget(
                                regionName: controller.sectors[index]['name'],
                                selected: controller.sectorsSelected.contains(controller.sectors[index])? true : false,
                              ).marginOnly(bottom: 5))
                          );
                        })
                )
              ],
            ),
        ).marginOnly(bottom: 20),

        const SizedBox(height: 20),
      ],
    );
  }
}