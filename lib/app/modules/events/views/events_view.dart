import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/events/controllers/events_controller.dart';
import 'package:mapnrank/app/modules/events/widgets/buildSelectSector.dart';
import 'package:mapnrank/app/modules/events/widgets/buildSelectZone.dart';
import 'package:mapnrank/app/modules/global_widgets/event_card_widget.dart';
import 'package:mapnrank/app/modules/global_widgets/loading_cards.dart';
import 'package:mapnrank/app/routes/app_routes.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import '../../../../color_constants.dart';
import '../../../../common/helper.dart';
import '../../../../common/ui.dart';
import '../../../services/global_services.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../community/widgets/comment_loading_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';


class EventsView extends GetView<EventsController> {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    print(controller.loadingEvents.value);
    print(controller.allEvents);
    Get.lazyPut(()=>CommunityController());
    return WillPopScope(
      onWillPop: Helper().onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leadingWidth: 0,
          //floating: true,
          //toolbarHeight: controller.filterByLocation.value?450:100,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.white),
          leading: Icon(null),
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Container(
            //padding: EdgeInsets.all(20),
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
                        height: MediaQuery
                            .sizeOf(context)
                            .width <600? Get.width/6 : 80,
                        fit: BoxFit.fitHeight),
                  ),
                  Container(
                    height: 40,
                    width: Get.width/1.6,
                    decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10)

                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide:BorderSide.none,),
                          hintText: AppLocalizations.of(context).search_subdivision,
                          hintStyle: TextStyle(fontSize: 14),
                          prefixIcon: Icon(FontAwesomeIcons.search, color: Colors.grey, size: 15,)
                      ),
                    ),
                  ),
                  ClipOval(
                      child: GestureDetector(
                        onTap: () async {

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
                  ),
                ],
              )
          ),
        ),
        floatingActionButton:  SizedBox(
          height: 40,
          child: FloatingActionButton.extended(
              backgroundColor: interfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: (){
                controller.noFilter.value = true;
                controller.chooseARegion.value = false;
                controller.chooseADivision.value = false;
                controller.chooseASubDivision.value = false;

                if(controller.event?.sectors != null){
                  controller.event?.sectors!.clear();
                  controller.emptyArrays();
                }
                Get.toNamed(Routes.CREATE_EVENT);
              },
              heroTag: null,
              icon: const FaIcon(FontAwesomeIcons.add),
              label: Text(AppLocalizations.of(context).create_event)),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshEvents(showMessage: true);
              controller.onInit();
            },
            child: Container(
              decoration: BoxDecoration(color: backgroundColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0)),

              ),
              child: Obx(() => CustomScrollView(
                primary: true,
                shrinkWrap: false,
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    //expandedHeight: 80,
                    child: PreferredSize(preferredSize: Size(Get.width, 50),
                        child: Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            //border: Border(bottom: BorderSide(color: interfaceColor))
                          ),
                          child: Column(children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: <BoxShadow>[BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 20.0,
                                            offset: Offset(1, 1)
                                        )]
                                    ),
                                    child: TextButton.icon(
                                      icon: Image.asset(
                                          "assets/images/filter.png",
                                          width: 20,
                                          height: 20,
                                          fit: BoxFit.fitWidth) ,
                                      label: Text(AppLocalizations.of(context).filter_by_location, style: TextStyle(color: Colors.black),),
                                      onPressed: () {
                                        controller.noFilter.value = false;
                                        controller.filterByLocation.value = !controller.filterByLocation.value;

                                      },),
                                  ),
                                ),
                                // Expanded(
                                //   child: Container(
                                //     margin: EdgeInsets.fromLTRB(5, 20, 5, 15),
                                //     decoration: BoxDecoration(
                                //         color: Colors.white,
                                //         boxShadow: <BoxShadow>[BoxShadow(
                                //             color: Colors.black12,
                                //             blurRadius: 20.0,
                                //             offset: Offset(1, 1)
                                //         )],
                                //         borderRadius: BorderRadius.circular(10)
                                //     ),
                                //     child: TextButton.icon(
                                //       icon: Image.asset(
                                //           "assets/images/filter.png",
                                //           width: 20,
                                //           height: 20,
                                //           fit: BoxFit.fitWidth) ,
                                //       label: Text('Filter by sector', style: TextStyle(color: Colors.black)),
                                //       onPressed: () {
                                //
                                //         controller.noFilter.value = false;
                                //         showModalBottomSheet(context: context,
                                //
                                //           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                                //           builder: (context) {
                                //             return Container(
                                //                 padding: const EdgeInsets.all(20),
                                //                 decoration: const BoxDecoration(
                                //                     color: backgroundColor,
                                //                     borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                //
                                //                 ),
                                //                 child: BuildSelectSector()
                                //             );
                                //           },
                                //         );
                                //
                                //       },),
                                //   ),
                                // ),


                              ],),
                            Obx(() => Visibility(
                              visible: controller.filterByLocation.value,
                              child: Container(
                                width: Get.width,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: interfaceColor,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(AppLocalizations.of(context).select_location_title,
                                  style: Get.textTheme.bodyMedium?.merge(const TextStyle(color: Colors.white, fontSize: 16)),
                                  textAlign: TextAlign.start,),
                              ).marginOnly(bottom: 20, left: 5, right: 5),),),
                            Obx(() =>  Visibility(
                                visible: controller.filterByLocation.value,
                                child: Container(
                                    padding: EdgeInsets.all(10),
                                    color: Colors.white,
                                    height: Get.height/2.5,
                                    child: BuildSelectZone()).marginOnly(bottom: 10)),),
                          ],)

                        ),

                    ),

                  ),



                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return controller.loadingEvents.value?
                        const LoadingCardWidget()
                            :controller.allEvents.isNotEmpty?
                        Obx(() => GestureDetector(
                          onTap: (){
                            controller.eventDetails = controller.allEvents[index];
                            Get.toNamed(Routes.EVENT_DETAILS_VIEW);
                          },
                          child: EventCardWidget(
                            isAllEventsPage: true,
                            //likeTapped: RxBool(controller.allPosts[index].likeTapped),
                            content: controller.allEvents[index].content,
                            image: controller.allEvents[index].imagesUrl,
                            eventOrganizer: controller.allEvents[index].organizer,
                            title: controller.allEvents[index].title,
                            zone: controller.allEvents[index].zone != null?controller.allEvents[index].zone: '',
                            publishedDate: controller.allEvents[index].publishedDate,
                            eventId: controller.allEvents[index].eventId,
                            popUpWidget: SizedBox()
                          )
                        )
                        )

                            :Center(
                          child: SizedBox(
                            height: Get.height/2,
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.folderOpen, size: 30,),
                                Text(AppLocalizations.of(context).no_events_found)
                              ],
                            ),
                          ),

                        );
                      },
                          childCount: controller.allEvents.length
                      )),

                  SliverList(
                      delegate: SliverChildListDelegate([
                        !controller.loadingEvents.value?
                        controller.allEvents.isEmpty?
                        Center(
                          child: SizedBox(
                            //height: Get.height/2,
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:  [
                                SizedBox(height: Get.height/4),
                                FaIcon(FontAwesomeIcons.folderOpen, size: 30,),
                                Text(AppLocalizations.of(context).no_events_found)
                              ],
                            ),
                          ),

                        ):controller.page >0?
                        Center(
                          child: CircularProgressIndicator(color: interfaceColor, ),
                        ):SizedBox():LoadingCardWidget()
                      ]))
                ],
              )),
            )
        ),
      ),
    );
  }


}
