
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/community/views/community_view.dart';
import 'package:mapnrank/app/modules/community/views/create_post.dart';
import 'package:mapnrank/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mapnrank/app/modules/dashboard/views/dashboard_view.dart';
import 'package:mapnrank/app/modules/events/controllers/events_controller.dart';
import 'package:mapnrank/app/modules/events/views/events_view.dart';
import 'package:mapnrank/app/modules/notifications/views/notification_view.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../notifications/controllers/notification_controller.dart';


class RootController extends GetxController {
  final currentIndex = 0.obs;
  final notificationsCount = 0.obs;
  late NotificationController _notificationController;


  RootController() {
    _notificationController = new NotificationController();
  }

  @override
  void onInit() async {
    getNotificationsCount();
    super.onInit();
  }

  List<Widget> pages = [
    const CommunityView(),
    const DashboardView(),
    const CreatePostView(),
    const EventsView(),
    const NotificationView(),

  ];

  Widget get currentPage => pages[currentIndex.value];

  Future<void> changePageInRoot(int _index) async {
    if (Get.find<AuthService>().user.value.email == null && _index > 0) {
      await Get.offNamed(Routes.LOGIN);
    } else {
      currentIndex.value = _index;
      await refreshPage(_index);
      Get.lazyPut(()=>AuthController());
      Get.find<AuthController>().loading.value = false;
    }
  }

  Future<void> changePageOutRoot(int _index) async {
    if (Get.find<AuthService>().user.value.email == null && _index > 0) {
      await Get.toNamed(Routes.LOGIN);
    }else{
      currentIndex.value = _index;
      await refreshPage(_index);
      await Get.offNamedUntil(Routes.ROOT, (Route route) {
        if (route.settings.name == Routes.ROOT) {
          return true;
        }
        return true;
      }, arguments: _index);
    }
  }

  Future<void> changePage(int _index) async {
    if (Get.currentRoute == Routes.ROOT) {
      await changePageInRoot(_index);
    } else {
      await changePageOutRoot(_index);
    }
  }

  Future<void> refreshPage(int _index) async {
    switch (_index) {
      case 0:
        {
          await Get.find<AuthController>().getUser();
          if(Get.find<AuthService>().user.value.email != null){
            await Get.find<CommunityController>().refreshCommunity();
          }

          break;
        }
      case 1:
        {
          await Get.find<DashboardController>().refreshDashboard();

          break;
        }
      case 2:
        {
          Get.find<CommunityController>().isRootFolder = true;
          Get.find<CommunityController>().emptyArrays();
          break;
        }
      case 3:
        {
          if(Get.find<AuthService>().user.value.email != null){
            await Get.find<EventsController>().refreshEvents();
          }
          break;
        }

      case 4:
        {
          if(Get.find<AuthService>().user.value.email != null){
            await Get.find<NotificationController>().refreshNotification();
          }
          break;
        }
    }
  }

  void getNotificationsCount() async {
    var list = [];
    var count = 0;
    list =  await _notificationController.getNotifications()??[];
    for(int i =0; i<list.length; i++ ){

          count = count +1;

    }
    notificationsCount.value =count;
  }


}

