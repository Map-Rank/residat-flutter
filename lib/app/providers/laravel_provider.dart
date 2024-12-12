import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:mapnrank/app/models/feedback_model.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mapnrank/app/services/global_services.dart';
import '../../color_constants.dart';
import '../../common/ui.dart';
import '../exceptions/network_exceptions.dart';
import '../models/event_model.dart';
import '../models/notification_model.dart';
import '../routes/app_routes.dart';
import 'dio_client.dart';

//import 'package:dio/dio.dart' as dio_form_data;

class LaravelApiClient extends GetxService {
  late Dio httpClient;
  late String baseUrl;
  late dio.Options optionsNetwork;
  late dio.Options optionsCache;

  LaravelApiClient({required Dio dio}) {
    baseUrl = GlobalService().baseUrl;
    httpClient = dio;
  }

  // LaravelApiClient({Dio? dio})
  //     : httpClient = dio ?? Dio(BaseOptions(baseUrl: 'http://192.168.43.184:8080/api'));

  Future<LaravelApiClient> init() async {
    //optionsNetwork = httpClient.optionsNetwork!;
    //optionsCache = httpClient.optionsCache!;
    return this;
  }


  register(UserModel user) async {
    try {
      var headers = {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json'
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('${GlobalService().baseUrl}api/register'));
      request.fields.addAll({
        'first_name': user.firstName!,
        'last_name': user.lastName!,
        'email': user.email!,
        'phone': user.phoneNumber,
        'date_of_birth': user.birthdate!,
        'password': user.password!,
        'gender': user.gender!,
        'zone_id': user.zoneId!,
        'language':user.language!,
        'fcm_token':user.firebaseToken!,
        'sectors': user.sectors![0].toString()
      });

      if (user.imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'files', ".${user.imageFile!.path}"));
      }
      if (user.profession != null) {
        request.fields.addAll({
          'profession': user.profession!
        });
      }


      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

// coverage:ignore-start
      if (response.statusCode == 201) {
        var data = await response.stream.bytesToString();
        var result = json.decode(data);
        if (result['status'] == true) {
          return UserModel.fromJson(result['data']);
        } else {
          throw Exception((result['message']));
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end

  }

  registerInstitution(UserModel user) async {
    try {
      var headers = {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json'
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('${GlobalService().baseUrl}api/create/request'));
      request.fields.addAll({
        'company_name': user.firstName!,
        'email': user.email!,
        'phone': user.phoneNumber,
        'password': user.password!,
        'description': user.description!,
        'language':user.language!,
        'fcm_token':user.firebaseToken!,
        'zone_id': user.zoneId!,

      });

      if (user.imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'files', ".${user.imageFile!.path}"));
      }
      if (user.profession != null) {
        request.fields.addAll({
          'profession': user.profession!
        });
      }


      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

// coverage:ignore-start
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var result = json.decode(data);
        if (result['status'] == true) {
          return result['data'];
        } else {
          throw Exception((result['message']));
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end

  }

   getUser() async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var response = await httpClient.get(
        '${GlobalService().baseUrl}api/profile',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          var user = UserModel.fromJson(response.data['data']);
          user.myPosts = response.data['data']['my_posts'];
          user.myEvents = response.data['data']['events'];
          return user;
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }

  }

