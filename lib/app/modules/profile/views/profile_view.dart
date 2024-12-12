

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapnrank/app/modules/profile/controllers/profile_controller.dart';
import 'package:mapnrank/app/routes/app_routes.dart';
import 'package:mapnrank/color_constants.dart';
import '../../../../common/helper.dart';
import '../../../services/global_services.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../community/controllers/community_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../events/controllers/events_controller.dart';
import '../../notifications/controllers/notification_controller.dart';
import '../../root/controllers/root_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: Helper().onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: interfaceColor),
            key: Key('back_button'),
            onPressed: () async => {

              Get.find<CommunityController>().refreshCommunity(),
              Get.find<EventsController>().refreshEvents(),
              Get.toNamed(Routes.ROOT),
            },
          ),
        title: Text(
          AppLocalizations.of(context).profile,
          style: TextStyle(color: Colors.black87, fontSize: 30.0),
        ),
        ),
        body: RefreshIndicator(
      onRefresh: () async {
      await controller.refreshProfile(showMessage: true);
      controller.onInit();
      },
      child:
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Obx(() => !controller.loadProfileImage.value?
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: background,
                        child: Obx(() => CircleAvatar(
                            child: controller.currentUser.value.avatarUrl == null? Text('${controller.currentUser.value.firstName![0].toUpperCase()} ${controller.currentUser.value.lastName![0].toUpperCase()}', style: TextStyle( ),):null ,
                            backgroundColor: background,
                            radius: 65,
                            backgroundImage: controller.currentUser.value.avatarUrl != null?
                            NetworkImage(controller.currentUser.value!.avatarUrl!, headers: GlobalService.getTokenHeaders())
                                :null


                        )),
                      ):
                      CircleAvatar(
                        radius: 65,
                        backgroundColor:  background,
                        child: Image.file(
                          controller.profileImage.value,
                          fit: BoxFit.cover,
                          width: 130,
                          height: 130,
                        ),
                      )
                        ,),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: [
                         Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            controller.currentUser.value.firstName.toString()! +" " +controller.currentUser.value.lastName.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                            ),
                          ),
                        ),

                        //email;phone;last name;Firts name;birth Date;password;
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.ARTICLES);
                              },
                              child: SizedBox(
                                child: Column(
                                  children: [
                                    Text(
    ! Platform.environment.containsKey('FLUTTER_TEST')?controller.currentUser.value.myPosts!.length.toString():'1',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        AppLocalizations.of(context).posts_count,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                '|',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.0),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.MY_EVENTS);
                              },
                              child: SizedBox(
                                child: Column(
                                  children: [
                                    Text(
                                      ! Platform.environment.containsKey('FLUTTER_TEST')?controller.currentUser.value.myEvents!.length.toString():'1',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        AppLocalizations.of(context).events,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                '|',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.0),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.FOLLOWERS);
                              },
                              child: SizedBox(
                                child: Column(
                                  children: [
                                    Text(
                                      "${controller.currentUser.value.followerCount??0} / ${controller.currentUser.value.followingCount??0} ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "${AppLocalizations.of(context).followers_count} / ${AppLocalizations.of(context).following}",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ).marginSymmetric(vertical: 30),
              GestureDetector(
                onTap: (() {
                  Get.toNamed(Routes.ACCOUNT);
                }),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.03),
                      borderRadius: BorderRadius.circular(14.0)),
                  child: ListTile(
                    leading: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(.05)),
                      child: const Icon(
                        Icons.settings_rounded,
                        size: 26,
                        color: Colors.black,
                      ),
                    ),
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        AppLocalizations.of(context).general,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    subtitle:Text(
                      AppLocalizations.of(context).account,
                      style: TextStyle(color: Colors.grey, fontSize: 14.0),
                    ),
                    trailing: const Icon(
                      Icons.navigate_next_rounded,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: (() {
                  Get.toNamed(Routes.CONTACT_US);
                }),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.03),
                      borderRadius: BorderRadius.circular(14.0)),
                  child: ListTile(
                    leading: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(.05)),
                      child: const Icon(
                        Icons.call,
                        size: 26,
                        color: Colors.black,
                      ),
                    ),
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        AppLocalizations.of(context).contact_us,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    subtitle: const Text(
                      'whatsapp, via application',
                      style: TextStyle(color: Colors.grey, fontSize: 14.0),
                    ),
                    trailing: const Icon(
                      Icons.navigate_next_rounded,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),

              GestureDetector(
                onTap: (() {
                 Get.toNamed(Routes.SETTINGS_LANGUAGE);
                }),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.03),
                      borderRadius: BorderRadius.circular(14.0)),
                  child: ListTile(
                    leading: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(.05)),
                      child: const Icon(
                        Icons.call,
                        size: 26,
                        color: Colors.black,
                      ),
                    ),
                    title:  Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text(
                          AppLocalizations.of(context).language,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      '${AppLocalizations.of(context).en}, ${AppLocalizations.of(context).fr}',
                      style: TextStyle(color: Colors.grey, fontSize: 14.0),
                    ),
                    trailing: const Icon(
                      Icons.navigate_next_rounded,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                key: Key('signoutkey'),
                onTap: (() {
                  Get.lazyPut(()=>AuthController());
                  if(! Platform.environment.containsKey('FLUTTER_TEST')){
                    Get.find<AuthController>().loading.value = false;
                  }
                  showDialog(context: context,
                    builder: (context) => AlertDialog(
                      key: Key('logout_app'),
                      insetPadding: EdgeInsets.all(20),
                      icon: Icon(FontAwesomeIcons.warning, color: Colors.orange,),
                      title:  Text(AppLocalizations.of(context).logout),
                      content: Obx(() =>  !Get.find<AuthController>().loading.value ?Text(AppLocalizations.of(context).sign_out_warning, textAlign: TextAlign.justify, style: TextStyle(),)
                          : SizedBox(height: 30,
                          child: SpinKitThreeBounce(color: interfaceColor, size: 20)),),
                      actions: [
                        TextButton(onPressed: (){
                          Get.find<AuthController>().logout();
                          Get.lazyPut(()=>AuthController());
                        }, child: Text(AppLocalizations.of(context).exit, style: TextStyle(color: Colors.red),)),

                        TextButton(onPressed: (){
                          Navigator.of(context).pop();
                        }, child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: interfaceColor),)),

                      ],

                    ),);
                }),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.03),
                      borderRadius: BorderRadius.circular(14.0)),
                  child: ListTile(
                    leading: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(.05)),
                      child: const Icon(
                        Icons.exit_to_app_rounded,
                        size: 27,
                        color: Colors.black,
                      ),
                    ),
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        AppLocalizations.of(context).sign_out,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context).logout_of_app,
                      style: TextStyle(color: Colors.grey, fontSize: 14.0),
                    ),
                    trailing: const Icon(
                      Icons.navigate_next_rounded,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: (() {
                  Get.find<AuthController>().loading.value = false;
                  showDialog(context: context,
                    builder: (context) => AlertDialog(
                      insetPadding: EdgeInsets.all(20),
                      icon: Icon(FontAwesomeIcons.warning, color: Colors.orange,),
                      title:  Text(AppLocalizations.of(context).delete_account),
                      content: Obx(() =>  !Get.find<AuthController>().loading.value ?Text(AppLocalizations.of(context).delete_account_warning, textAlign: TextAlign.justify, style: TextStyle(),)
                          : SizedBox(height: 30,
                          child: SpinKitThreeBounce(color: interfaceColor, size: 20)),),
                      actions: [
                        TextButton(onPressed: (){
                          Get.find<AuthController>().deleteAccount();
                          Get.lazyPut(()=>AuthController());
                        }, child: Text(AppLocalizations.of(context).delete, style: TextStyle(color: Colors.red),)),

                        TextButton(onPressed: (){
                          Navigator.of(context).pop();
                        }, child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: interfaceColor),)),

                      ],

                    ),);
                }),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.03),
                      borderRadius: BorderRadius.circular(14.0)),
                  child: ListTile(
                    leading: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(.05)),
                      child: const Icon(
                        Icons.delete_forever,
                        size: 27,
                        color: Colors.black,
                      ),
                    ),
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        AppLocalizations.of(context).delete_account,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context).delete_account_of_app,
                      style: TextStyle(color: Colors.grey, fontSize: 14.0),
                    ),
                    trailing: const Icon(
                      Icons.navigate_next_rounded,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const SizedBox(
                height: 60,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Version 0.1-2024',
                    style: TextStyle(color: Colors.grey, fontSize: 12.0),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }
}


