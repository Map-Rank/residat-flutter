import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../color_constants.dart';
import '../../../../common/ui.dart';
import '../../../models/notification_model.dart' as model;
import '../../../models/notification_model.dart';
import '../../../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../global_widgets/read_more_text.dart';

class NotificationItemWidget extends StatelessWidget {
  NotificationItemWidget({Key? key, required this.notification,  required this.icon, required this.onDismissed, required this.onTap}) : super(key: key);
  final NotificationModel notification;
  final ValueChanged<model.NotificationModel> onDismissed;
  final ValueChanged<model.NotificationModel> onTap;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(notification.date!);
    return notification.userModel?.userId == Get.find<AuthService>().user.value.userId? Dismissible(
      key: Key(this.notification.hashCode.toString()),
      background: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 20,),
        decoration: Ui.getBoxDecoration(color: Colors.red),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
          ),
        ),
      ),
      onDismissed: (direction) {
        onDismissed(this.notification);
        // Then show a snackbar
      },
      child: GestureDetector(
        onTap: () {
          onTap(notification);
        },
        child: Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 10,),
          decoration: BoxDecoration(
              color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2))
          ),
          //Ui.getBoxDecoration(color: this.notification.isSeen ? Get.theme.primaryColor : Get.theme.focusColor.withOpacity(0.15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  icon,


                ],
              ),
              SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[

                   Row(
                     //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Column(
                         mainAxisAlignment: MainAxisAlignment.start,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                               this.notification.title!,
                               overflow: TextOverflow.ellipsis,
                               maxLines: 3,
                               style: TextStyle(
                                   fontWeight:  FontWeight.bold, fontSize: 14, color: buttonColor)
                             //notification.isSeen ? FontWeight.normal : FontWeight.bold, fontSize: 14, color: buttonColor),
                           ),
                           RichText(text: TextSpan(
                               children: [
                                 TextSpan(
                                     text: "${AppLocalizations.of(context).created} ${AppLocalizations.of(context).on}: ",
                                     style: Get.textTheme.bodyLarge?.merge(TextStyle(
                                         fontWeight: FontWeight.normal,fontSize: 12, color: Color(0xff242424).withOpacity(0.9)))
                                 ),
                                 TextSpan(
                                     text: "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}",
                                     style: Get.textTheme.bodySmall?.merge(TextStyle(
                                         fontWeight: FontWeight.w600,fontSize: 12, color: Colors.black38))
                                 ),
                                 TextSpan(
                                     text: " ${AppLocalizations.of(context).at}: ",
                                     style: Get.textTheme.bodyLarge?.merge(TextStyle(
                                         fontWeight: FontWeight.normal,fontSize: 12, color: Color(0xff242424).withOpacity(0.9)))
                                 ),
                                 TextSpan(
                                     text: "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}",
                                     style: Get.textTheme.bodySmall?.merge(TextStyle(
                                         fontWeight: FontWeight.w600,fontSize: 12, color: Colors.black38))
                                 ),


                               ]
                           )),

                           RichText(text: TextSpan(
                               children: [
                                 TextSpan(
                                     text: "${AppLocalizations.of(context).by}: ",
                                     style: Get.textTheme.bodySmall?.merge(TextStyle(
                                         fontWeight: FontWeight.w600,fontSize: 12, color: Color(0xff242424).withOpacity(0.9)))
                                 ),
                                 TextSpan(
                                     text: '${notification.userModel!.lastName} ${notification.userModel!.firstName}',
                                     style: Get.textTheme.bodyLarge?.merge(TextStyle(
                                         fontWeight: FontWeight.normal,fontSize: 12, color: Colors.black))
                                 ),
                                 TextSpan(
                                     text: "    Zone: ",
                                     style: Get.textTheme.bodySmall?.merge(TextStyle(
                                         fontWeight: FontWeight.w600,fontSize: 12, color: Color(0xff242424).withOpacity(0.9)))
                                 ),
                                 TextSpan(
                                     text: " ${notification.zoneName} ",
                                     style: Get.textTheme.bodyLarge?.merge(TextStyle(
                                         fontWeight: FontWeight.normal,fontSize: 12, color: Colors.black))
                                 ),

                               ]
                           )),
                         ],
                       ),
                       Spacer(),

                       Align(
                         alignment: Alignment.topRight,
                           child: PopupMenuButton(
                             itemBuilder: (context) => <PopupMenuEntry<String>>[
                             PopupMenuItem<String>(
                               value: 'Delete',
                               child: Text('Delete'),
                             ),

                           ],
                               onSelected: (value) async {
                                 if(value == 'Delete'){
                                   onDismissed(notification);
                                 }
                               },
                               child: Icon(Icons.more_vert_outlined),)
                       )

                     ],

                   ),


                    SizedBox(height: 10,),
                    ReadMoreText(
                        notification.content! == null? '':notification.content!?.replaceAllMapped(RegExp(r'<p>|<\/p>'), (match) {
                          return match.group(0) == '</p>' ? '\n' : ''; // Replace </p> with \n and remove <p>
                        })
                            .replaceAll(RegExp(r'^\s*\n', multiLine: false), ''), // Remove empty lines),
                        maxLines: 3,
                        trimMode: TrimMode.line,
                        textStyle: Get.textTheme.displayMedium!),

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ): GestureDetector(
      onTap: () {
        onTap(notification);
      },
      child:  Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 10,),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2))
        ),
        //Ui.getBoxDecoration(color: this.notification.isSeen ? Get.theme.primaryColor : Get.theme.focusColor.withOpacity(0.15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                icon,


              ],
            ),
            SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[

                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              this.notification.title!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: TextStyle(
                                  fontWeight:  FontWeight.bold, fontSize: 14, color: buttonColor)
                            //notification.isSeen ? FontWeight.normal : FontWeight.bold, fontSize: 14, color: buttonColor),
                          ),
                          RichText(text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "${AppLocalizations.of(context).created} ${AppLocalizations.of(context).on}: ",
                                    style: Get.textTheme.bodyLarge?.merge(TextStyle(
                                        fontWeight: FontWeight.normal,fontSize: 12, color: Color(0xff242424).withOpacity(0.9)))
                                ),
                                TextSpan(
                                    text: "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}",
                                    style: Get.textTheme.bodySmall?.merge(TextStyle(
                                        fontWeight: FontWeight.w600,fontSize: 12, color: Colors.black38))
                                ),
                                TextSpan(
                                    text: " ${AppLocalizations.of(context).at}: ",
                                    style: Get.textTheme.bodyLarge?.merge(TextStyle(
                                        fontWeight: FontWeight.normal,fontSize: 12, color: Color(0xff242424).withOpacity(0.9)))
                                ),
                                TextSpan(
                                    text: "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}",
                                    style: Get.textTheme.bodySmall?.merge(TextStyle(
                                        fontWeight: FontWeight.w600,fontSize: 12, color: Colors.black38))
                                ),


                              ]
                          )),

                          RichText(text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "${AppLocalizations.of(context).by}: ",
                                    style: Get.textTheme.bodySmall?.merge(TextStyle(
                                        fontWeight: FontWeight.w600,fontSize: 12, color: Color(0xff242424).withOpacity(0.9)))
                                ),
                                TextSpan(
                                    text: '${notification.userModel!.lastName} ${notification.userModel!.firstName}',
                                    style: Get.textTheme.bodyLarge?.merge(TextStyle(
                                        fontWeight: FontWeight.normal,fontSize: 12, color: Colors.black))
                                ),
                                TextSpan(
                                    text: "    Zone: ",
                                    style: Get.textTheme.bodySmall?.merge(TextStyle(
                                        fontWeight: FontWeight.w600,fontSize: 12, color: Color(0xff242424).withOpacity(0.9)))
                                ),
                                TextSpan(
                                    text: " ${notification.zoneName} ",
                                    style: Get.textTheme.bodyLarge?.merge(TextStyle(
                                        fontWeight: FontWeight.normal,fontSize: 12, color: Colors.black))
                                ),

                              ]
                          )),
                        ],
                      ),
                      Spacer(),

                      Align(
                          alignment: Alignment.topRight,
                          child: PopupMenuButton(
                            itemBuilder: (context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'Delete',
                                child: Text('Delete'),
                              ),

                            ],
                            onSelected: (value) async {
                              if(value == 'Delete'){
                                onDismissed(notification);
                              }
                            },
                            child: Icon(Icons.more_vert_outlined),)
                      )

                    ],

                  ),


                  SizedBox(height: 10,),
                  ReadMoreText(
                      notification.content! == null? '':notification.content!?.replaceAllMapped(RegExp(r'<p>|<\/p>'), (match) {
                        return match.group(0) == '</p>' ? '\n' : ''; // Replace </p> with \n and remove <p>
                      })
                          .replaceAll(RegExp(r'^\s*\n', multiLine: false), ''), // Remove empty lines),
                      maxLines: 3,
                      trimMode: TrimMode.line,
                      textStyle: Get.textTheme.displayMedium!),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
