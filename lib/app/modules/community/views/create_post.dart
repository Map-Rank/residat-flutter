import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/community/widgets/buildSelectSector.dart';
import 'package:mapnrank/app/modules/community/widgets/buildSelectZone.dart';
import 'package:mapnrank/app/modules/global_widgets/location_widget.dart';
import 'package:mapnrank/app/modules/global_widgets/text_field_widget.dart';
import 'package:mapnrank/app/services/global_services.dart';
import '../../../../color_constants.dart';

class CreatePostView extends GetView<CommunityController> {
  const CreatePostView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Get.theme.colorScheme.secondary,
          elevation: 0,
          title:  Text(
            !controller.createUpdatePosts.value?'Create a Post'.tr:'Update a Post',
            style: Get.textTheme.headline6!.merge(const TextStyle(color: Colors.white)),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => {
              Navigator.pop(context),
              //Get.back()
            },
          ),
        ),
        bottomSheet: SizedBox(
            height: 80,
            child: Center(
                child: InkWell(
                    onTap: () async{
                      !controller.createUpdatePosts.value?
                      controller.createPost(controller.post!)
                      :controller.updatePost(controller.post!);
                      Navigator.pop(context);
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: interfaceColor,
                          ),

                        width: Get.width/2,
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        child: Center(
                            child: Obx(() =>  !controller.createUpdatePosts.value?!controller.createPosts.value ?
                            Text('Post', style: Get.textTheme.bodyText2!.merge(const TextStyle(color: Colors.white)))
                                : const SizedBox(height: 20,
                                child: SpinKitThreeBounce(color: Colors.white, size: 20)):
                                !controller.updatePosts.value?
                            Text('Update', style: Get.textTheme.bodyText2!.merge(const TextStyle(color: Colors.white)))
                                    : const SizedBox(height: 20,
                                    child: SpinKitThreeBounce(color: Colors.white, size: 20))

                            )
                        )
                    )
                )
            )
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
            decoration: const BoxDecoration(color: backgroundColor,
              ),
            child:  ListView(
              children: [
                Column(
                    children: <Widget>[
                      Card(
                          elevation: 0,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: Get.height*0.5,
                                child: TextFormField(
                                  initialValue: controller.post.content,
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                  cursorColor: Colors.black,
                                  textInputAction:TextInputAction.done ,
                                  maxLines: 20,
                                  minLines: 2,
                                  onChanged: (input) => controller.post!.content = input,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      //label: Text(AppLocalizations.of(context).description),
                                      fillColor: Palette.background,
                                      enabledBorder: InputBorder.none,
                                      //filled: true,
                                      prefixIcon: const Icon(Icons.description),
                                      hintText: 'Share your thoughts ',
                                      hintStyle: TextStyle(fontSize: 28, color: Colors.grey.shade400)
                                  ),

                                ),
                              )
                          )
                      )
                    ]
                ).marginOnly(top: 20, bottom: 5),

                buildInputImages(context),

                BuildSelectSector(),

                BuildSelectZone(),




              ],
            ).paddingOnly(bottom: 80)
          ),
        )
    );
  }



  Widget buildInputImages(BuildContext context){
    return Container(
      decoration: const BoxDecoration(
        color: backgroundColor,
      ),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
         Obx(() => 
             controller.createUpdatePosts.value?
             SizedBox(
               height: Get.height/4,
               child: ListView.builder(
                 scrollDirection: Axis.horizontal,
                 itemCount: controller.post.imagesUrl?.length,
                 itemBuilder: (context, index) {
                   return GestureDetector(
                     //onTap: onPictureTapped,
                     child: FadeInImage(
                       width: Get.width-50,
                       height: Get.height/4,
                       fit: BoxFit.cover,
                       image:  NetworkImage('${GlobalService().baseUrl}'
                           '${controller.post.imagesUrl![index]['url'].substring(1,controller.post.imagesUrl![index]['url'].length)}',
                           headers: GlobalService.getTokenHeaders()
                       ),
                       placeholder: const AssetImage(
                           "assets/images/loading.gif"),
                       imageErrorBuilder:
                           (context, error, stackTrace) {
                         return Image.asset(
                             "assets/images/loading.gif",
                             width: Get.width,
                             height: Get.height/4,
                             fit: BoxFit.fitWidth);
                       },
                     ).marginOnly(right: 10),
                   );

                 },
               ),
             )
                 :SizedBox()
                 
         ),
         Obx(() =>  controller.imageFiles.length <= 0 ?
         GestureDetector(
             onTap: () {
               showDialog(
                   context: Get.context!,
                   builder: (_){
                     return AlertDialog(
                       shape: const RoundedRectangleBorder(
                           borderRadius: BorderRadius.all(Radius.circular(20))
                       ),
                       content: Container(
                           height: 140,
                           padding: const EdgeInsets.all(10),
                           child: Column(
                               children: [
                                 ListTile(
                                   onTap: ()async{
                                     await controller.pickImage(ImageSource.camera);
                                     Navigator.pop(Get.context!);
                                   },
                                   leading: const Icon(FontAwesomeIcons.camera),
                                   title: Text('Take a picture', style: Get.textTheme.headline1!.merge(const TextStyle(fontSize: 15))),
                                 ),
                                 ListTile(
                                   onTap: ()async{
                                     await controller.pickImage(ImageSource.gallery);
                                     Navigator.pop(Get.context!);
                                   },
                                   leading: const Icon(FontAwesomeIcons.image),
                                   title: Text('Upload an image', style: Get.textTheme.headline1!.merge(const TextStyle(fontSize: 15))),
                                 )
                               ]
                           )
                       ),
                       actions: [
                         TextButton(
                             onPressed: ()=> Navigator.pop(context),
                             child: Text('Cancel', style: Get.textTheme.headline4!.merge(const TextStyle(color: inactive)),))
                       ],
                     );
                   });
             },
             child: const Align(
                 alignment: Alignment.centerRight,

                 child: FaIcon(FontAwesomeIcons.camera))
         )
             : Column(
           children: [
             SizedBox(
               height:Get.width/2,
               child: ListView.separated(
                   scrollDirection: Axis.horizontal,
                   padding: const EdgeInsets.all(12),
                   itemBuilder: (context, index){
                     return Stack(
                       //mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         Padding(
                             padding: const EdgeInsets.symmetric(vertical: 10),
                             child: ClipRRect(
                               borderRadius: const BorderRadius.all(Radius.circular(10)),
                               child: Image.file(
                                 controller.imageFiles[index],
                                 fit: BoxFit.cover,
                                 width: Get.width/2,
                                 height:Get.width/2,
                               ),
                             )
                         ),
                         Positioned(
                           top:0,
                           right:0,
                           child: Align(
                             //alignment: Alignment.centerRight,
                             child: IconButton(
                                 onPressed: (){
                                   controller.imageFiles.removeAt(index);
                                 },
                                 icon: const Icon(Icons.delete, color: inactive, size: 25, )
                             ),
                           ),
                         ),
                       ],
                     );
                   },
                   separatorBuilder: (context, index){
                     return const SizedBox(width: 8);
                   },
                   itemCount: controller.imageFiles.length),
             ),
             Align(
               alignment: Alignment.centerRight,
               child: Visibility(
                   child: InkWell(
                     onTap: (){
                       showDialog(
                           context: Get.context!,
                           builder: (_){
                             return AlertDialog(
                               shape: const RoundedRectangleBorder(
                                   borderRadius: BorderRadius.all(Radius.circular(20))
                               ),
                               content: Container(
                                   height: 140,
                                   padding: const EdgeInsets.all(10),
                                   child: Column(
                                     children: [
                                       ListTile(
                                         onTap: ()async{
                                           await controller.pickImage(ImageSource.camera);
                                           Navigator.pop(Get.context!);
                                         },
                                         leading: const Icon(FontAwesomeIcons.camera),
                                         title: Text('Take a picture', style: Get.textTheme.headline1!.merge(const TextStyle(fontSize: 15))),
                                       ),
                                       ListTile(
                                         onTap: ()async{
                                           await controller.pickImage(ImageSource.gallery);
                                           Navigator.pop(Get.context!);
                                         },
                                         leading: const Icon(FontAwesomeIcons.image),
                                         title: Text(
                                             'Upload an image', style: Get.textTheme.headline1!.merge(const TextStyle(fontSize: 15))),
                                       )
                                     ],
                                   )
                               ),
                               actions: [
                                 TextButton(
                                     onPressed: ()=> Navigator.pop(context),
                                     child: Text('Cancel', style: Get.textTheme.headline4!.merge(const TextStyle(color: inactive)),))
                               ],
                             );
                           });
                     },
                     child: const Icon(FontAwesomeIcons.circlePlus),
                   )
               ),
             )
           ],
         ),
         ),
        ],
      ),
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
