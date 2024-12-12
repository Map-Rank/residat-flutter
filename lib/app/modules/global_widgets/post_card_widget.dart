import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/global_widgets/read_more_text.dart';
import 'package:mapnrank/app/modules/other_user_profile/controllers/other_user_profile_controller.dart';
import 'package:mapnrank/app/services/global_services.dart';
import '../../../color_constants.dart';
import '../../routes/app_routes.dart';
import '../community/controllers/community_controller.dart';
import '../community/widgets/comment_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PostCardWidget extends StatelessWidget {
  PostCardWidget({Key? key,
    this.user,
    this.sectors,
    this.zone,
    this.content,
    this.postId,
    this.publishedDate,
    this.likeCount,
    this.commentCount,
    this.shareCount,
    this.images,
    this.liked,
    this.onLikeTapped,
    this.onCommentTapped,
    this.onPictureTapped,
    this.onSharedTapped,
    this.shareTapped,
    this.likeTapped,
    this.commentTapped,
    this.onFollowTapped,
    this.likeWidget,
    this.onActionTapped,
    this.popUpWidget,
    this.followWidget,
    this.isCommunityPage,
    this.imageScrollController,
  }) : super(key: key);

  final List? sectors;
  final String? publishedDate;
  final String? content;
  final int? postId;
  var zone;
  final UserModel? user;
  RxInt? likeCount;
  RxInt? commentCount;
  RxInt? shareCount;
  final List? images;
  final bool? liked;
  final Function()? onLikeTapped;
  final Function()? onCommentTapped;
  final Function()? onSharedTapped;
  final Function()? onPictureTapped;
  final Function()? onActionTapped;
  final Function()? onFollowTapped;
  RxBool? likeTapped;
  var commentTapped;
  var shareTapped;
  Widget? likeWidget;
  Widget? popUpWidget;
  Widget? followWidget;
  bool? isCommunityPage;
  ScrollController? imageScrollController;





  @override
  Widget build(BuildContext context) {
    imageScrollController = ScrollController();
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                //width: Get.width,
                //height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    InkWell(
                      child: ClipOval(
                          child: FadeInImage(
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            image:  NetworkImage(user!.avatarUrl!, headers: GlobalService.getTokenHeaders()),
                            placeholder: const AssetImage(
                                "assets/images/loading.gif"),
                            imageErrorBuilder:
                                (context, error, stackTrace) {
                              return Image.asset(
                                  "assets/images/user_admin.png",
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.fitWidth);
                            },
                          )
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Get.width*0.81,
                          child: Row(
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: Get.width*0.45,
                                child: GestureDetector(
                                  onTap: () async {
                                    if(isCommunityPage == true){
                                      Get.toNamed(Routes.OTHER_USER_PROFILE, arguments: {'userId':user?.userId});
                                    };

                                  },
                                  child: Wrap(
                                    children: [
                                      Text('${user?.firstName![0].toUpperCase()}${user?.firstName!.substring(1).toLowerCase()} ${user?.lastName![0].toUpperCase()}${user?.lastName!.substring(1).toLowerCase()}',
                                          //overflow:TextOverflow.ellipsis ,
                                          style: Get.textTheme.titleSmall)
                                    ],
                                  ),
                                ),
                              ),
                              Spacer(),


                              isCommunityPage!?
                              followWidget!:
                              SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: popUpWidget!),


                            ],
                          ),
                        ),

                        SizedBox(
                          height: 10,
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,

                            children: [
                              const FaIcon(FontAwesomeIcons.locationDot, size: 15,).marginOnly(right: 10),
                              SizedBox(
                                //width: Get.width/4,
                                child: Text(zone.toString(), style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis,).marginOnly(right: 10),),
                              const FaIcon(FontAwesomeIcons.solidCircle, size: 5,).marginOnly(right: 10),
                              SizedBox(
                                //width: Get.width/4,
                                  child: Text(publishedDate!, style: Get.textTheme.bodySmall)),


                              //Text("⭐️ ${this.rating}", style: TextStyle(fontSize: 13, color: appColor))
                            ],
                          ),
                        ),
                      ],
                    ),

                  ],


                ),
              ).paddingSymmetric(horizontal: 10),

              ReadMoreText(
                  content == null? '':content?.replaceAllMapped(RegExp(r'<p>|<\/p>'), (match) {
                    return match.group(0) == '</p>' ? '\n' : ''; // Replace </p> with \n and remove <p>
                  })
                      .replaceAll(RegExp(r'^\s*\n', multiLine: false), ''), // Remove empty lines),
                  maxLines: 3,
                  trimMode: TrimMode.line,
                  textStyle: Get.textTheme.displayMedium!).paddingSymmetric(horizontal: 10).marginOnly(top: 20),
              if(images!.isNotEmpty)...[
                if( images!.length == 1)...[
                  GestureDetector(
                    onTap: onPictureTapped,
                    child: ClipRect(
                        child: FadeInImage(
                          width: Get.width,
                          height: 375,
                          fit: BoxFit.cover,
                          image:  NetworkImage(
                              '${images![0]['url']}',
                              headers: GlobalService.getTokenHeaders()
                          ),
                          placeholder: const AssetImage(
                              "assets/images/loading.gif"),
                          imageErrorBuilder:
                              (context, error, stackTrace) {
                            return Image.asset(
                                "assets/images/loading.gif",
                                width: Get.width,
                                height: 375,
                                fit: BoxFit.fitHeight);
                          },
                        )

                    ),
                  )
                ]
                else...[
                  SizedBox(
                      height: 375,
                      child: images!.length == 2?
                      Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                                onTap: onPictureTapped,
                                child: SizedBox(
                                    height: Get.height,
                                    child: _buildImage(images![0]['url'], Colors.transparent)),
                              )),
                          SizedBox(width: 2),
                          Expanded(child: GestureDetector(
                            onTap: onPictureTapped,
                            child: SizedBox(
                                height: Get.height,
                                child: _buildImage(images![1]['url'], Colors.transparent)),
                          )),

                        ],
                      )
                          :images!.length == 3?
                      Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                                onTap: onPictureTapped,
                                child: SizedBox(
                                    height: Get.height,
                                    child: _buildImage(images![0]['url'], Colors.transparent)),
                              )),
                          SizedBox(width: 2),
                          Expanded(child: GestureDetector(
                            onTap: onPictureTapped,
                            child: SizedBox(
                                height: Get.height,
                                child: _buildImage(images![1]['url'], Colors.transparent)),
                          )),
                          SizedBox(width: 2),
                          Expanded(child: GestureDetector(
                            onTap: onPictureTapped,
                            child: SizedBox(
                                height: Get.height,
                                child: _buildImage(images![2]['url'], Colors.transparent)),
                          )),
                        ],
                      ):
                      Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                                onTap: onPictureTapped,
                                child: SizedBox(
                                    height: Get.height,
                                    child: _buildImage(images![0]['url'], Colors.transparent)),
                              )),
                          SizedBox(width: 2),
                          Expanded(child: GestureDetector(
                            onTap: onPictureTapped,
                            child: SizedBox(
                                height: Get.height,
                                child: _buildImage(images![1]['url'], Colors.transparent)),
                          )),
                          SizedBox(width: 2),
                          Expanded(child: GestureDetector(
                            onTap: onPictureTapped,
                            child: SizedBox(
                                height: Get.height,
                                child: _buildImage(images![2]['url'], Colors.transparent)),
                          )),
                          images!.length > 4?
                          Expanded(
                              child: GestureDetector(
                                onTap: () => onPictureTapped,
                                child: SizedBox(
                                  height: Get.height,
                                    child: _buildMoreOverlay(images![3]['url'], images!.length - 4)),
                              ))
                              :Expanded(
                              child: GestureDetector(
                                onTap: onPictureTapped,
                                child: SizedBox(
                                  height: Get.height,
                                    child: _buildImage(images![3]['url'], Colors.transparent)),
                              )),
                        ],
                      )

                  )



                  //The code belows allows to display images exactly like on LinkedIn and Facebook

                  // SizedBox(
                  //     height: 375,
                  //     child: images!.length == 2?
                  //     Row(
                  //       children: [
                  //         Expanded(
                  //             child: GestureDetector(
                  //               onTap: onPictureTapped,
                  //               child: SizedBox(
                  //               height: Get.height,
                  //               child: _buildImage(images![0]['url'],  Colors.transparent)),
                  //             )),
                  //         SizedBox(width: 2),
                  //         Expanded(child: GestureDetector(
                  //           onTap: onPictureTapped,
                  //           child: SizedBox(
                  //               height: Get.height,
                  //               child: _buildImage(images![1]['url'],  Colors.transparent)),
                  //         )),
                  //       ],
                  //     )
                  //         :images!.length == 3?
                  //     Column(
                  //       children: [
                  //         Expanded(child:
                  //         SizedBox(
                  //             width: Get.width,
                  //             height: Get.height*3/4,
                  //             child: _buildImage(images![0]['url'],  Colors.transparent))),
                  //         SizedBox(height: 2),
                  //         Row(
                  //           children: [
                  //             Expanded(
                  //                 child: SizedBox(
                  //                   height: Get.height/5,
                  //                     child: _buildImage(images![1]['url'],  Colors.transparent))),
                  //             SizedBox(width: 2),
                  //             Expanded(child: SizedBox(
                  //                 height: Get.height/5,
                  //                 child: _buildImage(images![2]['url'],  Colors.transparent))),
                  //           ],
                  //         ),
                  //       ],
                  //     ):Column(
                  //       children: [
                  //         Expanded(child: SizedBox(
                  //             width: Get.width,
                  //             height: Get.height*3/4,
                  //             child: _buildImage(images![0]['url'], Colors.transparent))),
                  //         SizedBox(height: 2),
                  //         Row(
                  //           children: [
                  //             Expanded(
                  //                 child: GestureDetector(
                  //                   onTap: () => onPictureTapped,
                  //                   child: SizedBox(
                  //                     height: Get.height/5,
                  //                       child: _buildImage(images![1]['url'],  Colors.transparent)),
                  //                 )),
                  //             SizedBox(width: 2),
                  //             Expanded(child:
                  //             GestureDetector(
                  //               onTap: () => onPictureTapped,
                  //               child: SizedBox(
                  //                 height: Get.height/5,
                  //                   child: _buildImage(images![2]['url'],  Colors.transparent)),
                  //             )),
                  //             SizedBox(width: 2),
                  //             images!.length > 4?
                  //             Expanded(child: _buildMoreOverlay(images![3]['url'], images!.length - 4))
                  //                 :Expanded(
                  //                 child: SizedBox(
                  //                   height: Get.height/5,
                  //                     child: _buildImage(images![3]['url'],  Colors.transparent))),
                  //           ],
                  //         ),
                  //       ],
                  //     )
                  //
                  // )
                ]

                ,
              ],


              Obx(() => Row(
                children: [
                  Obx(() => likeCount!.value>0?FaIcon(FontAwesomeIcons.solidHeart, size: 20, color: interfaceColor):FaIcon(FontAwesomeIcons.heart, color: null)),
                  const SizedBox(width: 10,),
                  if(likeCount!.value <= 1)...[
                    Obx(() => Text('${likeCount!.value} ${AppLocalizations.of(context).like}', style: Get.textTheme.headlineMedium?.merge(TextStyle(fontSize: 12)),),)
                  ]
                  else...[
                    Obx(() => Text('${likeCount!.value}  ${AppLocalizations.of(context).like}s', style: Get.textTheme.headlineMedium?.merge(TextStyle(fontSize: 12))),)
                  ],


                  const Spacer(),
                  if(commentCount! <= 1)...[
                    Text(' ${commentCount!}  ${AppLocalizations.of(context).comment}', style: Get.textTheme.headlineMedium?.merge(TextStyle(fontSize: 12)),),
                  ]
                  else...[
                    Text(' ${commentCount!}  ${AppLocalizations.of(context).comment}s', style: Get.textTheme.headlineMedium?.merge(TextStyle(fontSize: 12))),
                  ],
                  if(shareCount! <= 1)...[
                    Obx(() =>  Text(' . ${shareCount!}  ${AppLocalizations.of(context).share}', style: Get.textTheme.headlineMedium?.merge(TextStyle(fontSize: 12))),),

                  ]
                  else...[
                    Obx(() =>Text(' . ${shareCount!}  ${AppLocalizations.of(context).share}s', style: Get.textTheme.headlineMedium?.merge(TextStyle(fontSize: 12))), )

                  ],




                ],
              ).marginOnly(top: 5,),).paddingSymmetric(horizontal: 10),

              Divider(
                color: Colors.grey.shade300,
              ).paddingSymmetric(horizontal: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap:onLikeTapped,

                    child: Column(
                      children:  [
                        likeWidget!,
                        Text(AppLocalizations.of(context).like_verb)
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onCommentTapped,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/icons/comment.png',
                          //fit: BoxFit.cover,
                          // width: 150,
                          // height: 130,

                        ),
                        Text(AppLocalizations.of(context).comment_verb)
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onSharedTapped,
                    child: Column(
                      children:[
                        Image.asset(
                          'assets/icons/share.png',
                          //fit: BoxFit.cover,
                          //  width: 150,
                          //  height: 130,

                        ),
                        Text(AppLocalizations.of(context).share_verb),
                      ],
                    ),
                  ),
                ],

              ).paddingSymmetric(horizontal: 10,),

            ]
        ).paddingSymmetric( vertical: 10)
    );
  }



  Widget _buildImage(String imageUrl, Color color) {
    return GestureDetector(
      onTap: onPictureTapped,
      child: ClipRRect(
        //borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imageUrl,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
                "assets/images/loading.gif",
                width: 40,
                height: 40,
                fit: BoxFit.fitWidth);
          },
          fit: BoxFit.cover,
          color: color==Colors.transparent?null:color.withOpacity(0.5),
          colorBlendMode: BlendMode.hardLight,
        ),
      ),
    );
  }

  Widget _buildMoreOverlay(String imageUrl, int remainingCount) {
    return SizedBox(
      height: Get.height/5,
      child: GestureDetector(
        onTap: onPictureTapped,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(imageUrl, Colors.black87),
            Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+$remainingCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'more',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

}