import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mapnrank/app/modules/global_widgets/block_button_widget.dart';
import 'package:mapnrank/app/modules/global_widgets/text_field_widget.dart';
import 'package:mapnrank/app/modules/profile/controllers/profile_controller.dart';
import 'package:mapnrank/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../services/global_services.dart';
import '../../../services/permission_service.dart';

class AccountView extends GetView<ProfileController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,

        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: interfaceColor),
          onPressed: () => {
            controller.profileImage.value = File('assets/images/loading.gif'),
            controller.loadProfileImage.value = false,
            Navigator.pop(context),
            //Get.back()
          },
        ),
        title:Text(
          AppLocalizations.of(context).general,
          style: TextStyle(color: Colors.black87, fontSize: 30.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Row(
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
                          child: ClipOval(
                            child: Image.file(
                              controller.profileImage.value,
                              fit: BoxFit.cover,
                              width: 130,
                              height: 130,
                            ),
                          ),
                        )
                      ,),


                    Positioned(
                      bottom: 2,
                      right: 3,
                      child: GestureDetector(
                        onTap: () async {
                          selectCameraOrGalleryProfileImage(context);

                        },
                        child: Container(
                          height: 32,
                          width: 32,
                          decoration: const BoxDecoration(
                              color: interfaceColor,
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ).marginSymmetric(vertical: 30),

            Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if(controller.currentUser.value.type?.toUpperCase() != 'COUNCIL')...[
                    TextFieldWidget(
                      textController: controller.firstNameController,
                      readOnly: false,
                      labelText: AppLocalizations.of(context).first_name,
                      hintText: "John",
                      //initialValue: '',
                      keyboardType: TextInputType.text,
                      // onSaved: (input) =>
                      //     controller.currentUser.value.firstName = input,
                      onChanged: (value) => {
                        controller.firstNameController.text = value,
                        controller.currentUser.value.firstName = controller.firstNameController.text,
                      },
                      validator: (input) => input!.length < 3
                          ? AppLocalizations.of(context).enter_three_characters
                          : null,
                      iconData: Icons.person,
                      key: null,
                      errorText: '',
                      prefixIcon: const Icon(Icons.person_2_outlined),
                      suffixIcon: const Icon(null),
                      suffix: const Icon(null),
                    ),
                    TextFieldWidget(
                      textController: controller.lastNameController,
                      isFirst: true,
                      readOnly: false,
                      labelText: AppLocalizations.of(context).last_name,
                      hintText: "Doe",
                      //initialValue: '',
                      keyboardType: TextInputType.text,
                      // onSaved: (input) =>
                      //     controller.currentUser.value.lastName = input,
                      onChanged: (value) => {
                        controller.lastNameController.text = value,
                        controller.currentUser.value.lastName = controller.lastNameController.text,
                      },
                      validator: (input) => input!.length < 3
                          ? AppLocalizations.of(context).enter_three_characters
                          : null,
                      iconData: Icons.person,
                      key: null,
                      errorText: '',
                      prefixIcon: const Icon(Icons.person_2_outlined),
                      suffixIcon: const Icon(null),
                      suffix: const Icon(null),
                    ),
                    TextFieldWidget(
                      textController: controller.emailController,
                      readOnly: true,
                      labelText: AppLocalizations.of(context).email,
                      hintText: "johndoe@gmail.com",
                      //initialValue: '',
                      keyboardType: TextInputType.emailAddress,
                      // onSaved: (input) =>
                      //     controller.currentUser.value.email = input,
                      // onChanged: (value) =>
                      //     {controller.currentUser.value.email = value},
                      validator: (input) {
                        return !input!.contains('@')
                            ? AppLocalizations.of(context).enter_valid_email_address
                            : null;
                      },
                      iconData: Icons.alternate_email,
                      key: null,
                      errorText: '',
                      prefixIcon: const Icon(Icons.email_outlined),
                      suffixIcon: const Icon(null),
                      suffix: const Icon(null),
                    ),
                    TextFieldWidget(
                      textController: controller.birthdateController,
                      readOnly: false,
                      labelText: AppLocalizations.of(context).date_of_birth,
                      //hintText: "Male",
                      //initialValue: '',
                      keyboardType: TextInputType.number,
                      // onSaved: (input) =>
                      //     controller.currentUser.value.phoneNumber = input,
                      // onChanged: (value) =>
                      //     {controller.currentUser.value.phoneNumber = value},
                      iconData: Icons.calendar_month,
                      key: null,
                      errorText: '',
                      prefixIcon: Icon(Icons.calendar_month),
                      suffix:const Icon(null), suffixIcon: Icon(null),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.of(context).phone_number,
                          style: Get.textTheme.labelMedium,
                          textAlign:TextAlign.start,
                        ).paddingOnly(left: 10, right: 20),
                        SizedBox(height: 10,),
                        IntlPhoneField(
                          initialValue: controller.phoneNumberController.text,
                          validator: (phone) {
                            // Check if the field is empty and return null to skip validation
                            if (phone!.completeNumber.isEmpty) {
                              return AppLocalizations.of(context).input_phone_number;
                            }
                            return AppLocalizations.of(context).input_phone_number;

                          },

                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid, color: Get.theme.focusColor.withOpacity(0.5) ), borderRadius: BorderRadius.circular(10),),
                            border:OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid, color: Get.theme.focusColor.withOpacity(0.5) ), borderRadius: BorderRadius.circular(10),),
                            contentPadding: EdgeInsets.all(10),
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            hintText: '677777777',
                            labelText: AppLocalizations.of(context).phone_number,
                            suffixIcon: Icon(Icons.phone_android_outlined, color: Colors.white,),
                          ),
                          //initialCountryCode: 'CM',
                          style:  Get.textTheme.headlineMedium,
                          onSaved: (phone) {
                            controller.currentUser.value.phoneNumber = phone?.completeNumber;
                          },
                          onChanged:(value) => {
                            controller.currentUser.value.phoneNumber = value.completeNumber,
                            print('${value.completeNumber}'),
                          },
                        ),
                      ],
                    ),

                    TextFieldWidget(
                      textController: controller.genderController,
                      readOnly: true,
                      labelText: AppLocalizations.of(context).gender,
                      hintText: "Male",
                      //initialValue: '',
                      keyboardType: TextInputType.number,
                      // onSaved: (input) =>
                      //     controller.currentUser.value.phoneNumber = input,
                      // onChanged: (value) =>
                      //     {controller.currentUser.value.phoneNumber = value},
                      iconData: Icons.person,
                      key: null,
                      errorText: '',
                      prefixIcon:const Icon(Icons.groups_outlined),
                      suffix:const Icon(null), suffixIcon: Icon(null),
                    ),
                  ]
                  else...[
                    TextFieldWidget(
                      textController: controller.firstNameController,
                      readOnly: false,
                      labelText: AppLocalizations.of(context).institution,
                      hintText: "John",
                      //initialValue: '',
                      keyboardType: TextInputType.text,
                      // onSaved: (input) =>
                      //     controller.currentUser.value.firstName = input,
                      onChanged: (value) => {
                        controller.firstNameController.text = value,
                        controller.currentUser.value.firstName = controller.firstNameController.text,
                      },
                      validator: (input) => input!.length < 3
                          ? AppLocalizations.of(context).enter_three_characters
                          : null,
                      iconData: Icons.person,
                      key: null,
                      errorText: '',
                      prefixIcon: const Icon(Icons.person_2_outlined),
                      suffixIcon: const Icon(null),
                      suffix: const Icon(null),
                    ),
                    TextFieldWidget(
                      textController: controller.emailController,
                      readOnly: true,
                      labelText: AppLocalizations.of(context).email,
                      hintText: "johndoe@gmail.com",
                      //initialValue: '',
                      keyboardType: TextInputType.emailAddress,
                      // onSaved: (input) =>
                      //     controller.currentUser.value.email = input,
                      // onChanged: (value) =>
                      //     {controller.currentUser.value.email = value},
                      validator: (input) {
                        return !input!.contains('@')
                            ? AppLocalizations.of(context).enter_valid_email_address
                            : null;
                      },
                      iconData: Icons.alternate_email,
                      key: null,
                      errorText: '',
                      prefixIcon: const Icon(Icons.email_outlined),
                      suffixIcon: const Icon(null),
                      suffix: const Icon(null),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.of(context).phone_number,
                          style: Get.textTheme.labelMedium,
                          textAlign:TextAlign.start,
                        ).paddingOnly(left: 10, right: 20),
                        SizedBox(height: 10,),
                        IntlPhoneField(
                          initialValue: controller.phoneNumberController.text,
                          validator: (phone) {
                            // Check if the field is empty and return null to skip validation
                            if (phone!.completeNumber.isEmpty) {
                              return AppLocalizations.of(context).input_phone_number;
                            }
                            return AppLocalizations.of(context).input_phone_number;

                          },

                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid, color: Get.theme.focusColor.withOpacity(0.5) ), borderRadius: BorderRadius.circular(10),),
                            border:OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid, color: Get.theme.focusColor.withOpacity(0.5) ), borderRadius: BorderRadius.circular(10),),
                            contentPadding: EdgeInsets.all(10),
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            hintText: '677777777',
                            labelText: AppLocalizations.of(context).phone_number,
                            suffixIcon: Icon(Icons.phone_android_outlined, color: Colors.white,),
                          ),
                          //initialCountryCode: 'CM',
                          style:  Get.textTheme.headlineMedium,
                          onSaved: (phone) {
                            controller.currentUser.value.phoneNumber = phone?.completeNumber;
                          },
                          onChanged:(value) => {
                            controller.currentUser.value.phoneNumber = value.completeNumber,
                            print('${value.completeNumber}'),
                          },
                        ),
                      ],
                    ),

                  ]

                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ),
          if(controller.currentUser.value.type?.toUpperCase() != 'COUNCIL')...[
            Obx(() => !controller.updateUserInfo.value?BlockButtonWidget(
                onPressed: () async {
                  controller.updateUser();
                },
                color: Get.theme.colorScheme.secondary,
                text: Text(
                  AppLocalizations.of(context).update_information,
                  style: TextStyle(
                    color: Get.theme.primaryColor,
                    fontSize: 20.0,
                  ),
                )):BlockButtonWidget(
              onPressed: () async {

              },
              color: Get.theme.colorScheme.secondary,
              text: const SizedBox(height: 30,
                  child: SpinKitThreeBounce(color: Colors.white, size: 20)),
            ),)
          ]

          ],
        ),
      ),
    );
  }

  selectCameraOrGalleryProfileImage(BuildContext context){
    showDialog(
        context: context,
        builder: (_){
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
                height: 170,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      onTap: ()async{
                        final bool cameraStatus = await GetPermissions.getCameraPermission();
                        if(cameraStatus){
                          await controller.profileImagePicker('camera');
                          controller.loadProfileImage.value = true;
                        }

                        //Navigator.pop(Get.context);


                      },
                      leading: const Icon(FontAwesomeIcons.camera),
                      title: Text(AppLocalizations.of(Get.context!).take_picture, style: Get.textTheme.headlineMedium?.merge(const TextStyle(fontSize: 15))),
                    ),
                    ListTile(
                      onTap: ()async{
                         final bool galleryStatus = await GetPermissions.getStoragePermission();
                         if(galleryStatus){
                          await controller.profileImagePicker('gallery');
                          controller.loadProfileImage.value = true;
                        }


                        //Navigator.pop(Get.context);

                      },
                      leading: const Icon(FontAwesomeIcons.image),
                      title: Text(AppLocalizations.of(Get.context!).upload_image, style: Get.textTheme.headlineMedium?.merge(const TextStyle(fontSize: 15))),
                    )
                  ],
                )
            ),
          );
        });
  }
}