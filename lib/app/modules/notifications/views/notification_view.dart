
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/routes/app_routes.dart';
import 'package:mapnrank/app/services/global_services.dart';
import '../../../../color_constants.dart';
import '../../../../common/helper.dart';
import '../../global_widgets/circular_loading_widget.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_item_widget.dart';


class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper().onWillPop,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          titleSpacing: 0,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.white),
          backgroundColor: Colors.white,
          leadingWidth: 0,
          //toolbarHeight: controller.filterByLocation.value || controller.filterBySector.value?590:190,
          leading: Icon(null),
          centerTitle: true,
          title: Container(
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
                 Spacer(),
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
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshNotification();
          },
          child: Container(
            height: Get.height,
            decoration: BoxDecoration(color: backgroundColor,),
            child: ListView(
              key: Key('listView'),
              children: [
                if(controller.currentUser.value.type?.toUpperCase() == "COUNCIL")...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: (){
                        Get.toNamed(Routes.INSTITUTION_CREATE_MESSAGE);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text('Send mass message', style:  TextStyle(color: Colors.white),),
                      ).paddingSymmetric(vertical: 10, horizontal: 20),
                    ),

                  ),

                  Row(
                    children: [
                      GestureDetector(
                          onTap: (){
                            controller.isMyCreatedNotification.value = !controller.isMyCreatedNotification.value;
                          },
                          child: Obx(() => Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: controller.isMyCreatedNotification.value?secondaryColor:backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: controller.isMyCreatedNotification.value?null:Border.all(color: Colors.black26, width: 0.5)
                            ),
                            child: Text('Recently sent', style:  TextStyle(color: controller.isMyCreatedNotification.value?Colors.white:Colors.black),),
                          ).paddingSymmetric(vertical: 10, horizontal: 5),)
                      ),

                      GestureDetector(
                          onTap: (){
                            controller.isMyCreatedNotification.value = !controller.isMyCreatedNotification.value;
                          },
                          child: Obx(() => Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: !controller.isMyCreatedNotification.value?secondaryColor:backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: !controller.isMyCreatedNotification.value?null:Border.all(color: Colors.black26, width: 0.5)
                            ),
                            child: Text('Inbox', style:  TextStyle(color: !controller.isMyCreatedNotification.value?Colors.white:Colors.black),),
                          ).paddingSymmetric(vertical: 10, horizontal: 5),)
                      ),
                    ],
                  ),

                ]else...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Important messages', style:  TextStyle(color: Colors.white),),
                    ).paddingSymmetric(vertical: 10, horizontal: 5),
                  ),
                ],


                Obx(() => controller.loadingNotifications.value?
                CircularLoadingWidget(
                  key: Key('circularLoading'),
                  height: 300,
                  onCompleteText: "Notification List is Empty".tr,
                  onComplete: (value) {

                  },
                ):
                    controller.currentUser.value.type?.toUpperCase() !='COUNCIL'?
                    ListView.separated(
                        itemCount: controller.notifications.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(
                              height: 0,
                          );
                        },
                        shrinkWrap: true,
                        primary: false,
                        itemBuilder: (context, index) {
                          var _notification = controller.notifications.elementAt(index);
                          return NotificationItemWidget(
                            notification: _notification,
                            onDismissed: (notification) {
                            },
                            onTap: (notification) async {

                            }, icon: ClipOval(
                              child: FadeInImage(
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                image:  NetworkImage(_notification.bannerUrl!, headers: GlobalService.getTokenHeaders()),
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
                              )
                          ),
                          );
                        }
                    )
                :controller.isMyCreatedNotification.value?
                ListView.separated(
                    itemCount: controller.createdNotifications.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 0,
                      );
                    },
                    shrinkWrap: true,
                    primary: false,
                    itemBuilder: (context, index) {
                      var _notification = controller.notifications.elementAt(index);
                      return NotificationItemWidget(
                        notification: _notification,
                        onDismissed: (notification) async {
                          await controller.deleteSpecificNotification(_notification.notificationId);
                        },
                        onTap: (notification) async {

                        }, icon: ClipOval(
                          child: FadeInImage(
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            image:  NetworkImage(_notification.bannerUrl!, headers: GlobalService.getTokenHeaders()),
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
                          )
                      ),
                      );
                    }
                )
                  :ListView.separated(
                    itemCount: controller.receivedNotifications.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 0);
                    },
                    shrinkWrap: true,
                    primary: false,
                    itemBuilder: (context, index) {
                      var _notification = controller.notifications.elementAt(index);
                      return NotificationItemWidget(
                        notification: _notification,
                        onDismissed: (notification) {
                        },
                        onTap: (notification) async {

                        }, icon: ClipOval(
                          child: FadeInImage(
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            image:  NetworkImage(_notification.bannerUrl!, headers: GlobalService.getTokenHeaders()),
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
                          )
                      ),
                      );
                    }
                ),)
              ],
            )

            ),
          ),
        ),
    );
  }

}
