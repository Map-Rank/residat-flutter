import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/community/widgets/comment_widget.dart';
import 'package:mapnrank/app/modules/global_widgets/post_card_widget_boilerplate.dart';
import '../../../../color_constants.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/global_services.dart';
import '../../global_widgets/post_card_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommentView extends GetView<CommunityController> {
   CommentView({
     this.post,
    super.key
  });
  Post? post;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        bottomSheet: SizedBox(
          height: 100,
          child: Column(
              children: <Widget>[
                SizedBox(
                  child: Card(
                      elevation: 0,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: controller.commentController,
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                            cursorColor: Colors.black,
                            textInputAction:TextInputAction.done ,
                            maxLines: 20,
                            minLines: 2,
                            onChanged: (input) => controller.comment.value = input,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                //label: Text(AppLocalizations.of(context).description),
                                fillColor: Palette.background,
                                enabledBorder: InputBorder.none,
                                //filled: true,
                                prefixIcon: const Icon(Icons.description, color: Colors.grey,),
                                hintText: 'Share your thoughts ',
                                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                              suffixIcon: Obx(() => !controller.sendComment.value?GestureDetector(
                                  onTap: () async {
                                    controller.comment.value = controller.commentController.text;

                                    var result =  await controller.commentPost(controller.postDetails!.value.postId!, controller.comment.value);
                                    controller.commentCount!.value =  controller.commentCount!.value +1;
                                    controller.commentController.clear();
                                    controller.commentList.value = result.commentList;
                                  },
                                  child: FaIcon(FontAwesomeIcons.paperPlane,color: Colors.grey, )

                              ):SizedBox(
                                  height: 10,
                                  width: 10,
                                  child: SpinKitDualRing(color: interfaceColor, size: 10,))),

                          )
                      )
                  ),
                )
                )]
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(bottom: 100),
          //height:  Get.height,
          child: CustomScrollView(
            //controller: controller.scrollbarController,
            //primary: true,
            shrinkWrap: false,
            slivers: <Widget>[
              SliverAppBar(
                //expandedHeight: 80,
                floating: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(FontAwesomeIcons.arrowLeft, color: interfaceColor),
                  onPressed: () => {
                    controller.sendComment.value = false,
                    controller.likeTapped.value = false,
                    controller.commentList.clear(),
                    Navigator.pop(context),
                    //Get.back()
                  },
                ),

                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                ),

              ),


              Obx(() => SliverToBoxAdapter(
                child:  controller.loadingAPost.value? PostCardWidget(
                  followWidget:Obx(() => !controller.postDetails!.value.isFollowing!.value?
                  GestureDetector(
                      onTap: (){

                        controller.postDetails!.value.isFollowing!.value = !controller.postDetails!.value.isFollowing!.value;
                        controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].isFollowing.value
                        = !controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].isFollowing.value;
                        controller.followUser(controller.postDetails!.value.user!.userId!,
                            controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0]));


                      },
                      child: Text('+ ${AppLocalizations.of(context).follow}',style:Get.textTheme.displaySmall,)):
                  GestureDetector(
                      onTap: (){

                        controller.postDetails!.value.isFollowing!.value = !controller.postDetails!.value.isFollowing!.value;
                        controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].isFollowing.value
                        = !controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].isFollowing.value;
                        controller.unfollowUser(controller.postDetails!.value.user!.userId!,
                            controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0]));
                        //}
                      },
                      child: Text(AppLocalizations.of(context).following, style: Get.textTheme.displaySmall,textAlign: TextAlign.end,)
                  ),),
                  popUpWidget: SizedBox(),
                  isCommunityPage: true,
                  likeTapped: RxBool(controller.postDetails!.value.likeTapped!.value),
                  content: controller.postDetails!.value.content,
                  zone: controller.postDetails!.value.zone['name'],
                  publishedDate: controller.postDetails!.value.publishedDate,
                  postId: controller.postDetails!.value.postId,
                  commentCount: RxInt(controller.commentList.length),
                  likeCount: RxInt(controller.postDetails!.value.likeCount!.value),
                  shareCount: controller.postDetails.value.shareCount,
                  images: controller.postDetails!.value.imagesUrl,
                  user: controller.postDetails!.value.user!,
                    likeWidget:  Obx(() =>
                    controller.postDetails!.value.likeTapped!.value && controller.likeTapped.value?
                    const FaIcon(FontAwesomeIcons.solidHeart, color: interfaceColor,):
                    !controller.postDetails!.value.likeTapped!.value && controller.likeTapped.value?
                    const FaIcon(FontAwesomeIcons.heart,):
                    controller.postDetails!.value.likeTapped!.value && !controller.likeTapped.value?
                    const FaIcon(FontAwesomeIcons.solidHeart, color: interfaceColor,):
                    const FaIcon(FontAwesomeIcons.heart,)


                      ,),
                    onLikeTapped: (){

                      if(controller.postDetails!.value.likeTapped!.value){
                        controller.postDetails.value.likeTapped!.value = false;
                        controller.postDetails.value.likeCount = controller.postDetails.value.likeCount!-1;

                        controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].likeTapped.value
                        = !controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].likeTapped.value;

                        controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].likeCount.value
                        = controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].likeCount.value -1;
                        controller.likeUnlikePost(controller.postDetails!.value.postId!,  controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0]));

                      }
                      else{
                        controller.postDetails.value.likeTapped!.value = true;
                        controller.postDetails.value.likeCount = controller.postDetails.value.likeCount!+1;
                        // controller.postDetails!.value.likeTapped!.value = !controller.postDetails!.value.likeTapped!.value;
                        controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].likeTapped.value
                        = !controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].likeTapped.value;

                        controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].likeCount.value
                        = controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].likeCount.value +1;
                        controller.likeUnlikePost(controller.postDetails!.value.postId!, controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0]));
                      }


                    },

                  onSharedTapped: () async {

                    controller.postDetails.value.shareCount = controller.postDetails.value.shareCount!+1;
                    controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].shareCount.value
                    = controller.allPosts[controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0])].shareCount.value +1;
                    await controller.sharePost(post!.postId!, controller.allPosts.indexOf(controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0]));

                  },
                  liked: controller.postDetails!.value.liked,
                ).marginOnly(top: 20, bottom: 5)
                :PostCardWidgetBoilerplate(
                  images: [],
                ),)),



              Obx(() => SliverList(
                  delegate: SliverChildBuilderDelegate(

                  childCount: controller.commentList.length,
                      (context, index){
                        return Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: CommentWidget(
                            userAvatar: GestureDetector(
                              onTap: (){
                                Get.toNamed(Routes.OTHER_USER_PROFILE, arguments: {'userId':controller.commentList[index]['user']['id']});
                              },
                              child: ClipOval(
                                  child: FadeInImage(
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      image: NetworkImage(controller.commentList[index]['user']['avatar'], headers: GlobalService.getTokenHeaders()),
                                      placeholder: AssetImage(
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
                              ).marginOnly(right: 10),
                            ),
                            user: '${controller.commentList[index]['user']['first_name'][0].toUpperCase()}${controller.commentList[index]['user']['first_name'].substring(1).toLowerCase()} '
                                '${controller.commentList[index]['user']['last_name'][0].toUpperCase()}${controller.commentList[index]['user']['last_name'].substring(1).toLowerCase()}' ,
                            comment: controller.commentList[index]['text'],
                          ),
                        );

              }
                       )))



            ],

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