  getAnotherUserProfileInfo(int userId,)async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      //var dio = Dio();
      // dio.interceptors.add(LogInterceptor(responseBody: true));
      var response = await httpClient.get(
        '${GlobalService().baseUrl}api/profile/detail/$userId',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          print('Code is reaching here');
          var user = UserModel.fromJson(response.data['data']);
          user.myPosts = response.data['data']['my_posts'];
          user.myEvents = response.data['data']['events'];
          return user;
        } else {
          throw Exception(response.data['message']);
        }
      }
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
        throw NetworkExceptions.getDioException(e);
    }

  }

  updateUser(UserModel user) async{
    try{
    var headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${Get
          .find<AuthService>()
          .user
          .value
          .authToken}'
    };
    var request = http.MultipartRequest('POST',
        Uri.parse('${GlobalService().baseUrl}api/profile/update/${user.userId}'));
    request.fields.addAll({
      'first_name': user.firstName!,
      'last_name': user.lastName!,
      'phone': user.phoneNumber,
      'date_of_birth': user.birthdate!,
      '_method': 'PUT'
    });

    if (user.imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'files', ".${user.imageFile!.path}"));
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
// coverage:ignore-start
    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      var result = json.decode(data);
      if (result['status'] == true) {
        return UserModel.fromJson(result['data']);
      } else {
        throw Exception((result['message']));
      }
    }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end
  }


  //Handling User
   login(UserModel user) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      var data = user.email!=null?
      json.encode({
        "email": user.email,
        "password": user.password
      }):
      json.encode({
        "email": user.phoneNumber,
        "password": user.phoneNumber
      });
      var response = await httpClient.post(
        '${GlobalService().baseUrl}api/login',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          if(response.data['data']['verified'].toString() == 'false'){
            Get.offAllNamed(Routes.WELCOME_INSTITUTIONAL_USER);

          }else{
            return UserModel.fromJson(response.data['data']);
          }

        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      print(e.toString());
      throw NetworkExceptions.getDioException(e);
    }


  }



  Future logout() async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var response = await httpClient.post(
        '${GlobalService().baseUrl}api/logout',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }


  Future deleteAccount() async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var response = await httpClient.delete(
        '${GlobalService().baseUrl}api/delete-user',
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }


  Future resetPassword(String email) async{
    try{
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    var data = json.encode({
      "email": email
    });
    var response = await httpClient.post(
      '${GlobalService().baseUrl}api/forgot-password',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      if (response.data['status'] == true) {
        showDialog(context: Get.context!,
          builder: (context) =>
              AlertDialog(
                insetPadding: EdgeInsets.all(20),
                icon: Icon(FontAwesomeIcons.infoCircle, color: interfaceColor,),
                title: Text('Message'),
                content: Text(
                  'A mail has been sent to you, Log into your mail box and follow the instructions to reset your password please.',
                  textAlign: TextAlign.justify, style: TextStyle(),),
                actions: [
                  TextButton(onPressed: () {
                    Navigator.of(context).pop();
                  },
                      child: Text(
                        'Ok', style: TextStyle(color: interfaceColor),)),

                ],

              ),);
        //Get.showSnackbar(Ui.SuccessSnackBar(message: 'Log into your mail box and follow the instructions please.'));
      }
    }

    else {
        throw  Exception(response.data['message']);
      }
    }
    on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }

  }

  Future checkTokenValidity(String token) async{
    try{
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };

      var response = await httpClient.post(
        '${GlobalService().baseUrl}api/verify-token',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        return true;
      }
      else{
        return false;
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  Future followUser(int userId) async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var response = await httpClient.post(
        '${GlobalService().baseUrl}api/follow/$userId',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        print(json.encode(response.data));
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }

  }

  Future unfollowUser(int userId) async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var response = await httpClient.post(
        '${GlobalService().baseUrl}api/unfollow/$userId',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        print(json.encode(response.data));
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }

  }

  sendFeedback(FeedbackModel feedbackModel) async {
    try {
      var headers = {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('${GlobalService().baseUrl}api/create-feedback'));
      request.fields.addAll({
        'page_link': 'https://feedback-from-mobile-application',
        'text': feedbackModel.feedbackText!,
        'rating': feedbackModel.rating!,
      });

      if (feedbackModel.imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'files', ".${feedbackModel.imageFile!.path}"));
      }



      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

