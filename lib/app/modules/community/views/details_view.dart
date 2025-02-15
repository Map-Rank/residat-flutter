import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/community/widgets/comment_loading_widget.dart';
import 'package:mapnrank/app/modules/community/widgets/comment_widget.dart';
import 'package:mapnrank/app/routes/app_routes.dart';
import '../../../../color_constants.dart';
import '../../../models/user_model.dart';
import '../../../services/global_services.dart';
import '../../global_widgets/post_card_widget.dart';

class DetailsView extends GetView<CommunityController> {
  DetailsView({
    this.post,
    this.imageScrollController,
    super.key
  });
  Post? post;
  ScrollController? imageScrollController;




  @override
  Widget build(BuildContext context) {
    imageScrollController = ScrollController();
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                    child: FadeInImage(
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                        image: NetworkImage(controller.postDetails!.value.user!.avatarUrl!, headers: GlobalService.getTokenHeaders()),
                        placeholder: const AssetImage(
                            "assets/images/loading.gif"),
                        imageErrorBuilder:
                            (context, error, stackTrace) {
                          return Image.asset(
                              "assets/images/user_admin.png",
                              width: 50,
                              height: 50,
                              fit: BoxFit.fitWidth);
                        }
                    )
                ),
                const SizedBox(
                  width: 10,
                ),

