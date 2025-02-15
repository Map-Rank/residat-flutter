import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mapnrank/app/modules/auth/bindings/auth_binding.dart';
import 'package:mapnrank/app/modules/auth/views/login_view.dart';
import 'package:mapnrank/app/modules/root/bindings/root_binding.dart';
import 'package:mapnrank/app/modules/root/views/root_view.dart';
import 'package:mapnrank/app/providers/laravel_provider.dart';
import 'package:mapnrank/app/repositories/user_repository.dart';
import 'package:mapnrank/app/routes/theme_app_pages.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mapnrank/app/services/global_services.dart';
import 'package:mapnrank/app/services/settings_services.dart';
import 'app/routes/app_routes.dart';
import 'app/services/firebase_messaging_service.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  DefaultFirebaseOptions.currentPlatform;

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}
AndroidNotificationChannel channel = AndroidNotificationChannel('', 'name');

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  initServices() async {
  Get.log('starting services ...');
  await GetStorage.init();
  await Firebase.initializeApp();
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => LaravelApiClient(dio:Dio()).init());
  //await Get.putAsync(() => FirebaseProvider().init());
  await Get.putAsync(() => SettingsService().init());
  //Get.lazyPut(()=>RootBinding());
  //await Get.putAsync(() => TranslationService().init());
  Get.log('All services started...');
  var box = GetStorage();
  if(box.read("authToken") != null)
    {
      try{
        var validity = await UserRepository().checkTokenValidity(box.read("authToken"));
        print('Validity: ${validity.toString()}');
        if(validity != null){
          GlobalService.isAuthTokenValid = validity;
        }
      }
      catch(e){

      }

    }
  await GlobalService().getAppVersion();




}

void main() async{



   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   await initServices();

   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

   if (!kIsWeb) {
     channel = const AndroidNotificationChannel(
         "high_importance_channel", 'High Importance Notifications');
     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

     await flutterLocalNotificationsPlugin
         .resolvePlatformSpecificImplementation<
         AndroidFlutterLocalNotificationsPlugin>()
         ?.createNotificationChannel(channel);

     await FirebaseMessaging.instance
         .setForegroundNotificationPresentationOptions(
         alert: true, badge: true, sound: true);
   }


   runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
  var languageBox = GetStorage();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   fontFamily: 'Poppins'
      // ),
      //initialRoute: Theme1AppPages.INITIAL,
      onReady: () async {
        await Get.putAsync(() => FireBaseMessagingService().init());
      },
      onUnknownRoute: (settings) {
        // Optionally, navigate to a specific error page or handle it gracefully
        return GetPageRoute(
          settings: RouteSettings(name: '/notfound'),
          page: () => Scaffold(
            appBar: AppBar(title: Text('Page Not Found')),
            body: Center(child: Text('404 - Page Not Found')),
          ),
        );
      },
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => Scaffold(
          appBar: AppBar(title: Text('Page Not Found')),
          body: Center(child: Text('404 - Page Not Found')),
        ),
      ),
      initialBinding: GlobalService.isAuthTokenValid?RootBinding():AuthBinding(),
      getPages: Theme1AppPages.routes,
      defaultTransition: Transition.cupertino,
      themeMode: Get.find<SettingsService>().getThemeMode(),
      theme: Get.find<SettingsService>().getLightTheme(),
      darkTheme: Get.find<SettingsService>().getDarkTheme(),
      home:  GlobalService.isAuthTokenValid?RootView():LoginView(),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale.fromSubtags(languageCode: languageBox.read('language')==null? Platform.localeName:languageBox.read('language')),

      supportedLocales: [
        Locale('en'), // English
        Locale('fr'), // French
      ],
    );
  }
}


