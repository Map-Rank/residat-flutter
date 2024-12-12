import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mapnrank/app/modules/global_widgets/block_button_widget.dart';
import 'package:mapnrank/app/routes/app_routes.dart';
import 'package:mapnrank/app/services/settings_services.dart';
import 'package:mapnrank/common/helper.dart';
import 'package:mapnrank/common/ui.dart';
import '../../../../color_constants.dart';
import '../../../models/setting_model.dart';
import '../../global_widgets/text_field_widget.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginView extends GetView<AuthController> {
  final Setting _settings = Get.find<SettingsService>().setting.value;


  //backgroundColor: Colors.white,
  @override
  Widget build(BuildContext context) {
    controller.loginFormKey = GlobalKey<FormState>();
    return WillPopScope(
      onWillPop: Helper().onWillPop,
      child: Scaffold(

        body: Stack(
          children: [
            Image.asset(
              'assets/images/background_login.jpeg',
              //fit: BoxFit.cover,
              width: Get.width,
              height: Get.height,
              fit: BoxFit.cover,

            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                padding: EdgeInsets.symmetric( horizontal:  20),
                margin: EdgeInsets.fromLTRB(5, 100, 5, 60),
                child: Form(
                  key: controller.loginFormKey,
                  child: ListView(
                    primary: true,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/logo.png',
                          //fit: BoxFit.cover,
                          width: 150,
                          height: 80,

                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                                onTap: (){
                                  controller.loginOrRegister.value = !controller.loginOrRegister.value;
                                  Get.offAllNamed(Routes.LOGIN);
                                },
                                child: Obx(() => Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: controller.loginOrRegister.value?interfaceColor:Colors.white,
                                      border: Border.all(width: 1, color: interfaceColor)
                                  ),
                                  child: Text(AppLocalizations.of(context).login, textAlign: TextAlign.center,
                                    style: TextStyle(color: controller.loginOrRegister.value?Colors.white:Colors.black),),),)
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                controller.loginOrRegister.value = !controller.loginOrRegister.value;
                                Get.offAllNamed(Routes.REGISTER);
                              },
                              child: Obx(() => Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: controller.loginOrRegister.value?Colors.white:interfaceColor,
                                    border: Border.all(width: 1, color: interfaceColor)
                                ),
                                child: Text(AppLocalizations.of(context).register,textAlign: TextAlign.center,
                                  style: TextStyle(color: !controller.loginOrRegister.value?Colors.white:Colors.black),),),),
                            ),
                          )


                        ],
                      ).marginOnly(left: 10, right: 10, bottom: 20),

                      Align(
                          alignment:Alignment.center,
                          child: Text(AppLocalizations.of(context).welcome_back.toUpperCase(), style: TextStyle(fontSize: 30, color: Colors.black, ), )).marginOnly(bottom: 30),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            Obx(() => !controller.loginWithPhoneNumber.value?
                            TextFieldWidget(
                              textController: controller.emailController,
                              isFirst: true,
                              focus: controller.emailFocus,
                              readOnly: false,
                              labelText: "${AppLocalizations.of(context).email} ${AppLocalizations.of(context).or} ${AppLocalizations.of(context).phone_number} ",
                              hintText: "johndoe@gmail.com",
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (input) => controller.currentUser.value.email = input,
                              onChanged: (value) => {
                                controller.currentUser.value.email = value,
                                if(value.isNum){
                                  controller.phoneController.text = value,
                                  controller.phoneFocus = true,
                                  controller.loginWithPhoneNumber.value = !controller.loginWithPhoneNumber.value,

                                }
                              },
                              validator: (input) {
                                return !input!.contains('@') ?  AppLocalizations.of(context).enter_valid_email_address : null;
                              },
                              prefixIcon: Image.asset("assets/icons/email.png", width: 22, height: 22),
                              iconData: Icons.mail_outline,
                              key: null, suffixIcon: const Icon(null), suffix: Icon(null),
                            )
                                :Column(
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
                                  controller: controller.phoneController,
                                  autofocus: controller.phoneFocus,
                                  keyboardType: TextInputType.text,
                                  validator: (phone) {
                                    // Check if the field is empty and return null to skip validation
                                    if (phone!.completeNumber.isEmpty) {
                                      return AppLocalizations.of(context).input_phone_number;
                                    }
                                    return  AppLocalizations.of(context).input_phone_number;

                                  },

                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid, color: Get.theme.focusColor.withOpacity(0.5) ), borderRadius: BorderRadius.circular(10),),
                                    border:OutlineInputBorder(borderSide:BorderSide(width: 1, style: BorderStyle.solid, color: Get.theme.focusColor.withOpacity(0.5) ), borderRadius: BorderRadius.circular(10),),
                                    contentPadding: EdgeInsets.all(10),
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                    hintText: '677777777',
                                    labelText:  AppLocalizations.of(context).phone_number,
                                    suffixIcon: Icon(Icons.phone_android_outlined, color: Colors.white,),
                                  ),
                                  initialCountryCode: 'CM',
                                  style:  Get.textTheme.headlineMedium,
                                  onSaved: (phone) {
                                    controller.currentUser.value.phoneNumber = phone?.completeNumber;
                                  },
                                  onChanged:(value) => {
                                    controller.currentUser.value.phoneNumber = value.completeNumber,
                                    if(!value.completeNumber.isNum){
                                      controller.emailController.text = value.number.toString(),
                                      controller.emailFocus = true,
                                      controller.loginWithPhoneNumber.value = !controller.loginWithPhoneNumber.value,


                                    }
                                  },
                                ),
                              ],
                            ),),

                            Obx(() {
                              return TextFieldWidget(
                                isFirst: true,
                                labelText: AppLocalizations.of(context).password,
                                hintText: "••••••••••••",
                                readOnly: false,
                                //initialValue: controller.password.value,
                                textController: TextEditingController(text: controller.currentUser.value.password),
                                onSaved: (input) => controller.currentUser.value.password = input,
                                onChanged: (value) => {
                                  controller.currentUser.value.password = value
                                },
                                validator: (input) {
                                  return input!.length < 6 ? AppLocalizations.of(context).enter_six_characters : null;

                                },
                                obscureText: controller.hidePassword.value,
                                iconData: Icons.lock_outline,
                                prefixIcon: Image.asset("assets/icons/password.png", width: 22, height: 22,),
                                keyboardType: TextInputType.visiblePassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    controller.hidePassword.value = !controller.hidePassword.value;
                                  },
                                  color: Theme.of(context).focusColor,
                                  icon: Icon(controller.hidePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                ),
                                suffix: Icon(null),
                              );
                            }),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  if( controller.currentUser.value.email != null){
                                    controller.emailController.text = controller.currentUser.value.email!;
                                  }
                                  Get.toNamed(Routes.FORGOT_PASSWORD);
                                },
                                child:  Text("${AppLocalizations.of(context).forgot_password}?",
                                  style: TextStyle(fontFamily: "poppins",fontSize: 14,
                                    color: interfaceColor,
                                  ),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),


                            Obx(() =>
                            !controller.loading.value?BlockButtonWidget(
                                key: Key('loginButton'),
                                onPressed: () async {
                                  if (controller.loginFormKey.currentState!.validate()) {
                                    controller.loginFormKey.currentState!.save();
                                    await controller.login();

                                  }
                                  },
                                color: Get.theme.colorScheme.secondary,
                                text: Text(
                                  AppLocalizations.of(context).login,
                                  style: Get.textTheme.headlineSmall?.merge(TextStyle(color: Get.theme.primaryColor)),
                                )
                            ).paddingSymmetric(vertical: 20, )
                                :BlockButtonWidget(
                              onPressed: () async {

                              },
                              color: Get.theme.colorScheme.secondary,
                              text: const SizedBox(height: 30,
                                  child: SpinKitThreeBounce(color: Colors.white, size: 20)),
                            ).paddingOnly(top: 20,)),

                            GestureDetector(
                              onTap: (){
                                Get.offAllNamed(Routes.INSTITUTIONAL_USER);

                              },
                                child: Text(AppLocalizations.of(context).register_institution,style: TextStyle(fontFamily: "poppins",fontSize: 15, color: interfaceColor, fontWeight: FontWeight.w500), textAlign: TextAlign.center,).paddingSymmetric(vertical: 20)),
                          ],
                        ),


                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
