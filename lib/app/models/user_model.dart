
import 'parents/model.dart';

class UserModel extends Model {
  String? firstName;
  String? lastName;
  String? description;
  String? language;
  String? type;
  String? email;
  String? password;
  String? gender;
  var phoneNumber;
  String? birthdate;
  String? zoneId;
  int? userId;
  String? avatarUrl;
  var imageFile;
  String? authToken;
  String? followerCount;
  String? followingCount;
  String? firebaseToken;
  String? profession;
  static bool? auth;
  List? sectors;
  List? myPosts = [];
  List? myEvents = [];

  UserModel({this.userId,this.firstName, this.language, this.email, this.authToken, this.firebaseToken, this.password, this.phoneNumber, this.avatarUrl, this.birthdate, this.profession, this.gender,this.imageFile,
  this.lastName,this.description, this.type, this.zoneId, this. sectors, this.myPosts, this.myEvents, this.followerCount, this.followingCount});

  UserModel.fromJson(Map<String, dynamic> json) {
    firstName = stringFromJson(json, 'first_name');
    lastName = stringFromJson(json, 'last_name');
    description = stringFromJson(json, 'description');
    language = stringFromJson(json, 'language');
    type = stringFromJson(json, 'type');
    email = stringFromJson(json, 'email');
    phoneNumber = stringFromJson(json, 'phone');
    gender = stringFromJson(json, 'gender');
    userId = intFromJson(json, 'id');
    birthdate = stringFromJson(json, 'date_of_birth');
    authToken = stringFromJson(json, 'token');
    zoneId = stringFromJson(json, 'zone_id');
    avatarUrl = stringFromJson(json, 'avatar');
    myPosts = listFromJson(json, 'my_posts');
    followerCount = stringFromJson(json, 'follower_count');
    followingCount = stringFromJson(json, 'following_count');

    super.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone'] = phoneNumber;
    data['gender'] = gender;
    data['zone_id'] = zoneId;
    data['date_of_birth'] = birthdate;
    data['password'] = password;
    data['token'] = authToken;
    data['id'] = userId;
    data['my_posts'] = myPosts;
    data['description'] = description;
    data['type'] = type;
    data['language'] = language;
    //data['sectors'] = sectors;


    return data;
  }




}
