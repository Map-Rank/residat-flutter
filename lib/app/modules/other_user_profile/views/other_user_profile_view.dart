
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/modules/global_widgets/block_button_widget.dart';
import 'package:mapnrank/app/routes/app_routes.dart';
import 'package:mapnrank/color_constants.dart';
import '../../../../common/helper.dart';
import '../../../models/user_model.dart';
import '../../../services/global_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/widgets/comment_loading_widget.dart';
import '../../events/controllers/events_controller.dart';
import '../../global_widgets/loading_cards.dart';
import '../../global_widgets/post_card_widget.dart';
import '../controllers/other_user_profile_controller.dart';

class OtherUserProfileView extends GetView<OtherUserProfileController> {
  const OtherUserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
        },
        child:  Container(
          color: backgroundColor,
          margin: EdgeInsets.only(bottom: 20),
          height: Get.height,
          child: Obx(() => CustomScrollView(
            shrinkWrap: false,
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                surfaceTintColor: Colors.white,
                centerTitle: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: interfaceColor),
                  key: Key('back_button'),
                  onPressed: () async => {
                    Get.back(),

                  },
                ),

              ),
              if(!controller.loadingPosts.value)...[
                SliverToBoxAdapter(
                  child: LoadingCardWidget(),
                )
              ]
              else...[
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.all(10),
                    color: Colors.white,
                    child: Column(
                      children: [

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
                                  SizedBox(
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
                                  const Padding(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      '|',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14.0),
                                    ),
                                  ),

                                  SizedBox(
                                    child: Column(
                                      children: [
                                        Text(
                                          controller.currentUser.value.followerCount??'0',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            AppLocalizations.of(context).followers_count,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14.0),
                                          ),
                                        ),
                                      ],
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

                                  SizedBox(
                                    child: Column(
                                      children: [
                                        Text(
                                          controller.currentUser.value.followingCount??'0',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            AppLocalizations.of(context).following,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      children: [

                        Text('About '),
                        Text('Your description here'),
                        BlockButtonWidget(color: interfaceColor, text: Wrap(children: [
                          Icon(Icons.add),
                          Text('Follow'),
                        ],), onPressed: (){})
                      ],
                    ),
                  ),
                ),

                SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return  controller.allPosts.isNotEmpty? Obx(() => PostCardWidget(
                        //likeTapped: RxBool(controller.allPosts[index].likeTapped),
                        content: controller.allPosts[index].content == false?'':controller.allPosts[index].content,
                        zone: controller.allPosts[index].zone != null?controller.allPosts[index].zone['name']: '',
                        publishedDate: controller.allPosts[index].publishedDate,
                        postId: controller.allPosts[index].postId,
                        commentCount: controller.allPosts[index].commentCount,
                        shareCount:  controller.allPosts[index].shareCount,
                        images: controller.allPosts[index].imagesUrl,
                        isCommunityPage: false,
                        user: UserModel(
                            firstName: controller.currentUser.value.firstName,
                            lastName: controller.currentUser.value.lastName,
                            avatarUrl: controller.currentUser.value.avatarUrl
                        ),
                        followWidget: SizedBox(),
                        likeCount: controller.allPosts[index].likeCount,
                        likeWidget:  Obx(() =>
                        controller.allPosts[index].likeTapped.value && controller.postSelectedIndex.value == index?
                        const FaIcon(FontAwesomeIcons.solidHeart, color: interfaceColor,):
                        !controller.allPosts[index].likeTapped.value  && controller.postSelectedIndex.value == index?
                        const FaIcon(FontAwesomeIcons.heart,):
                        controller.allPosts[index].likeTapped.value ?
                        const FaIcon(FontAwesomeIcons.solidHeart, color: interfaceColor,):
                        const FaIcon(FontAwesomeIcons.heart,)

                          ,),
                        onLikeTapped: (){
                          controller.postSelectedIndex.value = index.toDouble();

                          if(controller.allPosts[index].likeTapped.value){
                            controller.allPosts[index].likeTapped.value = !controller.allPosts[index].likeTapped.value;
                            controller.allPosts[index].likeCount.value = controller.allPosts[index].likeCount.value-1;

                            Get.find<CommunityController>().allPosts[Get.find<CommunityController>().allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0])].likeTapped.value
                            = !Get.find<CommunityController>().allPosts[Get.find<CommunityController>().allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0])].likeTapped.value;

                            Get.find<CommunityController>().allPosts[Get.find<CommunityController>().allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0])].likeCount.value
                            = Get.find<CommunityController>().allPosts[controller.allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0])].likeCount.value -1;

                            Get.find<CommunityController>().likeUnlikePost(controller.allPosts[index].postId, Get.find<CommunityController>().allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0]));
                          }
                          else{
                            controller.allPosts[index].likeTapped.value = !controller.allPosts[index].likeTapped.value;
                            controller.allPosts[index].likeCount.value = controller.allPosts[index].likeCount.value+1;

                            Get.find<CommunityController>().allPosts[Get.find<CommunityController>().allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0])].likeTapped.value
                            = !Get.find<CommunityController>().allPosts[Get.find<CommunityController>().allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0])].likeTapped.value;

                            Get.find<CommunityController>().allPosts[Get.find<CommunityController>().allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0])].likeCount.value
                            = Get.find<CommunityController>().allPosts[controller.allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0])].likeCount.value +1;
                            Get.find<CommunityController>().likeUnlikePost(controller.allPosts[index].postId, Get.find<CommunityController>().allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0]));
                          }


                        },
                        onCommentTapped: () async{

                          controller.likeTapped.value = false;
                          Get.toNamed(Routes.COMMENT_VIEW,arguments: {'post': controller.allPosts[index]} );

                          await Get.find<CommunityController>().getAPost(controller.allPosts[index].postId);
                          controller.likeCount!.value = controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0].likeCount;
                          controller.commentList.value = controller.postDetails.value.commentList!;
                          controller.commentCount!.value =controller.postDetails.value.commentCount!.value;
                          controller.likeCount?.value = controller.postDetails.value.likeCount!.value;
                          controller.shareCount?.value =controller.postDetails.value.shareCount!.value;

                        },
                        onPictureTapped: () async{
                          var post = controller.allPosts[index];
                          post.user = controller.currentUser.value;
                          await controller.initializePostDetails(post);
                          Get.toNamed(Routes.DETAILS_VIEW, arguments: {'post': controller.allPosts[index]} );

                        },
                        onSharedTapped: ()async{
                          controller.postSharedIndex.value = index;
                          controller.sharedPost.add(controller.allPosts[index]);
                          controller.allPosts[index].shareCount.value = controller.allPosts[index].shareCount.value+1;

                          Get.find<CommunityController>().allPosts[Get.find<CommunityController>().allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0])].shareCount.value
                          = Get.find<CommunityController>().allPosts[controller.allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0])].shareCount.value -1;

                          await Get.find<CommunityController>().sharePost(Get.find<CommunityController>().allPosts[index].postId, Get.find<CommunityController>().allPosts.indexOf(Get.find<CommunityController>().allPosts.where((element)=>element.postId == controller.allPosts[index].postId).toList()[0]));


                        },
                        popUpWidget:SizedBox(),

                        liked: controller.allPosts[index].liked,
                      )):Center(
                        child: SizedBox(
                          height: Get.height/4,
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.folderOpen, size: 30,),
                              Text(AppLocalizations.of(context).no_posts_found)
                            ],
                          ),
                        ),

                      );
                    },
                        childCount: controller.allPosts.length
                    )),
              ],





            ],

          )),
        ),

      ),

    );
  }
}


