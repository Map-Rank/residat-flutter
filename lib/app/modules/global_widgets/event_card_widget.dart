import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/services/global_services.dart';
import '../../../color_constants.dart';
import '../community/controllers/community_controller.dart';
import '../community/widgets/comment_widget.dart';


class EventCardWidget extends StatelessWidget {
  EventCardWidget({Key? key,
    this.eventCreatorId,
    this.eventOrganizer,
    this.sectors,
    this.zone,
    this.content,
    this.eventId,
    this.publishedDate,
    this.image,
    this.title,
    this.isAllEventsPage,
    this.popUpWidget,
  }) : super(key: key);

  final List? sectors;
  final String? publishedDate;
  final String? content;
  final String? title;
  final int? eventId;
  var zone;
  final int? eventCreatorId;
  final String? eventOrganizer;
  final String? image;
  Widget? popUpWidget;
  var isAllEventsPage;





  @override
  Widget build(BuildContext context) {


    return Card(
        color: Get.theme.primaryColor,
        shape: const RoundedRectangleBorder(
          side:  BorderSide(
              color: inactive, width: 0, style: BorderStyle.none
            //travelState != 'accepted' && isUser ? inactive : interfaceColor.withOpacity(0.4), width: 2
          ) ,
          //borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

                    InkWell(
                      onTap: () => showDialog(
                          context: context, builder: (_){
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Material(
                                  child: IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.close, size: 20))
                              ),
                              ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                child: FadeInImage(
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  image:  NetworkImage(image!, headers: {}),
                                  placeholder: const AssetImage(
                                      "assets/images/loading.gif"),
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Center(
                                        child: Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.white,
                                            child: const Center(
                                                child: Icon(Icons.person, size: 100)
                                            )
                                        )
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                      child: ClipOval(
                          child: FadeInImage(
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            image:  NetworkImage(image!, headers: {}),
                            placeholder: const AssetImage(
                                "assets/images/loading.gif"),
                            imageErrorBuilder:
                                (context, error, stackTrace) {
                              return Image.asset(
                                  "assets/images/user_admin.png",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fitWidth);
                            },
                          )
                      ),
                    ),
                    const SizedBox(width: 20,),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        SizedBox(
                            child: Text(title??'', style: Get.textTheme.headlineLarge),
                          width: !isAllEventsPage? Get.width/1.8:Get.width
                        ),
                        if(!isAllEventsPage)...[
                          popUpWidget!,
                        ]



                      ],


                    ),

        SizedBox(
          width: Get.width,
          height: 10,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,

            children: [
              const FaIcon(FontAwesomeIcons.locationDot, size: 10,).marginOnly(right: 10),
              SizedBox(
                width: Get.width/4,
                child: Text(zone.toString(), style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis,).marginOnly(right: 10),),
              const FaIcon(FontAwesomeIcons.solidCircle, size: 8,).marginOnly(right: 10),
              SizedBox(
                width: Get.width/4.5,
                  child: Text(publishedDate!, style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis,)),


              //Text("⭐️ ${this.rating}", style: TextStyle(fontSize: 13, color: appColor))
            ],
          ),
        ).marginOnly(bottom: 10),


                    // RichText(text: TextSpan(children: [
                    //   TextSpan(text: 'Organized by: ', style: TextStyle(color: Colors.black)),
                    //   TextSpan(text: eventOrganizer, style: TextStyle(color: Colors.black))
                    // ])).marginOnly(bottom: 10),

                    Text(content??''.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''), maxLines: 3, style: Get.textTheme.displayMedium?.merge(TextStyle(overflow: TextOverflow.ellipsis,) )),



                  ],
                ),
              ),


            ]
        ).paddingSymmetric(horizontal: 10, vertical: 10)
    );
  }

}