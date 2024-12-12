import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../color_constants.dart';
import '../../../services/global_services.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({Key? key,
    required this.user,
    required this.comment,
    this.userAvatar,}) : super(key: key);

  final String user;
  final userAvatar;
  final String comment;



  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userAvatar,

          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  //borderRadius: BorderRadius.circular(20)
              ),
              //height: 150,
              width: Get.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user, style: Get.textTheme.headlineSmall?.merge(TextStyle(fontSize: 14, fontWeight: FontWeight.w600))!,).marginOnly(bottom: 10),
                  Wrap(
                    children: [
                      Text(comment, style: Get.textTheme.bodyMedium,)
                    ],
                  )
                ],

              ),
            ),
          ),

        ]
    );
  }
}