// coverage:ignore-start
      if (response.statusCode == 201) {
        var data = await response.stream.bytesToString();
        var result = json.decode(data);
        if (result['status'] == true) {
          return;
        } else {
          throw Exception((result['message']));
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end

  }


  // Handling Sectors and zones


 getCameroonGeoJson() async {
    try{
      var response = await httpClient.get(
        'https://www.residat.com/assets/maps/National_Region.json',
        options: Options(
          method: 'GET',
        ),
      );
      if (response.statusCode == 200) {
        return json.encode(response.data);
      }
      else {
        throw Exception((response.statusMessage));
      }

    }on SocketException catch (e) {
  throw SocketException(e.toString());
  } on FormatException catch (_) {
  throw const FormatException("Unable to process the data");
  } catch (e) {
  throw NetworkExceptions.getDioException(e);
  }

 }

Future getAllZones(int levelId, int parentId) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      var dio = Dio();
      var response = await httpClient.get(
        '${GlobalService()
            .baseUrl}api/zone?level_id=$levelId&parent_id=$parentId',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
// coverage:ignore-start
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data;
        } else {
          throw Exception(response.data['message']);
        }
      }
    }
    on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end


}

Future getAllZonesFilterByName() async{
    try{
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };
  var dio = Dio();

  var response = await httpClient.get(
    '${GlobalService().baseUrl}api/zone',
    options: Options(
      method: 'GET',
      headers: headers,
    ),
  );

  if (response.statusCode == 200) {
    if (response.data['status'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message']);
    }
  }
  }on SocketException catch (e) {
  throw SocketException(e.toString());
  } on FormatException catch (_) {
  throw const FormatException("Unable to process the data");
  } catch (e) {
  throw NetworkExceptions.getDioException(e);
  }
}

Future getSpecificZoneByName(String name) async{
    try{
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };

      var response = await httpClient.get(
        name=='CAMEROUN'?'${GlobalService().baseUrl}api/zone?name=$name':'${GlobalService().baseUrl}api/zone?code=$name',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
      else {
        print(response.statusMessage);
      }
    }on SocketException catch (e) {
  throw SocketException(e.toString());
  } on FormatException catch (_) {
  throw const FormatException("Unable to process the data");
  } catch (e) {
  throw NetworkExceptions.getDioException(e);
  }

}

  getSpecificZoneGeoJson(String url) async {
    try{
      var response = await httpClient.get(
        url,
        options: Options(
          method: 'GET',
        ),
      );
      if (response.statusCode == 200) {
        return json.encode(response.data);
      }
      else {
        throw Exception((response.statusMessage));
      }

    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }

  }

Future getSpecificZone(int zoneId)async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      var response = await httpClient.get(
        '${GlobalService().baseUrl}api/zone/$zoneId',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }

}

Future getDisasterMarkers() async{
  try {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${Get
          .find<AuthService>()
          .user
          .value
          .authToken}'
    };
    var response = await httpClient.get(
      '${GlobalService().baseUrl}api/disasters',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );
    if (response.statusCode == 200) {
      if (response.data['status'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message']);
      }
    }
  }on SocketException catch (e) {
    throw SocketException(e.toString());
  } on FormatException catch (_) {
    throw const FormatException("Unable to process the data");
  } catch (e) {
    throw NetworkExceptions.getDioException(e);
  }
}

  Future getAllSectors() async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };

      var response = await httpClient.get(
        '${GlobalService().baseUrl}api/sector',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data;
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }

  }


  // Handling Posts
Future getAllPosts(int page) async {
    try {
      print("Page is: ${page}");
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}',
      };
      var response = await httpClient.get(
        '${GlobalService().baseUrl}api/post?page=$page&size=10',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }


}

  Future getPostsByZone(int zone_id) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}',
      };
      var response = await httpClient.get(
        '${GlobalService().baseUrl}api/post?zone_id=$zone_id&size=4',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }


  }

Future createPost(Post post)async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse('${GlobalService().baseUrl}api/post'));
      request.fields.addAll({
        'content': post.content!,
        'published_at': '${DateTime
            .now()
            .year}-${DateTime
            .now()
            .month}-${DateTime
            .now()
            .day}',
      });

      if (post.imagesFilePaths != null) {
        for (var i = 0; i < post.imagesFilePaths!.length; i++) {
          request.files.add(await http.MultipartFile.fromPath(
              'media[]', "${post.imagesFilePaths![i].path}"));
        }
      }
      if (post.sectors != null) {
        for (var i = 0; i < post.sectors!.length; i++) {
          request.fields['sectors[${i}]'] = post.sectors![i].toString();
        }
      }
      if (post.zonePostId == null) {
        request.fields.addAll({
          'zone_id': '1'
        });
      }
      else {
        request.fields.addAll({
          'zone_id': post.zonePostId.toString()
        });
      }


      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
