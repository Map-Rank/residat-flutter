import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/modules/profile/controllers/profile_controller.dart';
import 'package:mapnrank/common/helper.dart';

import '../../../../color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../common/ui.dart';
import '../../../services/permission_service.dart';
import '../../global_widgets/block_button_widget.dart';

class ContactUsView extends GetView<ProfileController> {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: interfaceColor),
          onPressed: () => {
            Navigator.pop(context),
          },
        ),
        title:Text(
          AppLocalizations.of(context).contact_us,
          style: TextStyle(color: Colors.black87, fontSize: 30.0),
        ),
      ),
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
             SizedBox(
              height: 60,
              child: Text(
                  AppLocalizations.of(context).contact_us_explanation,
                style: Get.textTheme.displayMedium!
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: Get.width,
              height: 70,
              child: TextFormField(
                controller: controller.feedbackController,
                maxLines: 80,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).enter_feedback_here,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(width: 0.4, color: Colors.grey,)),
                  focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(width: 0.4, color: Colors.grey,)),

                ),
                onChanged: (value) {
                  controller.feedbackController.text = value;
                },

              ),
            ).marginOnly(bottom: 20),
            RichText(text: TextSpan(
                children: [
                  WidgetSpan(child:Text(AppLocalizations.of(context).input_image, style: TextStyle(fontSize: 16),),),
                  WidgetSpan(child:Text('  (${AppLocalizations.of(context).optional})', style: TextStyle(fontSize: 12, color: Colors.grey),),),

                ]
            )).marginOnly(bottom: 20),
            Row(
              children: [
                Obx(() {
                  if(!controller.loadFeedbackImage.value) {
                    return buildLoader();
                  } else {
                    return controller.feedbackImage !=null? ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Image.file(
                        controller.feedbackImage,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    ):
                    buildLoader();
                  }
                }
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {

                    await selectCameraOrGalleryFeedbackImage(context);
                    controller.loadFeedbackImage.value = false;

                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Get.theme.focusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.add_photo_alternate_outlined, size: 42, color: Get.theme.focusColor.withOpacity(0.4)),
                  ),
                )
              ],
            ).marginOnly(bottom: 20, left: 20),
            Text(AppLocalizations.of(context).rate_us, style: TextStyle(fontSize: 16)).marginOnly(top: 10, bottom: 10),
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(5, (index) {
                  return InkWell(
                    onTap: () {
                      controller.rating.value = (index + 1).toInt();
                    },
                    child: index < controller.rating.value
                        ? Icon(Icons.star, size: 50, color: Color(0xFFFFB24D))
                        : Icon(Icons.star_border, size: 50, color: Color(0xFFFFB24D)),
                  );
                }),
              );
            }).marginOnly(bottom: Get.height/10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: Get.width,
                  child: BlockButtonWidget(color: interfaceColor,
                      text: Text(AppLocalizations.of(context).submit, style: TextStyle(color: Colors.white),),
                      onPressed: () async{
                        if(controller.feedbackController.text.isNotEmpty){
                          if(controller.rating.value != 0){
                            await controller.sendFeedback();
                            Navigator.of(context).pop();
                          }
                          else{
                            Get.showSnackbar(Ui.warningSnackBar(message: AppLocalizations.of(context).please_rate_us));
                          }

                        }
                        else{
                          Get.showSnackbar(Ui.warningSnackBar(message: AppLocalizations.of(context).please_write_feedback));
                        }

                      } ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: Get.width,
                  decoration:BoxDecoration(
                    border: Border.all(color: interfaceColor),
                    borderRadius: BorderRadius.circular(20),

                  ),
                  //width: Get.width/2,
                  child: MaterialButton(
                    onPressed: (){
                      if(controller.feedbackController.text.isNotEmpty){
                        controller.launchWhatsApp(controller.feedbackController.text);
                      }
                      else{
                        Get.showSnackbar(Ui.warningSnackBar(message: 'Please write a feedback'));
                      }

                    },
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    color: Colors.white,
                    disabledElevation: 0,
                    disabledColor: Get.theme.focusColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Wrap(
                      children: [
                        Icon(FontAwesomeIcons.whatsapp, color: interfaceColor,),
                        SizedBox(width: 10,),
                        Text(AppLocalizations.of(context).send_via_whatsapp)
                      ],
                    ),
                    elevation: 0,
                  ),
                )


              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoader() {
    return SizedBox(
        width: 100,
        height: 100,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Image.asset(
            'assets/images/loading.gif',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 100,
          ),
        ));
  }

  selectCameraOrGalleryFeedbackImage(BuildContext context){
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
                          await controller.feedbackImagePicker('camera');
                        }

                        //Navigator.pop(Get.context);


                      },
                      leading: const Icon(FontAwesomeIcons.camera),
                      title: Text(AppLocalizations.of(Get.context!).take_picture, style: Get.textTheme.headlineMedium?.merge(const TextStyle(fontSize: 15))),
                    ),
                    ListTile(
                      onTap: ()async{
                        final bool cameraStatus = await GetPermissions.getStoragePermission();
                        if(cameraStatus){
                          await controller.feedbackImagePicker('gallery');
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