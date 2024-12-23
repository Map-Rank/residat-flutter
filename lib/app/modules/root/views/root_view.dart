import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/common/helper.dart';
import '../../global_widgets/custom_bottom_nav_bar.dart';
import '../../global_widgets/main_drawer_widget.dart';
import '../controllers/root_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() =>  WillPopScope(
      onWillPop: Helper().onWillPop,
      child: Scaffold(
        drawer: const MainDrawerWidget(),
        body: controller.currentPage,
        bottomNavigationBar: CustomBottomNavigationBar(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          itemColor: context.theme.colorScheme.secondary,
          currentIndex: controller.currentIndex.value,
          onChange: (index) {
            controller.changePage(index);
          },
          children: [
            CustomBottomNavigationItem(
              icon: controller.currentIndex.value == 0?Image.asset(
        'assets/icons/community_colored.png',
        ):Image.asset(
        'assets/icons/community.png',
      ),
              label: AppLocalizations.of(context).community,
            ),
            CustomBottomNavigationItem(
              icon: controller.currentIndex.value == 1?Image.asset(
                'assets/icons/dashboard_colored.png',
              ):Image.asset(
                'assets/icons/dashboard.png',
              ),
              label: AppLocalizations.of(context).dashboard,
            ),

            CustomBottomNavigationItem(
              icon: controller.currentIndex.value == 2?Image.asset(
                'assets/icons/create_colored.png',
              ):Image.asset(
                'assets/icons/create.png',
              ),
              label: AppLocalizations.of(context).post,
            ),
            CustomBottomNavigationItem(
              icon: controller.currentIndex.value == 3?Image.asset(
                'assets/icons/event_colored.png',
              ):Image.asset(
                'assets/icons/event.png',
              ),
              label: AppLocalizations.of(context).events,

            ),
            CustomBottomNavigationItem(
              icon: controller.currentIndex.value == 4?Image.asset(
                'assets/icons/notification_colored.png',
              ):Image.asset(
                'assets/icons/notification.png',
              ),
              label: AppLocalizations.of(context).notification,

            ),
            // CustomBottomNavigationItem(
            //   icon: FontAwesomeIcons.bell,
            //   label: 'Notifications',
            // ),
          ],
        ),
      ),
    ));
    }
  }

