import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/profile/controllers/profile_controller.dart';
import 'package:mapnrank/common/helper.dart';

import '../../../../color_constants.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../community/widgets/comment_loading_widget.dart';
import '../../global_widgets/loading_cards.dart';
import '../../global_widgets/post_card_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ArticlesView extends GetView<ProfileController> {
  const ArticlesView({super.key});

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
        AppLocalizations.of(context).posts_count,
        style: TextStyle(color: Colors.black87, fontSize: 30.0),
      ),
    ),
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        //color: backgroundColor,
        //padding: const EdgeInsets.all(24.0),
        child: Obx(() => controller.allPosts.isNotEmpty? ListView.builder(
          itemCount: controller.allPosts.length,
            itemBuilder: (context, index) =>
            Obx(() => PostCardWidget(
              likeTapped: controller.allPosts[index].likeTapped,
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
                  controller.allPosts[index].likeCount.value = controller.allPosts[index].likeCount.value -1;
                  Get.find<CommunityController>().likeUnlikePost(controller.allPosts[index].postId, index);
                }
                else{
                  controller.allPosts[index].likeTapped.value = !controller.allPosts[index].likeTapped.value;
                  controller.allPosts[index].likeCount.value = controller.allPosts[index].likeCount.value +1;
                  Get.find<CommunityController>().likeMyPost.value = true;
                  Get.find<CommunityController>().likeUnlikePost(controller.allPosts[index].postId, index);
                  Get.find<CommunityController>().likeMyPost.value = false;
                }


              },
              onCommentTapped: () async{

                controller.likeTapped.value = false;
                Get.toNamed(Routes.COMMENT_VIEW,arguments: {'post': controller.allPosts[index]} );
                var post = controller.allPosts[index];
                var postDetails = await Get.find<CommunityController>().getAPost(controller.allPosts[index].postId);
                controller.commentList.value = postDetails.commentList!;
                await Get.find<CommunityController>().initializePostDetails(postDetails);



                //controller.likeCount!.value = controller.allPosts.where((element)=>element.postId == controller.postDetails.value.postId).toList()[0].likeCount;
                // controller.commentList.value = controller.postDetails.value.commentList!;
                // controller.commentCount!.value =controller.postDetails.value.commentCount!.value;
                // controller.likeCount?.value = controller.postDetails.value.likeCount!.value;
                // controller.shareCount?.value =controller.postDetails.value.shareCount!.value;

              },
              onPictureTapped: () async{
                var post = controller.allPosts[index];
                post.user = controller.currentUser.value;
                await controller.initializeMyPostDetails(post);
                Get.toNamed(Routes.DETAILS_VIEW, arguments: {'post': controller.allPosts[index]} );

              },
              onSharedTapped: ()async{
                controller.postSharedIndex.value = index;
                controller.allPosts[index].shareCount.value = controller.allPosts[index].shareCount.value +1;
                Get.find<CommunityController>().shareMyPost.value = true;
                await Get.find<CommunityController>().sharePost(Get.find<CommunityController>().allPosts[index].postId, index);
                Get.find<CommunityController>().shareMyPost.value = false;


              },
              popUpWidget:SizedBox(),

              liked: controller.allPosts[index].liked,
            ))
        ):Center(
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

        ),)
      ),
    );
  }
}