                SizedBox(
                  width: Get.width*0.48,
                    child: Text('${controller.postDetails!.value.user!.firstName!} ${controller.postDetails!.value.user!.lastName!}', style: Get.textTheme.headlineMedium!.merge(const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)), overflow: TextOverflow.ellipsis,)),


              ]
          ).paddingOnly(left: 5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
            onPressed: () => {
              Navigator.pop(context),
              //Get.back()
            },
          ),
        ),
        bottomSheet: Container(
          color: Colors.black,
          height: 140,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    showModalBottomSheet(context: context,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                      builder: (context) {
                        return Container(
                          width: Get.width,
                          height: Get.height/2,
                          padding: EdgeInsets.all(20),
                          decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                          child: Text(controller.postDetails!.value.content!.replaceAllMapped(RegExp(r'<p>|<\/p>'), (match) {
                            return match.group(0) == '</p>' ? '\n' : ''; // Replace </p> with \n and remove <p>
                          })
                              .replaceAll(RegExp(r'^\s*\n', multiLine: false), ''), style: const TextStyle(color: Colors.black), ).marginOnly(bottom: 50),

                        );
                      },
                    );
                  },
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                          child: Text(controller.postDetails!.value.content!.replaceAllMapped(RegExp(r'<p>|<\/p>'), (match) {
                            return match.group(0) == '</p>' ? '\n' : ''; // Replace </p> with \n and remove <p>
                          })
                              .replaceAll(RegExp(r'^\s*\n', multiLine: false), ''), style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis,)).marginAll(20)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: (){
                        print(controller.postDetails.value.likeTapped!.value);

                          if( controller.postDetails.value.likeTapped!.value){
                            controller.postDetails.value.likeTapped!.value = false;
                            controller.postDetails.value.likeCount = controller.postDetails.value.likeCount!-1;

                          }
                          else{
                            controller.postDetails.value.likeTapped!.value = true;
                            controller.postDetails.value.likeCount = controller.postDetails.value.likeCount!+1;

                          }
                          // controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].likeTapped.value
                          // = !controller.postDetails.value.likeTapped!.value;
                          controller.likeUnlikePost(controller.postDetails.value.postId!,  controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0]));

                      },
                      icon: Obx(() => controller.postDetails.value.likeTapped!.value?
                      FaIcon(FontAwesomeIcons.solidHeart, color: interfaceColor,)
                          :FaIcon(FontAwesomeIcons.heart, color: Colors.white,),),
                      label:  Obx(() => Text('${controller.postDetails.value.likeCount!.value}', style: TextStyle(color: Colors.white,),)),),


                    TextButton.icon(
                        onPressed: () async{
                          Get.toNamed(Routes.COMMENT_VIEW);
                          controller.postDetails = await controller.getAPost(controller.postDetails!.value.postId!);
                          controller.commentList.value = controller.postDetails.value.commentList!;
                          controller.commentCount!.value = controller.postDetails.value.commentCount!.value;

                        },
                        icon: const FaIcon(FontAwesomeIcons.comment, color: Colors.white,),
                        label: Text('${controller.postDetails.value.commentCount}', style:  TextStyle(color: Colors.white,),)),
                    TextButton.icon(
                        onPressed: () async{

                            // controller.shareCount?.value = (controller.shareCount!.value + 1);
                            // controller.sharedPost.add(post);
                          controller.postDetails.value.shareCount!.value = controller.postDetails.value.shareCount!.value+1;
                            await controller.sharePost(controller.postDetails.value.postId!, controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0]) );


                        },
                        icon: const FaIcon(FontAwesomeIcons.share, color: Colors.white,),
                        label: Obx(() => Text('${controller.postDetails.value.shareCount!.value}', style: TextStyle(color: Colors.white,),)))

                  ],)

              ]
          ),
        ),
        body: Theme(
          data: ThemeData(
            //canvasColor: Colors.yellow,
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Get.theme.colorScheme.secondary,
                //background: Colors.red,
                secondary: validateColor,
              )
          ),
          child: Container(
            decoration: const BoxDecoration(color: Colors.black,
            ),
            child:   Column(
              children:
              [
                if(controller.postDetails.value.imagesUrl!.isNotEmpty)...[
                  if( controller.postDetails.value.imagesUrl!.length == 1)...[
                    Expanded(
                      child: GestureDetector(
                        //onTap: onPictureTapped,
                        child: ClipRect(
                            child: FadeInImage(
                              width: Get.width,
                              height: Get.height,
                              fit: BoxFit.fitWidth,
                              image:  NetworkImage(
                                  '${controller.postDetails.value.imagesUrl![0]['url']}',
                                  headers: GlobalService.getTokenHeaders()
                              ),
                              placeholder: const AssetImage(
                                  "assets/images/loading.gif"),
                              imageErrorBuilder:
                                  (context, error, stackTrace) {
                                return Image.asset(
                                    "assets/images/loading.gif",
                                    width: Get.width,
                                    height: Get.height,
                                    fit: BoxFit.fitWidth);
                              },
                            )

                        ),
                      ),
                    )
                  ]
                  else...[
                    Expanded(
                      //width: Get.width,
                      //height: Get.height*0.7,
                      child: ListView.builder(
                        controller: imageScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.postDetails.value.imagesUrl?.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              GestureDetector(
                                //onTap: onPictureTapped,
                                child: FadeInImage(
                                  width: Get.width,
                                  height: Get.height*0.8,
                                  fit: BoxFit.fitWidth,
                                  image:  NetworkImage(
                                      '${controller.postDetails.value.imagesUrl![index]['url']}',
                                      headers: GlobalService.getTokenHeaders()
                                  ),
                                  placeholder: const AssetImage(
                                      "assets/images/loading.gif"),
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Image.asset(
                                        "assets/images/loading.gif",
                                        width: Get.width,
                                        height: Get.height,
                                        fit: BoxFit.fitWidth);
                                  },
                                ).marginOnly(right: 10,),
                              ),
                              Positioned(
                                top: Get.height*0.8/2.2,
                                child: SizedBox(
                                  width: Get.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if(index > 0)...[
                                        GestureDetector(
                                          child: Icon(Icons.arrow_back_ios_outlined, color: Colors.white,),
                                          onTap: (){
                                            // imageScrollController?.animateTo(
                                            //   imageScrollController!.position.pixels - Get.width ,
                                            //   duration: const Duration(milliseconds: 300),
                                            //   curve: Curves.easeInOut,
                                            // );
                                            imageScrollController!.jumpTo(imageScrollController!.position.pixels - Get.width);

                                          },
                                        )
                                      ],
                                      Spacer(),
                                      if(index < controller.postDetails.value.imagesUrl!.length - 1)...[
                                        GestureDetector(
                                          child: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white,),
                                          onTap: (){
                                            imageScrollController!.jumpTo(imageScrollController!.position.pixels + Get.width);
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );

                        },
                      ),
                    )
                  ]

                  ,
                ],



              ],).paddingOnly(bottom: 80),
          ),
        )
    );
  }



  Widget buildLoader() {
    return Container(
        width: 100,
        height: 100,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Image.asset(
            'assets/img/loading.gif',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 100,
          ),
        ));
  }
}