// coverage:ignore-start
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var result = json.decode(data);
        if (result['status'] == true) {
          return result['data'];
        } else {
          throw Exception((result['message']));
        }
      }
    }
    on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end

}

Future updatePost(Post post) async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };

      var request = http.MultipartRequest('POST',
          Uri.parse('${GlobalService().baseUrl}api/post/${post.postId}'));
      request.fields.addAll({
        'content': post.content!,
        'published_at': '${DateTime
            .now()
            .year}-${DateTime
            .now()
            .month}-${DateTime
            .now()
            .day}',
        'sectors[]': '${post.sectors}',
        '_method': 'PUT'
      });

      if (post.imagesFilePaths != null) {
        for (var i = 0; i < post.imagesFilePaths!.length; i++) {
          request.files.add(await http.MultipartFile.fromPath(
              'media[]', "${post.imagesFilePaths![i].path}"));
        }
      }
      if (post.zonePostId == null) {
        request.fields.addAll({
          'zone_id': '1'
        });
      }
      else {
        request.fields.addAll({
          'zone_id': post.zonePostId.toString()
        });
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
// coverage:ignore-start
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var result = json.decode(data);
        if (result['status'] == true) {
          return result['data'];
        } else {
          throw Exception((result['message']));
        }
      }
    }
    on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end

}


Future likeUnlikePost(int postId)async{
try {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${Get
        .find<AuthService>()
        .user
        .value
        .authToken}'
  };
  var response = await httpClient.post(
    '${GlobalService().baseUrl}api/post/like/$postId',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
  );

  if (response.statusCode == 200) {
    if (response.data['status'] == true) {
      print(response.data);
      return response.data['data'];
    } else {
      throw Exception(response.data['message']);
    }
  }
}on SocketException catch (e) {
  throw SocketException(e.toString());
} on FormatException catch (_) {
  throw const FormatException("Unable to process the data");
} catch (e) {
  throw NetworkExceptions.getDioException(e);
}

}

Future getAPost(int postId) async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var response = await httpClient.get(
        '${GlobalService().baseUrl}api/post/$postId',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }
    on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
}

Future commentPost(int postId, String comment)async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var data = json.encode({
        "text": comment
      });
      var dio = Dio();
      var response = await httpClient.post(
        '${GlobalService().baseUrl}api/post/comment/$postId',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }
    on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }


}

sharePost(int postId) async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var response = await httpClient.post(
        '${GlobalService().baseUrl}api/post/share/$postId',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
}

deletePost(int postId) async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var response = await httpClient.delete(
        '${GlobalService().baseUrl}api/post/$postId',
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }
    on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }

}

//Filter Posts by zone
  Future filterPostsByZone(int page, int zoneId) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}',
      };
      var response = await httpClient.get(
        '${GlobalService().baseUrl}api/post?page=$page&zone_id=$zoneId&size=10',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
// coverage:ignore-start
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }
    on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end


  }

  //Filter Posts by sectors
  Future filterPostsBySectors(int page, var sectors) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}',
      };
      var response = await httpClient.get(
        '${GlobalService()
            .baseUrl}api/post?page=$page&sectors=$sectors&size=10',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
// coverage:ignore-start
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end


  }


