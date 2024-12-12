import 'package:get/get.dart' show GetPage, Transition;
import 'package:mapnrank/app/modules/auth/views/institutional_user_view.dart';
import 'package:mapnrank/app/modules/auth/views/login_view.dart';
import 'package:mapnrank/app/modules/auth/views/register_view.dart';
import 'package:mapnrank/app/modules/auth/views/welcome_institutonal_user_view.dart';
import 'package:mapnrank/app/modules/community/views/create_post.dart';
import 'package:mapnrank/app/modules/events/views/create_event.dart';
import 'package:mapnrank/app/modules/events/views/event_details_view.dart';
import 'package:mapnrank/app/modules/notifications/views/institutional_create_message.dart';
import 'package:mapnrank/app/modules/other_user_profile/binding/other_user_profile_binding.dart';
import 'package:mapnrank/app/modules/other_user_profile/views/other_user_profile_view.dart';
import 'package:mapnrank/app/modules/profile/views/events_view.dart';
import 'package:mapnrank/app/modules/root/bindings/root_binding.dart';
import 'package:mapnrank/app/modules/root/views/root_view.dart';
import 'package:mapnrank/app/modules/settings/views/language_view.dart';
import 'package:mapnrank/app/modules/settings/views/settings_view.dart';
import 'package:mapnrank/app/modules/settings/views/theme_mode_view.dart';


import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/community/views/comment_view.dart';
import '../modules/community/views/details_view.dart';
import '../modules/notifications/bindings/notification_binding.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/account_view.dart';
import '../modules/profile/views/articles_view.dart';
import '../modules/profile/views/contact_us_view.dart';
import '../modules/profile/views/followers_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import 'app_routes.dart';

class Theme1AppPages {

  static final routes = [
    //GetPage(name: Routes.ROOT, page: () => RootView(), binding: RootBinding()),
    GetPage(name: Routes.SETTINGS, page: () => SettingsView(), binding: SettingsBinding()),
    GetPage(name: Routes.SETTINGS_THEME_MODE, page: () => ThemeModeView(), binding: SettingsBinding()),
    GetPage(name: Routes.LOGIN, page: () => LoginView(), binding: AuthBinding(), transition: Transition.zoom),
    GetPage(name: Routes.FORGOT_PASSWORD, page: () => ForgotPasswordView(), binding: AuthBinding(), transition: Transition.zoom),
    GetPage(name: Routes.REGISTER, page: () => RegisterView(), binding: AuthBinding(), transition: Transition.zoom),
    GetPage(name: Routes.INSTITUTIONAL_USER, page: () => InstitutionalUserView(), binding: AuthBinding(), transition: Transition.zoom),
    GetPage(name: Routes.INSTITUTION_CREATE_MESSAGE, page: () => InstitutionCreateMessage(), binding: NotificationBinding(), transition: Transition.zoom),
    GetPage(name: Routes.WELCOME_INSTITUTIONAL_USER, page: () => WelcomeInstitutionalUserView(), binding: AuthBinding(), transition: Transition.zoom),
    GetPage(name: Routes.ROOT, page: () => const RootView(), binding: RootBinding(), transition: Transition.zoom ),
    GetPage(name: Routes.CREATE_POST, page: () => const CreatePostView(), transition: Transition.downToUp ),
    GetPage(name: Routes.COMMENT_VIEW,  page: () => CommentView(), transition: Transition.rightToLeft ),
    GetPage(name: Routes.DETAILS_VIEW, page: () => DetailsView(), transition: Transition.rightToLeft ),
    GetPage(name: Routes.EVENT_DETAILS_VIEW, page: () => EventDetailsView(), transition: Transition.rightToLeft ),
    GetPage(name: Routes.CREATE_EVENT, page: () => const CreateEventView(), transition: Transition.downToUp ),
    GetPage(name: Routes.PROFILE, page: () =>const ProfileView(),binding: ProfileBinding(), transition: Transition.rightToLeft ),
    GetPage(name: Routes.ACCOUNT, page: () =>const AccountView(),binding: ProfileBinding(), transition: Transition.rightToLeft ),
    GetPage(name: Routes.CONTACT_US, page: () =>const ContactUsView(),binding: ProfileBinding(), transition: Transition.rightToLeft ),
    GetPage(name: Routes.FOLLOWERS, page: () =>const FollowersView(), transition: Transition.rightToLeft ),
    GetPage(name: Routes.ARTICLES, page: () =>const ArticlesView(),transition: Transition.rightToLeft ),
    GetPage(name: Routes.MY_EVENTS, page: () =>const MyEventsView(),transition: Transition.rightToLeft ),
    GetPage(name: Routes.OTHER_USER_PROFILE, page: () =>const OtherUserProfileView(),binding: OtherUserProfileBinding(), transition: Transition.rightToLeft ),
    GetPage(name: Routes.SETTINGS_LANGUAGE, page: () =>LanguageView(), binding: SettingsBinding(),transition: Transition.rightToLeft ),

  ];
}