//Handling Events

  getAllEvents(int page) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}',
      };

      var response = await httpClient.get(
        '${GlobalService().baseUrl}api/events?page=$page&size=10',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          print(response.data['data']);
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }


  }

  Future getAnEvent(int eventId) async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var dio = Dio();
      var response = await httpClient.get(
        '${GlobalService().baseUrl}api/events/$eventId',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  createEvent(Event event) async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('${GlobalService().baseUrl}api/events'));
      request.fields.addAll({
        'title': event.title!,
        'description': event.content!,
        'location': event.zone!,
        'organized_by': event.organizer!,
        'user_id': Get
            .find<AuthService>()
            .user
            .value
            .userId
            .toString(),
        'date_debut': event.startDate!,
        'date_fin': event.endDate!,
        'sector_id': event.sectors![0].toString(),
        'zone_id': event.zoneEventId!.toString(),
        'published_at': '${DateTime
            .now()
            .year}-${DateTime
            .now()
            .month}-${DateTime
            .now()
            .day}'
      });


      request.files.add(await http.MultipartFile.fromPath(
          'media', ".${event.imagesFileBanner![0].path}"));

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
// coverage:ignore-start
      if (response.statusCode == 201) {
        var data = await response.stream.bytesToString();
        var result = json.decode(data);
        if (result['status'] == true) {
          return result['data'];
        } else {
          throw Exception((result['message']));
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end
  }

  updateEvent(Event event)async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };

      var request = http.MultipartRequest('POST',
          Uri.parse('${GlobalService().baseUrl}api/events/${event.eventId}'));
      request.fields.addAll({
        'title': event.title!,
        'description': event.content!,
        'location': event.zone!,
        'organized_by': event.organizer!,
        'user_id': Get
            .find<AuthService>()
            .user
            .value
            .userId
            .toString(),
        'date_debut': event.startDate!,
        'date_fin': event.endDate!,
        'published_at': '${DateTime
            .now()
            .year}-${DateTime
            .now()
            .month}-${DateTime
            .now()
            .day}',
        'sector_id': '${event.sectors[0]}',
        'zone_id': '${event.zoneEventId}',
        '_method': 'PUT'
      });

      if (event.imagesFileBanner != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'media', ".${event.imagesFileBanner![0].path}"));
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
// coverage:ignore-start
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var result = json.decode(data);
        if (result['status'] == true) {
          return result['data'];
        } else {
          throw Exception((result['message']));
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end


  }

  deleteEvent(int eventId) async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };
      var response = await httpClient.delete(
        '${GlobalService().baseUrl}api/events/$eventId',
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );
// coverage:ignore-start
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end

  }


  //Filter Events by zone
  Future filterEventsByZone(int page, int zoneId) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}',
      };
      var dio = Dio();
      var response = await httpClient.get(
        '${GlobalService()
            .baseUrl}api/events?page=$page&zone_id=$zoneId&size=10',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          print(response.data['data']);
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }


  }

  //Filter Events by sectors
  Future filterEventsBySectors(int page, var sectors) async {
    try {
      print("Page is: ${page}");
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}',
      };
      var dio = Dio();
      var response = await httpClient.get(
        '${GlobalService()
            .baseUrl}api/events?page=$page&sectors=$sectors&size=10',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }


  }


  // Handling notifications

  ///Get list of notifications
  Future getUserNotifications() async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}',
      };

      var response = await httpClient.get(
        '${GlobalService()
            .baseUrl}api/notifications',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  /// Get specific notification

  Future getSpecificNotification(var id) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}',
      };

      var response = await httpClient.get(
        '${GlobalService()
            .baseUrl}api/notifications/$id',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  ///Delete specific notification

  Future deleteSpecificNotification(var id) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}',
      };

      var response = await httpClient.delete(
        '${GlobalService()
            .baseUrl}api/notifications/$id',
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          return response.data['data'];
        } else {
          throw Exception(response.data['message']);
        }
      }
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  createNotification(NotificationModel notification) async{
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${Get
            .find<AuthService>()
            .user
            .value
            .authToken}'
      };

      var request = http.MultipartRequest(
          'POST', Uri.parse('${GlobalService().baseUrl}api/notifications'));
      request.fields.addAll({
        'titre_en': notification.title!,
        'titre_fr': notification.title!,
        'zone_id': notification.zoneId!,
        'content_en': notification.content!,
        'content_fr': notification.content!
      });


      request.files.add(await http.MultipartFile.fromPath(
          'media', ".${notification.imageNotificationBanner![0].path}"));

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
// coverage:ignore-start
      if (response.statusCode == 201) {
        var data = await response.stream.bytesToString();
        var result = json.decode(data);
        if (result['status'] == true) {
          return result['data'];
        } else {
          throw Exception((result['message']));
        }
      }
    }on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }// coverage:ignore-end
  }





}
